/*
 * Copyright 2010-2023, Tarantool AUTHORS, please see AUTHORS file.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/**
 * To build this example see CMakeLists.txt or Makefile in current directory.
 * Prerequisites to run this test:
 * 1. Run Tarantool instance on localhost and set listening port 3301;
 * 2. Create space with id = 512 without format (primary key must index the first field)
 * 3. Grant read-write privileges for guest (or simply box.schema.user.grant('guest', 'super'))
 * 4. Compile and run ./Schemaless
 */

#include "../src/Client/Connector.hpp"
#include "../src/Buffer/Buffer.hpp"

#include "Reader.hpp"

const char *address = "127.0.0.1";
int port = 3301;
int WAIT_TIMEOUT = 1000; //milliseconds

using Buf_t = tnt::Buffer<16 * 1024>;
#include "../src/Client/LibevNetProvider.hpp"
using Net_t = LibevNetProvider<Buf_t, DefaultStream>;

/**
 * Field of schemaless tuple.
 */
using SchemalessField = std::variant<std::nullptr_t, int, std::string>;

/**
 * Schemaless tuple itself - dynamic array of fields.
 */
using SchemalessTuple = std::vector<SchemalessField>;

template <class BUFFER>
std::vector<SchemalessTuple>
decodeSchemalessTuple(Data<BUFFER> &data)
{
	std::vector<SchemalessTuple> results;
	bool ok = data.decode(results);
	(void)ok;
	assert(ok);
	return results;
}

template<class BUFFER>
void
printResponse(Response<BUFFER> &response)
{
	std::cout << ">>> RESPONSE {" << std::endl;
	if (response.body.error_stack != std::nullopt) {
		Error err = (*response.body.error_stack)[0];
		std::cout << "RESPONSE ERROR: msg=" << err.msg <<
			  " line=" << err.file << " file=" << err.file <<
			  " errno=" << err.saved_errno <<
			  " type=" << err.type_name <<
			  " code=" << err.errcode << std::endl;
	}
	if (response.body.data != std::nullopt) {
		Data<BUFFER>& data = *response.body.data;
		std::vector<SchemalessTuple> tuples = decodeSchemalessTuple(data);
		if (tuples.empty()) {
			std::cout << "Empty result" << std::endl;
			return;
		}
		for (auto const& t : tuples) {
			for (auto const &field : t)
				std::visit([](auto &v){std::cout << v << " ";}, field);
			std::cout << std::endl;
		}
	}
	std::cout << "}" << std::endl;
}

int
main()
{
	/*
	 * Create default connector.
	 */
	Connector<Buf_t, Net_t> client;
	/*
	 * Create single connection. Constructor takes only client reference.
	 */
	Connection<Buf_t, Net_t> conn(client);
	/*
	 * Try to connect to given address:port. Current implementation is
	 * exception free, so we rely only on return codes.
	 */
	int rc = client.connect(conn, {.address = address,
				       .service = std::to_string(port),
				       /*.user = ...,*/
				       /*.passwd = ...,*/
				       /* .transport = STREAM_SSL, */});
	if (rc != 0) {
		//assert(conn.getError().saved_errno != 0);
		std::cerr << conn.getError().msg << std::endl;
		return -1;
	}
	/*
	 * Now let's execute several requests.
	 * Note that any of :request() methods can't fail; they always
	 * return request id - the future (number) which is used to get
	 * response once it is received. Also note that at this step,
	 * requests are encoded (into msgpack format) and saved into
	 * output connection's buffer - they are ready to be sent.
	 * But network communication itself will be done later.
	 */
	/*
	 * Let's create a collection of tuples of different formats.
	 */
	std::vector<SchemalessTuple> tuples = {
		{1, "first"},
		{2, 5, nullptr, "second"},
		{3, nullptr, 1, 2, 3, 4, 5, 6},
		{4, "a", "bc", "def"},
		{5}
	};
	/* Insert the collection into our space. */
	uint32_t space_id = 512;
	std::vector<rid_t> futures;
	for (const auto &t : tuples) {
		rid_t f = conn.space[space_id].replace(t);
		futures.push_back(f);
	}
	/* Wait for all futures and then print each response. */
	client.waitAll(conn, futures);
	Response<Buf_t> response;
	for (const auto &f : futures) {
		assert(conn.futureIsReady(f));
		response = conn.getResponse(f);
		printResponse<Buf_t>(response);
	}

	/* Let's select our tuples of different formats. */
	rid_t select = conn.space[space_id].select(std::make_tuple(0), 0, 100,
						   0, IteratorType::GE);
	/* Wait for the future and then print the response. */
	client.wait(conn, select);
	assert(conn.futureIsReady(select));
	response = conn.getResponse(select);
	printResponse<Buf_t>(response);

	/* Finally, user is responsible for closing connections. */
	client.close(conn);
	return 0;
}

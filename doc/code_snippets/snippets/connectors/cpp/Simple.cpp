/*
 * Copyright 2010-2020, Tarantool AUTHORS, please see AUTHORS file.
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
 * 2. Create space with id = 512 and fields format {integer, string, float}
 * 3. Grant read-write privileges for guest (or simply box.schema.user.grant('guest', 'super'))
 * 4. Compile and run ./Simple
 */

//doclabel01-1
#include "../src/Client/Connector.hpp"
//doclabel01-2
#include "../src/Buffer/Buffer.hpp"
//doclabel01-3

#include "Reader.hpp"
//doclabel01-4

//doclabel05-1
const char *address = "127.0.0.1";
int port = 3301;
int WAIT_TIMEOUT = 1000; //milliseconds
//doclabel05-2

//doclabel02-1
using Buf_t = tnt::Buffer<16 * 1024>;
#include "../src/Client/LibevNetProvider.hpp"
using Net_t = LibevNetProvider<Buf_t, DefaultStream>;
//doclabel02-2

//doclabel14-1
template <class BUFFER>
std::vector<UserTuple>
decodeUserTuple(Data<BUFFER> &data)
{
	std::vector<UserTuple> results;
	bool ok = data.decode(results);
	(void)ok;
	assert(ok);
	return results;
}
//doclabel14-2

template<class BUFFER>
void
printResponse(Response<BUFFER> &response)
{
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
		std::vector<UserTuple> tuples = decodeUserTuple(data);
		if (tuples.empty()) {
			std::cout << "Empty result" << std::endl;
			return;
		}
		for (auto const& t : tuples) {
			std::cout << t << std::endl;
		}
	}
}

int
main()
{
	/*
	 * Create default connector - it'll handle many connections
	 * asynchronously.
	 */
	//doclabel03-1
	Connector<Buf_t, Net_t> client;
	//doclabel03-2
	/*
	 * Create single connection. Constructor takes only client reference.
	 */
	//doclabel04-1
	Connection<Buf_t, Net_t> conn(client);
	//doclabel04-2
	/*
	 * Try to connect to given address:port. Current implementation is
	 * exception free, so we rely only on return codes.
	 */
	//doclabel06-1
	int rc = client.connect(conn, {.address = address,
				       .service = std::to_string(port),
				       /*.user = ...,*/
				       /*.passwd = ...,*/
				       /* .transport = STREAM_SSL, */});
	//doclabel06-2
	if (rc != 0) {
		//assert(conn.getError().saved_errno != 0);
		std::cerr << conn.getError().msg << std::endl;
		return -1;
	}
	//doclabel06-3
	/*
	 * Now let's execute several requests: ping, replace and select.
	 * Note that any of :request() methods can't fail; they always
	 * return request id - the future (number) which is used to get
	 * response once it is received. Also note that at this step,
	 * requests are encoded (into msgpack format) and saved into
	 * output connection's buffer - they are ready to be sent.
	 * But network communication itself will be done later.
	 */
	/* PING */
	//doclabel07-1
	rid_t ping = conn.ping();
	//doclabel07-2
	/* REPLACE - equals to space:replace(pk_value, "111", 1)*/
	//doclabel08-1
	uint32_t space_id = 512;
	int pk_value = 666;
	std::tuple data = std::make_tuple(pk_value /* field 1*/, "111" /* field 2*/, 1.01 /* field 3*/);
	rid_t replace = conn.space[space_id].replace(data);
	//doclabel08-2
	/* SELECT - equals to space.index[0]:select({pk_value}, {limit = 1})*/
	//doclabel09-1
	uint32_t index_id = 0;
	uint32_t limit = 1;
	uint32_t offset = 0;
	IteratorType iter = IteratorType::EQ;
	auto i = conn.space[space_id].index[index_id];
	rid_t select = i.select(std::make_tuple(pk_value), limit, offset, iter);
	//doclabel09-2
	/*
	 * Now let's send our requests to the server. There are two options
	 * for single connection: we can either wait for one specific
	 * future or for all at once. Let's try both variants.
	 */
	//doclabel10-1
	while (! conn.futureIsReady(ping)) {
		/*
		 * wait() is the main function responsible for sending/receiving
		 * requests and implements event-loop under the hood. It may
		 * fail due to several reasons:
		 *  - connection is timed out;
		 *  - connection is broken (e.g. closed);
		 *  - epoll is failed.
		 */
		if (client.wait(conn, ping, WAIT_TIMEOUT) != 0) {
			std::cerr << conn.getError().msg << std::endl;
			conn.reset();
		}
	}
	//doclabel10-2
	/* Now let's get response using our future.*/
	//doclabel11-1
	std::optional<Response<Buf_t>> response = conn.getResponse(ping);
	/*
	 * Since conn.futureIsReady(ping) returned <true>, then response
	 * must be ready.
	 */
	assert(response != std::nullopt);
	/*
	 * If request is successfully executed on server side, response
	 * will contain data (i.e. tuple being replaced in case of :replace()
	 * request or tuples satisfying search conditions in case of :select();
	 * responses for pings contain nothing - empty map).
	 * To tell responses containing data from error responses, one can
	 * rely on response code storing in the header or check
	 * Response->body.data and Response->body.error_stack members.
	 */
	printResponse<Buf_t>(*response);
	//doclabel11-2
	/* Let's wait for both futures at once. */
	std::vector<rid_t> futures(2);
	futures[0] = replace;
	futures[1] = select;
	/* No specified timeout means that we poll futures until they are ready.*/
	client.waitAll(conn, futures);
	for (size_t i = 0; i < futures.size(); ++i) {
		assert(conn.futureIsReady(futures[i]));
		response = conn.getResponse(futures[i]);
		assert(response != std::nullopt);
		printResponse<Buf_t>(*response);
	}
	//doclabel11-3
	/* Let's create another connection. */
	Connection<Buf_t, Net_t> another(client);
	if (client.connect(another, {.address = address,
				     .service = std::to_string(port),
				     /* .transport = STREAM_SSL, */}) != 0) {
		std::cerr << conn.getError().msg << std::endl;
		return -1;
	}
	/* Simultaneously execute two requests from different connections. */
	rid_t f1 = conn.ping();
	rid_t f2 = another.ping();
	/*
	 * waitAny() returns the first connection received response.
	 * All connections registered via :connect() call are participating.
	 */
	std::optional<Connection<Buf_t, Net_t>> conn_opt = client.waitAny(WAIT_TIMEOUT);
	Connection<Buf_t, Net_t> first = *conn_opt;
	if (first == conn) {
		assert(conn.futureIsReady(f1));
		(void) f1;
	} else {
		assert(another.futureIsReady(f2));
		(void) f2;
	}
	//doclabel11-4
	/* Finally, user is responsible for closing connections. */
	//doclabel12-1
	client.close(conn);
	client.close(another);
	//doclabel12-2
	return 0;
}

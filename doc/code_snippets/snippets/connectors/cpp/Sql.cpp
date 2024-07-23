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
 * 2. Grant privileges for guest (box.schema.user.grant('guest', 'super'))
 * 3. Compile and run ./Sql
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
	if (response.body.stmt_id != std::nullopt)
		std::cout << "stmt_id: " << *response.body.stmt_id << std::endl;
	if (response.body.bind_count != std::nullopt)
		std::cout << "bind_count: " << *response.body.bind_count << std::endl;
	if (response.body.sql_info != std::nullopt) {
		std::cout << "row_count: " << response.body.sql_info->row_count << std::endl;
		if (!response.body.sql_info->autoincrement_ids.empty()) {
			std::cout << "autoincrements ids: ";
			for (const auto &id : response.body.sql_info->autoincrement_ids)
				std::cout << id << " ";
			std::cout << std::endl;
		}
	}
	if (response.body.metadata != std::nullopt) {
		for (const auto &cm : response.body.metadata->column_maps) {
			std::cout << "SQL column " << cm.field_name <<
				" of type " << cm.field_type;
			if (cm.is_nullable)
				std::cout << " nullable";
			if (cm.is_autoincrement)
				std::cout << " autoincrement";
			if (!cm.collation.empty())
				std::cout << " with collation " << cm.collation;
			if (cm.span != std::nullopt)
				std::cout << " with span " << *cm.span;
			std::cout << std::endl;		}
	}
	if (response.body.data != std::nullopt) {
		Data<BUFFER>& data = *response.body.data;
		std::vector<UserTuple> tuples = decodeUserTuple(data);
		if (tuples.empty()) {
			std::cout << "Empty result" << std::endl;
		} else {
			for (auto const& t : tuples)
				std::cout << t << std::endl;
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
		std::cerr << conn.getError().msg << std::endl;
		return -1;
	}
	/*
	 * Now let's execute several sql requests.
	 * Note that any of :request() methods can't fail; they always
	 * return request id - the future (number) which is used to get
	 * response once it is received. Also note that at this step,
	 * requests are encoded (into msgpack format) and saved into
	 * output connection's buffer - they are ready to be sent.
	 * But network communication itself will be done later.
	 */
	/*
	 * Let's create a space. An empty tuple at the end means that we pass
	 * no arguments to the SQL statement.
	 */
	rid_t create_space = conn.execute(
		"CREATE TABLE IF NOT EXISTS tntcxx_sql_example "
		"(id UNSIGNED PRIMARY KEY AUTOINCREMENT, "
		"str_id STRING, value DOUBLE);",
		std::make_tuple());
	/*
	 * Fill the newly created table.
	 * Let's try to use different approaches in one statement to learn more.
	 * Firstly, generate tuple with arguments for the insert statement. Then,
	 * execute the insert statement and pass generated arguments.
	 */
	std::tuple tntcxx_sql_data = std::make_tuple(
		/*
		 * Pass NULL as the first field - it will be generated
		 * in tarantool since it has autoincrement attribute.
		 */
		nullptr, "One", 12.8,
	        nullptr, "Two", -8.0,
		/* NULL for the 1st field is written right in statement. */
		"Three", 345.298,
		/* Pass the first field expilictly. */
		10, "Ten", -308.098
	);
	rid_t fill_space = conn.execute(
		"INSERT INTO tntcxx_sql_example VALUES "
		"(?, ?, ?), (?, ?, ?), (NULL, ?, ?), (?, ?, ?);",
		tntcxx_sql_data
	);
	/*
	 * Let's read from tarantool.
	 * Add a parameter to select statement to reuse it later.
	 */
	std::string select_stmt = "SELECT * FROM tntcxx_sql_example WHERE id = ?";
	rid_t select_from_space = conn.execute(select_stmt, std::make_tuple(1));
	/*
	 * Let's enable sql metadata and then read from tarantool again.
	 * Note that each session has its own _session_settings space, so
	 * this statement enables metadata only for the connection in
	 * which it was executed.
	 */
	rid_t enable_metadata = conn.execute(
		"UPDATE \"_session_settings\" SET \"value\" = true "
		"WHERE \"name\" = 'sql_full_metadata';", std::make_tuple());
	rid_t select_with_meta = conn.execute(select_stmt, std::make_tuple(2));
	
	/* Let's wait for all futures at once. */
	std::vector<rid_t> futures = {
		create_space, fill_space, select_from_space,
		enable_metadata, select_with_meta
	};

	/* No specified timeout means that we poll futures until they are ready. */
	client.waitAll(conn, futures);
	for (size_t i = 0; i < futures.size(); ++i) {
		assert(conn.futureIsReady(futures[i]));
		Response<Buf_t> response = conn.getResponse(futures[i]);
		printResponse<Buf_t>(response);
	}

	/* Let's prepare select_stmt to use it later. */
	rid_t prepare_stmt = conn.prepare(select_stmt);
	client.wait(conn, prepare_stmt);
	assert(conn.futureIsReady(prepare_stmt));
	Response<Buf_t> response = conn.getResponse(prepare_stmt);
	printResponse<Buf_t>(response);
	assert(response.body.stmt_id.has_value());
	uint32_t stmt_id = *response.body.stmt_id;

	/* Let's read some data using prepared statement. */
	std::vector<rid_t> prepared_select_futures;
	prepared_select_futures.push_back(conn.execute(stmt_id, std::make_tuple(3)));
	prepared_select_futures.push_back(conn.execute(stmt_id, std::make_tuple(10)));
	/* Again, wait for all futures at once. */
	client.waitAll(conn, prepared_select_futures);
	for (size_t i = 0; i < prepared_select_futures.size(); ++i) {
		assert(conn.futureIsReady(prepared_select_futures[i]));
		Response<Buf_t> response =
			conn.getResponse(prepared_select_futures[i]);
		printResponse<Buf_t>(response);
	}

	/*
	 * Let's calculate a very important statistic.
	 * Add integer and string at the beginning to suit UserTuple format.
	 */
	rid_t calculate_stmt = conn.execute(
		"SELECT 0 as id, 'zero' as zero_id, sum(value) as important_statistic "
		"FROM SEQSCAN tntcxx_sql_example;",
		std::make_tuple()
	);
	client.wait(conn, calculate_stmt);
	assert(conn.futureIsReady(calculate_stmt));
	response = conn.getResponse(calculate_stmt);
	printResponse<Buf_t>(response);

	/* Finally, user is responsible for closing connections. */
	client.close(conn);
	return 0;
}

..  _internals-iproto-streams:
..  _box_protocol-streams:

Streams
=======

The :ref:`Streams and interactive transactions <txn_mode_stream-interactive-transactions>`
feature, which was added in Tarantool version
:tarantool-release:`2.10.0`, allows two things:
sequential processing and interleaving.

Sequential processing:
With streams there is a guarantee that the server instance will not
handle the next request in a stream until it has completed the previous one.

Interleaving:
For example, a series of requests can include
"begin for stream #1", "begin for stream #2",
"insert for stream #1", "insert for stream #2", "delete
for stream #1", "commit for stream #1", "rollback for stream #2".

To make these things possible,
the engine should be :ref:`vinyl <engines-vinyl>` or :ref:`memtx with mvcc <cfg_basic-memtx_use_mvcc_engine>`, and
the client is responsible for ensuring that the stream identifier,
unsigned integer :ref:`IPROTO_STREAM_ID <box_protocol-iproto_stream_id>`, is in the request header.
IPROTO_STREAM_ID can be any positive 64-bit number, and should be unique for the connection.
If IPROTO_STREAM_ID equals zero the server instance will ignore it.

For example, suppose that the client has started a stream with
the :ref:`net.box module <net_box-module>`

..  code-block:: lua

    net_box = require('net.box')
    conn = net_box.connect('localhost:3302')
    stream = conn:new_stream()

At this point the stream object will look like a duplicate of
the conn object, with just one additional member: ``stream_id``.
Now, using stream instead of conn, the client sends two requests:

..  code-block:: lua

    stream.space.T:insert{1}
    stream.space.T:insert{2}

The header and body of these requests will be the same as in
non-stream :ref:`IPROTO_INSERT <box_protocol-insert>` requests, except
that the header will contain an additional item: IPROTO_STREAM_ID=0x0a
with MP_UINT=0x01. It happens to equal 1 for this example because
each call to conn:new_stream() assigns a new number, starting with 1.

..  _box_protocol-stream_transactions:

The client makes stream transactions by sending, in order:

1. IPROTO_BEGIN with an optional transaction timeout in the IPROTO_TIMEOUT field of the request body.
2. The transaction data-change and query requests.
3. IPROTO_COMMIT or IPROTO_ROLLBACK.

All these requests must contain the same IPROTO_STREAM_ID value.

A rollback will happen automatically if
a disconnect occurs or the transaction timeout expires before the commit is possible.

Thus there are now multiple ways to do transactions:
with ``net_box`` ``stream:begin()`` and ``stream:commit()`` or ``stream:rollback()``
which cause IPROTO_BEGIN and IPROTO_COMMIT or IPROTO_ROLLBACK with
the current value of stream.stream_id;
with :ref:`box.begin() <box-begin>` and :ref:`box.commit() <box-commit>` or :ref:`box.rollback() <box-rollback>`;
with SQL and :ref:`START TRANSACTION <sql_start_transaction>` and :ref:`COMMIT <sql_commit>` or :ref:`ROLLBACK <sql_rollback>`.
An application can use any or all of these ways.

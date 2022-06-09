..  _box_stream:

Streams and interactive transactions
====================================

..  _box_stream-overview:

Overview
--------

Since :tarantool-release:`2.10.0`, iproto implements streams and interactive transactions.

..  glossary::

    Stream
        A stream supports multiplexing several transactions over one connection.
        All requests in the stream are executed strictly sequentially,
        which allows the implementation of
        :term:`interactive transactions <interactive transaction>`.

Unlike a thread associated with multitasking and execution within a program,
a stream transfers data via the protocol between a client and a server.

..  glossary::

    Interactive transaction
        An interactive transaction is a transaction that does not need to be sent in a single request.
        The ``begin``, ``commit``, and other TX statements can be sent and executed in different requests.

..  _box_stream-features:

Features
--------

The primary purpose of :term:`streams <stream>` is to execute transactions via iproto.
Every stream has its own identifier, which is unique within the connection.
All requests with the same non-zero stream ID belong to the same stream.
All requests in the stream are processed synchronously.
The next request will not start executing until the previous one is completed.
If a request's stream ID is ``0``, it does not belong to any stream and is processed in the old way.

In :doc:`net.box </reference/reference_lua/net_box>`, a stream is an object above the connection that has the same methods
but allows executing requests sequentially.
The ID is generated on the client side automatically.
If a user writes their own connector and wants to use streams,
they must transmit the ``stream_id`` over the iproto protocol.

Interactive transactions over streams only work if
the ``box.cfg{}`` option :ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>`
is enabled on the server: ``memtx_use_mvcc_engine = true``.

..  _box_stream-interaction:

Interaction between streams and transactions
--------------------------------------------

As each stream can start a transaction, several transactions can be multiplexed over one connection.
There are multiple ways to begin, commit, and roll back a transaction.
One can do that using the appropriate stream methods -- ``call``, ``eval``,
or ``execute`` -- with the SQL transaction syntax. Users can mix these methods.
For example, one might start a transaction using ``stream:begin()``
and commit it with ``stream:call('box.commit')`` or ``stream:execute('COMMIT')``.
All the requests between ``stream:begin()`` and ``stream:commit()`` are executed within the same transaction.
If any request fails during the transaction, it will not affect the other requests in the transaction.
If a disconnect occurs while there is an active transaction in the stream,
that transaction will be rolled back if it hasn't been committed before the connection failure.

Example:

..  code-block:: lua

    local conn = net_box.connect(remote_server_addr)
    local conn_space = conn.space.test
    local stream = conn:new_stream()
    local stream_space = stream.space.test

    -- Begin transaction over an iproto stream:
    stream:begin()
    stream_space:replace({1})

    -- Empty select, the transaction was not committed.
    -- You can't see it from the requests that do not belong to the
    -- transaction.
    conn_space:select{}

    -- Select returns the previously inserted tuple,
    -- because this select belongs to the transaction:
    stream_space:select({})

    -- Commit transaction:
    stream:commit()

    -- Now this select also returns the tuple, because the transaction has been committed:
    conn_space:select{}
..  _box_stream:

Streams
=======

Since version :tarantool-release:`2.10.0-beta1`, streams and interactive :ref:`transactions <atomic-atomic_execution>`
in them are implemented in iproto.
Unlike a thread associated with multitasking and execution within a program,
a stream occurs between a client and a server.
It deals with connecting and transferring a protocol over the network.

The primary purpose of streams is to execute transactions via iproto.
Every stream has its own identifier, which is unique within the connection.
All requests with the same non-zero stream ID belong to the same stream.
All requests in the stream are processed synchronously.
The next request will not start executing until the previous one is completed.
If a request's stream ID is ``0``, it does not belong to any stream and is processed in the old way.

In ``net.box``, a stream is an object above the connection that has the same methods
but allows executing requests sequentially.
The ID is generated on the client side automatically.
If a user writes their own connector and wants to use streams,
they must transmit the ``stream_id`` over the iproto protocol.

As each stream can start a transaction, several transactions can be multiplexed over one connection.
There are multiple ways to begin, commit, and roll back a transaction.
One can do that using the appropriate stream methods, ``call``, ``eval``,
or ``execute`` with the SQL transaction syntax. Users can mix these methods.
For example, one might start a transaction using ``stream:begin()``,
and commit it with ``stream:call('box.commit')`` or ``stream:execute('COMMIT')``.
All the requests between ``stream:begin()`` and ``stream:commit()`` are executed within the same transaction.
If any request fails during the transaction, it will not affect the other requests in the transaction.
If a disconnect occurs while there is an active transaction in the stream,
that transaction will be rolled back if it hasn't been committed before the connection failure.




..  _box-protocol-shutdown:

Graceful shutdown protocol
==========================

Overview
--------

Since :doc:`2.10.0 </release/2.10.0>`.

The graceful shutdown protocol is a mechanism that helps to prevent data loss in requests in case of a shutdown command.
According to the protocol, when a server receives an ``os.exit()`` command or a ``SIGTERM``  signal,
it does not exit immediately.
Instead of that, first, the server stops listening for new connections.
Then, the server sends the shutdown packets to all connections that support the graceful shutdown protocol.
When a client is notified about the upcoming server exit, it stops serving any new requests and
waits for active requests to complete before closing the connections.
Once all connections are terminated, the server will be shut down.

The protocol uses the event subscription system.
That is, the feature is available if the server supports the :ref:`box.shutdown <system-events_box-shutdown>` event
and ``IPROTO_WATCH``.
For more information about it, see :ref:`reference for the event watchers <box-watchers>`
and the :ref:`corresponding page in the Binary Protocol section <box-protocol-watchers>`.

How the graceful shutdown works
-------------------------------

The shutdown protocol works in the following way:

#.  First, the server receives a shutdown request.
    It can be either an ``os.exit()`` command or a :ref:`SIGTERM <admin-server_signals>` signal.

#.  Then the :ref:`box.shutdown <system-events_box-shutdown>` event is generated.
    The server broadcasts it to all subscribed remote watchers (see :ref:`IPROTO_WATCH <box_protocol-watch>`).
    That is, the server calls :ref:`box.broadcast('box.shutdown', true) <box-broadcast>`
    from the :ref:`box.ctl.on_shutdown() <box_ctl-on_shutdown>` trigger callback.
    Once this is done, the server stops listening for new connections.

#.  From now on, the server waits until all subscribed connections are terminated.

#.  At the same time, the client gets the ``box.shutdown`` event and shuts the connection down gracefully.

#.  After all connections are closed, the server will be stopped.
    Otherwise, a timeout occurs, and the Tarantool exits immediately.
    You can set up the required timeout with the
    :ref:`set_on_shutdown_timeout() <box_ctl-on_shutdown_timeout>` function.
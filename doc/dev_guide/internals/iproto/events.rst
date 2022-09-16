..  _internals-events:

Events and subscriptions
========================

..  _box-protocol-watchers:

Watchers
--------

The commands below support asynchronous server-client notifications signalled
with :ref:`box.broadcast() <box-broadcast>`.
Servers that support the new feature set the ``IPROTO_FEATURE_WATCHERS`` feature in reply to the ``IPROTO_ID`` command.
When the connection is closed, all watchers registered for it are unregistered.

The remote :ref:`watcher <box-watchers>` protocol works in the following way:

#.  The client sends an ``IPROTO_WATCH`` packet to subscribe to the updates of a specified key defined on the server.

#.  The server sends an ``IPROTO_EVENT`` packet to the subscribed client after registration.
    The packet contains the key name and its current value.
    After that, the packet is sent every time the key value is updated with
    ``box.broadcast()``, provided that the last notification was acknowledged (see below).

#.  After receiving the notification, the client sends an ``IPROTO_WATCH`` packet to acknowledge the notification.

#.  If the client doesn't want to receive any more notifications, it unsubscribes by sending
    an ``IPROTO_UNWATCH`` packet.

All the three request types are asynchronous -- the receiving end doesn't send a packet in reply to any of them.
Therefore, neither of them has a sync number.

..  _box_protocol-watch:

IPROTO_WATCH = 0x4a
~~~~~~~~~~~~~~~~~~~

Registers a new watcher for the given notification key or confirms a notification if the watcher is
already subscribed.
The watcher is notified after registration.
After that, the notification is sent every time the key is updated.
The server doesn't reply to the request unless it fails to parse the packet.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_WATCH
    })
    # <body>
    msgpack({
        IPROTO_EVENT_KEY: :samp:`{{MP_STR string}}}`
    })

``IPROTO_EVENT_KEY`` (code 0x56) contains the key name.

..  _box_protocol-unwatch:

IPROTO_UNWATCH = 0x4b
~~~~~~~~~~~~~~~~~~~~~

Unregisters a watcher subscribed to the given notification key.
The server doesn't reply to the request unless it fails to parse the packet.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_UNWATCH
    })
    # <body>
    msgpack({
        IPROTO_EVENT_KEY: :samp:`{{MP_STR string}}}`
    })

``IPROTO_EVENT_KEY`` (code 0x56) contains a key name.

..  _box_protocol-event:

IPROTO_EVENT = 0x4c
~~~~~~~~~~~~~~~~~~~

Sent by the server to notify a client about an update of a key.

The body is a 2-item map:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_EVENT
    })
    # <body>
    msgpack({
        IPROTO_EVENT_KEY: :samp:`{{MP_STR string}}}`,
        IPROTO_EVENT_DATA: :samp:`{{MP_OBJECT value}}}`
    })

``IPROTO_EVENT_KEY`` (code 0x56) contains the key name.

``IPROTO_EVENT_DATA`` (code 0x57) contains data sent to a remote watcher.
The parameter is optional, the default value is ``nil``.

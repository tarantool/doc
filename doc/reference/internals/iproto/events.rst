..  _internals-events:
..  _box-protocol-watchers:

Events and subscriptions
========================

The commands below support asynchronous server-client notifications signalled
with :ref:`box.broadcast() <box-broadcast>`.
Servers that support the new feature set the ``IPROTO_FEATURE_WATCHERS`` feature in reply to the ``IPROTO_ID`` command.
When the connection is closed, all watchers registered for it are unregistered.

The remote watcher (event subscription) protocol works in the following way:

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

IPROTO_WATCH
------------

Code: 0x4a.

Register a new watcher for the given notification key or confirms a notification if the watcher is
already subscribed.
The watcher is notified after registration.
After that, the notification is sent every time the key is updated.
The server doesn't reply to the request unless it fails to parse the packet.

..  raw:: html
    :file: images/events_watch.svg

..  _box_protocol-unwatch:

IPROTO_UNWATCH
--------------

Code: 0x4b.

Unregister a watcher subscribed to the given notification key.
The server doesn't reply to the request unless it fails to parse the packet.

..  raw:: html
    :file: images/events_unwatch.svg

..  _box_protocol-event:

IPROTO_EVENT
------------

Code: 0x4c.

Sent by the server to notify a client about an update of a key.

..  raw:: html
    :file: images/event.svg
    
``IPROTO_EVENT_DATA`` contains data sent to a remote watcher.
The parameter is optional, the default value is ``MP_NIL``.

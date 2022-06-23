.. _box-broadcast:

================================================================================
box.broadcast()
================================================================================

..  function:: box.broadcast(key, value)

    Update the value of a given key and inform all the key watchers about the update.

    :param string key: a key name of an event to subscribe to
    :param value: any data that can be encoded in MsgPack

    :return:
    :rtype: ?

    **Example:**

    ..  code-block:: lua

        -- Broadcast value 123 for the key 'foo'.
        box.broadcast('foo', 123)



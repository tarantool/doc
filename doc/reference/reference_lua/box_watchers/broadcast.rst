.. _box-broadcast:

================================================================================
box.broadcast()
================================================================================

..  function:: box.broadcast(key, value)

    Update the value of a particular key and notify all key watchers of the update.

    :param string key: a key name of an event to subscribe to
    :param value: any data that can be encoded in MsgPack

    :return: none

    **Example:**

    ..  code-block:: lua

        -- Broadcast value 123 for the 'foo' key.
        box.broadcast('foo', 123)



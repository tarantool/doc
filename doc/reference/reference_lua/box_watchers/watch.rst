.. _box-watch:

================================================================================
box.watch()
================================================================================

..  function:: box.watch(key, func)

    Subscribe to events broadcast by a remote host.

    :param string key: a key name of an event to subscribe to
    :param function func: a callback to invoke when the key value is updated

    :return: a watcher handle that can be used to unregister the watcher
    :rtype: ?

    **Example:**

    ..  code-block:: lua

        -- Broadcast value 123 for key 'foo'.
        box.broadcast('foo', 123)
        -- Subscribe to updates of key 'foo'.
        w = box.watch('foo', function(key, value)
            assert(key == 'foo')
            -- do something with value
        end)
        -- Unregister the watcher when it's no longer needed.
        w:unregister()


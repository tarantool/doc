.. _box-watch:

================================================================================
box.watch()
================================================================================

..  function:: box.watch(key, func)

    Subscribe to events broadcast by a local host.
    It is possible to register more than one watcher for the same key.

    :param string key: a key name of an event to subscribe to
    :param function func: a callback to invoke when the key value is updated

    :return: a watcher handle that can be used to unregister the watcher

    A watcher callback is first invoked unconditionally after the watcher registration.
    Subsequent invocations are triggered by :doc:`box.broadcast() </reference/reference_lua/box_watchers/broadcast>`
    called on the remote host.
    A watcher callback is passed the key for which it was registered and the current key value.
    A watcher callback is always invoked in a new fiber so it is okay to yield in it.
    A watcher callback is never executed in parallel with itself.
    If the key is updated while the watcher callback is running, the callback will be invoked again with the new
    value as soon as it returns.

    Note that garbage collection of a watcher handle doesn't result in unregistering the watcher.
    It is okay to discard the result of ``box.watch`` if the watcher will never be unregistered.


    **Example:**

    ..  code-block:: lua

        -- Broadcast value 123 for the 'foo' key.
        box.broadcast('foo', 123)
        -- Subscribe to updates of the 'foo' key.
        w = box.watch('foo', function(key, value)
            assert(key == 'foo')
            -- do something with value
        end)
        -- Unregister the watcher when it is no longer needed.
        w:unregister()


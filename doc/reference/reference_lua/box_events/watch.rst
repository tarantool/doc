.. _box-watch:

================================================================================
box.watch()
================================================================================

..  function:: box.watch(key, func)

    Subscribe to events broadcast by a local host.

    :param string key: a key name of an event to subscribe to
    :param function func: a callback to invoke when the key value is updated

    :return: a watcher handle. The handle consists of one method -- ``unregister()``, which unregisters the watcher.

    To read more about watchers, see the `Functions for watchers <box-watchers>` section.

    ..  note::

        Keep in mind that garbage collection of a watcher handle doesn't lead to the watcher's destruction.
        In this case, the watcher remains registered.
        It is okay to discard the result of ``watch`` function if the watcher will never be unregistered.

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


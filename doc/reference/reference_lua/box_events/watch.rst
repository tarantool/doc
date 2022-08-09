.. _box-watch:

================================================================================
box.watch()
================================================================================

..  function:: box.watch(key, func)

    Subscribe to events broadcast by a local host.

    :param string key: key name of the event to subscribe to
    :param function func: callback to invoke when the key value is updated

    :return: a watcher handle. The handle consists of one method -- ``unregister()``, which unregisters the watcher.

    To read more about watchers, see the :ref:`Functions for watchers <box-watchers>` section.

    ..  note::

        Keep in mind that garbage collection of a watcher handle doesn't lead to the watcher's destruction.
        In this case, the watcher remains registered.
        It is okay to discard the result of ``watch`` function if the watcher will never be unregistered.

    **Example:**

    ..  code-block:: lua

        -- Broadcast value 42 for the 'foo' key.
        box.broadcast('foo', 42)

        local log = require('log')
        -- Subscribe to updates of the 'foo' key.
        local w = box.watch('foo', function(key, value)
            assert(key == 'foo')
            log.info("The box.id value is '%d'", value)
        end)

    If you don't need the watcher anymore, you can unregister it using the command below:

    ..  code-block:: lua

        w:unregister()


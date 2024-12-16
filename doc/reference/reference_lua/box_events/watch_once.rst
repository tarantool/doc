.. _box-watch_once:

box.watch_once()
================

..  function:: box.watch_once(key, func)

    Returns the current value of a given notification key.
    The function can be used as an alternative to :ref:`box.watch() <box-watch>`
    when the caller only needs the current value without subscribing to future changes.

    :param string key: key name

    :return: the key value

    To read more about watchers, see the :ref:`box-watchers` section.

    **Example:**

    ..  code-block:: lua

        -- Broadcast value 42 for the 'foo' key.
        box.broadcast('foo', 42)

        -- Get the value of this key
        tarantool> box.watch_once('foo')
        ---
        - 42
        ...

        -- Non-existent keys' values are empty
        tarantool> box.watch_once('none')
        ---
        ...





.. _box_session-storage:

================================================================================
box.session.storage
================================================================================

.. module:: box.session

.. data:: storage

    A Lua table that can hold arbitrary unordered session-specific
    names and values, which will last until the session ends.
    For example, this table could be useful to store current tasks when working
    with a `Tarantool queue manager <https://github.com/tarantool/queue>`_.

    **Example**

    .. code-block:: tarantoolsession

        tarantool> box.session.peer(box.session.id())
        ---
        - 127.0.0.1:45129
        ...
        tarantool> box.session.storage.random_memorandum = "Don't forget the eggs"
        ---
        ...
        tarantool> box.session.storage.radius_of_mars = 3396
        ---
        ...
        tarantool> m = ''
        ---
        ...
        tarantool> for k, v in pairs(box.session.storage) do
                 >   m = m .. k .. '='.. v .. ' '
                 > end
        ---
        ...
        tarantool> m
        ---
        - 'radius_of_mars=3396 random_memorandum=Don't forget the eggs. '
        ...
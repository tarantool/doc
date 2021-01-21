.. _box_error-error_object:

===============================================================================
error_object
===============================================================================

.. class:: error_object

    Errors can be organized into lists. To achieve this, a Lua table representing an
    error object has ``.prev`` field and ``e:set_prev(err)`` method.

    .. _box_error-prev:

    .. data:: prev

        Return a previous error, if any.

    .. _box_error-set_prev:

    .. method:: set_prev(error object)

        Set an error as the previous error. Accepts an ``error object`` or ``nil``.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> e1 = box.error.new({code = 111, reason = 'some cause'})
        ---
        ...
        tarantool> e2 = box.error.new({code = 111, reason = 'cause of cause'})
        ---
        ...
        tarantool> e1:set_prev(e2)
        ---
        ...
        tarantool> e1.prev
        ---
        - cause of cause
        ...

    Cycles are not allowed for error lists:

    .. code-block:: tarantoolsession

        tarantool> e2:set_prev(e1)
        ---
        - error: 'builtin/error.lua:147: Cycles are not allowed'
        ...

    Setting the previous error does not erase its own previous members:

    .. code-block:: Lua

        -- e1 -> e2 -> e3 -> e4
        e1:set_prev(e2)
        e2:set_prev(e3)
        e3:set_prev(e4)
        e2:set_prev(e5)
        -- Now there are two lists: e1->e2->e5 and e3->e4

    The iProto protocol also supports stacked diagnostics. See details in
    :ref:`MessagePack extensions -- The ERROR type <msgpack_ext-error>`.
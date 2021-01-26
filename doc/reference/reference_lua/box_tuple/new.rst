.. _box_tuple-new:

================================================================================
box.tuple.new()
================================================================================

.. module:: box.tuple

.. function:: new(value)

    Construct a new tuple from either a scalar or a Lua table. Alternatively,
    one can get new tuples from Tarantool's :ref:`select <box_space-select>`
    or :ref:`insert <box_space-insert>` or :ref:`replace <box_space-replace>`
    or :ref:`update <box_space-update>` requests,
    which can be regarded as statements that do
    ``new()`` implicitly.

    :param lua-value value: the value that will become the tuple contents.

    :return: a new tuple
    :rtype:  tuple

    In the following example, ``x`` will be a new table object containing one
    tuple and ``t`` will be a new tuple object. Saying ``t`` returns the
    entire tuple ``t``.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> x = box.space.tester:insert{
                 >   33,
                 >   tonumber('1'),
                 >   tonumber64('2')
                 > }:totable()
        ---
        ...
        tarantool> t = box.tuple.new{'abc', 'def', 'ghi', 'abc'}
        ---
        ...
        tarantool> t
        ---
        - ['abc', 'def', 'ghi', 'abc']
        ...

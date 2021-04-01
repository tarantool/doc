.. _box_error-set:

===============================================================================
box.error.set()
===============================================================================

.. function:: box.error.set(error object)

    Since version :doc:`2.4.1 </release/2.4.1>`.
    Set an error as the last system error explicitly. Accepts an error object and
    makes it available via :doc:`/reference/reference_lua/box_error/last`.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> err = box.error.new({code = 111, reason = 'cause'})
        ---
        ...
        tarantool> box.error.last()
        ---
        - error: '[string "return tarantool> box.error.last()"]:1: attempt to compare two
            nil values'
        ...
        tarantool> box.error.set(err)
        ---
        ...
        tarantool> box.error.last()
        ---
        - cause
        ...

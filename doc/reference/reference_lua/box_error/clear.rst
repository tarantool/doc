.. _box_error-clear:

===============================================================================
box.error.clear()
===============================================================================

.. function:: box.error.clear()

    Clear the record of errors, so functions like ``box.error()``
    or ``box.error.last()`` will have no effect.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.error.last()
        ---
        - Invalid identifier '' (expected printable symbols only or it is too long)
        ...
        tarantool> box.error.clear()
        ---
        ...
        tarantool> box.error.last()
        ---
        - null
        ...

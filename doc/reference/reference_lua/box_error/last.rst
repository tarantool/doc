.. _box_error-last:

===============================================================================
box.error.last()
===============================================================================

.. function:: box.error.last()

    Show the last error object.

    **Example:**

    You can reach the last error object's fields like this:

    .. code-block:: tarantoolsession

        tarantool> box.schema.space.create('')
        ---
        - error: Invalid identifier '' (expected printable symbols only or it is too long)
        ...
        tarantool> box.error.last()
        ---
        - Invalid identifier '' (expected printable symbols only or it is too long)
        ...
        tarantool> box.error.last().code
        ---
        - 70
        ...
        tarantool> box.error.last().type
        ---
        - ClientError
        ...

    :return: the last error object
    :rtype: cdata

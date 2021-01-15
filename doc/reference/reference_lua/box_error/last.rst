.. _box_error-last:

===============================================================================
box.error.last()
===============================================================================

.. function:: box.error.last()

    Return a description of the last error, as a Lua table with four members:

    * "code" (number) error’s number
    * "type" (string) error’s C++ class
    * "message" (string) error’s message
    * "trace" -- table with 2 members:
          * "line" (number) Tarantool source file line number
          * "file" (string) Tarantool source file

    Additionally, if the error is a system error (for example due to a
    failure in socket or file io), there may be a fifth member:
    "errno" (number) C standard error number.

    :rtype: table

    To show the table, use ``unpack()``:

    .. code-block:: tarantoolsession

        tarantool> box.schema.space.create('')
        ---
        - error: Invalid identifier '' (expected printable symbols only or it is too long)
        ...
        tarantool> box.error.last()
        ---
        - Invalid identifier '' (expected printable symbols only or it is too long)
        ...
        tarantool> box.error.last():unpack()
        ---
        - type: ClientError
          code: 70
          message: Invalid identifier '' (expected printable symbols only or it is too long)
          trace:
          - file: /tmp/tarantool-20200109-43082-1pv0594/tarantool-2.3.1.1/src/box/identifier.c
            line: 68
        ...
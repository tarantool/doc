.. _box_error-custom_type:

===============================================================================
                            Custom error types
===============================================================================

From above you know that errors can be created in two ways: with ``box.error.new()``
and with ``box.error()``.

Both methods can take arguments either as a list (``code, reason, <reason string args>``):

.. code-block:: lua

    box.error(9, 'my_space', 'reason') -- error: 'Failed to create space my_space: reason'

...or as a table (``{code = code, reason = reason, ...}``):

.. code-block:: lua

    box.error({code = 9, reason = 'Failed to create space my_space: reason'})

It is also possible to specify your own type of errors instead of pre-defined
ones. Put a string with your type in the ``type`` field if you pass arguments as
a table, or instead of the ``code`` parameter if you use listing:

.. code-block:: lua

    box.error('MyErrorType', 'Message')
    box.error({type = 'MyErrorType', code = 1024, reason = 'Message'})

Or a no-throw version:

.. code-block:: lua

    box.error.new('MyErrorType', 'Message')
    box.error.new({type = 'MyErrorType', code = 1024, reason = 'Message'})

When a custom type is specified, it is reported in the ``err.type`` attribute.
When it is not specified, ``err.type`` reports one of built-in errors such as
``'ClientError'``, ``'OutOfMemory'``, etc.

The maximum name length for a custom type is *63 bytes*. Everything longer than
this limit is truncated.

The original error type can be checked using the ``err.base_type`` member,
although normally it should not be used. For user-defined types, the base type
is ``'CustomError'``.

**Example:**

.. code-block:: tarantoolsession

    tarantool> e = box.error.new({type = 'MyErrorType', code = 1024, reason = 'Message'})
    ---
    ...

    tarantool> e:unpack()
    ---
    - code: 1024
    trace:
    - file: '[string "e = box.error.new({type = ''MyErrorType'', code..."]'
        line: 1
    type: MyErrorType
    custom_type: MyErrorType
    message: Message
    base_type: CustomError
    ...

Since version :doc:`2.4.2 </release/2.4.2>`,
you can also use a format string to compose an error message for
the ``'CustomError'`` type:

.. code-block:: lua

    box.error('MyCustomType', 'The error reason: %s', 'some error reason')
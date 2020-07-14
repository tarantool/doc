-------------------------------------------------------------------------------
                            Submodule `box.error`
-------------------------------------------------------------------------------

.. module:: box.error

===============================================================================
                                   Overview
===============================================================================

The ``box.error`` function is for raising an error. The difference between this
function and Lua's built-in `error <https://www.lua.org/pil/8.3.html>`_ function
is that when the error reaches the client, its error code is preserved.
In contrast, a Lua error would always be presented to the client as
:errcode:`ER_PROC_LUA`.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.error`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.error()                    | Throw an error                  |
    | <box_error-error>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.last()               | Get a description of the        |
    | <box_error-last>`                    | last error                      |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.clear()              | Clear the record of errors      |
    | <box_error-clear>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.new()                | Create an error but do not      |
    | <box_error-new>`                     | throw                           |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.set()                | Set an error as                 |
    | <box_error-set>`                     | ``box.error.last()``            |
    +--------------------------------------+---------------------------------+
    | :ref:`error_object.prev              | Return the previous error       |
    | <box_error-prev>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`error_object.set_prev()        | Set the previous error          |
    | <box_error-set_prev>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`Custom error types             | Create a custom error type      |
    | <box_error-custom_type>`             |                                 |
    +--------------------------------------+---------------------------------+

.. _box_error-error:

.. function:: box.error()

    When called without arguments, ``box.error()`` re-throws whatever the last
    error was.

.. function:: box.error{reason = string [, code = number]}

    Throw an error. When called with a Lua-table argument, the code and reason
    have any user-desired values. The result will be those values.

    :param string reason: description of an error, defined by user
    :param integer  code: numeric code for this error, defined by user

.. function:: box.error(code, errtext [, errtext ...])

    Throw an error. This method emulates a request error, with text based on one
    of the pre-defined Tarantool errors defined in the file `errcode.h
    <https://github.com/tarantool/tarantool/blob/2.1/src/box/errcode.h>`_ in
    the source tree. Lua constants which correspond to those Tarantool errors are
    defined as members of ``box.error``, for example ``box.error.NO_SUCH_USER == 45``.

    :param number       code: number of a pre-defined error
    :param string errtext(s): part of the message which will accompany the error

    For example:

    the ``NO_SUCH_USER`` message is "``User '%s' is not found``" -- it includes
    one "``%s``" component which will be replaced with errtext. Thus a call to
    ``box.error(box.error.NO_SUCH_USER, 'joe')`` or ``box.error(45, 'joe')``
    will result in an error with the accompanying message "``User 'joe' is not found``".

    :except: whatever is specified in errcode-number.

.. function:: box.error(code, errtext [, errtext ...])

    ``box.error()`` accepts two sets of arguments:

    * error code and reason/errtext (``box.error{code = 555, reason = 'Arbitrary
      message'}``), or
    * error object (``box.error(err)``).

    In both cases the error is promoted as the last error.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> e1 = box.error.new({code = 111, reason = 'Сause'})
        ---
        ...
        tarantool> box.error(e1)
        ---
        - error: Сause
        ...
        tarantool> box.error{code = 555, reason = 'Arbitrary message'}
        ---
        - error: Arbitrary message
        ...
        tarantool> box.error()
        ---
        - error: Arbitrary message
        ...
        tarantool> box.error(box.error.FUNCTION_ACCESS_DENIED, 'A', 'B', 'C')
        ---
        - error: A access denied for user 'B' to function 'C'
        ...

.. _box_error-last:

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

.. _box_error-clear:

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

.. _box_error-new:

.. function:: box.error.new(code, errtext [, errtext ...])

    Create an error object, but not throw it as :ref:`box.error() <box_error-error>`
    does. This is useful when error information should be saved for later retrieval.
    To set an error as the last explicitly use :ref:`box.error.set() <box_error-set>`.

    :param number       code: number of a pre-defined error
    :param string errtext(s): part of the message which will accompany the error

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> e=box.error.new{code=5,reason='A',type='B'}
        ---
        ...
        tarantool> e:unpack()
        ---
        - code: 5
          base_type: CustomError
          type: B
          custom_type: B
          message: A
          trace:
          - file: '[string "e=box.error.new{code=5,reason=''A'',type=''B''}"]'
            line: 1
        ...
        tarantool> box.error.last()
        ---
        - null

    Beginning in version 2.4.1 there is a :ref:`session_settings <box_space-session_settings>`
    setting which affects structure of error objects. If ``error_marshaling_enabled``
    is changed to ``true``, then the object will have the MP_EXT type and the
    MP_ERROR subtype. Using the :ref:`binary protocol <internals-box_protocol>`,
    in the body of a packet that the server could send in response to ``box.error.new()``,
    one will see:
    the encoding of MP_EXT according to the
    `MessagePack specification <https://github.com/msgpack/msgpack/blob/master/spec.md>`_
    (usually 0xc7),
    followed by the encoding of MP_ERROR (0x03),
    followed by the encoding of MP_ERROR_STACK (0x81),
    followed by all of the MP_ERROR_STACK components
    (MP_ARRAY which contains MP_MAP which contains keys MP_ERROR_MESSAGE, MP_ERROR_CODE, etc.)
    that are described and illustrated in section
    :ref:`MessagePack extensions -- The ERROR type <msgpack_ext-error>`.
    The map field for error object "type" will have key = MP_ERROR_TYPE,
    the map field for error object "code" will have key = MP_ERROR_CODE,
    the map field for error object "message" will have key = MP_ERROR_MESSAGE.

.. _box_error-set:

.. function:: box.error.set(error object)

    Set an error as the last system error explicitly. Accepts an error object and 
    makes it available via :ref:`box.error.last() <box_error-last>`.

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

.. _box_error-error_object:

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
``'ClientError'``, ``'OurOfMemory'``, etc.

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

You can also use a format string to compose an error message for
the ``'CustomError'`` type.

.. code-block:: lua

    box.error('MyCustomType', 'The error reason: %s', 'some error reason')
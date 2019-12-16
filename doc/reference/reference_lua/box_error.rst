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
``ER_PROC_LUA``.

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

``box.error`` throws an object that has the cdata type and contain the following
fields:

* "type" (string) error's C++ class,
* "code" (number) error's number,
* "message" (string) error's message,
* "file" (string) Tarantool source file,
* "line" (number) line number in the Tarantool source file,
* "errno" (number) C standard error number; this field is added only if the error
  is a system error (for example, due to a failure in a socket or file i/o).

.. function:: box.error{reason = string [, code = number]}

    When called with a Lua-table argument, the code and reason have any
    user-desired values. The result will be those values.

    :param string reason: description of an error, defined by user
    :param integer  code: numeric code for this error, defined by user

.. function:: box.error()

    When called without arguments, ``box.error()`` re-throws whatever the last
    error was.

.. _box_error-error:

.. function:: box.error(code, errtext [, errtext ...])

    Emulate a request error, with text based on one of the pre-defined Tarantool
    errors defined in the file `errcode.h
    <https://github.com/tarantool/tarantool/blob/1.10/src/box/errcode.h>`_ in
    the source tree. Lua constants which correspond to those Tarantool errors are
    defined as members of ``box.error``, for example ``box.error.NO_SUCH_USER == 45``.

    :param number       code: number of a pre-defined error
    :param string errtext(s): part of the message which will accompany the error

    For example:

    the ``NO_SUCH_USER`` message is "``User '%s' is not found``" -- it includes
    one "``%s``" component which will be replaced with errtext. Thus a call to
    ``box.error(box.error.NO_SUCH_USER, 'joe')`` or ``box.error(45, 'joe')``
    will result in an error with the accompanying message
    "``User 'joe' is not found``".

    :except: whatever is specified in errcode-number.

    **Example:**

    .. code-block:: tarantoolsession

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

    Show the last error object.

    **Example**

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

.. _box_error-clear:

.. function:: box.error.clear()

    Clear the record of errors, so functions like ``box.error()``
    or ``box.error.last()`` will have no effect.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.schema.space.create('')
        ---
        - error: Invalid identifier '' (expected printable symbols only or it is too long)
        ...
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

    Create an error object, but do not throw.
    This is useful when error information should be saved for later retrieval.
    The parameters are the same as for :ref:`box.error() <box_error-error>`,
    see the description there.

    :param number       code: number of a pre-defined error
    :param string errtext(s): part of the message which will accompany the error

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> e = box.error.new{code = 555, reason = 'Arbitrary message'}
        ---
        ...
        tarantool> e:unpack()
        ---
        - type: ClientError
          code: 555
          message: Arbitrary message
          trace:
          - file: '[string "e = box.error.new{code = 555, reason = ''Arbit..."]'
            line: 1
        ...

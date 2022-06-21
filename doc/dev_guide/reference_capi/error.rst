===========================================================
                    Module error
===========================================================

.. module:: capi_error

.. _capi-box_error_code:

    For a complete list of errors, refer to the Tarantool
    `error code header file <https://github.com/tarantool/tarantool/blob/2.10/src/box/errcode.h>`__
    (provided for version 2.10).

.. c:type:: box_error_t

    Error -- contains information about error.

.. c:function:: const char * box_error_type(const box_error_t *error)

    Return the error type, e.g. "ClientError", "SocketError", etc.

    :param box_error_t* error: error
    :return: not-null string

.. _capi-box_error_code_code:

.. c:function:: uint32_t box_error_code(const box_error_t *error)

    Return IPROTO error code

    :param box_error_t* error: error
    :return: enum :ref:`box_error_code <capi-box_error_code>`

.. c:function:: const char * box_error_message(const box_error_t *error)

    Return the error message

    :param box_error_t* error: error
    :return: not-null string

.. _c_api-error-box_error_last:

.. c:function:: box_error_t * box_error_last(void)

    Get the information about the last API call error.

    The Tarantool error handling works most like libc's errno. All API calls
    return -1 or NULL in the event of error. An internal pointer to box_error_t
    type is set by API functions to indicate what went wrong. This value is only
    significant if API call failed (returned -1 or NULL).

    Successful function can also touch the last error in some cases. You don't
    have to clear the last error before calling API functions. The returned
    object is valid only until next call to **any** API function.

    You must set the last error using box_error_set() in your stored C procedures
    if you want to return a custom error message. You can re-throw the last API
    error to IPROTO client by keeping the current value and returning -1 to
    Tarantool from your stored procedure.

    :return: last error

.. c:function:: void box_error_clear(void)

    Clear the last error.

.. c:function:: int box_error_set(const char *file, unsigned line, uint32_t code, const char *format, ...)

    Set the last error.

    :param const char* file:
    :param unsigned line:
    :param uint32_t code: IPROTO :ref:`error code<capi-box_error_code>`
    :param const char* format:
    :param ...: format arguments

    See also: IPROTO :ref:`error code<capi-box_error_code>`

.. c:macro:: box_error_raise(code, format, ...)

    A backward-compatible API define.

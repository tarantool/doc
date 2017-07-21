===========================================================
                    Module `error`
===========================================================

.. module:: capi_error

.. _capi-box_error_code:

.. cpp:enum:: box_error_code

    .. cpp:enumerator:: ::ER_UNKNOWN
    .. cpp:enumerator:: ::ER_ILLEGAL_PARAMS
    .. cpp:enumerator:: ::ER_MEMORY_ISSUE
    .. cpp:enumerator:: ::ER_TUPLE_FOUND
    .. cpp:enumerator:: ::ER_TUPLE_NOT_FOUND
    .. cpp:enumerator:: ::ER_UNSUPPORTED
    .. cpp:enumerator:: ::ER_NONMASTER
    .. cpp:enumerator:: ::ER_READONLY
    .. cpp:enumerator:: ::ER_INJECTION
    .. cpp:enumerator:: ::ER_CREATE_SPACE
    .. cpp:enumerator:: ::ER_SPACE_EXISTS
    .. cpp:enumerator:: ::ER_DROP_SPACE
    .. cpp:enumerator:: ::ER_ALTER_SPACE
    .. cpp:enumerator:: ::ER_INDEX_TYPE
    .. cpp:enumerator:: ::ER_MODIFY_INDEX
    .. cpp:enumerator:: ::ER_LAST_DROP
    .. cpp:enumerator:: ::ER_TUPLE_FORMAT_LIMIT
    .. cpp:enumerator:: ::ER_DROP_PRIMARY_KEY
    .. cpp:enumerator:: ::ER_KEY_PART_TYPE
    .. cpp:enumerator:: ::ER_EXACT_MATCH
    .. cpp:enumerator:: ::ER_INVALID_MSGPACK
    .. cpp:enumerator:: ::ER_PROC_RET
    .. cpp:enumerator:: ::ER_TUPLE_NOT_ARRAY
    .. cpp:enumerator:: ::ER_FIELD_TYPE
    .. cpp:enumerator:: ::ER_FIELD_TYPE_MISMATCH
    .. cpp:enumerator:: ::ER_SPLICE
    .. cpp:enumerator:: ::ER_UPDATE_ARG_TYPE
    .. cpp:enumerator:: ::ER_TUPLE_IS_TOO_LONG
    .. cpp:enumerator:: ::ER_UNKNOWN_UPDATE_OP
    .. cpp:enumerator:: ::ER_UPDATE_FIELD
    .. cpp:enumerator:: ::ER_FIBER_STACK
    .. cpp:enumerator:: ::ER_KEY_PART_COUNT
    .. cpp:enumerator:: ::ER_PROC_LUA
    .. cpp:enumerator:: ::ER_NO_SUCH_PROC
    .. cpp:enumerator:: ::ER_NO_SUCH_TRIGGER
    .. cpp:enumerator:: ::ER_NO_SUCH_INDEX
    .. cpp:enumerator:: ::ER_NO_SUCH_SPACE
    .. cpp:enumerator:: ::ER_NO_SUCH_FIELD
    .. cpp:enumerator:: ::ER_EXACT_FIELD_COUNT
    .. cpp:enumerator:: ::ER_INDEX_FIELD_COUNT
    .. cpp:enumerator:: ::ER_WAL_IO
    .. cpp:enumerator:: ::ER_MORE_THAN_ONE_TUPLE
    .. cpp:enumerator:: ::ER_ACCESS_DENIED
    .. cpp:enumerator:: ::ER_CREATE_USER
    .. cpp:enumerator:: ::ER_DROP_USER
    .. cpp:enumerator:: ::ER_NO_SUCH_USER
    .. cpp:enumerator:: ::ER_USER_EXISTS
    .. cpp:enumerator:: ::ER_PASSWORD_MISMATCH
    .. cpp:enumerator:: ::ER_UNKNOWN_REQUEST_TYPE
    .. cpp:enumerator:: ::ER_UNKNOWN_SCHEMA_OBJECT
    .. cpp:enumerator:: ::ER_CREATE_FUNCTION
    .. cpp:enumerator:: ::ER_NO_SUCH_FUNCTION
    .. cpp:enumerator:: ::ER_FUNCTION_EXISTS
    .. cpp:enumerator:: ::ER_FUNCTION_ACCESS_DENIED
    .. cpp:enumerator:: ::ER_FUNCTION_MAX
    .. cpp:enumerator:: ::ER_SPACE_ACCESS_DENIED
    .. cpp:enumerator:: ::ER_USER_MAX
    .. cpp:enumerator:: ::ER_NO_SUCH_ENGINE
    .. cpp:enumerator:: ::ER_RELOAD_CFG
    .. cpp:enumerator:: ::ER_CFG
    .. cpp:enumerator:: ::ER_UNUSED60
    .. cpp:enumerator:: ::ER_UNUSED61
    .. cpp:enumerator:: ::ER_UNKNOWN_REPLICA
    .. cpp:enumerator:: ::ER_REPLICASET_UUID_MISMATCH
    .. cpp:enumerator:: ::ER_INVALID_UUID
    .. cpp:enumerator:: ::ER_REPLICASET_UUID_IS_RO
    .. cpp:enumerator:: ::ER_INSTANCE_UUID_MISMATCH
    .. cpp:enumerator:: ::ER_REPLICA_ID_IS_RESERVED
    .. cpp:enumerator:: ::ER_INVALID_ORDER
    .. cpp:enumerator:: ::ER_MISSING_REQUEST_FIELD
    .. cpp:enumerator:: ::ER_IDENTIFIER
    .. cpp:enumerator:: ::ER_DROP_FUNCTION
    .. cpp:enumerator:: ::ER_ITERATOR_TYPE
    .. cpp:enumerator:: ::ER_REPLICA_MAX
    .. cpp:enumerator:: ::ER_INVALID_XLOG
    .. cpp:enumerator:: ::ER_INVALID_XLOG_NAME
    .. cpp:enumerator:: ::ER_INVALID_XLOG_ORDER
    .. cpp:enumerator:: ::ER_NO_CONNECTION
    .. cpp:enumerator:: ::ER_TIMEOUT
    .. cpp:enumerator:: ::ER_ACTIVE_TRANSACTION
    .. cpp:enumerator:: ::ER_NO_ACTIVE_TRANSACTION
    .. cpp:enumerator:: ::ER_CROSS_ENGINE_TRANSACTION
    .. cpp:enumerator:: ::ER_NO_SUCH_ROLE
    .. cpp:enumerator:: ::ER_ROLE_EXISTS
    .. cpp:enumerator:: ::ER_CREATE_ROLE
    .. cpp:enumerator:: ::ER_INDEX_EXISTS
    .. cpp:enumerator:: ::ER_TUPLE_REF_OVERFLOW
    .. cpp:enumerator:: ::ER_ROLE_LOOP
    .. cpp:enumerator:: ::ER_GRANT
    .. cpp:enumerator:: ::ER_PRIV_GRANTED
    .. cpp:enumerator:: ::ER_ROLE_GRANTED
    .. cpp:enumerator:: ::ER_PRIV_NOT_GRANTED
    .. cpp:enumerator:: ::ER_ROLE_NOT_GRANTED
    .. cpp:enumerator:: ::ER_MISSING_SNAPSHOT
    .. cpp:enumerator:: ::ER_CANT_UPDATE_PRIMARY_KEY
    .. cpp:enumerator:: ::ER_UPDATE_INTEGER_OVERFLOW
    .. cpp:enumerator:: ::ER_GUEST_USER_PASSWORD
    .. cpp:enumerator:: ::ER_TRANSACTION_CONFLICT
    .. cpp:enumerator:: ::ER_UNSUPPORTED_ROLE_PRIV
    .. cpp:enumerator:: ::ER_LOAD_FUNCTION
    .. cpp:enumerator:: ::ER_FUNCTION_LANGUAGE
    .. cpp:enumerator:: ::ER_RTREE_RECT
    .. cpp:enumerator:: ::ER_PROC_C
    .. cpp:enumerator:: ::ER_UNKNOWN_RTREE_INDEX_DISTANCE_TYPE
    .. cpp:enumerator:: ::ER_PROTOCOL
    .. cpp:enumerator:: ::ER_UPSERT_UNIQUE_SECONDARY_KEY
    .. cpp:enumerator:: ::ER_WRONG_INDEX_RECORD
    .. cpp:enumerator:: ::ER_WRONG_INDEX_PARTS
    .. cpp:enumerator:: ::ER_WRONG_INDEX_OPTIONS
    .. cpp:enumerator:: ::ER_WRONG_SCHEMA_VERSION
    .. cpp:enumerator:: ::ER_MEMTX_MAX_TUPLE_SIZE
    .. cpp:enumerator:: ::ER_WRONG_SPACE_OPTIONS
    .. cpp:enumerator:: ::ER_UNSUPPORTED_INDEX_FEATURE
    .. cpp:enumerator:: ::ER_VIEW_IS_RO
    .. cpp:enumerator:: ::ER_UNUSED114
    .. cpp:enumerator:: ::ER_SYSTEM
    .. cpp:enumerator:: ::ER_LOADING
    .. cpp:enumerator:: ::ER_CONNECTION_TO_SELF
    .. cpp:enumerator:: ::ER_KEY_PART_IS_TOO_LONG
    .. cpp:enumerator:: ::ER_COMPRESSION
    .. cpp:enumerator:: ::ER_CHECKPOINT_IN_PROGRESS
    .. cpp:enumerator:: ::ER_SUB_STMT_MAX
    .. cpp:enumerator:: ::ER_COMMIT_IN_SUB_STMT
    .. cpp:enumerator:: ::ER_ROLLBACK_IN_SUB_STMT
    .. cpp:enumerator:: ::ER_DECOMPRESSION
    .. cpp:enumerator:: ::ER_INVALID_XLOG_TYPE
    .. cpp:enumerator:: ::ER_ALREADY_RUNNING
    .. cpp:enumerator:: ::ER_INDEX_FIELD_COUNT_LIMIT
    .. cpp:enumerator:: ::ER_LOCAL_INSTANCE_ID_IS_READ_ONLY
    .. cpp:enumerator:: ::ER_BACKUP_IN_PROGRESS
    .. cpp:enumerator:: ::ER_READ_VIEW_ABORTED
    .. cpp:enumerator:: ::ER_INVALID_INDEX_FILE
    .. cpp:enumerator:: ::ER_INVALID_RUN_FILE
    .. cpp:enumerator:: ::ER_INVALID_VYLOG_FILE
    .. cpp:enumerator:: ::ER_CHECKPOINT_ROLLBACK
    .. cpp:enumerator:: ::ER_VY_QUOTA_TIMEOUT
    .. cpp:enumerator:: ::ER_PARTIAL_KEY
    .. cpp:enumerator:: ::ER_TRUNCATE_SYSTEM_SPACE
    .. cpp:enumerator:: ::box_error_code_MAX

.. c:type:: box_error_t

    Error - contains information about error.

.. c:function:: const char * box_error_type(const box_error_t *error)

    Return the error type, e.g. "ClientError", "SocketError", etc.

    :param box_error_t* error: error
    :return: not-null string

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

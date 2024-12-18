===========================================================
                        Module box
===========================================================

.. c:type:: box_function_ctx_t

    Opaque structure passed to a C stored procedure

.. _box-box_return_tuple:

.. c:function:: int box_return_tuple(box_function_ctx_t *ctx, box_tuple_t *tuple)

    Return a tuple from a C stored procedure.

    The returned tuple is automatically reference-counted by Tarantool.
    An example program that uses ``box_return_tuple()`` is
    :ref:`write.c <f_c_tutorial-write>`.

    :param box_function_ctx_t* ctx: an opaque structure passed to the C stored
                                    procedure by Tarantool
    :param box_tuple_t*     tuple: a tuple to return

    :return: -1 on error (perhaps, out of memory; check
             :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise


.. _box-box_return_mp:

.. c:function:: int box_return_mp(box_function_ctx_t *ctx, const char *mp, const char *mp_end)

    Return a pointer to a series of bytes in MessagePack format.

    This can be used instead of :ref:`box_return_tuple() <box-box_return_tuple>` --
    it can send the same value, but as MessagePack instead of as a tuple object.
    It may be simpler than ``box_return_tuple()`` when the result is small, for
    example a number or a boolean or a short string.
    It will also be faster than ``box_return_tuple()``, if the result is that
    users save time by not creating a tuple every time they want to return
    something from a C function.

    On the other hand, if an already-existing tuple was obtained from
    an iterator, then it would be faster to return the tuple via ``box_return_tuple()``
    rather than extracting its parts and sending them via ``box_return_mp()``.

    :param box_function_ctx_t* ctx: an opaque structure passed to the C stored
                                    procedure by Tarantool
    :param char*               mp:  the first MessagePack byte
    :param char*           mp_end:  after the last MessagePack byte

    :return: -1 on error (perhaps, out of memory; check
             :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    For example, if ``mp`` is a buffer, and ``mp_end`` is a return value
    produced by encoding a single MP_UINT scalar value with
    ``mp_end=mp_encode_uint(mp,1);``, then
    ``box_return_mp(ctx,mp,mp_end);`` should return ``0``.

.. _box-box_space_id_by_name:

.. c:function:: uint32_t box_space_id_by_name(const char *name, uint32_t len)

    Find space id by name.

    This function performs a SELECT request on the ``_vspace`` system space.

    :param const char* name: space name
    :param uint32_t     len: length of ``name``

    :return: :c:macro:`BOX_ID_NIL` on error or if not found (check
             :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: space_id otherwise

    See also: :c:type:`box_index_id_by_name`

.. c:function:: uint32_t box_index_id_by_name(uint32_t space_id, const char *name, uint32_t len)

    Find index id by name.

    This function performs a SELECT request on the ``_vindex`` system space.

    :param uint32_t space_id: space identifier
    :param const char*  name: index name
    :param uint32_t      len: length of ``name``

    :return: :c:macro:`BOX_ID_NIL` on error or if not found (check
             :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: space_id otherwise

    See also: :c:type:`box_space_id_by_name`

.. _box-box_insert:

.. c:function:: int box_insert(uint32_t space_id, const char *tuple, const char *tuple_end, box_tuple_t **result)

    Execute an INSERT/REPLACE request.

    :param uint32_t     space_id: space identifier
    :param const char*     tuple: encoded tuple in MsgPack Array format ([ field1, field2, ...])
    :param const char* tuple_end: end of a ``tuple``
    :param box_tuple_t**  result: output argument. Resulting tuple. Can be set to
                                  NULL to discard result

    :return: -1 on error (check :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    See also: :ref:`space_object.insert()<box_space-insert>`

.. _box-box_replace:

.. c:function:: int box_replace(uint32_t space_id, const char *tuple, const char *tuple_end, box_tuple_t **result)

    Execute a REPLACE request.

    :param uint32_t     space_id: space identifier
    :param const char*     tuple: encoded tuple in MsgPack Array format ([ field1, field2, ...])
    :param const char* tuple_end: end of a ``tuple``
    :param box_tuple_t**  result: output argument. Resulting tuple. Can be set to
                                  NULL to discard result

    :return: -1 on error (check :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    See also: :ref:`space_object.replace()<box_space-replace>`

.. c:function:: int box_delete(uint32_t space_id, uint32_t index_id, const char *key, const char *key_end, box_tuple_t **result)

    Execute a DELETE request.

    :param uint32_t    space_id: space identifier
    :param uint32_t    index_id: index identifier
    :param const char*      key: encoded key in MsgPack Array format ([ field1, field2, ...])
    :param const char*  key_end: end of a ``key``
    :param box_tuple_t** result: output argument. An old tuple. Can be
                                 set to NULL to discard result

    :return: -1 on error (check :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    See also: :ref:`space_object.delete()<box_space-delete>`

.. c:function:: int box_update(uint32_t space_id, uint32_t index_id, const char *key, const char *key_end, const char *ops, const char *ops_end, int index_base, box_tuple_t **result)

    Execute an UPDATE request.

    :param uint32_t    space_id: space identifier
    :param uint32_t    index_id: index identifier
    :param const char*      key: encoded key in MsgPack Array format ([ field1, field2, ...])
    :param const char*  key_end: end of a ``key``
    :param const char*      ops: encoded operations in MsgPack Array format, e.g.
                                 ``[[ '=', field_id,  value ], ['!', 2, 'xxx']]``
    :param const char*  ops_end: end of an ``ops`` section
    :param int       index_base: 0 if field_ids are zero-based as in C,
                                 1 if field ids are 1-based as in Lua
    :param box_tuple_t** result: output argument. An old tuple. Can be
                                 set to NULL to discard result

    :return: -1 on error (check :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    See also: :ref:`space_object.update()<box_space-update>`

.. c:function:: int box_upsert(uint32_t space_id, uint32_t index_id, const char *tuple, const char *tuple_end, const char *ops, const char *ops_end, int index_base, box_tuple_t **result)

    Execute an UPSERT request.

    :param uint32_t     space_id: space identifier
    :param uint32_t     index_id: index identifier
    :param const char*     tuple: encoded tuple in MsgPack Array format ([ field1, field2, ...])
    :param const char* tuple_end: end of a ``tuple``
    :param const char*       ops: encoded operations in MsgPack Array format, e.g.
                                 ``[[ '=', field_id,  value ], ['!', 2, 'xxx']]``
    :param const char*   ops_end: end of a ``ops``
    :param int        index_base: 0 if field_ids are zero-based as in C,
                                  1 if field ids are 1-based as in Lua
    :param box_tuple_t**  result: output argument. An old tuple. Can be
                                  set to NULL to discard result

    :return: -1 on error (check :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    See also: :ref:`space_object.upsert()<box_space-upsert>`

.. c:function:: int box_truncate(uint32_t space_id)

    Truncate a space.

    :param uint32_t space_id: space identifier

.. _box_box_session_push:

.. c:function:: int box_session_push(const char *data, const char *data_end)

    **Deprecated since** :doc:`3.0.0 </release/3.0.0>`.

    Since version :doc:`2.4.1 </release/2.4.1>`. Push MessagePack data into
    a session data channel -- socket, console or
    whatever is behind the session. Behaves just like Lua
    :doc:`/reference/reference_lua/box_session/push`.

    :param const char* data: begin of MessagePack to push
    :param const char* data_end: end of MessagePack to push

    :return: -1 on error (check :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

.. _box_box_sequence_current:

.. c:function:: int box_sequence_current(uint32_t seq_id, int64_t *result)

    Since version :doc:`2.4.1 </release/2.4.1>`.
    Return the last retrieved value of the specified sequence.

    :param uint32_t seq_id: sequence identifier
    :param int64_t result: pointer to a variable where the current sequence
                            value will be stored on success.

    :return: 0 on success and -1 otherwise. In case of an error user
                could get it via ``box_error_last()``.

..  _box_box_schema_version:

..  c:function:: uint32_t box_schema_version(void)

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Return the database schema version.
    A schema version is a number that indicates whether the :ref:`database schema <index-box-data_schema_description>` is changed.
    For example, the ``schema_version`` value grows if a :ref:`space <index-box_space>` or :ref:`index <index-box_index>`
    is added or deleted, or a space, index, or field name is changed.

    :return: the database schema version
    :rtype: number

    See also: :ref:`box.info.schema_version <box_info_schema_version>` and :ref:`IPROTO_SCHEMA_VERSION <internals-iproto-keys-schema_version>`

..  _box_box_session_id:

..  c:function:: uint64_t box_session_id(void)

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Return the unique identifier (ID) for the current session.

    :return: the session identifier; 0 or -1 if there is no session
    :rtype: number

    See also: :ref:`box.session.id() <box_session-id>`

..  _box_box_iproto_send:

..  c:function:: int box_iproto_send(uint64_t sid, char *header, char *header_end[, char *body, char *body_end])

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Send an :ref:`IPROTO <internals-iproto-format>` packet over the session's socket with the given MsgPack header
    and body.
    The function yields.
    The function works for binary sessions only. For details, see :ref:`box.session.type() <box_session-type>`.

    :param uint32_t     sid: the IPROTO session identifier (see :ref:`box_session_id() <box_box_session_id>`)
    :param char*     header: a MsgPack-encoded header
    :param char*     header_end: end of a header encoded as MsgPack
    :param char*     body: a MsgPack-encoded body. If the ``body`` and ``body_end`` parameters are omitted, the packet
                           consists of the header only.
    :param char*     body_end: end of a body encoded as MsgPack

    :return: 0 on success; -1 on error (check :ref:`box_error_last() <c_api-error-box_error_last>`)
    :rtype: number

    See also: :ref:`box.iproto.send() <reference_lua-box_iproto_send>`

    **Possible errors:**

    *   :errcode:`ER_SESSION_CLOSED` -- the session is closed.
    *   :errcode:`ER_NO_SUCH_SESSION` -- the session does not exist.
    *   :errcode:`ER_MEMORY_ISSUE` -- out-of-memory limit has been reached.
    *   :errcode:`ER_WRONG_SESSION_TYPE` -- the session type is not binary.

    For details, see `src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`__.

    **Example**

    ..  code-block:: c

        /* IPROTO constants are not exported to C.
        * That is, the user encodes them by himself.
        */
        #define IPROTO_REQUEST_TYPE 0x00
        #define IPROTO_OK 0x00
        #define IPROTO_SYNC 0x01
        #define IPROTO_SCHEMA_VERSION 0x05
        #define IPROTO_DATA 0x30

        char buf[256] = {};
        char *header = buf;
        char *header_end = header;
        header_end = mp_encode_map(header_end, 3);
        header_end = mp_encode_uint(header_end, IPROTO_REQUEST_TYPE);
        header_end = mp_encode_uint(header_end, IPROTO_OK);
        header_end = mp_encode_uint(header_end, IPROTO_SYNC);
        header_end = mp_encode_uint(header_end, 10);
        header_end = mp_encode_uint(header_end, IPROTO_SCHEMA_VERSION);
        header_end = mp_encode_uint(header_end, box_schema_version());

        char *body = header_end;
        char *body_end = body;
        body_end = mp_encode_map(body_end, 1);
        body_end = mp_encode_uint(body_end, IPROTO_DATA);
        body_end = mp_encode_uint(body_end, 1);

        /* The packet contains both the header and body. */
        box_iproto_send(box_session_id(), header, header_end, body, body_end);

        /* The packet contains the header only. */
        box_iproto_send(box_session_id(), header, header_end, NULL, NULL);

..  _box_box_iproto_override:

..  c:function:: void box_iproto_override(uint32_t request_type, iproto_handler_t handler, iproto_handler_destroy_t destroy, void *ctx)

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Set a new IPROTO request handler with the provided context for the given request type.
    The function yields.

    :param uint32_t request_type: IPROTO request type code (for example, ``IPROTO_SELECT``).
                                  For details, check :ref:`Client-server requests and responses <internals-requests_responses>`.

                                  To override the handler of unknown request types, use the :ref:`IPROTO_UNKNOWN <internals-iproto-unknown>` type code.

    :param iproto_handler_t handler: IPROTO request handler. To reset the request handler, set the ``handler`` parameter to ``NULL``.
                                     See the full parameter description in the :ref:`Handler function <box_box_iproto_override-handler>` section.

    :param iproto_handler_destroy_t destroy: IPROTO request handler destructor. The destructor is called when the
                                             corresponding handler is removed. See the full parameter description
                                             in the :ref:`Handler destructor function <box_box_iproto_override-destroy>` section.

    :param void* ctx: a context passed to the ``handler`` and ``destroy`` callbacks

    :return: 0 on success; -1 on error (check :ref:`box_error_last() <c_api-error-box_error_last>`)
    :rtype: number

    See also: :ref:`box.iproto.override() <reference_lua-box_iproto_override>`

    **Possible errors:**

    If a Lua handler throws an exception, the behavior is similar to that of a remote procedure call.
    The following errors are returned to the client over IPROTO (see `src/lua/utils.h <https://github.com/tarantool/tarantool/blob/dec0e0221e183fa972efa65bb0fb658112f2196f/src/lua/utils.h#L366-L371>`__):

    *   :errcode:`ER_PROC_LUA` -- an exception is thrown from a Lua handler, diagnostic is not set.
    *   diagnostics from ``src/box/errcode.h`` -- an exception is thrown, diagnostic is set.

    For details, see `src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`__.

..  _box_box_iproto_override-handler:

    **Handler function**

    The signature of a handler function (the ``handler`` parameter):

    ..  code-block:: c

        enum iproto_handler_status {
                IPROTO_HANDLER_OK,
                IPROTO_HANDLER_ERROR,
                IPROTO_HANDLER_FALLBACK,
        }

        typedef enum iproto_handler_status
        (*iproto_handler_t)(const char *header, const char *header_end,
                            const char *body, const char *body_end, void *ctx);

    where:

    *   ``header`` (const char*) -- a MsgPack-encoded header
    *   ``header_end`` (const char*) -- end of a header encoded as MsgPack
    *   ``body`` (const char*) -- a MsgPack-encoded body
    *   ``header_end`` (const char*) -- end of a body encoded as MsgPack

    The handler returns a status code. Possible statuses:

    *   ``IPROTO_REQUEST_HANDLER_OK`` -- success
    *   ``IPROTO_REQUEST_HANDLER_ERROR`` -- error, diagnostic must be set by handler
        (see :ref:`box_error_set() <c_api-error-box_error_set>` and :ref:`box_error_raise() <c_api-error-box_error_raise>`)

    *   ``IPROTO_REQUEST_HANDLER_FALLBACK`` -- fallback to the default handler

..  _box_box_iproto_override-destroy:

    **Handler destructor function**

    The destructor is called when the handler is reset.
    The signature of a destructor function (the ``destroy`` parameter):

    ..  code-block:: c

        typedef void (*iproto_handler_destroy_t)(void *ctx);

    where:

    *   ``ctx`` (void*): the context provided by ``box_iproto_override()`` function.

    **Examples**

    ..  code-block:: c

        box_iproto_override(1000, iproto_request_handler_с, NULL)
        box_iproto_override(IPROTO_SELECT, iproto_request_handler_с, (uintptr_t)23)
        box_iproto_override(IPROTO_SELECT, NULL, NULL)
        box_iproto_override(IPROTO_UNKNOWN, iproto_unknown_request_handler_с, &ctx)

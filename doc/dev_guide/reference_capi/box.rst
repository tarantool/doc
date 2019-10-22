===========================================================
                        Module `box`
===========================================================

.. c:type:: box_function_ctx_t

    Opaque structure passed to a C stored procedure

.. _box-box_return_tuple:

.. c:function:: int box_return_tuple(box_function_ctx_t *ctx, box_tuple_t *tuple)

    Return a tuple from a C stored procedure.

    The returned tuple is automatically reference-counted by Tarantool.
    An example program that uses ``box_return_tuple()`` is
    :ref:`write.c <f_c_tutorial-write>`.

    :param box_funtion_ctx_t* ctx: an opaque structure passed to the C stored
                                   procedure by Tarantool
    :param box_tuple_t*     tuple: a tuple to return

    :return: -1 on error (perhaps, out of memory; check
             :ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

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

    See also :ref:`space_object.insert()<box_space-insert>`

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

    See also :ref:`space_object.replace()<box_space-replace>`

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

    See also :ref:`space_object.delete()<box_space-delete>`

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

    See also :ref:`space_object.update()<box_space-update>`

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

    :return: -1 on error (check ::ref:`box_error_last()<c_api-error-box_error_last>`)
    :return: 0 otherwise

    See also :ref:`space_object.upsert()<box_space-upsert>`

.. c:function:: int box_truncate(uint32_t space_id)

    Truncate a space.

    :param uint32_t space_id: space identifier


===========================================================
                     Module `tuple`
===========================================================

.. c:type:: box_tuple_format_t

.. _c_api-tuple-box_tuple_format_default:

.. c:function:: box_tuple_format_t *box_tuple_format_default(void)

    Tuple format.

    Each Tuple has associated format (class). Default format is used to
    create tuples which are not attach to any particular space.

.. c:type:: box_tuple_t

    Tuple

.. _c_api-tuple-box_tuple_new:

.. c:function:: box_tuple_t *box_tuple_new(box_tuple_format_t *format, const char *tuple, const char *tuple_end)

    Allocate and initialize a new tuple from a raw MsgPack Array data.

    :param box_tuple_format_t* format: tuple format. Use
                                       :ref:`box_tuple_format_default()<c_api-tuple-box_tuple_format_default>`
                                       to create space-independent tuple.
    :param const char*          tuple: tuple data in MsgPack Array format ([field1, field2, ...])
    :param const char*      tuple_end: the end of ``data``

    :return: NULL on out of memory
    :return: tuple otherwise

    See also: :ref:`box.tuple.new()<box_tuple-new>`

.. _c_api-tuple-box_tuple_ref:

.. c:function:: int box_tuple_ref(box_tuple_t *tuple)

    Increase the reference counter of tuple.

    Tuples are reference counted. All functions that return tuples guarantee
    that the last returned tuple is refcounted internally until the next
    call to API function that yields or returns another tuple.

    You should increase the reference counter before taking tuples for long
    processing in your code. Such tuples will not be garbage collected even
    if another fiber remove they from space. After processing please
    decrement the reference counter using
    :ref:`box_tuple_unref()<c_api-tuple-box_tuple_unref>`,
    otherwise the tuple will leak.

    :param box_tuple_t* tuple: a tuple

    :return: -1 on error
    :return: 0 otherwise

    See also: :ref:`box_tuple_unref()<c_api-tuple-box_tuple_unref>`

.. _c_api-tuple-box_tuple_unref:

.. c:function:: void box_tuple_unref(box_tuple_t *tuple)

    Decrease the reference counter of tuple.

    :param box_tuple_t* tuple: a tuple

    :return: -1 on error
    :return: 0 otherwise

    See also: :ref:`box_tuple_ref()<c_api-tuple-box_tuple_ref>`

.. _c_api-tuple-box_tuple_field_count:

.. c:function:: uint32_t box_tuple_field_count(const box_tuple_t *tuple)

    Return the number of fields in tuple (the size of MsgPack Array).

    :param box_tuple_t* tuple: a tuple

.. c:function:: size_t box_tuple_bsize(const box_tuple_t *tuple)

    Return the number of bytes used to store internal tuple data (MsgPack Array).

    :param box_tuple_t* tuple: a tuple

.. c:function:: ssize_t box_tuple_to_buf(const box_tuple_t *tuple, char *buf, size_t size)

    Dump raw MsgPack data to the memory buffer ``buf`` of size ``size``.

    Store tuple fields in the memory buffer.

    Upon successful return, the function returns the number of bytes written.
    If buffer size is not enough then the return value is the number of bytes
    which would have been written if enough space had been available.

    :return: -1 on error
    :return: number of bytes written on success.

.. c:function:: box_tuple_format_t *box_tuple_format(const box_tuple_t *tuple)

    Return the associated format.

    :param box_tuple_t* tuple: a tuple

    :return: tuple format

.. _c_api-tuple-box_tuple_field:

.. c:function:: const char *box_tuple_field(const box_tuple_t *tuple, uint32_t field_id)

    Return the raw tuple field in MsgPack format.
    The result is a pointer to raw MessagePack data which can be
    decoded with mp_decode functions, for an example see the tutorial
    program :ref:`read.c <f_c_tutorial-read>`.

    The buffer is valid until next call to box_tuple_* functions.

    :param box_tuple_t* tuple: a tuple
    :param uint32_t field_id: zero-based index in MsgPack array.

    :return: NULL if i >= :ref:`box_tuple_field_count()<c_api-tuple-box_tuple_field_count>`
    :return: msgpack otherwise

.. c:type:: box_tuple_iterator_t

    Tuple iterator

.. c:function:: box_tuple_iterator_t *box_tuple_iterator(box_tuple_t *tuple)

    Allocate and initialize a new tuple iterator. The tuple iterator allow to
    iterate over fields at root level of MsgPack array.

    **Example:**

    .. code-block:: c

        box_tuple_iterator_t* it = box_tuple_iterator(tuple);
        if (it == NULL) {
            // error handling using box_error_last()
        }
        const char* field;
        while (field = box_tuple_next(it)) {
            // process raw MsgPack data
        }

        // rewind iterator to first position
        box_tuple_rewind(it)
        assert(box_tuple_position(it) == 0);

        // rewind three fields
        field = box_tuple_seek(it, 3);
        assert(box_tuple_position(it) == 4);

        box_iterator_free(it);

.. c:function:: void box_tuple_iterator_free(box_tuple_iterator_t *it)

    Destroy and free tuple iterator

.. _c_api-tuple-box_tuple_position:

.. c:function:: uint32_t box_tuple_position(box_tuple_iterator_t *it)

    Return zero-based next position in iterator. That is, this function
    return the field id of field that will be returned by the next call
    to :ref:`box_tuple_next()<c_api-tuple-box_tuple_next>`.
    Returned value is zero after initialization
    or rewind and :ref:`box_tuple_field_count()<c_api-tuple-box_tuple_field_count>`
    after the end of iteration.

    :param box_tuple_iterator_t* it: a tuple iterator
    :return: position

.. c:function:: void box_tuple_rewind(box_tuple_iterator_t *it)

    Rewind iterator to the initial position.

    :param box_tuple_iterator_t* it: a tuple iterator

    After: ``box_tuple_position(it) == 0``

.. c:function:: const char *box_tuple_seek(box_tuple_iterator_t *it, uint32_t field_no)

    Seek the tuple iterator.

    The result is a pointer to raw MessagePack data which can be
    decoded with mp_decode functions, for an example see the tutorial
    program :ref:`read.c <f_c_tutorial-read>`.
    The returned buffer is valid until next call to box_tuple_* API.
    Requested field_no returned by next call to box_tuple_next(it).

    :param box_tuple_iterator_t* it: a tuple iterator
    :param uint32_t        field_no: field number - zero-based position
                                     in MsgPack array

    After:

    * ``box_tuple_position(it) == field_not`` if returned value is not NULL.
    * ``box_tuple_position(it) == box_tuple_field_count(tuple)`` if returned
      value is NULL.

.. _c_api-tuple-box_tuple_next:

.. c:function:: const char *box_tuple_next(box_tuple_iterator_t *it)

    Return the next tuple field from tuple iterator.

    The result is a pointer to raw MessagePack data which can be
    decoded with mp_decode functions, for an example see the tutorial
    program :ref:`read.c <f_c_tutorial-read>`.
    The returned buffer is valid until next call to box_tuple_* API.

    :param box_tuple_iterator_t* it:
    :return: NULL if there are no more fields
    :return: MsgPack otherwise

    Before: :ref:`box_tuple_position()<c_api-tuple-box_tuple_position>`
    is zero-based ID of returned field.

    After: ``box_tuple_position(it) == box_tuple_field_count(tuple)`` if
    returned value is NULL.

.. c:function:: box_tuple_t *box_tuple_update(const box_tuple_t *tuple, const char *expr, const char *expr_end)

.. c:function:: box_tuple_t *box_tuple_upsert(const box_tuple_t *tuple, const char *expr, const char *expr_end)

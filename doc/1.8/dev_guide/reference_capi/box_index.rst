===========================================================
                     Module `index`
===========================================================

.. c:type:: box_iterator_t

    A space iterator

.. _c_api-box_index-iterator_type:

.. cpp:enum:: iterator_type

    Controls how to iterate over tuples in an index. Different index types
    support different iterator types. For example, one can start iteration
    from a particular value (request key) and then retrieve all tuples where
    keys are greater or equal (= GE) to this key.

    If iterator type is not supported by the selected index type, iterator
    constructor must fail with ER_UNSUPPORTED. To be selectable for primary
    key, an index must support at least ITER_EQ and ITER_GE types.

    NULL value of request key corresponds to the first or last key in the index,
    depending on iteration direction. (first key for GE and GT types, and last
    key for LE and LT). Therefore, to iterate over all tuples in an index, one
    can use ITER_GE or ITER_LE iteration types with start key equal to NULL.
    For ITER_EQ, the key must not be NULL.

    .. cpp:enumerator:: ::ITER_EQ

        key == x ASC order

    .. cpp:enumerator:: ::ITER_REQ

        key == x DESC order

    .. cpp:enumerator:: ::ITER_ALL

        all tuples

    .. cpp:enumerator:: ::ITER_LT

        key < x

    .. cpp:enumerator:: ::ITER_LE

        key <= x

    .. cpp:enumerator:: ::ITER_GE

        key >= x

    .. cpp:enumerator:: ::ITER_GT

        key > x

    .. cpp:enumerator:: ::ITER_BITS_ALL_SET

        all bits from x are set in key

    .. cpp:enumerator:: ::ITER_BITS_ANY_SET

        at least one x's bit is set

    .. cpp:enumerator:: ::ITER_BITS_ALL_NOT_SET

        all bits are not set

    .. cpp:enumerator:: ::ITER_OVERLAPS

        key overlaps x

    .. cpp:enumerator:: ::ITER_NEIGHBOR

        tuples in distance ascending order from specified point

.. _c_api-box_index-box_index_iterator:

.. c:function:: box_iterator_t *box_index_iterator(uint32_t space_id, uint32_t index_id, int type, const char *key, const char *key_end)

    Allocate and initialize iterator for space_id, index_id.

    The returned iterator must be destroyed by
    :ref:`box_iterator_free<c_api-box_index-box_iterator_free>`.

    :param uint32_t   space_id: space identifier
    :param uint32_t   index_id: index identifier
    :param int            type: :ref:`iterator_type<c_api-box_index-iterator_type>`
    :param const char*     key: encode key in MsgPack Array format ([part1, part2, ...])
    :param const char* key_end: the end of encoded ``key``

    :return: NULL on error (check :ref:`box_error_last <c_api-error-box_error_last>`)
    :return: iterator otherwise

    See also :ref:`box_iterator_next<c_api-box_index-box_iterator_next>`,
    :ref:`box_iterator_free<c_api-box_index-box_iterator_free>`

.. _c_api-box_index-box_iterator_next:

.. c:function:: int box_iterator_next(box_iterator_t *iterator, box_tuple_t **result)

    Retrieve the next item from the ``iterator``.

    :param box_iterator_t* iterator: an iterator returned by
                                     :ref:`box_index_iterator <c_api-box_index-box_index_iterator>`
    :param box_tuple_t**     result: output argument. result a tuple or NULL if
                                     there is no more data.

    :return: -1 on error (check :ref:`box_error_last <c_api-error-box_error_last>`)
    :return: 0 on success. The end of data is not an error.

.. _c_api-box_index-box_iterator_free:

.. c:function:: void box_iterator_free(box_iterator_t *iterator)

    Destroy and deallocate iterator.

    :param box_iterator_t* iterator: an iterator returned by
                                     :ref:`box_index_iterator <c_api-box_index-box_index_iterator>`

.. c:function:: int iterator_direction(enum iterator_type type)

    Determine a direction of the given iterator type:
    -1 for REQ, LT, LE, and +1 for all others.

.. c:function:: ssize_t box_index_len(uint32_t space_id, uint32_t index_id)

    Return the number of element in the index.

    :param uint32_t space_id: space identifier
    :param uint32_t index_id: index identifier

    :return: -1 on error (check :ref:`box_error_last <c_api-error-box_error_last>`)
    :return: >= 0 otherwise

.. c:function:: ssize_t box_index_bsize(uint32_t space_id, uint32_t index_id)

    Return the number of bytes used in memory by the index.

    :param uint32_t space_id: space identifier
    :param uint32_t index_id: index identifier

    :return: -1 on error (check :ref:`box_error_last <c_api-error-box_error_last>`)
    :return: >= 0 otherwise

.. c:function:: int box_index_random(uint32_t space_id, uint32_t index_id, uint32_t rnd, box_tuple_t **result)

    Return a random tuple from the index (useful for statistical analysis).

    :param uint32_t    space_id: space identifier
    :param uint32_t    index_id: index identifier
    :param uint32_t         rnd: random seed
    :param box_tuple_t** result: output argument. result a tuple or NULL if
                                 there is no tuples in space

    See also: :ref:`index_object.random<box_index-random>`

.. _c_api-box_index-box_index_get:

.. c:function:: int box_index_get(uint32_t space_id, uint32_t index_id, const char *key, const char *key_end, box_tuple_t **result)

    Get a tuple from index by the key.

    Please note that this function works much more faster than
    :ref:`index_object.select<box_index-select>` or
    :ref:`box_index_iterator<c_api-box_index-box_index_iterator>` +
    :ref:`box_iterator_next<c_api-box_index-box_iterator_next>`.

    :param uint32_t    space_id: space identifier
    :param uint32_t    index_id: index identifier
    :param const char*      key: encode key in MsgPack Array format ([part1, part2, ...])
    :param const char*  key_end: the end of encoded ``key``
    :param box_tuple_t** result: output argument. result a tuple or NULL if
                                 there is no tuples in space

    :return: -1 on error (check :ref:`box_error_last <c_api-error-box_error_last>`)
    :return: 0 on success

    See also: ``index_object.get()``

.. c:function:: int box_index_min(uint32_t space_id, uint32_t index_id, const char *key, const char *key_end, box_tuple_t **result)

    Return a first (minimal) tuple matched the provided key.

    :param uint32_t    space_id: space identifier
    :param uint32_t    index_id: index identifier
    :param const char*      key: encode key in MsgPack Array format ([part1, part2, ...])
    :param const char*  key_end: the end of encoded ``key``
    :param box_tuple_t** result: output argument. result a tuple or NULL if
                                 there is no tuples in space

    :return: -1 on error (check :ref:`box_error_last() <c_api-error-box_error_last>`)
    :return: 0 on success

    See also: :ref:`index_object.min()<box_index-min>`

.. c:function:: int box_index_max(uint32_t space_id, uint32_t index_id, const char *key, const char *key_end, box_tuple_t **result)

    Return a last (maximal) tuple matched the provided key.

    :param uint32_t    space_id: space identifier
    :param uint32_t    index_id: index identifier
    :param const char*      key: encode key in MsgPack Array format ([part1, part2, ...])
    :param const char*  key_end: the end of encoded ``key``
    :param box_tuple_t** result: output argument. result a tuple or NULL if
                                 there is no tuples in space

    :return: -1 on error (check :ref:`box_error_last() <c_api-error-box_error_last>`)
    :return: 0 on success

    See also: :ref:`index_object.max()<box_index-max>`

.. c:function:: ssize_t box_index_count(uint32_t space_id, uint32_t index_id, int type, const char *key, const char *key_end)

    Count the number of tuple matched the provided key.

    :param uint32_t   space_id: space identifier
    :param uint32_t   index_id: index identifier
    :param int            type: :ref:`iterator_type<c_api-box_index-iterator_type>`
    :param const char*     key: encode key in MsgPack Array format ([part1, part2, ...])
    :param const char* key_end: the end of encoded ``key``

    :return: -1 on error (check :ref:`box_error_last() <c_api-error-box_error_last>`)
    :return: 0 on success

    See also: :ref:`index_object.count()<box_index-count>`


.. c:function:: const box_key_def_t *box_index_key_def(uint32_t space_id, uint32_t index_id)

    Return :ref:`key definition <capi-tuple_key_def>` for an index

    Returned object is valid until the next yield.

    :param uint32_t space_id: space identifier
    :param uint32_t index_id: index identifier

    :return: key definition on success
    :return: NULL on error

    See also: :ref:`box_tuple_compare() <capi-tuple_box_tuple_compare>`,
              :ref:`box_tuple_format_new() <capi-tuple_box_tuple_format_new>`

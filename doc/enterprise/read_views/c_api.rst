.. _read_views_c_api:

Read views: C API
=================

This topic describes the C API for working with :ref:`read views <read_views>`.
The C API is MT-safe and provides the ability to use a read view from any thread,
not only from the :ref:`main (TX) thread <thread_model>`.

The C API has the following specifics:

*   The :ref:`space.upgrade <enterprise-space_upgrade>` function is not applied to retrieved tuples even if a space upgrade is in progress.

*   Tuples stored in :ref:`compressed spaces <tuple_compression>` are not decompressed - they are returned as :ref:`raw MessagePack <msgpack-module>` (``MP_EXT/MP_COMPRESSION``).

..  note::

    You can learn how to call C code using stored procedures in the
    :ref:`C tutorial<f_c_tutorial-c_stored_procedures>`.


.. _data_types:

Data types
----------

The opaque data types below represent raw read views and an iterator over data in a raw read view.
Note that there is no special data type for tuples retrieved from a read view.
Tuples are returned as raw MessagePack data (``const char *``).

..  c:type:: box_raw_read_view box_raw_read_view_t

    A raw database read view.

..  c:type:: box_raw_read_view_space box_raw_read_view_space_t

    A space in a raw read view.

..  c:type:: box_raw_read_view_index box_raw_read_view_index_t

    An index in a raw read view.

..  c:type:: box_raw_read_view_iterator box_raw_read_view_iterator_t

    An iterator over data in a raw read view.



.. _creating_destroying_read_views:

Creating and destroying read views
----------------------------------

To create or destroy a read view, use the functions below.

.. _box_raw_read_view_new:

..  c:function:: box_raw_read_view_t * box_raw_read_view_new(const char *name)

    Open a raw read view with the specified name and get a pointer to this read view.
    In the case of error, returns ``NULL`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`.
    This function may be called from the main (TX) thread only.

    :param const char *name: (optional) a read view name; if ``name`` is not specified, a read view name is set to ``unknown``

    :return: a pointer to a read view


.. _box_raw_read_view_delete:

..  c:function:: void box_raw_read_view_delete(box_raw_read_view_t *rv)

    Close a raw read view and release all resources associated with it.
    This function may be called from the main (TX) thread only.

    :param box_raw_read_view_t *rv: a pointer to a read view


.. NOTE::

    Read views created using ``box_raw_read_view_new`` are displayed in :ref:`box.read_view.list() <reference_lua-box_read_view_list>` along with read views :ref:`created in Lua <box-read_view-open>`.


.. _spaces_and_indexes:

Spaces and indexes
------------------

To fetch data from a read view, you need to specify an index to fetch the data from.
The following functions are available for looking up spaces and indexes in a read view object.


.. _box_raw_read_view_space_by_id:

..  c:function:: box_raw_read_view_space_t * box_raw_read_view_space_by_id(const box_raw_read_view_t *rv, uint32_t space_id)

    Find a space by ID in a raw read view.
    If not found, returns ``NULL`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`.

    :param const box_raw_read_view_t *rv: a pointer to a read view
    :param uint32_t space_id: a space identifier

    :return: a pointer to a space


.. _box_raw_read_view_space_by_name:

..  c:function:: box_raw_read_view_space_t * box_raw_read_view_space_by_name(const box_raw_read_view_t *rv, const char *space_name, uint32_t space_name_len)

    Find a space by name in a raw read view.
    If not found, returns ``NULL`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`.

    :param const box_raw_read_view_t *rv: a pointer to a read view
    :param const char *space_name: a space name
    :param uint32_t space_name_len: a space name length

    :return: a pointer to a space


.. _box_raw_read_view_index_by_id:

..  c:function:: box_raw_read_view_index_t * box_raw_read_view_index_by_id(const box_raw_read_view_space_t *space, uint32_t index_id)

    Find an index by ID in a read view's space.
    If not found, returns ``NULL`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`.

    :param const box_raw_read_view_space_t *space: a pointer to a read view's space
    :param uint32_t space_id: a space identifier

    :return: a pointer to an index


.. _box_raw_read_view_index_by_name:

..  c:function:: box_raw_read_view_index_t * box_raw_read_view_index_by_name(const box_raw_read_view_space_t *space, const char *index_name, uint32_t index_name_len)

    Find an index by name in a read view's space.
    If not found, returns ``NULL`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`.

    :param const box_raw_read_view_space_t *space: a pointer to a space
    :param const char *index_name: an index name
    :param uint32_t index_name_len: an index name length

    :return: a pointer to an index



.. _iteration_and_lookup:

Iteration and lookup
--------------------

The functions below provide the ability to look up a tuple by the key or create an iterator over a read view index.

.. NOTE::

    Methods of the read view iterator are safe to call from any thread, but they may be used in one thread at the same time. This means that an iterator should be thread-local.


.. _box_raw_read_view_get:

..  c:function:: int box_raw_read_view_get(const box_raw_read_view_index_t *index, const char *key, const char *key_end, const char **data, uint32_t *size)

    Look up a tuple in a read view's index.
    If found, the ``data`` and ``size`` out arguments return a pointer to and the size of tuple data.
    If not found, ``*data`` is set to ``NULL`` and ``*size`` is set to ``0``.

    :param const box_raw_read_view_index_t *index: a pointer to a read view's index
    :param const char *key: a pointer to the first byte of the MsgPack data that represents the search key
    :param const char *key_end: a pointer to the byte following the last byte of the MsgPack data that represents the search key
    :param const char **data: a pointer to the tuple data
    :param uint32_t *size: the size of tuple data

    :return: ``0`` on success; in the case of error, returns ``-1`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`




.. _box_raw_read_view_iterator_create:

..  c:function:: int box_raw_read_view_iterator_create(box_raw_read_view_iterator_t *it, const box_raw_read_view_index_t *index, int type, const char *key, const char *key_end)

    Create an iterator over a raw read view index.
    The initialized iterator object returned by this function remains valid and may be safely used until it's destroyed or the read view is closed.
    When the iterator object is no longer needed, it should be destroyed using
    :ref:`box_raw_read_view_iterator_destroy() <box_raw_read_view_iterator_destroy>`.

    :param box_raw_read_view_iterator_t *it: an iterator over a raw read view index
    :param const box_raw_read_view_index_t *index: a pointer to a read view index
    :param int type: an iteration direction represented by the :ref:`iterator_type <c_api-box_index-iterator_type>`
    :param const char *key: a pointer to the first byte of the MsgPack data that represents the search key
    :param const char *key_end: a pointer to the byte following the last byte of the MsgPack data that represents the search key

    :return: ``0`` on success; in the case of error, returns ``-1`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`



.. _box_raw_read_view_iterator_next:

..  c:function:: int box_raw_read_view_iterator_next(box_raw_read_view_iterator_t *it, const char **data, uint32_t *size)

    Retrieve the current tuple and advance the given iterator over a raw read view index.
    The pointer to and the size of tuple data are returned in the ``data`` and the ``size`` out arguments.
    The data returned by this function remains valid and may be safely used until the read view is closed.

    :param box_raw_read_view_iterator_t *it: an iterator over a read view index
    :param const char **data: a pointer to the tuple data; at the end of iteration, ``*data`` is set to ``NULL``
    :param uint32_t *size: the size of tuple data; at the end of iteration, ``*size`` is set to ``0``

    :return: ``0`` on success; in the case of error, returns ``-1`` and sets :ref:`box_error_last()<c_api-error-box_error_last>`



.. _box_raw_read_view_iterator_destroy:

..  c:function:: void box_raw_read_view_iterator_destroy(box_raw_read_view_iterator_t *it)

    Destroy an iterator over a raw read view index.
    The iterator object should not be used after calling this function,
    but the data returned by the iterator may be safely dereferenced until the read view is closed.

    :param box_raw_read_view_iterator_t *it: an iterator over a read view index





.. _space_format:

Space format
------------

A space object's methods below provide the ability to get names and types of space fields.


.. _box_raw_read_view_space_field_count:

..  c:function:: uint32_t box_raw_read_view_space_field_count(const box_raw_read_view_space_t *space)

    Get the number of fields defined in the format of a read view space.

    :param const box_raw_read_view_space_t *space: a pointer to a read view space

    :return: the number of fields



.. _box_raw_read_view_space_field_name:

..  c:function:: const char * box_raw_read_view_space_field_name(const box_raw_read_view_space_t *space, uint32_t field_no)

    Get the name of a field defined in the format of a read view space.
    If the field number is greater than the total number of fields defined in the format, ``NULL`` is returned.
    The string returned by this function is guaranteed to remain valid until the read view is closed.

    :param const box_raw_read_view_space_t *space: a pointer to a read view space
    :param uint32_t field_no: the field number (starts with ``0``)

    :return: the name of a field



.. _box_raw_read_view_space_field_type:

..  c:function:: const char * box_raw_read_view_space_field_type(const box_raw_read_view_space_t *space, uint32_t field_no)

    Get the type of a field defined in the format of a read view space.
    If the field number is greater than the total number of fields defined in the format, ``NULL`` is returned.
    The string returned by this function is guaranteed to remain valid until the read view is closed.

    :param const box_raw_read_view_space_t *space: a pointer to a read view space
    :param uint32_t field_no: the field number (starts with ``0``)

    :return: the type of a field

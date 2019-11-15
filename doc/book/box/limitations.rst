.. _limitations_fields_in_index:

================================================================================
Limitations
================================================================================

**Number of parts in an index**

    For TREE or HASH indexes, the maximum
    is 255 (``box.schema.INDEX_PART_MAX``). For :ref:`RTREE <box_index-rtree>` indexes, the
    maximum is 1 but the field is an ARRAY of up to 20 dimensions.
    For BITSET indexes, the maximum is 1.

.. _limitations_indexes_in_space:

**Number of indexes in a space**

    128 (``box.schema.INDEX_MAX``).

.. _limitations_fields_in_tuple:

**Number of fields in a tuple**

    The theoretical maximum is 2,147,483,647 (``box.schema.FIELD_MAX``). The
    practical maximum is whatever is specified by the space's
    :ref:`field_count <box_space-field_count>`
    member, or the maximal tuple length.

.. _limitations_bytes_in_tuple:

**Number of bytes in a tuple**

    The maximal number of bytes in a tuple is roughly equal to
    :ref:`memtx_max_tuple_size <cfg_storage-memtx_max_tuple_size>` or
    :ref:`vinyl_max_tuple_size <cfg_storage-vinyl_max_tuple_size>`
    (with a metadata
    overhead of about 20 bytes per tuple, which is added on top of useful bytes).
    By default, the value of either ``memtx_max_tuple_size`` or
    ``vinyl_max_tuple_size`` is 1,048,576. To increase it,
    specify a larger value when starting the Tarantool instance.
    For example, ``box.cfg{memtx_max_tuple_size=2*1048576}``.

.. _limitations_bytes_in_index_key:

**Number of bytes in an index key**

    If a field in a tuple can contain a million bytes, then the index key
    can contain a million bytes, so the maximum is determined by factors
    such as :ref:`Number of bytes in a tuple <limitations_bytes_in_tuple>`,
    not by the index support.

.. _limitations_number_of_spaces:

**Number of spaces**

    The theoretical maximum is 2147483647 (``box.schema.SPACE_MAX``)
    but the practical maximum is around 65,000.

.. _limitations_number_of_connections:

**Number of connections**

    The practical limit is the number of file descriptors that one can set
    with the operating system.

.. _limitations_space_size:

**Space size**

    The total maximum size for all spaces is in effect set by
    :ref:`memtx_memory <cfg_storage-memtx_memory>`, which in turn
    is limited by the total available memory.

.. _limitations_update_ops:

**Update operations count**

    The maximum number of operations per tuple that can be in a single update
    is 4000 (``BOX_UPDATE_OP_CNT_MAX``).

.. _limitations_users_and_roles:

**Number of users and roles**

    32 (``BOX_USER_MAX``).

.. _limitations_length:

**Length of an index name or space name or user name**

    65000 (``box.schema.NAME_MAX``).

.. _limitations_replicas:

**Number of replicas in a replica set**

    32 (``vclock.VCLOCK_MAX``).

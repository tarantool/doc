.. _limitations_fields_in_index:

================================================================================
Limitations
================================================================================

**Number of parts in an index**

    For TREE or HASH indexes, the maximum
    is 255 (``box.schema.INDEX_PART_MAX``). For RTREE indexes, the
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
    :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal>` (with a metadata
    overhead of about 20 bytes per tuple, which is added on top of useful bytes).
    By default, the value of ``slab_alloc_maximal`` is 1,048,576. To increase it,
    specify a larger value when starting the server.
    For example, ``box.cfg{slab_alloc_maximal=2*1048576}``.

.. _limitations_slab_size:

**Slab size**

    The maximal size of an allocatable memory unit (slab) is equal to one quarter
    of :ref:`slab_alloc_maximal <cfg_storage-slab_alloc_maximal>` (by default,
    approximately 262,000 bytes). To see memory usage statistics broken down by
    slab size, use :ref:`box.slab.stats() <box_slab_stats>`.

.. _limitations_bytes_in_index_key:

**Number of bytes in an index key**

    If a field in a tuple can contain a million bytes, then the index key
    can contain a million bytes, so the maximum is determined by factors
    such as :ref:`Number of bytes in a tuple <limitations_bytes_in_tuple>`,
    not by the index support.

.. _limitations_number_of_spaces:

**Number of spaces**

    The theoretical maximum is 65,000 (``box.schema.SPACE_MAX``).

.. _limitations_number_of_connections:

**Number of connections**

    The practical limit is the number of file descriptors that one can set
    with the operating system.

.. _limitations_space_size:

**Space size**

    The total maximum size for all spaces is in effect set by
    :ref:`slab_alloc_arena <cfg_storage-slab_alloc_arena>`, which in turn
    is limited by the total available memory.

.. _limitations_update_ops:

**Update operations count**

    The maximum number of operations that can be in a single update
    is 4000 (``BOX_UPDATE_OP_CNT_MAX``).

.. _limitations_users_and_roles:

**Number of users and roles**

    32 (BOX_USER_MAX).

.. _limitations_length:

**Length of an index name or space name or user name**

    32 (``box.schema.NAME_MAX``).

.. _limitations_replicas:

**Number of replicas in a cluster**

    32 (``box.schema.REPLICA_MAX``).

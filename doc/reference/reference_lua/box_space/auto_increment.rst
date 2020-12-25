.. _box_space-auto_increment:

===============================================================================
space_object:auto_increment()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: auto_increment(tuple)

        Insert a new tuple using an auto-increment primary key. The space
        specified by space_object must have an
        :ref:`'unsigned' or 'integer' or 'number' <index-box_indexed-field-types>`
        primary key index of type ``TREE``. The primary-key field
        will be incremented before the insert.

        Since version 1.7.5 this method is deprecated – it is better to use a
        :ref:`sequence <index-box_sequence>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param table/tuple         tuple: tuple's fields, other than the
                                          primary-key field

        :return: the inserted tuple.
        :rtype:  tuple

        **Complexity factors:** Index size, Index type,
        Number of indexes accessed, :ref:`WAL settings <cfg_binary_logging_snapshots-rows_per_wal>`.

        **Possible errors:**

        * index has wrong type;
        * primary-key indexed field is not a number.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:auto_increment{'Fld#1', 'Fld#2'}
            ---
            - [1, 'Fld#1', 'Fld#2']
            ...
            tarantool> box.space.tester:auto_increment{'Fld#3'}
            ---
            - [2, 'Fld#3']
            ...

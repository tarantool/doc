.. _box_index-parts:

===============================================================================
index_object:parts()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. data:: parts

        An array describing the index fields. To learn more about the index field
        types, refer to :ref:`this table <box_space-index_field_types>`.

        :rtype: table

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary
            ---
            - unique: true
              parts:
              - type: unsigned
                is_nullable: false
                fieldno: 1
              id: 0
              space_id: 513
              name: primary
              type: TREE
            ...

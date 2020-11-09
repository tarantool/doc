.. _box_space-field_count:

===============================================================================
space_object:field_count
===============================================================================

.. module:: box.space

.. class:: space_object

    .. data:: field_count

        The required field count for all tuples in this space. The field_count
        can be set initially with:

        .. cssclass:: highlight
        .. parsed-literal::

            box.schema.space.create(..., {
                ... ,
                field_count = *field_count_value* ,
                ...
            })

        The default value is ``0``, which means there is no required field count.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester.field_count
            ---
            - 0
            ...

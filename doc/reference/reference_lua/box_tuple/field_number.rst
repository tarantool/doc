
.. _box_tuple-field_number:

================================================================================
tuple_object[field-number]
================================================================================

.. class:: tuple_object

    .. operator:: tuple_object[field-number]

        If ``t`` is a tuple instance, ``t[field-number]`` will return the field
        numbered field-number in the tuple. The first field is ``t[1]``.

        :return: field value.
        :rtype:  lua-value

        In the following example, a tuple named ``t`` is created and then the
        second field in ``t`` is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4'}
            ---
            ...
            tarantool> t[2]
            ---
            - Fld#2
            ...

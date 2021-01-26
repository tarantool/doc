
.. _box_tuple-count_fields:

================================================================================
#tuple_object
================================================================================

.. class:: tuple_object

    .. operator:: #tuple_object

        The ``#`` operator in Lua means "return count of components". So,
        if ``t`` is a tuple instance, ``#t`` will return the number of fields.

        :rtype: number

        In the following example, a tuple named ``t`` is created and then the
        number of fields in ``t`` is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4'}
            ---
            ...
            tarantool> #t
            ---
            - 4
            ...

.. _box_tuple-find:

================================================================================
tuple_object:find(), tuple_object:findall()
================================================================================

.. class:: tuple_object

    .. method:: find([field-number, ] search-value)
                findall([field-number, ] search-value)

        If ``t`` is a tuple instance, ``t:find(search-value)`` will return the
        number of the first field in ``t`` that matches the search value,
        and ``t:findall(search-value [, search-value ...])`` will return numbers
        of all fields in ``t`` that match the search value. Optionally one can
        put a numeric argument ``field-number`` before the search-value to
        indicate “start searching at field number ``field-number``.”

        :return: the number of the field in the tuple.
        :rtype:  number

        In the following example, a tuple named ``t`` is created and then: the
        number of the first field in ``t`` which matches 'a' is returned, then
        the numbers of all the fields in ``t`` which match 'a' are returned,
        then the numbers of all the fields in t which match 'a' and are at or
        after the second field are returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'a', 'b', 'c', 'a'}
            ---
            ...
            tarantool> t:find('a')
            ---
            - 1
            ...
            tarantool> t:findall('a')
            ---
            - 1
            - 4
            ...
            tarantool> t:findall(2, 'a')
            ---
            - 4
            ...

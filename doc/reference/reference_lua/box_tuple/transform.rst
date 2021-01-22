
.. _box_tuple-transform:

================================================================================
tuple_object:transform()
================================================================================

.. module:: box.tuple

.. class:: tuple_object

    .. method:: transform(start-field-number, fields-to-remove [, field-value, ...])

        If ``t`` is a tuple instance,
        :samp:`t:transform({start-field-number},{fields-to-remove})`
        will return a tuple where, starting from field ``start-field-number``,
        a number of fields (``fields-to-remove``) are removed. Optionally one
        can add more arguments after ``fields-to-remove`` to indicate new
        values that will replace what was removed.

        If the original tuple comes from a space that has been formatted with a
        :ref:`format clause <box_space-format>`, the formatting will not be
        preserved for the result tuple.

        :param integer start-field-number: base 1, may be negative
        :param integer   fields-to-remove:
        :param lua-value   field-value(s):
        :return: tuple
        :rtype:  tuple

        In the following example, a tuple named ``t`` is created and then,
        starting from the second field, two fields are removed but one new
        one is added, then the result is returned.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> t:transform(2, 2, 'x')
            ---
            - ['Fld#1', 'x', 'Fld#4', 'Fld#5']
            ...
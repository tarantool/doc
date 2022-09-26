.. _box_space-update:

===============================================================================
space_object:update()
===============================================================================

.. class:: space_object

    .. method:: update(key, {{operator, field_identifier, value}, ...})

        Update a tuple.

        The ``update`` function supports operations on fields — assignment,
        arithmetic (if the field is numeric), cutting and pasting
        fragments of a field, deleting or inserting a field. Multiple
        operations can be combined in a single update request, and in this
        case they are performed atomically and sequentially. Each operation
        requires specification of a field identifier, which is usually a number. When multiple operations
        are present, the field number for each operation is assumed to be
        relative to the most recent state of the tuple, that is, as if all
        previous operations in a multi-operation update have already been
        applied. In other words, it is always safe to merge multiple ``update``
        invocations into a single invocation, with no change in semantics.

        Possible operators are:

        * ``+`` for addition. values must be numeric, e.g. unsigned or decimal
        * ``-`` for subtraction. values must be numeric
        * ``&`` for bitwise AND. values must be unsigned numeric
        * ``|`` for bitwise OR. values must be unsigned numeric
        * ``^`` for bitwise :abbr:`XOR(exclusive OR)`. values must be
          unsigned numeric
        * ``:`` for string splice.
        * ``!`` for insertion of a new field.
        * ``#`` for deletion.
        * ``=`` for assignment.

        Possible field_identifiers are:

            * Positive field number. The first field is 1, the second field is 2,
              and so on.
            * Negative field number. The last field is -1, the second-last field
              is -2, and so on. In other words: (#tuple + negative field number + 1).
            * Name. If the space was formatted with
              :doc:`/reference/reference_lua/box_space/format`, then this can
              be a string for the field 'name'.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table key: primary-key field values, must be passed as a
                                 Lua table if key is multi-part
        :param string  operator: operation type represented in string
        :param number-or-string  field_identifier: what field the operation will apply to.
        :param lua_value  value: what value will be applied

        :return: * the updated tuple
                 * nil if the key is not found
        :rtype:  tuple or nil

        **Possible errors:**

        *   It is illegal to modify a primary key field.
        *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
            :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

        **Complexity factors:** Index size, Index type, number of indexes
        accessed, WAL settings.

        Thus, in the instruction:

        .. code-block:: lua

            s:update(44, {{'+', 1, 55 }, {'=', 3, 'x'}})

        the primary-key value is ``44``, the operators are ``'+'`` and ``'='``
        meaning *add a value to a field and then assign a value to a field*, the
        first affected field is field ``1`` and the value which will be added to
        it is ``55``, the second affected field is field ``3`` and the value
        which will be assigned to it is ``'x'``.

        **Example:**

        Assume that initially there is a space named ``tester`` with a
        primary-key index whose type is ``unsigned``. There is one tuple, with
        ``field[1]`` = ``999`` and ``field[2]`` = ``'A'``.

        In the update: |br|
        ``box.space.tester:update(999, {{'=', 2, 'B'}})`` |br|
        The first argument is ``tester``, that is, the affected space is ``tester``.
        The second argument is ``999``, that is, the affected tuple is identified by
        primary key value = 999.
        The third argument is ``=``, that is, there is one operation —
        *assignment to a field*.
        The fourth argument is ``2``, that is, the affected field is ``field[2]``.
        The fifth argument is ``'B'``, that is, ``field[2]`` contents change to ``'B'``.
        Therefore, after this update, ``field[1]`` = ``999`` and ``field[2]`` = ``'B'``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'=', 2, 'B'}})`` |br|
        the arguments are the same, except that the key is passed as a Lua table
        (inside braces). This is unnecessary when the primary key has only one
        field, but would be necessary if the primary key had more than one field.
        Therefore, after this update, ``field[1]`` = ``999`` and ``field[2]`` = ``'B'`` (no change).

        In the update: |br|
        ``box.space.tester:update({999}, {{'=', 3, 1}})`` |br|
        the arguments are the same, except that the fourth argument is ``3``,
        that is, the affected field is ``field[3]``. It is okay that, until now,
        ``field[3]`` has not existed. It gets added. Therefore, after this update,
        ``field[1]`` = ``999``, ``field[2]`` = ``'B'``, ``field[3]`` = ``1``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'+', 3, 1}})`` |br|
        the arguments are the same, except that the third argument is ``'+'``,
        that is, the operation is addition rather than assignment. Since
        ``field[3]`` previously contained ``1``, this means we're adding ``1``
        to ``1``. Therefore, after this update, ``field[1]`` = ``999``,
        ``field[2]`` = ``'B'``, ``field[3]`` = ``2``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'|', 3, 1}, {'=', 2, 'C'}})`` |br|
        the idea is to modify two fields at once. The formats are ``'|'`` and
        ``=``, that is, there are two operations, OR and assignment. The fourth
        and fifth arguments mean that ``field[3]`` gets OR'ed with ``1``. The
        seventh and eighth arguments mean that ``field[2]`` gets assigned ``'C'``.
        Therefore, after this update, ``field[1]`` = ``999``, ``field[2]`` = ``'C'``,
        ``field[3]`` = ``3``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'#', 2, 1}, {'-', 2, 3}})`` |br|
        The idea is to delete ``field[2]``, then subtract ``3`` from ``field[3]``.
        But after the delete, there is a renumbering, so ``field[3]`` becomes
        ``field[2]`` before we subtract ``3`` from it, and that's why the
        seventh argument is ``2``, not ``3``. Therefore, after this update,
        ``field[1]`` = ``999``, ``field[2]`` = ``0``.

        In the update: |br|
        ``box.space.tester:update({999}, {{'=', 2, 'XYZ'}})`` |br|
        we're making a long string so that splice will work in the next example.
        Therefore, after this update, ``field[1]`` = ``999``, ``field[2]`` = ``'XYZ'``.

        In the update: |br|
        ``box.space.tester:update({999}, {{':', 2, 2, 1, '!!'}})`` |br|
        The third argument is ``':'``, that is, this is the example of splice.
        The fourth argument is ``2`` because the change will occur in ``field[2]``.
        The fifth argument is 2 because deletion will begin with the second byte.
        The sixth argument is 1 because the number of bytes to delete is 1.
        The seventh argument is ``'!!'``, because ``'!!'`` is to be added at this position.
        Therefore, after this update, ``field[1]`` = ``999``, ``field[2]`` = ``'X!!Z'``.

        For more usage scenarios and typical errors see
        :ref:`Example: using data operations <box_space-operations-detailed-examples>`
        further in this section.

        Since Tarantool 2.3 a tuple can also be updated via :ref:`JSON paths<json_paths-module>`.

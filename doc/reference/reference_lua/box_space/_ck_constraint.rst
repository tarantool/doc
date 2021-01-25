.. _box_space-ck_constraint:

===============================================================================
box.space._ck_constraint
===============================================================================

.. module:: box.space

.. data:: _ck_constraint

    ``_ck_constraint`` is a system space where check constraints are stored.

    Tuples in this space contain the following fields:

    * the numeric id of the space ("space_id"),
    * the name,
    * whether the check is deferred ("is_deferred"),
    * the language of the expression, such as 'SQL',
    * the expression ("code")

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.space._ck_constraint:select()
        ---
        - - [527, 'c1', false, 'SQL', '"f2" > ''A''']
          - [527, 'c2', false, 'SQL', '"f2" == UPPER("f3") AND NOT "f2" LIKE ''__''']
        ...
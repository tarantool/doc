.. _box_space-create_check_constraint:

===============================================================================
box.space.create_check_constraint()
===============================================================================

.. warning::

    This function was removed in :doc:`2.11.0 </release/2.11.0>`.
    The check constraint mechanism is replaced with the new tuple constraints.
    Learn more about tuple constraints in :ref:`Constraints <index-constraints>`.


.. class:: space_object

    .. method:: create_check_constraint(check_constraint_name, expression)

        Create a check constraint.
        A check constraint is a requirement that must be met when a tuple
        is inserted or updated in a space.
        Check constraints created with ``space_object:create_check_constraint`` have
        the same effect as check constraints created with an SQL CHECK() clause
        in a :ref:`CREATE TABLE statement <sql_create_table>`.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param string check_constraint_name: name of check constraint, which should conform to the
                                             :ref:`rules for object names <app_server-names>`
        :param string expression: SQL code of an expression which must return a boolean result

        :return: check constraint object
        :rtype:  check_constraint_object

        The space must be formatted with :doc:`/reference/reference_lua/box_space/format`
        so that the expression can contain field names.
        The space must be empty. The space must not be a system space.

        The expression must return true or false and should be deterministic.
        The expression may be any SQL (not Lua) expression containing field names,
        built-in function names, literals, and operators. Not subqueries.
        If a field name contains lower case characters, it must be enclosed in "double quotes".

        Check constraints are checked before the request is performed,
        at the same time as Lua
        :doc:`before_replace triggers </reference/reference_lua/box_space/before_replace>`.
        If there is more than one check constraint or before_replace trigger,
        then they are ordered according to time of creation.
        (This is a change from the earlier behavior of check constraints,
        which caused checking before the tuple was formed.)

        Check constraints can be dropped with :samp:`{space_object}.ck_constraint.{check_constraint_name}:drop()`.

        Check constraints can be disabled with :samp:`{space_object}.ck_constraint.{check_constraint_name}:enable(false)`
        or :samp:`{check_constraint_object}:enable(false)`.
        Check constraints can be enabled with :samp:`{space_object}.ck_constraint.{check_constraint_name}:enable(true)`
        or :samp:`{check_constraint_object}:enable(true)`.
        By default a check constraint is 'enabled' which means that the check is performed
        whenever the request is performed, but can be changed to 'disabled' which means that
        the check is not performed.

        During the recovery process, for example when the Tarantool server is starting,
        the check is not performed unless
        :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`
        is specified.

        **Example:**

        .. code-block:: lua

            box.schema.space.create('t')
            box.space.t:format({{name = 'f1', type = 'unsigned'},
                                {name = 'f2', type = 'string'},
                                {name = 'f3', type = 'string'}})
            box.space.t:create_index('i')
            box.space.t:create_check_constraint('c1', [["f2" > 'A']])
            box.space.t:create_check_constraint('c2',
                                    [["f2"=UPPER("f3") AND NOT "f2" LIKE '__']])
            -- This insert will fail, constraint c1 expression returns false
            box.space.t:insert{1, 'A', 'A'}
            -- This insert will fail, constraint c2 expression returns false
            box.space.t:insert{1, 'B', 'c'}
            -- This insert will succeed, both constraint expressions return true
            box.space.t:insert{1, 'B', 'b'}
            -- This update will fail, constraint c2 expression returns false
            box.space.t:update(1, {{'=', 2, 'xx'}, {'=', 3, 'xx'}})

        A list of check constraints is in :doc:`/reference/reference_lua/box_space/_ck_constraint`.

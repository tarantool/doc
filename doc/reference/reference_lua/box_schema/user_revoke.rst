.. _box_schema-user_revoke:

===============================================================================
box.schema.user.revoke()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.revoke(user-name, privileges, object-type, object-name[, {options} ])
              box.schema.user.revoke(user-name, privileges, 'universe'[, nil, {options} ])
              box.schema.user.revoke(user-name, role-name[, nil, nil, {options} ])

    Revoke :ref:`privileges <authentication-owners_privileges>` from a user
    or from another role.

    :param string user-name: the name of the user.
    :param string privilege: 'read' or 'write' or 'execute' or 'create' or
                             'alter' or 'drop' or a combination.
    :param string object-type: 'space' or 'function' or 'sequence'.
    :param string object-name: the name of a function or space or sequence.
    :param table      options: ``if_exists``.

    The user must exist, and the object must exist,
    but if the option setting is ``{if_exists=true}`` then
    it is not an error if the user does not have the privilege.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` (see section :ref:`Roles <authentication-roles>`).

    **Variation:** instead of
    :samp:`box.schema.user.revoke('{user-name}','usage,session','universe',nil,` :code:`{if_exists=true})`
    say :samp:`box.schema.user.disable('{user-name}')`.

    **Example:**

    .. code-block:: lua

        box.schema.user.revoke('Lena', 'read', 'space', 'tester')
        box.schema.user.revoke('Lena', 'execute', 'function', 'f')
        box.schema.user.revoke('Lena', 'read,write', 'universe')
        box.schema.user.revoke('Lena', 'Accountant')

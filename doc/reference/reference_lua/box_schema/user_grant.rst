.. _box_schema-user_grant:

===============================================================================
box.schema.user.grant()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.grant(user-name, privileges, object-type, object-name[, {options} ])
              box.schema.user.grant(user-name, privileges, 'universe'[, nil, {options} ])
              box.schema.user.grant(user-name, role-name[, nil, nil, {options} ])

    Grant :ref:`privileges <authentication-owners_privileges>` to a user or
    to another role.

    :param string   user-name: the name of the user.
    :param string  privileges: 'read' or 'write' or 'execute' or 'create' or
                               'alter' or 'drop' or a combination.
    :param string object-type: 'space' or 'function' or 'sequence' or 'role'.
    :param string object-name: name of object to grant permissions for.
    :param string   role-name: name of role to grant to user.
    :param table      options: ``grantor``, ``if_not_exists``.

    If :samp:`'function','{object-name}'` is specified, then a _func tuple with
    that object-name must exist.

    **Variation:** instead of ``object-type, object-name`` say 'universe' which
    means 'all object-types and all objects'. In this case, object name is omitted.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` (see section :ref:`Roles <authentication-roles>`).

    **Variation:** instead of
    :samp:`box.schema.user.grant('{user-name}','usage,session','universe',nil,` :code:`{if_not_exists=true})`
    say :samp:`box.schema.user.enable('{user-name}')`.

    The possible options are:

    * ``grantor`` = *grantor_name_or_id* -- string or number, for custom grantor,
    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means there should be no error if the user already has the privilege.

    **Example:**

    .. code-block:: lua

        box.schema.user.grant('Lena', 'read', 'space', 'tester')
        box.schema.user.grant('Lena', 'execute', 'function', 'f')
        box.schema.user.grant('Lena', 'read,write', 'universe')
        box.schema.user.grant('Lena', 'Accountant')
        box.schema.user.grant('Lena', 'read,write,execute', 'universe')
        box.schema.user.grant('X', 'read', 'universe', nil, {if_not_exists=true})

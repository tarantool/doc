.. _box_schema-user_grant:

===============================================================================
box.schema.user.grant()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.grant(username, permissions, object-type, object-name[, {options} ])
              box.schema.user.grant(username, permissions, 'universe'[, nil, {options} ])
              box.schema.user.grant(username, role-name[, nil, nil, {options} ])

    Grant :ref:`privileges <authentication-owners_privileges>` to a user or
    to another role.

    :param string   username: the name of a user to grant privileges to
    :param string  permissions: one or more :ref:`permissions <access_control_list_privileges>` to grant to the user (for example, ``read`` or ``read,write``)
    :param string object-type: a database :ref:`object type <access_control_list_objects>` to grant permissions to (for example, ``space``, ``role``, or ``function``)
    :param string object-name: the name of a database object to grant permissions to
    :param string   role-name: the name of a role to grant to the user
    :param table      options: ``grantor``, ``if_not_exists``

    If :samp:`'function','{object-name}'` is specified, then a _func tuple with
    that object-name must exist.

    **Variation:** instead of ``object-type, object-name`` say ``universe`` which
    means 'all object-types and all objects'. In this case, object name is omitted.

    **Variation:** instead of ``permissions, object-type, object-name`` say
    ``role-name`` (see section :ref:`Roles <authentication-roles>`).

    **Variation:** instead of
    :samp:`box.schema.user.grant('{username}','usage,session','universe',nil,` :code:`{if_not_exists=true})`
    say :samp:`box.schema.user.enable('{username}')`.

    The possible options are:

    * ``grantor`` = *grantor_name_or_id* -- string or number, for custom grantor,
    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means there should be no error if the user already has the privilege.

    **Example:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
        :language: lua
        :start-after: Grant privileges to the specified user
        :end-before: End: Grant privileges to the specified user
        :dedent:

    See also: :ref:`access_control_users`.

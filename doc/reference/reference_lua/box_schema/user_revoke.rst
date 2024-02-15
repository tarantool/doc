.. _box_schema-user_revoke:

===============================================================================
box.schema.user.revoke()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.revoke(username, permissions, object-type, object-name[, {options} ])
              box.schema.user.revoke(username, permissions, 'universe'[, nil, {options} ])
              box.schema.user.revoke(username, role-name[, nil, nil, {options} ])

    Revoke :ref:`privileges <authentication-owners_privileges>` from a user
    or from another role.

    :param string username: the name of the user
    :param string permissions: one or more :ref:`permissions <access_control_list_privileges>` to revoke from the user (for example, ``read`` or ``read,write``)
    :param string object-type: a database :ref:`object type <access_control_list_objects>` to revoke permissions from (for example, ``space``, ``role``, or ``function``)
    :param string object-name: the name of a database object to revoke permissions from
    :param table      options: ``if_exists``

    The user must exist, and the object must exist,
    but if the option setting is ``{if_exists=true}`` then
    it is not an error if the user does not have the privilege.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'.

    **Variation:** instead of ``permissions, object-type, object-name`` say
    ``role-name`` (see section :ref:`Roles <authentication-roles>`).

    **Variation:** instead of
    :samp:`box.schema.user.revoke('{username}','usage,session','universe',nil,` :code:`{if_exists=true})`
    say :samp:`box.schema.user.disable('{username}')`.

    **Example:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
        :language: lua
        :start-after: Revoke space reading
        :end-before: End: Revoke space reading
        :dedent:

    See also: :ref:`access_control_users`.

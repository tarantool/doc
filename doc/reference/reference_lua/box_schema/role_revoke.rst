.. _box_schema-role_revoke:

===============================================================================
box.schema.role.revoke()
===============================================================================

.. module:: box.schema

.. function:: box.schema.role.revoke(role-name, privilege, object-type, object-name)

    Revoke :ref:`privileges <authentication-owners_privileges>` from a role.

    :param string role-name: the name of the role
    :param string privilege: one or more :ref:`privileges <access_control_list_privileges>` to revoke from the role (for example, ``read`` or ``read,write``)
    :param string object-type: a database :ref:`object type <access_control_list_objects>` to revoke privileges from (for example, ``space``, ``role``, or ``function``)
    :param string object-name: the name of a database object to revoke privileges from

    The role must exist, and the object must exist,
    but it is not an error if the role does not have the privilege.

    **Variation:** instead of ``object-type, object-name`` say ``universe``
    which means 'all object-types and all objects'.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name``.

    See also: :ref:`access_control_roles`.

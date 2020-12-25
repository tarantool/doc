.. _box_schema-user_passwd:

===============================================================================
box.schema.user.passwd()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.passwd([user-name,] password)

    Associate a password with the user who is currently logged in,
    or with the user specified by user-name. The user must exist and must not be 'guest'.

    Users who wish to change their own passwords should
    use ``box.schema.user.passwd(password)`` syntax.

    Administrators who wish to change passwords of other users should
    use ``box.schema.user.passwd(user-name, password)`` syntax.

    :param string user-name: user-name
    :param string password: password

    **Example:**

    .. code-block:: lua

        box.schema.user.passwd('ЛЕНА')
        box.schema.user.passwd('Lena', 'ЛЕНА')

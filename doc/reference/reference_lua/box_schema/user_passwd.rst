.. _box_schema-user_passwd:

===============================================================================
box.schema.user.passwd()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.passwd([name,] new_password)

    Sets a password for a currently logged in or a specified user:

    *   A currently logged in user can change their password using
        ``box.schema.user.passwd(new_password)``.

    *   An administrator can change the password of another user with
        ``box.schema.user.passwd(name, new_password)``.

    :param string user-name: name
    :param string password: new_password

    **Example:**

    .. code-block:: lua

        box.schema.user.passwd('foobar')
        box.schema.user.passwd('testuser', 'foobar')

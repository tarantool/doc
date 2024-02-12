.. _box_schema-user_passwd:

===============================================================================
box.schema.user.passwd()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.passwd([username,] password)

    Sets a password for a currently logged in or a specified user:

    *   A currently logged-in user can change their password using
        ``box.schema.user.passwd(password)``.

    *   An administrator can change the password of another user with
        ``box.schema.user.passwd(username, password)``.

    :param string username: a username
    :param string password: a new password

    **Example:**

    ..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
        :language: lua
        :start-after: Set a password for the specified user
        :end-before: End: Set a password for the specified user
        :dedent:

    See also: :ref:`access_control_users`.

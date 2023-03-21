.. _box_schema-user_password:

===============================================================================
box.schema.user.password()
===============================================================================

.. module:: box.schema

.. function:: box.schema.user.password(password)

    Return a hash of a user's password. For explanation of how Tarantool maintains
    passwords, see section :ref:`Passwords <authentication-passwords>` and reference on
    :ref:`_user <box_space-user>` space.

    .. NOTE::

       * If a non-'guest' user has no password, it’s **impossible** to connect
         to Tarantool using this user. The user is regarded as “internal” only,
         not usable from a remote connection. Such users can be useful if they
         have defined some procedures with the
         :doc:`SETUID </reference/reference_lua/box_schema/func_create>` option,
         on which privileges are granted to externally-connectable users.
         This way, external users cannot create/drop objects,
         they can only invoke procedures.

       * For the 'guest' user, it’s impossible to set a password: that would be misleading,
         since 'guest' is the default user on a newly-established connection over a
         :ref:`binary port <admin-security>`, and Tarantool does not require
         a password to establish a :ref:`binary connection <box_protocol-iproto_protocol>`.
         It is, however, possible to change the
         current user to ‘guest’ by providing the
         :ref:`AUTH packet <box_protocol-authentication>` with no password at all or an
         empty password. This feature is useful for connection pools, which want to reuse a
         connection for a different user without re-establishing it.

    :param string password: password to be hashed
    :rtype: string

    **Example:**

    .. code-block:: lua

        box.schema.user.password('foobar')

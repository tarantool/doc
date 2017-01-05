.. _box_schema:

-------------------------------------------------------------------------------
                             Submodule `box.schema`
-------------------------------------------------------------------------------

.. module:: box.schema

The ``box.schema`` submodule has data-definition functions
for spaces, users, roles, and function tuples.

.. _box_schema-space_create:

.. function:: box.schema.space.create(space-name [, {options}])

    Create a space.

    :param string space-name: name of space, which should not be a number
                                and should not contain special characters
    :param table options: see "Options for box.schema.space.create" chart, below

    :return: space object
    :rtype: userdata

    .. container:: table

        **Options for box.schema.space.create**

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4

        +---------------+--------------------------------+---------+---------------------+
        | Name          | Effect                         | Type    | Default             |
        +===============+================================+=========+=====================+
        | temporary     | space is temporary             | boolean | false               |
        +---------------+--------------------------------+---------+---------------------+
        | id            | unique identifier              | number  | last space's id, +1 |
        +---------------+--------------------------------+---------+---------------------+
        | field_count   | fixed field count              | number  | 0 i.e. not fixed    |
        +---------------+--------------------------------+---------+---------------------+
        | if_not_exists | no error if                    | boolean | false               |
        |               | duplicate name                 |         |                     |
        +---------------+--------------------------------+---------+---------------------+
        | engine        | storage engine =               | string  | 'memtx'             |
        |               | 'memtx' or 'vinyl'             |         |                     |
        +---------------+--------------------------------+---------+---------------------+
        | user          | user name                      | string  | current user's name |
        +---------------+--------------------------------+---------+---------------------+
        | format        | field names+types              | table   | (blank)             |
        +---------------+--------------------------------+---------+---------------------+

    There are three :ref:`syntax variations <app_server-object_reference>`
    for object references targeting space objects, for example
    :samp:`box.schema.space.drop({space-id})`
    will drop a space. However, the common approach is to use functions
    attached to the space objects, for example
    :ref:`space_object:drop() <box_space-drop>`.

    .. NOTE::

        | Note re storage engine:
        | vinyl does not support temporary spaces.


    **Example**

    .. code-block:: tarantoolsession

       tarantool> s = box.schema.space.create('space55')
       ---
       ...
       tarantool> s = box.schema.space.create('space55', {
                >   id = 555,
                >   temporary = false
                > })
       ---
       - error: Space 'space55' already exists
       ...
       tarantool> s = box.schema.space.create('space55', {
                >   if_not_exists = true
                > })
       ---
       ...

    For an illustration with the ``format`` clause, see
    :ref:`box.space._space <box_space-space>` example.

    After a space is created, usually the next step is to
    :ref:`create an index <box_space-create_index>` for it, and then it is
    available for insert, select, and all the other :ref:`box.space <box_space>` functions.

.. _box_schema-user_create:

.. function:: box.schema.user.create(user-name [, {options}])

    Create a user.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users<authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    The possible options are:

    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means there should be no error if the user already exists,

    * ``password`` (default = '') - string; the ``password`` = *password*
      specification is good because in a :ref:`URI <index-uri>`
      (Uniform Resource Identifier) it is usually illegal to include a
      user-name without a password.

    .. NOTE::

        The maximum number of users is 32.

    :param string user-name: name of user, which should not be a number
                             and should not contain special characters
    :param table options: ``if_not_exists``, ``password``

    :return: nil

    **Examples:**

    .. code-block:: lua

        box.schema.user.create('Lena')
        box.schema.user.create('Lena', {password = 'X'})
        box.schema.user.create('Lena', {if_not_exists = false})

.. _box_schema-user_drop:

.. function:: box.schema.user.drop(user-name [, {options}])

    Drop a user.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string user-name: the name of the user
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the user does not exist.

    **Examples:**

    .. code-block:: lua

        box.schema.user.drop('Lena')
        box.schema.user.drop('Lena',{if_exists=false})

.. _box_schema-user_exists:

.. function:: box.schema.user.exists(user-name)

    Return ``true`` if a user exists; return ``false`` if a user does not exist.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string user-name: the name of the user
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.user.exists('Lena')

.. _box_schema-user_grant:

.. function:: box.schema.user.grant(user-name, priveleges, object-type, object-name[, {options} ])
              box.schema.user.grant(user-name, priveleges, 'universe'[, nil, {options} ])
              box.schema.user.grant(user-name, role-name[, nil, nil, {options} ])

    Grant :ref:`privileges <authentication-owners_privileges>` to a user or
    to another role.

    :param string   user-name: the name of the user
    :param string  priveleges: 'read' or 'write' or 'execute' or a combination,
    :param string object-type: 'space' or 'function'.
    :param string object-name: name of object to grant permissions to
    :param string   role-name: name of role to grant to user.
    :param table      options: ``grantor``, ``if_not_exists``

    If :samp:`'function','{object-name}'` is specified, then a _func tuple with
    that object-name must exist.

    **Variation:** instead of ``object-type, object-name`` say 'universe' which
    means 'all object-types and all objects'. In this case, object name is omitted.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` (see section :ref:`Roles <authentication-roles>`).

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
        box.schema.user.grant('X', 'read', 'universe', nil, {if_not_exists=true}))

.. _box_schema-user_revoke:

.. function:: box.schema.user.revoke(user-name, privilege, object-type, object-name)
              box.schema.user.revoke(user-name, privilege, 'role', role-name)

    Revoke :ref:`privileges <authentication-owners_privileges>` from a user
    or from another role.

    :param string user-name: the name of the user
    :param string privilege: 'read' or 'write' or 'execute' or a combination
    :param string object-type: 'space' or 'function'
    :param string object-name: the name of a function or space

    The user must exist, and the object must exist,
    but it is not an error if the user does not have the privilege.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` (see section :ref:`Roles <authentication-roles>`).

    **Example:**

    .. code-block:: lua

        box.schema.user.revoke('Lena', 'read', 'space', 'tester')
        box.schema.user.revoke('Lena', 'execute', 'function', 'f')
        box.schema.user.revoke('Lena', 'read,write', 'universe')
        box.schema.user.revoke('Lena', 'Accountant')

.. _box_schema-user_password:

.. function:: box.schema.user.password(password)

    Return a hash of a user's password. For explanation of how Tarantool maintains
    passwords, see section :ref:`Passwords <authentication-passwords>` and reference on
    :ref:`_user <box_space-user>` space.

    .. NOTE::

       * If a non-'guest' user has no password, it’s **impossible** to connect to Tarantool
         using this user. The user is regarded as “internal” only, not usable from a remote
         connection. Such users can be useful if they have defined some procedures with the
         :ref:`SETUID <box_schema-func_create>` option, on which privileges are granted
         to externally-connectable users. This way, external users cannot create/drop objects,
         they can only invoke procedures.

       * For the 'guest' user, it’s impossible to set a password: that would be misleading,
         since 'guest' is the default user on a newly-established connection over the
         :ref:`binary protocol <administration-admin_ports>`, and Tarantool does not require
         a password to establish a binary connection. It is, however, possible to change the
         current user to ‘guest’ by providing the AUTH packet with no password at all or an
         empty password. This feature is useful for connection pools, which want to reuse a
         connection for a different user without re-establishing it.

    :param string password: password
    :rtype: string

    **Example:**

    .. code-block:: lua

        box.schema.user.password('ЛЕНА')

.. _box_schema-user_passwd:

.. function:: box.schema.user.passwd([user-name,] password)

    Associate a password with the user who is currently logged in.
    or with another user.
    Users who wish to change their own passwords should
    use ``box.schema.user.passwd(password)``.
    Administrators who wish to change passwords of other users should
    use ``box.schema.user.passwd(user-name, password)``.

    :param string user-name: user-name
    :param string password: password

    **Example:**

    .. code-block:: lua

        box.schema.user.passwd('ЛЕНА')
        box.schema.user.passwd('Lena', 'ЛЕНА')

.. _box_schema-user_info:

.. function:: box.schema.user.info([user-name])

    Return a description of a user's privileges.
    For explanation of how Tarantool maintains user data, see
    section :ref:`Users <authentication-users>` and reference on
    :ref:`_user <box_space-user>` space.

    :param string user-name: the name of the user.
                             This is optional; if it is not
                             supplied, then the information
                             will be for the user who is
                             currently logged in.

    **Example:**

    .. code-block:: lua

        box.schema.user.info()
        box.schema.user.info('Lena')

.. _box_schema-role_create:

.. function:: box.schema.role.create(role-name [, {options}])

    Create a role.
    For explanation of how Tarantool maintains role data, see
    section :ref:`Roles <authentication-roles>`.

    :param string role-name: name of role, which should not be a number
                             and should not contain special characters
    :param table options: ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the
                          role already exists

    :return: nil

    **Example:**

    .. code-block:: lua

        box.schema.role.create('Accountant')
        box.schema.role.create('Accountant', {if_not_exists = false})

.. _box_schema-role_drop:

.. function:: box.schema.role.drop(role-name [, {options}])

    Drop a role.
    For explanation of how Tarantool maintains role data, see
    section :ref:`Roles <authentication-roles>`.

    :param string role-name: the name of the role
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the role does not exist.

    **Example:**

    .. code-block:: lua

        box.schema.role.drop('Accountant')

.. _box_schema-role_exists:

.. function:: box.schema.role.exists(role-name)

    Return ``true`` if a role exists; return ``false`` if a role does not exist.

    :param string role-name: the name of the role
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.role.exists('Accountant')

.. _box_schema-role_grant:

.. function:: box.schema.role.grant(user-name, privilege, object-type, object-name [, option])
              box.schema.role.grant(user-name, privilege, 'universe' [, nil, option])
              box.schema.role.grant(role-name, role-name [, nil, nil, option])

    Grant :ref:`privileges <authentication-owners_privileges>` to a role.

    :param string user-name: the name of the role
    :param string privilege: 'read' or 'write' or 'execute' or a combination
    :param string object-type: 'space' or 'function'
    :param string object-name: the name of a function or space
    :param table option: ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
                         ``true`` means there should be no error if the role already
                         has the privilege

    The role must exist, and the object must exist.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name`` -- to grant a role to a role.

    **Example:**

    .. code-block:: lua

        box.schema.role.grant('Accountant', 'read', 'space', 'tester')
        box.schema.role.grant('Accountant', 'execute', 'function', 'f')
        box.schema.role.grant('Accountant', 'read,write', 'universe')
        box.schema.role.grant('public', 'Accountant')
        box.schema.role.grant('role1', 'role2', nil, nil, {if_not_exists=false})

.. _box_schema-role_revoke:

.. function:: box.schema.role.revoke(user-name, privilege, object-type, object-name)

    Revoke :ref:`privileges <authentication-owners_privileges>` from a role.

    :param string user-name: the name of the role
    :param string privilege: 'read' or 'write' or 'execute' or a combination
    :param string object-type: 'space' or 'function'
    :param string object-name: the name of a function or space

    The role must exist, and the object must exist,
    but it is not an error if the role does not have the privilege.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'.

    **Variation:** instead of ``privilege, object-type, object-name`` say
    ``role-name``.

    **Example:**

    .. code-block:: lua

        box.schema.role.revoke('Accountant', 'read', 'space', 'tester')
        box.schema.role.revoke('Accountant', 'execute', 'function', 'f')
        box.schema.role.revoke('Accountant', 'read,write', 'universe')
        box.schema.role.revoke('public', 'Accountant')

.. _box_schema-role_info:

.. function:: box.schema.role.info([role-name])

    Return a description of a role's privileges.

    :param string role-name: the name of the role.

    **Example:**

    .. code-block:: lua

        box.schema.role.info('Accountant')

.. _box_schema-func_create:

.. function:: box.schema.func.create(func-name [, {options}])

    Create a function tuple.
    This does not create the function itself -- that is done with Lua --
    but if it is necessary to grant privileges for a function,
    box.schema.func.create must be done first.
    For explanation of how Tarantool maintains function data, see
    reference on :ref:`_func <box_space-func>` space.

    The possible options are:

    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means there should be no error if the ``_func`` tuple already exists.

    * ``setuid`` = ``true|false`` (default = false) - with ``true`` to make Tarantool
      treat the function’s caller as the function’s creator, with full privileges.
      Remember that SETUID works only over the
      :ref:`binary protocol <administration-admin_ports>`.
      SETUID doesn't work if you invoke a function via text console or
      inside a Lua script.

    * ``language`` = 'LUA'|'C' (default = ‘LUA’).

    :param string func-name: name of function, which should not be a number
                             and should not contain special characters
    :param table options: ``if_not_exists``, ``setuid``, ``language``.

    :return: nil

    **Example:**

    .. code-block:: lua

        box.schema.func.create('calculate')
        box.schema.func.create('calculate', {if_not_exists = false})
        box.schema.func.create('calculate', {setuid = false})
        box.schema.func.create('calculate', {language = 'LUA'})

.. _box_schema-func_drop:

.. function:: box.schema.func.drop(func-name [, {options}])

    Drop a function tuple.
    For explanation of how Tarantool maintains function data, see
    reference on :ref:`_func space <box_space-func>`.

    :param string func-name: the name of the function
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the _func tuple does not exist.

    **Example:**

    .. code-block:: lua

        box.schema.func.drop('calculate')

.. _box_schema-func_exists:

.. function:: box.schema.func.exists(func-name)

    Return true if a function tuple exists; return false if a function tuple does not exist.

    :param string func-name: the name of the function
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.func.exists('calculate')

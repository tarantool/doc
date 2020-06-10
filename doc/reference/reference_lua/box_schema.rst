.. _box_schema:

-------------------------------------------------------------------------------
                             Submodule `box.schema`
-------------------------------------------------------------------------------

.. module:: box.schema

===============================================================================
                                   Overview
===============================================================================

The ``box.schema`` submodule has data-definition functions
for spaces, users, roles, function tuples, and sequences.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``box.schema`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.schema.space.create()      | Create a space                  |
    | <box_schema-space_create>` or        |                                 |
    | :ref:`box.schema.create_space()      |                                 |
    | <box_schema-space_create>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.upgrade             | Upgrade a database              |
    | <admin-upgrades>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.create()       | Create a user                   |
    | <box_schema-user_create>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.drop()         | Drop a user                     |
    | <box_schema-user_drop>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.exists()       | Check if a user exists          |
    | <box_schema-user_exists>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.grant()        | Grant privileges to a user or   |
    | <box_schema-user_grant>`             | a role                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.revoke()       | Revoke privileges from a user   |
    | <box_schema-user_revoke>`            | or a role                       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.password()     | Get a hash of a user's password |
    | <box_schema-user_password>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.passwd()       | Associate a password with       |
    | <box_schema-user_passwd>`            | a user                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.user.info()         | Get a description of a user's   |
    | <box_schema-user_info>`              | privileges                      |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.create()       | Create a role                   |
    | <box_schema-role_create>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.drop()         | Drop a role                     |
    | <box_schema-role_drop>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.exists()       | Check if a role exists          |
    | <box_schema-role_exists>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.grant()        | Grant privileges to a role      |
    | <box_schema-role_grant>`             |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.revoke()       | Revoke privileges from a role   |
    | <box_schema-role_revoke>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.role.info()         | Get a description of a role's   |
    | <box_schema-role_info>`              | privileges                      |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.create()       | Create a function tuple         |
    | <box_schema-func_create>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.drop()         | Drop a function tuple           |
    | <box_schema-func_drop>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.func.exists()       | Check if a function tuple       |
    | <box_schema-func_exists>`            | exists                          |
    +--------------------------------------+---------------------------------+
    | :ref:`box.schema.sequence.create()   | Create a new sequence generator |
    | <box_schema-sequence_create>`        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:next()         | Generate and return the next    |
    | <box_schema-sequence_next>`          | value                           |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:alter()        | Change sequence options         |
    | <box_schema-sequence_alter>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:reset()        | Reset sequence state            |
    | <box_schema-sequence_reset>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:set()          | Set the new value               |
    | <box_schema-sequence_set>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:drop()         | Drop the sequence               |
    | <box_schema-sequence_drop>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:create_index()    | Create an index                 |
    | <box_schema-sequence_create_index>`  |                                 |
    +--------------------------------------+---------------------------------+

.. _box_schema-space_create:

.. function:: box.schema.space.create(space-name [, {options}])
              box.schema.create_space(space-name [, {options}])

    Create a :ref:`space <index-box_space>`.

    :param string space-name: name of space, which should
                              conform to the :ref:`rules for object names <app_server-names>`
    :param table options: see "Options for box.schema.space.create" chart, below

    :return: space object
    :rtype: userdata

    You can use either syntax. For example,
    ``s = box.schema.space.create('tester')`` has the same effect as
    ``s = box.schema.create_space('tester')``.

    .. container:: table

        **Options for box.schema.space.create**

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2
        .. rst-class:: left-align-column-3
        .. rst-class:: left-align-column-4

        .. tabularcolumns:: |\Y{0.2}|\Y{0.4}|\Y{0.2}|\Y{0.2}|

        +---------------+----------------------------------------------------+---------+---------------------+
        | Name          | Effect                                             | Type    | Default             |
        +===============+====================================================+=========+=====================+
        | engine        | 'memtx' or 'vinyl'                                 | string  | 'memtx'             |
        +---------------+----------------------------------------------------+---------+---------------------+
        | field_count   | fixed count of :ref:`fields <index-box_tuple>`:    | number  | 0 i.e. not fixed    |
        |               | for example if                                     |         |                     |
        |               | field_count=5, it is illegal                       |         |                     |
        |               | to insert a tuple with fewer                       |         |                     |
        |               | than or more than 5 fields                         |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | format        | field names and types:                             | table   | (blank)             |
        |               | See the illustrations of format clauses in the     |         |                     |
        |               | :ref:`space_object:format() <box_space-format>`    |         |                     |
        |               | description and in the                             |         |                     |
        |               | :ref:`box.space._space <box_space-space>`          |         |                     |
        |               | example. Optional and usually not specified.       |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | id            | unique identifier:                                 | number  | last space's id, +1 |
        |               | users can refer to spaces with                     |         |                     |
        |               | the id instead of the name                         |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | if_not_exists | create space only if a space                       | boolean | false               |
        |               | with the same name does not                        |         |                     |
        |               | exist already, otherwise do                        |         |                     |
        |               | nothing but do not cause an                        |         |                     |
        |               | error                                              |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | is_local      | space contents are                                 | boolean | false               |
        |               | :ref:`replication-local <replication-local>`:      |         |                     |
        |               | changes are stored in the                          |         |                     |
        |               | :ref:`write-ahead log <internals-wal>`             |         |                     |
        |               | of the local node but there is no                  |         |                     |
        |               | :ref:`replication <replication>`.                  |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | temporary     | space contents are temporary:                      | boolean | false               |
        |               | changes are not stored in the                      |         |                     |
        |               | :ref:`write-ahead log <internals-wal>`             |         |                     |
        |               | and there is no                                    |         |                     |
        |               | :ref:`replication <replication>`.                  |         |                     |
        |               | Note re storage engine: vinyl                      |         |                     |
        |               | does not support temporary spaces.                 |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+
        | user          | name of the user who is considered to be           | string  | current user's name |
        |               | the space's                                        |         |                     |
        |               | :ref:`owner <authentication-owners_privileges>`    |         |                     |
        |               | for authorization purposes                         |         |                     |
        +---------------+----------------------------------------------------+---------+---------------------+

    .. _box_schema-space_create-options:

    Saying ``box.cfg{read_only=true...}`` during :ref:`configuration <cfg_basic-read_only>`
    affects spaces differently depending on the options that were used during
    ``box.schema.space.create``, as summarized by this chart:

    .. container:: table

        +------------+-----------------+--------------------+----------------+----------------+
        | Option     | Can be created? | Can be written to? | Is replicated? | Is persistent? |
        +============+=================+====================+================+================+
        | (default)  | no              | no                 | yes            | yes            |
        +------------+-----------------+--------------------+----------------+----------------+
        | temporary  | no              | yes                | no             | no             |
        +------------+-----------------+--------------------+----------------+----------------+
        | is_local   | no              | yes                | no             | yes            |
        +------------+-----------------+--------------------+----------------+----------------+

    There are three :ref:`syntax variations <app_server-object_reference>`
    for object references targeting space objects, for example
    :samp:`box.schema.space.drop({space-id})`
    will drop a space. However, the common approach is to use functions
    attached to the space objects, for example
    :ref:`space_object:drop() <box_space-drop>`.

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

    After a space is created, usually the next step is to
    :ref:`create an index <box_space-create_index>` for it, and then it is
    available for insert, select, and all the other :ref:`box.space <box_space>`
    functions.

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

    :param string user-name: name of user, which should
                             conform to the :ref:`rules for object names <app_server-names>`
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
        box.schema.user.grant('X', 'read', 'universe', nil, {if_not_exists=true}))

.. _box_schema-user_revoke:

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

        box.schema.user.password('ЛЕНА')

.. _box_schema-user_passwd:

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

.. _box_schema-user_info:

.. function:: box.schema.user.info([user-name])

    Return a description of a user's :ref:`privileges <authentication-owners_privileges>`.
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

    :param string role-name: name of role, which should
                             conform to the :ref:`rules for object names <app_server-names>`
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

.. function:: box.schema.role.grant(role-name, privilege, object-type, object-name [, option])
              box.schema.role.grant(role-name, privilege, 'universe' [, nil, option])
              box.schema.role.grant(role-name, role-name [, nil, nil, option])

    Grant :ref:`privileges <authentication-owners_privileges>` to a role.

    :param string role-name: the name of the role.
    :param string privilege: 'read' or 'write' or 'execute' or 'create' or
                             'alter' or 'drop' or a combination.
    :param string object-type: 'space' or 'function' or 'sequence' or 'role'.
    :param string object-name: the name of a function or space or sequence or role.
    :param table option: ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
                         ``true`` means there should be no error if the role already
                         has the privilege.

    The role must exist, and the object must exist.

    **Variation:** instead of ``object-type, object-name`` say 'universe'
    which means 'all object-types and all objects'. In this case, object name is omitted.

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

.. function:: box.schema.role.revoke(role-name, privilege, object-type, object-name)

    Revoke :ref:`privileges <authentication-owners_privileges>` from a role.

    :param string role-name: the name of the role.
    :param string privilege: 'read' or 'write' or 'execute' or 'create' or
                             'alter' or 'drop' or a combination.
    :param string object-type: 'space' or 'function' or 'sequence' or 'role'.
    :param string object-name: the name of a function or space or sequence or role.

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

.. function:: box.schema.role.info(role-name)

    Return a description of a role's privileges.

    :param string role-name: the name of the role.

    **Example:**

    .. code-block:: lua

        box.schema.role.info('Accountant')

.. _box_schema-func_create:

.. function:: box.schema.func.create(func-name [, {options}])

    Create a function :ref:`tuple <index-box_tuple>`.
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
      Remember that SETUID works only over
      :ref:`binary ports <admin-security>`.
      SETUID doesn't work if you invoke a function via an
      :ref:`admin console <admin-security>` or inside a Lua script.

    * ``language`` = 'LUA'|'C' (default = ‘LUA’).

    :param string func-name: name of function, which should
                             conform to the :ref:`rules for object names <app_server-names>`
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

    Return true if a function tuple exists; return false if a function tuple
    does not exist.

    :param string func-name: the name of the function
    :rtype: bool

    **Example:**

    .. code-block:: lua

        box.schema.func.exists('calculate')

.. _box_schema-func_reload:

.. function:: box.schema.func.reload([name])

    Reload a C module with all its functions without restarting the server.

    Under the hood, Tarantool loads a new copy of the module (``*.so`` shared
    library) and starts routing all new request to the new version.
    The previous version remains active until all started calls are finished.
    All shared libraries are loaded with ``RTLD_LOCAL`` (see "man 3 dlopen"),
    therefore multiple copies can co-exist without any problems.

    .. NOTE::

        Reload will fail if a module was loaded from Lua script with
        `ffi.load() <http://luajit.org/ext_ffi_api.html#ffi_load>`_.

    :param string name: the name of the module to reload

    **Example:**

    .. code-block:: lua

        -- reload the entire module contents
        box.schema.func.reload('module')

.. _box_schema-sequence:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sequences
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An introduction to sequences is in the :ref:`Sequences <index-box_sequence>`
section of the "Data model" chapter.
Here are the details for each function and option.

All functions related to sequences require appropriate
:ref:`privileges <authentication-owners_privileges>`.

.. _box_schema-sequence_create:

.. function:: box.schema.sequence.create(name[, options])

    Create a new sequence generator.

    :param string name: the name of the sequence

    :param table options: see a quick overview in the
                          "Options for ``box.schema.sequence.create()``"
                          :ref:`chart <index-box_sequence-options>`
                          (in the :ref:`Sequences <index-box_sequence>`
                          section of the "Data model" chapter),
                          and see more details below.

    :return: a reference to a new sequence object.

    Options:

    * ``start`` -- the STARTS WITH value. Type = integer, Default = 1.

    * ``min`` -- the MINIMUM value. Type = integer, Default = 1.

    * ``max`` - the MAXIMUM value. Type = integer, Default = 9223372036854775807.

      There is a rule: ``min`` <= ``start`` <= ``max``.
      For example it is illegal to say ``{start=0}`` because then the
      specified start value (0) would be less than the default min value (1).

      There is a rule: ``min`` <= next-value <= ``max``.
      For example, if the next generated value would be 1000,
      but the maximum value is 999, then that would be considered
      "overflow".

    * ``cycle`` -- the CYCLE value. Type = bool. Default = false.

      If the sequence generator's next value is an overflow number,
      it causes an error return -- unless ``cycle == true``.

      But if ``cycle == true``, the count is started again, at the
      MINIMUM value or at the MAXIMUM value (not the STARTS WITH value).

    * ``cache`` -- the CACHE value. Type = unsigned integer. Default = 0.

      Currently Tarantool ignores this value, it is reserved for future use.

    * ``step`` -- the INCREMENT BY value. Type = integer. Default = 1.

      Ordinarily this is what is added to the previous value.

.. _box_schema-sequence_next:

.. function:: sequence_object:next()

    Generate the next value and return it.

    The generation algorithm is simple:

    * If this is the first time, then return the STARTS WITH value.
    * If the previous value plus the INCREMENT value is less than the
      MINIMUM value or greater than the MAXIMUM value, that is "overflow",
      so either raise an error (if ``cycle`` = ``false``) or return the
      MAXIMUM value (if ``cycle`` = ``true`` and ``step`` < 0)
      or return the MINIMUM value (if ``cycle`` = ``true`` and ``step`` > 0).

    If there was no error, then save the returned result, it is now
    the "previous value".

    For example, suppose sequence 'S' has:

    * ``min`` == -6,
    * ``max`` == -1,
    * ``step`` == -3,
    * ``start`` = -2,
    * ``cycle`` = true,
    * previous value = -2.

    Then ``box.sequence.S:next()`` returns -5 because -2 + (-3) == -5.

    Then ``box.sequence.S:next()`` again returns -1 because -5 + (-3) < -6,
    which is overflow, causing cycle, and ``max`` == -1.

    This function requires a :ref:`'write' privilege <box_schema-user_grant>`
    on the sequence.

    .. NOTE::

        This function should not be used in "cross-engine" transactions
        (transactions which use both the memtx and the vinyl storage engines).

        To see what the previous value was, without changing it, you can
        select from the :ref:`_sequence_data <box_space-sequence_data>`
        system space.

.. _box_schema-sequence_alter:

.. function:: sequence_object:alter(options)

    The ``alter()`` function can be used to change any of the sequence's
    options. Requirements and restrictions are the same as for
    :ref:`box.schema.sequence.create() <box_schema-sequence_create>`.

.. _box_schema-sequence_reset:

.. function:: sequence_object:reset()

    Set the sequence back to its original state.
    The effect is that a subsequent ``next()`` will return the ``start`` value.
    This function requires a :ref:`'write' privilege <box_schema-user_grant>`
    on the sequence.

.. _box_schema-sequence_set:

.. function:: sequence_object:set(new-previous-value)

    Set the "previous value" to ``new-previous-value``.
    This function requires a :ref:`'write' privilege <box_schema-user_grant>`
    on the sequence.

.. _box_schema-sequence_drop:

.. function:: sequence_object:drop()

    Drop an existing sequence.

    **Example:**

    Here is an example showing all sequence options and operations:

    .. code-block:: lua

        s = box.schema.sequence.create(
                       'S2',
                       {start=100,
                       min=100,
                       max=200,
                       cache=100000,
                       cycle=false,
                       step=100
                       })
        s:alter({step=6})
        s:next()
        s:reset()
        s:set(150)
        s:drop()

.. _box_schema-sequence_create_index:

.. function:: space_object:create_index(... [sequence='...' option] ...)

    You can use the :samp:`sequence={sequence-name}`
    (or :samp:`sequence={sequence-id}` or :samp:`sequence=true`)
    option when :ref:`creating <box_space-create_index>` or
    :ref:`altering <box_index-alter>` a primary-key index.
    The sequence becomes associated with the index, so that the next
    ``insert()`` will put the next generated number into the primary-key
    field, if the field would otherwise be nil.

    For example, if 'Q' is a sequence and 'T' is a new space, then this will
    work:

    .. code-block:: tarantoolsession

        tarantool> box.space.T:create_index('Q',{sequence='Q'})
        ---
        - unique: true
          parts:
          - type: unsigned
            is_nullable: false
            fieldno: 1
          sequence_id: 8
          id: 0
          space_id: 514
          name: Q
          type: TREE
        ...

    (Notice that the index now has a ``sequence_id`` field.)

    And this will work:

    .. code-block:: tarantoolsession

        tarantool> box.space.T:insert{box.NULL,0}
        ---
        - [1, 0]
        ...

    .. NOTE::

        If you are using negative numbers for the sequence options,
        make sure that the index key type is 'integer'. Otherwise
        the index key type may be either 'integer' or 'unsigned'.

        A sequence cannot be dropped if it is associated with an index.
        However, :ref:`index_object:alter() <box_index-alter>`
        can be used to say that a sequence
        is not associated with an index, for example
        ``box.space.T.index.I:alter({sequence=false})``.


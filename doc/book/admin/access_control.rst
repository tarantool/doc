.. _authentication:
.. _access_control:

Access control
==============

Tarantool enables flexible management of access to various database resources.
The main concepts of Tarantool access control system are as follows:

*   A *user* is a person or program that interacts with a Tarantool instance.
*   An *object* is an entity to which access can be granted, for example, a space, an index, or a function.
*   A *privilege* allows a user to perform certain operations on specific objects, for example, creating spaces, reading or updating data.
*   A *role* is a named collection of privileges that can be granted to a user.



.. _access_control_overview:

Overview
--------

.. _authentication-users:
.. _access_control_concepts_users:

Users
~~~~~

A user identifies a person or program that interacts with a Tarantool instance.
There might be different types of users, for example:

*   A database administrator responsible for the overall management and administration of a database.
    An administrator can create other users and grant them specified privileges.
*   A user with limited access to certain data and stored functions.
    Such users can get their privileges from the database administrator.
*   Users used in communications between Tarantool instances. For example, such users can be created to maintain replication and sharding in a Tarantool cluster.

There are two built-in users in Tarantool:

*   ``admin`` is a user with all available administrative permissions.
    If the connection uses an :ref:`admin-console port <admin-security>`, the current user is ``admin``.
    For example, ``admin`` is used when connecting to an instance using :ref:`tt connect <tt-connect>` locally using the instance name:

    ..  code-block:: console

        $ tt connect app:instance001

    To allow remote :ref:`binary port <admin-security>` connections using the ``admin`` user, you need to :ref:`set a password <access_control_user_changing_passwords>`.

*   ``guest`` is a user with minimum permissions used by default for remote :ref:`binary port <admin-security>` connections.
    For example, ``guest`` is used when connecting to an instance using :ref:`tt connect <tt-connect>` using the IP address and port without specifying the name of a user:

    ..  code-block:: console

        $ tt connect 192.168.10.10:3301

    ..  WARNING::

        Given that the ``guest`` user allows unauthenticated access to Tarantool instances, it is not recommended to grant additional privileges to this user.
        For example, granting the ``execute`` access to :ref:`universe <access_control_concepts_objects>` allows *remote code execution* on instances.

..  NOTE::

    Information about users is stored in the :ref:`_user <box_space-user>` space.




.. _authentication-passwords:

Passwords
~~~~~~~~~

Any user (except ``guest``) may have a password.
If a password is not set, a user cannot connect to Tarantool instances.

Tarantool :ref:`password hashes <enterprise-authentication-protocol>` are stored in the :ref:`_user <box_space-user>` system space.
By default, Tarantool uses the ``CHAP`` protocol to authenticate users and applies ``SHA-1`` hashing to
:ref:`passwords <authentication-passwords>`.
So, if the password is '123456', the stored hash is a string like 'a7SDfrdDKRBe5FaN2n3GftLKKtk='.
In the Enterprise Edition, you can enable ``PAP`` :ref:`authentication <enterprise-authentication-protocol>` with the ``SHA256`` hashing algorithm.

Tarantool Enterprise Edition allows you to improve database security by enforcing the use of strong passwords, setting up a maximum password age, and so on.
Learn more from the :ref:`configuration_authentication` topic.



.. _access_control_concepts_objects:

Objects
~~~~~~~

An object is a securable entity to which access can be granted.
Tarantool has a number of objects that enable flexible management of access to data, stored functions, specific actions, and so on.

Below are a few examples of objects:

*   ``universe`` represents a database (:ref:`box.schema <box_schema>`) that contains database objects, including spaces, indexes, users, roles, sequences, and functions.
    Granting privileges to ``universe`` gives a user access to any object in a database.
*   ``space`` enables granting privileges to user-created or system :ref:`spaces <index-box_space>`.
*   ``function`` enables granting privileges to :ref:`functions <box_schema-func_create>`.

..  NOTE::

    The full list of object types is available in the :ref:`access_control_list_objects` section.


.. _authentication-owners_privileges:

Privileges
~~~~~~~~~~

The privileges granted to a user determine which operations the user can perform, for example:

*   The ``read`` and ``write`` permissions granted to the ``space`` :ref:`object <access_control_concepts_objects>` allow a user to read or modify data in the specified space.
*   The ``create`` permission granted to the ``space`` object allows a user to create new spaces.
*   The ``execute`` permission granted to the ``function`` object allows a user to execute the specified function.
*   The ``session`` permission granted to a user allows connecting to an instance over IPROTO.

Note that some privileges might require read and write access to certain system spaces.
For example, the ``create`` permission granted to the ``space`` object requires ``read`` and ``write`` permissions to the :ref:`_space <box_space-space>` system space.
Similarly, granting the ability to create functions requires ``read`` and ``write`` access to the :ref:`_func <box_space-func>` space.

..  NOTE::

    Information about privileges is stored in the :ref:`_priv <box_space-priv>` space.



.. _access_control_concepts_roles:

Roles
~~~~~
A role is a container for :ref:`privileges <authentication-owners_privileges>` that can be granted to users.
Roles can also be assigned to other roles, creating a role hierarchy.

There are the following built-in roles in Tarantool:

*   ``super`` has all available administrative permissions.
*   ``public`` has certain read permissions. This role is automatically granted to new users when they are created.
*   ``replication`` can be granted to a user used to maintain :ref:`replication <replication_overview>` in a cluster.
*   ``sharding`` can be granted to a user used to maintain :ref:`sharding <sharding>` in a cluster.

    ..  NOTE::

        The ``sharding`` role is created only if an instance is managed using :ref:`YAML configuration <configuration_overview>`.

Below are a few diagrams that demonstrate how privileges can be granted to a user without and with using roles.

*   In this example, a user gets privileges directly without using roles.

    ..  code-block:: none

        user1 ── privilege1
            ├─── privilege2
            └─── privilege3

*   In this example, a user gets all privileges provided by ``role1`` and specific privileges assigned directly.

    ..  code-block:: none

        user1 ── role1 ── privilege1
            │        └─── privilege2
            ├─── privilege3
            └─── privilege4

*   In this example, ``role2`` is granted to ``role1``.
    This means that a user with ``role1`` subsequently gets all privileges from both roles ``role1`` and ``role2``.

    ..  code-block:: none

        user1 ── role1 ── privilege1
            │        ├─── privilege2
            │        └─── role2
            │                 ├─── privilege3
            │                 └─── privilege4
            ├─── privilege5
            └─── privilege6

..  NOTE::

    Information about roles is stored in the :ref:`_user <box_space-user>` space.



.. _authentication-owners:

Object owners
~~~~~~~~~~~~~

An owner of a database :ref:`object <access_control_concepts_objects>` is the user who created it.
The owner of the database and the owner of objects that are created initially (the system spaces and the default users) is the ``admin`` :ref:`user <access_control_concepts_users>`.

Owners automatically have :ref:`privileges <authentication-owners_privileges>` for objects they create.
They can :ref:`share these privileges <access_control_granting_privileges>` with other users or roles using ``box.schema.user.grant()`` and ``box.schema.role.grant()``.

..  NOTE::

    Information about users who gave the specified privileges is stored in the :ref:`_priv <box_space-priv>` space.



.. _authentication-sessions:

Sessions
~~~~~~~~

A session is the state of a connection to Tarantool.
The session contains:

*   An integer ID identifying the connection.
*   The current :ref:`user <authentication-users>` associated with the connection.
*   The text description of the connected peer.
*   A session's local state, such as Lua variables and functions.

In Tarantool, a single session can execute multiple concurrent transactions.
Each transaction is identified by a unique integer ID, which can be queried
at the start of the transaction using :doc:`/reference/reference_lua/box_session/sync`.

..  NOTE::

    To track all connects and disconnects, you can use :ref:`connection and authentication triggers <triggers>`.




.. _access_control_users:

Managing users
--------------

.. _access_control_user_creating:

Creating a user
~~~~~~~~~~~~~~~

To create a new user, call :ref:`box.schema.user.create() <box_schema-user_create>`.
In the example below, a user is created without a password:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Create a user without a password
    :end-before: End: Create a user without a password
    :dedent:


In this example, the password is specified in the ``options`` parameter:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Create a user with a password
    :end-before: End: Create a user with a password
    :dedent:


.. _access_control_user_changing_passwords:

Changing passwords
~~~~~~~~~~~~~~~~~~

To set or change a user's password, use :ref:`box.schema.user.passwd() <box_schema-user_create>`.
In the example below, a user password is set for a currently logged-in user:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Set a password for the current user
    :end-before: End: Set a password for the current user
    :dedent:

To set the password for the specified user, pass a username and password as shown below:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Set a password for the specified user
    :end-before: End: Set a password for the specified user
    :dedent:

..  NOTE::

    :doc:`/reference/reference_lua/box_schema/user_password` returns a hash of the specified password.



.. _access_control_user_granting_privileges:

Granting privileges to a user
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To grant the specified privileges to a user, use the :ref:`box.schema.user.grant() <box_schema-user_grant>` function.
In the example below, ``testuser`` gets read permissions to the ``writers`` space and read/write permissions to the ``books`` space:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Grant privileges to the specified user
    :end-before: End: Grant privileges to the specified user
    :dedent:

Learn more about granting privileges to different types of objects from :ref:`access_control_granting_privileges`.



.. _access_control_user_info:

Getting a user's information
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To check whether the specified user exists, call :ref:`box.schema.user.exists() <box_schema-user_exists>`:

..  code-block:: lua

    box.schema.user.exists('testuser')
    --[[
    - true
    --]]

To get information about privileges granted to a user, call :ref:`box.schema.user.info() <box_schema-user_info>`:

..  code-block:: lua

    box.schema.user.info('testuser')
    --[[
    - - - execute
        - role
        - public
      - - read
        - space
        - writers
      - - read,write
        - space
        - books
      - - session,usage
        - universe
        -
      - - alter
        - user
        - testuser
    --]]

In the example above, ``testuser`` has the following privileges:

*   The ``execute`` permission to the ``public`` role means that this role is :ref:`assigned to the user <access_control_roles_granting_user>`.

*   The ``read`` permission to the ``writers`` space means that the user can read data from this space.

*   The ``read,write`` permissions to the ``books`` space mean that the user can read and modify data in this space.

*   The ``session,usage`` permissions to ``universe`` mean the following:

    *   ``session``: the user can authenticate over an IPROTO connection.
    *   ``usage``: lets the user use their privileges on database objects (for example, read and modify data in a space).

*   The ``alter`` permission lets ``testuser`` modify its own settings, for example, a password.



.. _access_control_user_revoking_privileges:

Revoking user's privileges
~~~~~~~~~~~~~~~~~~~~~~~~~~

To revoke the specified privileges, use the :ref:`box.schema.user.revoke() <box_schema-user_revoke>` function.
In the example below, write access to the ``books`` space is revoked:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Revoke space reading
    :end-before: End: Revoke space reading
    :dedent:

Revoking the ``session`` permission from ``universe`` can be used to disallow a user to connect to a Tarantool instance:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Revoke session
    :end-before: End: Revoke session
    :dedent:


.. _access_control_users_current_user:

Changing the current user
~~~~~~~~~~~~~~~~~~~~~~~~~

The current user name can be found using :ref:`box.session.user() <box_session-user>`.

..  code-block:: lua

    box.session.user()
    --[[
    - admin
    --]]

The current user can be changed:

*   For an :ref:`admin-console <admin-security>` connection: using :doc:`/reference/reference_lua/box_session/su`:

    ..  code-block:: lua

        box.session.su('testuser')
        box.session.user()
        --[[
        - testuser
        --]]

*   For a binary port connection: using the
    :ref:`AUTH protocol command <box_protocol-iproto_protocol>`, supported by most clients.

*   For a binary-port connection invoking a stored function with the CALL command:
    if the :doc:`SETUID </reference/reference_lua/box_schema/func_create>`
    property is enabled for the function,
    Tarantool temporarily replaces the current user with the
    function's creator, with all the creator's privileges, during function execution.



.. _access_control_users_dropping:

Dropping users
~~~~~~~~~~~~~~

To drop the specified user, call :ref:`box.schema.user.drop() <box_schema-user_drop>`:

..  literalinclude:: /code_snippets/test/access_control/grant_user_privileges_test.lua
    :language: lua
    :start-after: Drop a user
    :end-before: End: Drop a user
    :dedent:




.. _authentication-roles:
.. _access_control_roles:

Managing roles
--------------

.. _access_control_roles_creating:

Creating a role
~~~~~~~~~~~~~~~

To create a new role, call :ref:`box.schema.role.create() <box_schema-role_create>`.
In the example below, two roles are created:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Create roles
    :end-before: End: Create roles
    :dedent:


.. _access_control_roles_granting_privileges:

Granting privileges to a role
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To grant the specified privileges to a role, use the :ref:`box.schema.role.grant() <box_schema-role_grant>` function.
In the example below, the ``books_space_manager`` role gets read and write permissions to the ``books`` space:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Grant read/write privileges to a role
    :end-before: Grant write privileges to a role
    :dedent:

The ``writers_space_reader`` role gets read permissions to the ``writers`` space:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Grant write privileges to a role
    :end-before: End: Grant privileges to roles
    :dedent:

Learn more about granting privileges to different types of objects from :ref:`access_control_granting_privileges`.

..  NOTE::

    Not all privileges can be granted to roles.
    Learn more from :ref:`access_control_list_privileges`.


.. _access_control_roles_granting_role:

Granting a role to a role
~~~~~~~~~~~~~~~~~~~~~~~~~

Roles can be assigned to other roles.
In the example below, the newly created ``all_spaces_manager`` role gets all privileges granted to ``books_space_manager`` and ``writers_space_reader``:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Grant a role to a role
    :end-before: End: Grant a role to a role
    :dedent:


.. _access_control_roles_granting_user:

Granting a role to a user
~~~~~~~~~~~~~~~~~~~~~~~~~

To grant the specified role to a :ref:`user <access_control_users>`, use the ``box.schema.user.grant()`` function.
In the example below, ``testuser`` gets privileges granted to the ``books_space_manager`` and ``writers_space_reader`` roles:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Grant a role to a user
    :end-before: End: Grant a role to a user
    :dedent:


.. _access_control_roles_info:

Getting a role's information
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To check whether the specified role exists, call :ref:`box.schema.role.exists() <box_schema-role_exists>`:

..  code-block:: lua

    box.schema.role.exists('books_space_manager')
    --[[
    - true
    --]]

To get information about privileges granted to a role, call :ref:`box.schema.role.info() <box_schema-role_info>`:

..  code-block:: lua

    box.schema.role.info('books_space_manager')
    --[[
    - - - read,write
        - space
        - books
    --]]

If a role has the ``execute`` permission to other roles, this means that these roles are :ref:`granted to this parent role <access_control_roles_granting_role>`:

..  code-block:: lua

    box.schema.role.info('all_spaces_manager')
    --[[
    - - - execute
        - role
        - books_space_manager
      - - execute
        - role
        - writers_space_reader
    --]]




.. _access_control_roles_revoking_role:

Revoking a role from a user
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To revoke the specified role from a user, revoke the ``execute`` privilege for this role using the :ref:`box.schema.user.revoke() <box_schema-user_revoke>` function.
In the example below, the ``books_space_reader`` role is revoked from ``testuser``:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Revoking a role from a user
    :end-before: End: Revoking a role from a user
    :dedent:

To revoke role's privileges, use :ref:`box.schema.role.revoke() <box_schema-role_revoke>`.


.. _access_control_roles_dropping:

Dropping roles
~~~~~~~~~~~~~~

To drop the specified role, call :ref:`box.schema.role.drop() <box_schema-role_drop>`:

..  literalinclude:: /code_snippets/test/access_control/grant_roles_test.lua
    :language: lua
    :start-after: Dropping a role
    :end-before: End: Dropping a role
    :dedent:



.. _access_control_granting_privileges:

Granting privileges
-------------------

To grant the specified privileges to a user or role, use the :ref:`box.schema.user.grant() <box_schema-user_grant>` and :ref:`box.schema.role.grant() <box_schema-role_grant>` functions,
which have similar signatures and accept the same set of arguments.
For example, the ``box.schema.user.grant()`` signature looks as follows:

.. code-block:: lua

    box.schema.user.grant(username, permissions, object-type, object-name[, {options}])

*   ``username``: the name of the user that gets the specified privileges.
*   ``permissions``: a string value that represents :ref:`permissions <access_control_list_privileges>` granted to the user. If there are several permissions, they should be separated by commas without a space.
*   ``object-type``: a type of :ref:`object <access_control_list_objects>` to which permissions are granted.
*   ``object-name``: the name of the object to which permissions are granted.
    An empty string (``""``) or ``nil`` provided instead of ``object-name`` grants the specified permissions to all objects of the specified type.

    ..  NOTE::

        ``object-name`` is ignored for the following combinations of permissions and object types:

        *   Any permission granted to ``universe``.
        *   The ``create`` and ``drop`` permissions for the following object types: ``user``, ``role``, ``space``, ``function``, ``sequence``.
        *   The ``execute`` permission for the following object types: ``lua_eval``, ``lua_call``, ``sql``.


.. _access_control_grant_creating_any_obj:

Any object
~~~~~~~~~~

In the example below, ``testuser`` gets privileges allowing them to create any object of any type:

..  code-block:: lua

    box.schema.user.grant('testuser','read,write,create','universe')

In this example, ``testuser`` can grant access to objects that ``testuser`` created:

..  code-block:: lua

    box.schema.user.grant('testuser','write','space','_priv')




.. _access_control_grant_spaces:

Spaces
~~~~~~

.. _access_control_grant_spaces_create:

Creating and altering spaces
****************************

In the example below, ``testuser`` gets privileges allowing them to create :ref:`spaces <index-box_space>`:

..  code-block:: lua

    box.schema.user.grant('testuser','create','space')
    box.schema.user.grant('testuser','write', 'space', '_schema')
    box.schema.user.grant('testuser','write', 'space', '_space')

As you can see, the ability to create spaces also requires ``write`` access to certain system spaces.

To allow ``testuser`` to drop a space that has associated objects, add the following privileges:

..  code-block:: lua

    box.schema.user.grant('testuser','create,drop','space')
    box.schema.user.grant('testuser','write','space','_schema')
    box.schema.user.grant('testuser','write','space','_space')
    box.schema.user.grant('testuser','write','space','_space_sequence')
    box.schema.user.grant('testuser','read','space','_trigger')
    box.schema.user.grant('testuser','read','space','_fk_constraint')
    box.schema.user.grant('testuser','read','space','_ck_constraint')
    box.schema.user.grant('testuser','read','space','_func_index')


.. _access_control_grant_spaces_indexes:

Creating and altering indexes
*****************************

In the example below, ``testuser`` gets privileges allowing them to create :ref:`indexes <index-box_index>` in the 'writers' space:

..  code-block:: lua

    box.schema.user.grant('testuser','create,read','space','writers')
    box.schema.user.grant('testuser','read,write','space','_space_sequence')
    box.schema.user.grant('testuser','write', 'space', '_index')

To allow ``testuser`` to alter indexes in the ``writers`` space, grant the permissions below.
This example assumes that indexes in the ``writers`` space are not created by ``testuser``.

..  code-block:: lua

    box.schema.user.grant('testuser','alter','space','writers')
    box.schema.user.grant('testuser','read','space','_space')
    box.schema.user.grant('testuser','read','space','_index')
    box.schema.user.grant('testuser','read','space','_space_sequence')
    box.schema.user.grant('testuser','write','space','_index')

If ``testuser`` created indexes in the ``writers`` space, granting the following permissions is enough to alter indexes:

..  code-block:: lua

    box.schema.user.grant('testuser','read','space','_space_sequence')
    box.schema.user.grant('testuser','read,write','space','_index')


.. _access_control_grant_spaces_crud:

CRUD operations
***************

In this example, ``testuser`` gets privileges allowing them to :ref:`select data <index-box_data-operations>` from the 'writers' space:

..  code-block:: lua

    box.schema.user.grant('testuser','read','space','writers')

In this example, ``testuser`` is allowed to read and modify data in the 'books' space:

..  code-block:: lua

    box.schema.user.grant('testuser','read,write','space','books')




.. _access_control_grant_sequences:

Sequences
~~~~~~~~~

.. _access_control_grant_sequences_create_drop:

Creating and dropping sequences
*******************************

In this example, ``testuser`` gets privileges to create :ref:`sequence <index-box_sequence>` generators:

..  code-block:: lua

    box.schema.user.grant('testuser','create','sequence')
    box.schema.user.grant('testuser', 'read,write', 'space', '_sequence')

To let ``testuser`` drop a sequence, grant them the following privileges:

..  code-block:: lua

    box.schema.user.grant('testuser','drop','sequence')
    box.schema.user.grant('testuser','write','space','_sequence_data')
    box.schema.user.grant('testuser','write','space','_sequence')

.. _access_control_grant_sequences_functions:

Using sequence functions
************************

In this example, ``testuser`` is allowed to use the ``id_seq:next()`` function with a sequence named 'id_seq':

..  code-block:: lua

    box.schema.user.grant('testuser','read,write','sequence','id_seq')

In the next example, ``testuser`` is allowed to use the ``id_seq:set()`` or ``id_seq:reset()`` functions with a sequence named 'id_seq':

..  code-block:: lua

    box.schema.user.grant('testuser','write','sequence','id_seq')



.. _access_control_grant_functions:

Functions
~~~~~~~~~

.. _access_control_grant_functions_create_drop:

Creating and dropping functions
*******************************

In this example, ``testuser`` gets privileges to create :ref:`functions <box_schema-func_create>`:

..  code-block:: lua

    box.schema.user.grant('testuser','create','function')
    box.schema.user.grant('testuser','read,write','space','_func')

To let ``testuser`` drop a function, grant them the following privileges:

..  code-block:: lua

    box.schema.user.grant('testuser','drop','function')
    box.schema.user.grant('testuser','write','space','_func')


.. _access_control_grant_functions_execute:

Executing functions
*******************

To give the ability to execute a function named 'sum', grant the following permissions:

..  code-block:: lua

    box.schema.user.grant('testuser','execute','function','sum')





.. _access_control_grant_users:

Users
~~~~~

In this example, ``testuser`` gets privileges to create other users:

..  code-block:: lua

    box.schema.user.grant('testuser','create','user')
    box.schema.user.grant('testuser', 'read,write', 'space', '_user')
    box.schema.user.grant('testuser', 'write', 'space', '_priv')

.. _access_control_grant_roles:

Roles
~~~~~

To let ``testuser`` create new roles, grant the following privileges:

..  code-block:: lua

    box.schema.user.grant('testuser','create','role')
    box.schema.user.grant('testuser', 'read,write', 'space', '_user')
    box.schema.user.grant('testuser', 'write', 'space', '_priv')


.. _access_control_grant_execute_code:

Executing code
~~~~~~~~~~~~~~

To let ``testuser`` execute Lua code, grant the ``execute`` privilege to the ``lua_eval`` object:

..  code-block:: lua

    box.schema.user.grant('testuser','execute','lua_eval')

Similarly, executing an arbitrary SQL expression requires the ``execute`` privilege to the ``sql`` object:

..  code-block:: lua

    box.schema.user.grant('testuser','execute','sql')





.. _creating_users_and_objects_granting_privileges:

Example
~~~~~~~

In the example below, the :ref:`created Lua function <box_schema-func_create>` is executed on behalf of its
creator, even if called by another user.

First, the two spaces (``space1`` and ``space2``) are created, and a no-password user (``private_user``)
is granted full access to them. Then ``read_and_modify`` is defined and ``private_user`` becomes this function's creator.
Finally, another user (``public_user``) is granted access to execute Lua functions created by ``private_user``.

..  code-block:: lua

    box.schema.space.create('space1')
    box.schema.space.create('space2')
    box.space.space1:create_index('pk')
    box.space.space2:create_index('pk')

    box.schema.user.create('private_user')

    box.schema.user.grant('private_user', 'read,write', 'space', 'space1')
    box.schema.user.grant('private_user', 'read,write', 'space', 'space2')
    box.schema.user.grant('private_user', 'create', 'universe')
    box.schema.user.grant('private_user', 'read,write', 'space', '_func')

    function read_and_modify(key)
      local space1 = box.space.space1
      local space2 = box.space.space2
      local fiber = require('fiber')
      local t = space1:get{key}
      if t ~= nil then
        space1:put{key, box.session.uid()}
        space2:put{key, fiber.time()}
      end
    end

    box.session.su('private_user')
    box.schema.func.create('read_and_modify', {setuid= true})
    box.session.su('admin')
    box.schema.user.create('public_user', {password = 'secret'})
    box.schema.user.grant('public_user', 'execute', 'function', 'read_and_modify')

Whenever ``public_user`` calls the function, it is executed on behalf of its creator, ``private_user``.




.. _access_control_list:

All object types and permissions
--------------------------------

.. _access_control_list_objects:

Object types
~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 20 80

        *   -   Object type
            -   Description
        *   -   ``universe``
            -   A database (:ref:`box.schema <box_schema>`) that contains database objects, including spaces, indexes, users, roles, sequences, and functions. Granting privileges to ``universe`` gives a user access to any object in the database.
        *   -   ``user``
            -   A :ref:`user <access_control_concepts_users>`.
        *   -   ``role``
            -   A :ref:`role <access_control_concepts_roles>`.
        *   -   ``space``
            -   A :ref:`space <index-box_space>`.
        *   -   ``function``
            -   A :ref:`function <box_schema-func_create>`.
        *   -   ``sequence``
            -   A :ref:`sequence <index-box_sequence>`.
        *   -   ``lua_eval``
            -   Executing arbitrary Lua code.
        *   -   ``lua_call``
            -   Calling any global user-defined Lua function.
        *   -   ``sql``
            -   Executing an arbitrary SQL expression.



.. _access_control_list_privileges:

Permissions
~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 15 15 15 55

        *   -   Permission
            -   Object type
            -   Granted to roles
            -   Description
        *   -   ``read``
            -   All
            -   Yes
            -   Allows reading data of the specified object.
                For example, this permission can be used to allow a user to select data from the specified space.
        *   -   ``write``
            -   All
            -   Yes
            -   Allows updating data of the specified object.
                For example, this permission can be used to allow a user to modify data in the specified space.
        *   -   ``create``
            -   All
            -   Yes
            -   Allows creating objects of the specified type.
                For example, this permission can be used to allow a user to create new spaces.

                Note that this permission requires read and write access to certain system spaces.
        *   -   ``alter``
            -   All
            -   Yes
            -   Allows altering objects of the specified type.

                Note that this permission requires read and write access to certain system spaces.
        *   -   ``drop``
            -   All
            -   Yes
            -   Allows dropping objects of the specified type.

                Note that this permission requires read and write access to certain system spaces.
        *   -   ``execute``
            -   ``role``, ``universe``, ``function``, ``lua_eval``, ``lua_call``, ``sql``
            -   Yes
            -   For ``role``, allows using the specified role.
                For other object types, allows calling a function.
        *   -   ``session``
            -   ``universe``
            -   No
            -   Allows a user to connect to an instance over IPROTO.
        *   -   ``usage``
            -   ``universe``
            -   No
            -   Allows a user to use their privileges on database objects (for example, read, write, and alter spaces).


.. _access_control_list_objects_and_privileges:

Object types and permissions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 15 85

        *   -   Object type
            -   Details
        *   -   ``universe``
            -   *   ``read``: Allows reading any object types, including all spaces or sequence objects.
                *   ``write``: Allows modifying any object types, including all spaces or sequence objects.
                *   ``execute``: Allows execute functions, Lua code, or SQL expressions, including IPROTO calls.
                *   ``session``: Allows a user to connect to an instance over IPROTO.
                *   ``usage``: Allows a user to use their privileges on database objects (for example, read, write, and alter space).
                *   ``create``: Allows creating users, roles, functions, spaces, and sequences.
                    This permission requires read and write access to certain system spaces.
                *   ``drop``: Allows creating users, roles, functions, spaces, and sequences.
                    This permission requires read and write access to certain system spaces.
                *   ``alter``: Allows altering user settings or space objects.
        *   -   ``user``
            -   *   ``alter``: Allows modifying a user description, for example, change the password.
                *   ``create``: Allows creating new users.
                    This permission requires read and write access to the ``_user`` system space.
                *   ``drop``: Allows dropping users.
                    This permission requires read and write access to the ``_user`` system space.
        *   -   ``role``
            -   *   ``execute``: Indicates that a role is assigned to the user or another role.
                *   ``create``: Allows creating new roles.
                    This permission requires read and write access to the ``_user`` system space.
                *   ``drop``: Allows dropping roles.
                    This permission requires read and write access to the ``_user`` system space.
        *   -   ``space``
            -   *   ``read``: Allows selecting data from a space.
                *   ``write``: Allows modifying data in a space.
                *   ``create``: Allows creating new spaces.
                    This permission requires read and write access to the ``_space`` system space.
                *   ``drop``: Allows dropping spaces.
                    This permission requires read and write access to the ``_space`` system space.
                *   ``alter``: Allows modifying spaces.
                    This permission requires read and write access to the ``_space`` system space.

                    If a space is created by a user, they can read and write it without granting explicit permission.
        *   -   ``function``
            -   *   ``execute``: Allows calling a function.
                *   ``create``: Allows creating a function.
                    This permission requires read and write access to the ``_func`` system space.

                    If a function is created by a user, they can execute it without granting explicit permission.
                *   ``drop``: Allows dropping a function.
                    This permission requires read and write access to the ``_func`` system space.
        *   -   ``sequence``
            -   *   ``read``: Allows using sequences in ``space_obj:create_index()``.
                *   ``write``: Allows all operations for a sequence object.

                    ``seq_obj:drop()`` requires a write permission to the ``_priv`` system space.
                *   ``create``: Allows creating sequences.
                    This permission requires read and write access to the ``_sequence`` system space.

                    If a sequence is created by a user, they can read/write it without explicit permission.
                *   ``drop``: Allows dropping sequences.
                    This permission requires read and write access to the ``_sequence`` system space.
                *   ``alter``:  Has no effect.
                    ``seq_obj:alter()`` and other methods require the ``write`` permission.
        *   -   ``lua_eval``
            -   *   ``execute``: Allows executing arbitrary Lua code using the IPROTO_EVAL request.
        *   -   ``lua_call``
            -   *   ``execute``: Allows executing any user-defined function using the IPROTO_CALL request.
                    This permission doesn't allow a user to call built-in Lua functions (for example, ``loadstring()`` or ``box.session.su()``) and functions defined in the ``_func`` system space.
        *   -   ``sql``
            -   *   ``execute``: Allows executing arbitrary SQL expression using the IPROTO_PREPARE and IPROTO_EXECUTE requests.

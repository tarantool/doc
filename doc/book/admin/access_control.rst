.. _authentication:

================================================================================
Access control
================================================================================

This section explains how Tarantool makes it possible for administrators
to prevent unauthorized access to the database and to certain functions.

Briefly:

* There is a method to guarantee with password checks that users really are
  who they say they are (“authentication”).

* There is a :ref:`_user <box_space-user>` system space, where usernames and
  password-hashes are stored.

* There are functions for saying that certain users are allowed to do certain
  things (“privileges”).

* There is a :ref:`_priv <box_space-priv>` system space, where privileges are
  stored. Whenever a user tries to do an operation, there is a check whether
  the user has the privilege to do the operation (“access control”).

Details follow.

.. _authentication-users:

--------------------------------------------------------------------------------
Users
--------------------------------------------------------------------------------

There is a **current user** for any program working with Tarantool,
local or remote.
If a remote connection is using a :ref:`binary port <admin-security>`,
the current user, by default, is '**guest**'.
If the connection is using an :ref:`admin-console port <admin-security>`,
the current user is '**admin**'.
When executing a :ref:`Lua initialization script <index-init_label>`,
the current user is also ‘**admin**’.

The current user name can be found with
:doc:`/reference/reference_lua/box_session/user`.

The current user can be changed:

* For a binary port connection -- with the
  :ref:`AUTH protocol command <box_protocol-iproto_protocol>`, supported
  by most clients;

* For an admin-console connection and in a Lua initialization script --
  with :doc:`/reference/reference_lua/box_session/su`;

* For a binary-port connection invoking a stored function with the CALL command --
  if the :doc:`SETUID </reference/reference_lua/box_schema/func_create>`
  property is enabled for the function,
  Tarantool temporarily replaces the current user with the
  function’s creator, with all the creator's privileges, during function execution.

.. _authentication-passwords:

--------------------------------------------------------------------------------
Passwords
--------------------------------------------------------------------------------

Each user (except 'guest') may have a **password**.
The password is any alphanumeric string.

Tarantool passwords are stored in the :ref:`_user <box_space-user>`
system space with a
`cryptographic hash function <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_
so that, if the password is ‘x’, the stored hash-password is a long string
like ‘lL3OvhkIPOKh+Vn9Avlkx69M/Ck=‘.
Tarantool supports two protocols for authenticating users:

*   `CHAP <https://en.wikipedia.org/wiki/Challenge-Handshake_Authentication_Protocol>`_ with ``SHA-1`` hashing

    In this case, password hashes are stored in the ``_user`` space `unsalted <https://en.wikipedia.org/wiki/Salt_(cryptography)>`_.
    For example, if an attacker gains access to the database, they may crack a password using a `rainbow table <https://en.wikipedia.org/wiki/Rainbow_table>`_.

*   `PAP <https://en.wikipedia.org/wiki/Password_Authentication_Protocol>`_ with ``SHA256`` hashing (Tarantool Enterprise)

    For PAP, a password is salted with a user-unique salt before saving it in the ``_user`` space.
    This keeps the database protected from cracking using a rainbow table.
    Note that PAP sends a password as plain text, so you need to configure SSL/TLS for a connection.

There are two functions for managing passwords in Tarantool:

*   :doc:`/reference/reference_lua/box_schema/user_passwd` allows you to change a user's password.

*   :doc:`/reference/reference_lua/box_schema/user_password` returns a hash of a user's password.

Tarantool Enterprise also allows you to improve database security by enforcing the use of strong passwords, setting up a maximum password age, and so on. Learn more from the `Access control <https://www.tarantool.io/en/enterprise_doc/security/#access-control>`__ section.



.. _authentication-owners_privileges:

--------------------------------------------------------------------------------
Owners and privileges
--------------------------------------------------------------------------------

Tarantool has one database. It may be called "box.schema" or "universe".
The database contains database objects, including
spaces, indexes, users, roles, sequences, and functions.

The **owner** of a database object is the user who created it.
The owner of the database itself, and the owner of objects that
are created initially (the system spaces and the default users)
is '**admin**'.

Owners automatically have **privileges** for what they create.
They can share these privileges with other users or with roles,
using :doc:`/reference/reference_lua/box_schema/user_grant` requests.
The following privileges can be granted:

* 'read', e.g. allow select from a space
* 'write', e.g. allow update on a space
* 'execute', e.g. allow call of a function, or (less commonly) allow use of a role
* 'create', e.g. allow
  :doc:`box.schema.space.create </reference/reference_lua/box_schema/user_create>`
  (access to certain system spaces is also necessary)
* 'alter', e.g. allow
  :doc:`box.space.x.index.y:alter </reference/reference_lua/box_index/alter>`
  (access to certain system spaces is also necessary)
* 'drop', e.g. allow
  :doc:`box.sequence.x:drop </reference/reference_lua/box_schema_sequence/drop>`
  (access to certain system spaces is also necessary)
* 'usage', e.g. whether any action is allowable regardless of other
  privileges (sometimes revoking 'usage' is a convenient way to
  block a user temporarily without dropping the user)
* 'session', e.g. whether the user can 'connect'.

To **create** objects, users need the 'create' privilege and
at least 'read' and 'write' privileges
on the system space with a similar name (for example, on the
:ref:`_space <box_space-space>` if the user needs to create spaces).

To **access** objects, users need an appropriate privilege
on the object (for example, the 'execute' privilege on function F
if the users need to execute function F). See below some
:ref:`examples for granting specific privileges <authentication-owners_privileges-examples-specific>`
that a grantor -- that is, 'admin' or the object creator -- can make.

To drop an object, a user must be an 'admin' or have the 'super' role.
Some objects may also be dropped by their creators.
As the owner of the entire database, any 'admin' can drop any object,
including other users.

To grant privileges to a user, the object owner says
:doc:`/reference/reference_lua/box_schema/user_grant`.
To revoke privileges from a user, the object owner says
:doc:`/reference/reference_lua/box_schema/user_revoke`.
In either case, there are up to five parameters:

.. code-block:: lua

    (user-name, privilege, object-type [, object-name [, options]])

* ``user-name`` is the user (or role) that will receive or lose the privilege;
* ``privilege`` is any of 'read', 'write', 'execute', 'create', 'alter', 'drop',
  'usage', or 'session' (or a comma-separated list);
* ``object-type`` is any of 'space', 'index',
  'sequence', 'function', 'user', 'role', or 'universe';
* ``object-name`` is what the privilege is for
  (omitted if ``object-type`` is 'universe')
  (may be omitted or ``nil`` if the intent is to grant for all objects of the same type);
* ``options`` is a list inside braces, for example ``{if_not_exists=true|false}``
  (usually omitted because the default is acceptable).

  All updates of user privileges are reflected immediately in the existing sessions
  and objects, e.g. functions.

**Example for granting many privileges at once**

In this example an 'admin' user grants many privileges on
many objects to user 'U', using a single request.

.. code-block:: lua

    box.schema.user.grant('U','read,write,execute,create,drop','universe')

.. _authentication-owners_privileges-examples-specific:

**Examples for granting privileges for specific operations**

In these examples an administrator grants strictly
the minimal privileges necessary for particular operations,
to user 'U'.

.. code-block:: lua

    -- So that 'U' can create spaces:
      box.schema.user.grant('U','create','space')
      box.schema.user.grant('U','write', 'space', '_schema')
      box.schema.user.grant('U','write', 'space', '_space')
    -- So that 'U' can  create indexes on space T
      box.schema.user.grant('U','create,read','space','T')
      box.schema.user.grant('U','read,write','space','_space_sequence')
      box.schema.user.grant('U','write', 'space', '_index')
    -- So that 'U' can  alter indexes on space T (assuming 'U' did not create the index)
      box.schema.user.grant('U','alter','space','T')
      box.schema.user.grant('U','read','space','_space')
      box.schema.user.grant('U','read','space','_index')
      box.schema.user.grant('U','read','space','_space_sequence')
      box.schema.user.grant('U','write','space','_index')
    -- So that 'U' can alter indexes on space T (assuming 'U' created the index)
      box.schema.user.grant('U','read','space','_space_sequence')
      box.schema.user.grant('U','read,write','space','_index')
    -- So that 'U' can create users:
      box.schema.user.grant('U','create','user')
      box.schema.user.grant('U', 'read,write', 'space', '_user')
      box.schema.user.grant('U', 'write', 'space', '_priv')
    -- So that 'U' can create roles:
      box.schema.user.grant('U','create','role')
      box.schema.user.grant('U', 'read,write', 'space', '_user')
      box.schema.user.grant('U', 'write', 'space', '_priv')
    -- So that 'U' can create sequence generators:
      box.schema.user.grant('U','create','sequence')
      box.schema.user.grant('U', 'read,write', 'space', '_sequence')
    -- So that 'U' can create functions:
      box.schema.user.grant('U','create','function')
      box.schema.user.grant('U','read,write','space','_func')
    -- So that 'U' can create any object of any type
      box.schema.user.grant('guest','read,write,create','universe')
    -- So that 'U' can grant access on objects that 'U' created
      box.schema.user.grant('U','write','space','_priv')
    -- So that 'U' can select or get from a space named 'T'
      box.schema.user.grant('U','read','space','T')
    -- So that 'U' can update or insert or delete or truncate a space named 'T'
      box.schema.user.grant('U','write','space','T')
    -- So that 'U' can execute a function named 'F'
      box.schema.user.grant('U','execute','function','F')
    -- So that 'U' can use the "S:next()" function with a sequence named S
      box.schema.user.grant('U','read,write','sequence','S')
    -- So that 'U' can use the "S:set()" or "S:reset() function with a sequence named S
      box.schema.user.grant('U','write','sequence','S')
    -- So that 'U' can drop a sequence (assuming 'U' did not create it)
      box.schema.user.grant('U','drop','sequence')
      box.schema.user.grant('U','write','space','_sequence_data')
      box.schema.user.grant('U','write','space','_sequence')
    -- So that 'U' can drop a function (assuming 'U' did not create it)
      box.schema.user.grant('U','drop','function')
      box.schema.user.grant('U','write','space','_func')
    -- So that 'U' can drop a space that has some associated objects
      box.schema.user.grant('U','create,drop','space')
      box.schema.user.grant('U','write','space','_schema')
      box.schema.user.grant('U','write','space','_space')
      box.schema.user.grant('U','write','space','_space_sequence')
      box.schema.user.grant('U','read','space','_trigger')
      box.schema.user.grant('U','read','space','_fk_constraint')
      box.schema.user.grant('U','read','space','_ck_constraint')
      box.schema.user.grant('U','read','space','_func_index')
    -- So that 'U' can drop any space (ignore if the privilege exists already)
      box.schema.user.grant('U','drop','space',nil,{if_not_exists=true})

**Example for creating users and objects then granting privileges**

Here a Lua function is created that will be executed under the user ID of its
creator, even if called by another user.

First, the two spaces ('u' and 'i') are created, and a no-password user ('internal')
is granted full access to them. Then a ('read_and_modify') is defined and the
no-password user becomes this function's creator. Finally, another user
('public_user') is granted access to execute Lua functions created by the no-password user.

.. code-block:: lua

    box.schema.space.create('u')
    box.schema.space.create('i')
    box.space.u:create_index('pk')
    box.space.i:create_index('pk')

    box.schema.user.create('internal')

    box.schema.user.grant('internal', 'read,write', 'space', 'u')
    box.schema.user.grant('internal', 'read,write', 'space', 'i')
    box.schema.user.grant('internal', 'create', 'universe')
    box.schema.user.grant('internal', 'read,write', 'space', '_func')

    function read_and_modify(key)
      local u = box.space.u
      local i = box.space.i
      local fiber = require('fiber')
      local t = u:get{key}
      if t ~= nil then
        u:put{key, box.session.uid()}
        i:put{key, fiber.time()}
      end
    end

    box.session.su('internal')
    box.schema.func.create('read_and_modify', {setuid= true})
    box.session.su('admin')
    box.schema.user.create('public_user', {password = 'secret'})
    box.schema.user.grant('public_user', 'execute', 'function', 'read_and_modify')

.. _authentication-roles:

--------------------------------------------------------------------------------
Roles
--------------------------------------------------------------------------------

A **role** is a container for privileges which can be granted to regular users.
Instead of granting or revoking individual privileges, you can put all the
privileges in a role and then grant or revoke the role.

Role information is stored in the :ref:`_user <box_space-user>` space, but
the third field in the tuple -- the type field -- is ‘role’ rather than ‘user’.

An important feature in role management is that roles can be **nested**.
For example, role R1 can be granted a privileged "role R2", so users with the
role R1 will subsequently get all privileges from both roles R1 and R2.
In other words, a user gets all the privileges granted to a user’s roles,
directly or indirectly.

There are actually two ways to grant or revoke a role:
:samp:`box.schema.user.grant-or-revoke({user-name-or-role-name},'execute', 'role',{role-name}...)`
or
:samp:`box.schema.user.grant-or-revoke({user-name-or-role-name},{role-name}...)`.
The second way is preferable.

The 'usage' and 'session' privileges cannot be granted to roles.

**Example**

.. code-block:: lua

   -- This example will work for a user with many privileges, such as 'admin'
   -- or a user with the pre-defined 'super' role
   -- Create space T with a primary index
   box.schema.space.create('T')
   box.space.T:create_index('primary', {})
   -- Create the user U1 so that later the current user can be changed to U1
   box.schema.user.create('U1')
   -- Create two roles, R1 and R2
   box.schema.role.create('R1')
   box.schema.role.create('R2')
   -- Grant role R2 to role R1 and role R1 to user U1 (order doesn't matter)
   -- There are two ways to grant a role; here the shorter way is used
   box.schema.role.grant('R1', 'R2')
   box.schema.user.grant('U1', 'R1')
   -- Grant read/write privileges for space T to role R2
   -- (but not to role R1, and not to user U1)
   box.schema.role.grant('R2', 'read,write', 'space', 'T')
   -- Change the current user to user U1
   box.session.su('U1')
   -- An insertion to space T will now succeed because (due to nested roles)
   -- user U1 has write privilege on space T
   box.space.T:insert{1}

More details are to be found in
:doc:`/reference/reference_lua/box_schema/user_grant` and
:doc:`/reference/reference_lua/box_schema/role_grant` in
the built-in modules reference.

.. _authentication-sessions:

--------------------------------------------------------------------------------
Sessions and security
--------------------------------------------------------------------------------

A **session** is the state of a connection to Tarantool. It contains:

* An integer ID identifying the connection,
* the :ref:`current user <authentication-users>` associated with the connection,
* text description of the connected peer, and
* session local state, such as Lua variables and functions.

In Tarantool, a single session can execute multiple concurrent transactions.
Each transaction is identified by a unique integer ID, which can be queried
at start of the transaction using :doc:`/reference/reference_lua/box_session/sync`.

.. NOTE::

   To track all connects and disconnects, you can use
   :ref:`connection and authentication triggers <triggers>`.

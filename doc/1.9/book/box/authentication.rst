.. _authentication:

================================================================================
Access control
================================================================================

Understanding security details is primarily an issue for administrators.
Meanwhile, ordinary users should at least skim this section to get an idea
of how Tarantool makes it possible for administrators to prevent unauthorized
access to the database and to certain functions.

In a nutshell:

* There is a method to guarantee with password checks that users really are
  who they say they are (“authentication”).

* There is a :ref:`_user <box_space-user>` system space, where usernames and
  password-hashes are stored.

* There are functions for saying that certain users are allowed to do certain
  things (“privileges”).

* There is a :ref:`_priv <box_space-priv>` system space, where privileges are
  stored. Whenever a user tries to do an operation, there is a check whether
  the user has the privilege to do the operation (“access control”).

Further on, we explain all of this in more detail.

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
the current user is also ‘admin’.

The current user name can be found with :ref:`box.session.user() <box_session-user>`.

The current user can be changed:

* For a binary port connection -- with AUTH protocol command, supported
  by most clients;

* For an admin-console connection and in a Lua initialization script --
  with :ref:`box.session.su <box_session-su>`;

* For a stored function invoked with CALL command over a binary port --
  with :ref:`SETUID <box_schema-func_create>` property enabled for the function,
  which makes Tarantool temporarily replace the current user with the
  function’s creator, with all creator's privileges, during function execution.

.. _authentication-passwords:

--------------------------------------------------------------------------------
Passwords
--------------------------------------------------------------------------------

Each user (except 'guest') may have a **password**. The password is any alphanumeric string.

Tarantool passwords are stored in the :ref:`_user <box_space-user>`
system space with a
`cryptographic hash function <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_
so that, if the password is ‘x’, the stored hash-password is a long string
like ‘lL3OvhkIPOKh+Vn9Avlkx69M/Ck=‘.
When a client connects to a Tarantool instance, the instance sends a random
`salt value <https://en.wikipedia.org/wiki/Salt_%28cryptography%29>`_
which the client must mix with the hashed-password before sending
to the instance. Thus the original value ‘x’ is never stored anywhere except
in the user’s head, and the hashed value is never passed down a network wire
except when mixed with a random salt.

.. NOTE::

   For more details of the password hashing algorithm (e.g. for the purpose of writing
   a new client application), read the
   `scramble.h <https://github.com/tarantool/tarantool/blob/1.9/src/scramble.h>`_
   header file.

This system prevents malicious onlookers from finding passwords by snooping
in the log files or snooping on the wire. It is the same system that
`MySQL introduced several years ago <http://dev.mysql.com/doc/refman/5.7/en/password-hashing.html>`_,
which has proved adequate for medium-security installations.
Nevertheless, administrators should warn users that no system
is foolproof against determined long-term attacks, so passwords should be
guarded and changed occasionally. Administrators should also advise users to
choose long unobvious passwords, but it is ultimately up to the users to choose
or change their own passwords.

There are two functions for managing passwords in Tarantool:
:ref:`box.schema.user.password() <box_schema-user_password>` for changing
a user's password and :ref:`box.schema.user.passwd() <box_schema-user_passwd>`
for getting a hash-password.

.. _authentication-owners_privileges:

--------------------------------------------------------------------------------
Owners and privileges
--------------------------------------------------------------------------------

Tarantool has one database. It may be called "box.schema" or "universe".
The database contains database objects, including
spaces, indexes, users, roles, sequences, and functions.

The **owner** of a database object is the user who created it.
The owner of the database itself, and the owner of objects that
are created initially -- the system spaces and the default users --
is 'admin'.

Owners automatically have **privileges** for what they create.
They can share these privileges with other users or with roles,
using **box.user.grant** requests. 
The following privileges can be granted:

* 'read', e.g. allow select from a space
* 'write', e.g. allow update on a space
* 'execute', e.g. allow call of a function
* 'create', e.g. allow
  :ref:`box.schema.space.create <box_schema-space_create>`
  (currently this can be granted but has no effect)
* 'alter', e.g. allow
  :ref:`box.space.x.index.y:alter <box_index-alter>`
  (currently this can be granted but has no effect)
* 'drop', e.g. allow
  :ref:`box.sequence.x:drop <box_schema-sequence_drop>`
  (currently this can be granted but has no effect)
* 'usage', e.g. whether any action is allowable regardless of other
  privileges (sometimes revoking 'usage' is a convenient way to
  block a user temporarily without dropping the user)
* 'session', e.g. whether the user can 'connect'.

To **create** objects, users need at least 'read' and 'write' privileges
on the system space with a similar name (for example, on the
:ref:`_space <box_space-space>` if the user needs to create spaces).
To **access** objects, users need an appropriate privilege
on the object (for example, the 'execute' privilege on function F
if the users need to execute function F). The exact "grant" requests
by the grantor (that is, 'admin' or the object creator)
are in the "Examples for granting specific privileges", below.

To **drop** an object, users must be the object's creator or be 'admin'.
As the owner of the entire database, 'admin' can drop any object including
other users.

To grant privileges to a user, the object owner says :ref:`grant() <box_schema-user_grant>`.
To revoke privileges from a user, the object owner says :ref:`revoke() <box_schema-user_revoke>`.
In either case, there are three or four parameters:
(user-name, privilege, object-type [, object-name]).

``user-name`` is the user (or role) that will receive or lose the privilege;
``privilege`` is 'read' or 'write or
'execute' or 'create' or 'alter' or 'drop' or 'usage' or 'session'
(or a comma-sepated list);
``object-type`` is 'space' or 'index' or
'sequence' or 'function' or role-name, or 'universe';
``object-name`` is what the privilege is for
(or is omitted if ``object-type`` is 'universe').

**Example for granting many privileges at once**

In this example user 'admin' grants many privileges on
many objects to user 'U', with a single request.

.. code-block:: lua_tarantool

    box.schema.user.grant('U','read,write,execute,create,drop','universe')

**Examples for granting privileges for specific operations**

In these examples the object's creator grants precisely
the minimal privileges necessary for particular operations,
to user 'U'.

.. code-block:: lua_tarantool

    -- So that 'U' can create spaces:
      box.schema.user.grant('U','write', 'space', '_schema')
      box.schema.user.grant('U','read,write', 'space', '_space')
    -- So that 'U' can  create indexes (assuming 'U' is the owner of the space)
      box.schema.user.grant('U','read', 'space', '_space')
      box.schema.user.grant('U','read,write', 'space', '_index')
    -- So that 'U' can create users or roles:
      box.schema.user.grant('U','read,write', 'space', '_user')
      box.schema.user.grant('U','read,write','space', '_priv')
    -- So that 'U' can create sequences:
      box.schema.user.grant('U','read,write','space','_sequence')
    -- So that 'U' can create functions:
      box.schema.user.grant('U','read,write','space','_func')
    -- So that 'U' can grant access on objects that 'U' created
      box.schema.user.grant('U','read','space','_user')
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

**Example for creating users and objects then granting privileges**

Here we create a Lua function that will be executed under the user id of its
creator, even if called by another user.

First, we create two spaces ('u' and 'i') and grant a no-password user ('internal')
full access to them. Then we define a function ('read_and_modify') and the
no-password user becomes this function's creator. Finally, we grant another user
('public_user') access to execute Lua functions created by the no-password user.

.. code-block:: lua_tarantool

   box.schema.space.create('u')
   box.schema.space.create('i')
   box.space.u:create_index('pk')
   box.space.i:create_index('pk')

   box.schema.user.create('internal')

   box.schema.user.grant('internal', 'read,write', 'space', 'u')
   box.schema.user.grant('internal', 'read,write', 'space', 'i')
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
For example, role R1 can be granted a privilege "role R2", so users with the
role R1 will subsequently get all privileges from both roles R1 and R2.
In other words, a user gets all the privileges that are granted to a user’s
roles, directly or indirectly.

The 'usage' and 'session' privileges cannot be granted to roles.

**Example**

.. code-block:: lua

   -- This example will work for a user with many privileges, such as 'admin'
   -- or a user with the pre-defined 'super' role
   -- Create space T with a primary index
   box.schema.space.create('T')
   box.space.T:create_index('primary', {})
   -- Create user U1 so that later we can change the current user to U1
   box.schema.user.create('U1')
   -- Create two roles, R1 and R2
   box.schema.role.create('R1')
   box.schema.role.create('R2')
   -- Grant role R2 to role R1 and role R1 to user U1 (order doesn't matter)
   box.schema.role.grant('R1', 'execute', 'role', 'R2')
   box.schema.user.grant('U1', 'execute', 'role', 'R1')
   -- Grant read/write privileges for space T to role R2
   -- (but not to role R1 and not to user U1)
   box.schema.role.grant('R2', 'read,write', 'space', 'T')
   -- Change the current user to user U1
   box.session.su('U1')
   -- An insertion to space T will now succeed because, due to nested roles,
   -- user U1 has write privilege on space T
   box.space.T:insert{1}

For details about Tarantool functions related to role management, see
reference on :ref:`box.schema <box_schema>` submodule.

.. _authentication-sessions:

--------------------------------------------------------------------------------
Sessions and security
--------------------------------------------------------------------------------

A **session** is the state of a connection to Tarantool. It contains:

* an integer id identifying the connection,
* the :ref:`current user <authentication-users>` associated with the connection,
* text description of the connected peer, and
* session local state, such as Lua variables and functions.

In Tarantool, a single session can execute multiple concurrent transactions.
Each transaction is identified by a unique integer id, which can be queried
at start of the transaction using :ref:`box.session.sync() <box_session-sync>`.

.. NOTE::

   To track all connects and disconnects, you can use
   :ref:`connection and authentication triggers <triggers>`.

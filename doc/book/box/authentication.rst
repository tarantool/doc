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

There is a notion of the **current user** in any program working with Tarantool,
local or remote.
If a remote connection is using the
:ref:`binary protocol <administration-admin_ports>`,
the current user, by default, is '**guest**'.
If the connection is using the :ref:`text protocol <administration-admin_ports>`,
its current user is '**admin**'.
When executing a :ref:`Lua initialization script <index-init_label>`,
Tarantool’s current user is also ‘admin’.

The current user can be changed:

* For a binary protocol connection -- with AUTH protocol command, supported
  by most clients;

* For a text protocol connection and in a Lua initialization script --
  with :ref:`box.session.su <box_session-su>`;

* For a stored function invoked with CALL command over the binary protocol -- 
  with :ref:`SETUID <box_schema-func_create>` property enabled for the function,
  which makes Tarantool temporarily replace the current user with the
  function’s creator, with all creator's privileges, during function execution.

.. _authentication-passwords:

--------------------------------------------------------------------------------
Passwords
--------------------------------------------------------------------------------

Each user may have a **password**. The password is any alphanumeric string.

Tarantool passwords are stored in the :ref:`_user <box_space-user>`
system space with a
`cryptographic hash function <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_
so that, if the password is ‘x’, the stored hash-password is a long string
like ‘lL3OvhkIPOKh+Vn9Avlkx69M/Ck=‘.
When a client connects to a Tarantool server, the server sends a random
`salt value <https://en.wikipedia.org/wiki/Salt_%28cryptography%29>`_
which the client must mix with the hashed-password before sending
to the server. Thus the original value ‘x’ is never stored anywhere except
in the user’s head, and the hashed value is never passed down a network wire
except when mixed with a random salt.

.. NOTE::
   
   For more details of the password hashing algorithm (e.g. for the purpose of writing
   a new client application), read the
   `scramble.h <https://github.com/tarantool/tarantool/blob/1.7/src/scramble.h>`_
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

In Tarantool, all objects are organized into a hierarchy of ownership.
Ordinarily the **owner** of every object is its creator. The creator of the initial database
state (we call it ‘universe’) --  including the database itself,
the system spaces, the users -- is ‘admin’.

An object's owner can share some rights on the object by **granting privileges**
to other users. The following privileges are implemented:

* Read an object,
* Write, i.e. modify contents of an object,
* Execute, i.e. use an object (if the privilege makes sense for the object;
  for example, spaces can not be "executed", but functions can).

.. NOTE::

   Currently, "drop" and "grant" privileges can not be granted to other users.
   This possibility will be added in future versions of Tarantool.

This is how the privilege system works under the hood. To be able to create
objects, a user needs to have write access to Tarantool's system spaces.
The 'admin' user, who is at the top of the hierarchy and who is the ultimate
source of privileges, shares write access to a system space
(e.g. :ref:`_space <box_space-space>`) with some users. Now the users can
insert data into the system space (e.g. creating new spaces) and themselves
become creators/definers of new objects. For the objects they created, the users
can in turn share privileges with other users.

This is why only an object's owner can drop the object, but not other
ordinary users. Meanwhile, 'admin' can drop any object or delete any other user,
because 'admin' is the creator and ultimate owner of them all.

The syntax of all
:ref:`grant() <box_schema-user_grant>`/:ref:`revoke() <box_schema-user_revoke>`
commands in Tarantool follows this basic idea.

* Their first argument is "who gets" or "who is revoked" a grant.

* Their second argument is the type of privilege granted, or a list of privileges.

* Their third argument is the object type on which the privilege is granted.

* Their fourth and optional argument is the object name (‘universe' has no name,
  because there is only one ‘universe’, but you need to specify names for
  functions/users/spaces/etc).

**Example #1**

Here we disable all privileges and run Tarantool in the ‘no-privilege’ mode.

.. code-block:: lua_tarantool

    box.schema.user.grant('guest', 'read,write,execute', 'universe')

**Example #2**

Here we create a Lua function that will be executed under the user id of its creator,
even if called by another user.

First, we create two spaces ('u' and 'i') and grant a no-password user ('internal')
full access to them. Then we define a function ('read_and_modify') and the
no-password user becomes this function's creator. Finally, we grant another user
('public_user') access to execute Lua functions created by the no-password user.

.. code-block:: lua_tarantool

   box.schema.space.create('u')
   box.schema.space.create('i')
   box.schema.space.u:create_index('pk')
   box.schema.space.i:create_index('pk')

   box.schema.user.create(‘internal’)

   box.schema.user.grant('internal', 'read,write', 'space', 'u')
   box.schema.user.grant('internal', 'read,write', 'space', 'i')

   function read_and_modify(key)
     local u = box.space.u
     local i = box.space.i
     local fiber = require('fiber')
     local t = u:get{key}
     if t ~= nil
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

**Example**

.. code-block:: lua_tarantool

   -- This example will work for a user with many privileges, such as 'admin'
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

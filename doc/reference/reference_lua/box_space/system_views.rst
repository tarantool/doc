.. _box_space-sysviews:
    
System space views
==================

A system space view, also called a 'sysview', is a restricted read-only copy of a system space.

The system space views and the system spaces that they are associated with are: |br|
``_vcollation``, a view of :ref:`_collation <box_space-collation>`, |br|
``_vfunc``, a view of :ref:`_func <box_space-func>`, |br|
``_vindex``, a view of :ref:`_index <box_space-index>`, |br|
``_vpriv``, a view of :ref:`_priv <box_space-priv>`, |br|
``_vsequence``, a view of :ref:`_sequence <box_space-sequence>`, |br|
``_vspace``, a view of :ref:`_space <box_space-space>`, |br|
``_vspace_sequence``, a view of :ref:`_space_sequence <box_space-space-sequence>`, |br|
``_vuser``, a view of :ref:`_user <box_space-user>`.

The structure of a system space view's tuples is identical to the
structure of the associated space's tuples. However, the privileges for a
system space view are usually different. By default, ordinary users do not have
any privileges for most system spaces, but have a 'read' privilege for system space views.

Typically this is the default situation: |br|
* :ref:`The 'public' role <box_space-user>` has 'read' privilege on all system space views
because that is the situation when the database is first created. |br|
* All users have the 'public' role, because it is granted
to them automatically during :ref:`box.schema.user.create() <box_schema-user_create>`. |br|
* The system space view will contain the tuples in the associated system space,
if and only if the user has a privilege for the object named in the tuple. |br|
Unless administrators change the privileges, the effect is that non-administrator
users cannot access the system space, but they can access the system space view, which shows
only the objects that they can access.

For example, typically, the 'admin' user can do anything with ``_space`` and ``_vspace``
looks the same as ``_space``. But the 'guest' user can only read ``_vspace``, and
``_vspace`` contains fewer tuples than ``_space``. Therefore in most installations
the 'guest' user should select from ``_vspace`` to get a list of spaces.

**Example:**
    
This example shows the difference between ``_vuser`` and ``_user``.
We have explained that:    
If the user has the full set of privileges (like 'admin'), the contents
of ``_vuser`` match the contents of ``_user``. If the user has limited
access, ``_vuser`` contains only tuples accessible to this user.

To see how ``_vuser`` works,
connect to a Tarantool database remotely
via ``net.box`` and select all tuples from the ``_user``
space, both when the 'guest' user *is* and *is not* allowed to read from the
database.

First, start Tarantool and grant read, write and execute
privileges to the ``guest`` user:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}
    ---
    ...
    tarantool> box.schema.user.grant('guest', 'read,write,execute', 'universe')
    ---
    ...

Switch to the other terminal, connect to the Tarantool instance and select all
tuples from the ``_user`` space:

.. code-block:: tarantoolsession

    tarantool> conn = require('net.box').connect(3301)
    ---
    ...
    tarantool> conn.space._user:select{}
    ---
    - - [0, 1, 'guest', 'user', {}]
      - [1, 1, 'admin', 'user', {}]
      - [2, 1, 'public', 'role', {}]
      - [3, 1, 'replication', 'role', {}]
      - [31, 1, 'super', 'role', {}]
    ...

This result contains the same set of users as if you made the request from your
Tarantool instance as 'admin'.

Switch to the first terminal and revoke the read privileges from the 'guest' user:

.. code-block:: tarantoolsession

    tarantool> box.schema.user.revoke('guest', 'read', 'universe')
    ---
    ...

Switch to the other terminal, stop the session (to stop ``tarantool`` type Ctrl+C
or Ctrl+D), start again, connect again, and repeat the
``conn.space._user:select{}`` request. The access is denied:

.. code-block:: tarantoolsession

    tarantool> conn.space._user:select{}
    ---
    - error: Read access to space '_user' is denied for user 'guest'
    ...

However, if you select from ``_vuser`` instead, the users' data available for the
'guest' user is displayed:

.. code-block:: tarantoolsession

    tarantool> conn.space._vuser:select{}
    ---
    - - [0, 1, 'guest', 'user', {}]
    ...

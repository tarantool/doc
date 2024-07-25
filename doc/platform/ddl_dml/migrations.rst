..  _migrations:

Migrations
==========

**Migration** refers to any change in a data schema: adding/removing a field,
creating/dropping an index, changing a field format, etc.

In Tarantool, there are two types of schema migration
that do not require data migration:

-   adding a field to the end of a space

-   creating an index

..  note::

    Check the :ref:`Upgrading space schema <enterprise-space_upgrade>` section.
    With the help of ``space:upgrade()``,
    you can enable compression and migrate, including already created tuples.


Adding a field to the end of a space
------------------------------------

You can add a field as follows:

..  code:: lua

    local users = box.space.users
    local fmt = users:format()

    table.insert(fmt, { name = 'age', type = 'number', is_nullable = true })
    users:format(fmt)

Note that the field must have the ``is_nullable`` parameter. Otherwise,
an error will occur.

After creating a new field, you probably want to fill it with data.
The `tarantool/moonwalker <https://github.com/tarantool/moonwalker>`_
module is useful for this task.
The README file describes how to work with this module.

Creating an index
-----------------

Index creation is described in the
:doc:`/reference/reference_lua/box_space/create_index` method.

..  _other-migrations:

Other types of migrations
-------------------------

Other types of migrations are also allowed, but it would be more difficult to
maintain data consistency.

Migrations are possible in two cases:

-   When Tarantool starts, and no client uses the database yet

-   During request processing, when active clients are already using the database

For the first case, it is enough to write and test the migration code.
The most difficult task is to migrate data when there are active clients.
You should keep it in mind when you initially design the data schema.

We identify the following problems if there are active clients:

-   Associated data can change atomically.

-   The system should be able to transfer data using both the new schema and the old one.

-   When data is being transferred to a new space, data access should consider
    that the data might be in one space or another.

-   Write requests must not interfere with the migration.
    A common approach is to write according to the new data schema.

These issues may or may not be relevant depending on your application and
its availability requirements.

What you need to know when writing complex migrations
-----------------------------------------------------

Tarantool has a transaction mechanism. It is useful when writing a migration,
because it allows you to work with the data atomically. But before using
the transaction mechanism, you should explore its limitations.

For details, see the section about :ref:`transactions <atomic-atomic_execution>`.

How you can apply migration
---------------------------

The migration code is executed on a running Tarantool instance.
Important: no method guarantees you transactional application of migrations
on the whole cluster.

**Method 1**: include migrations in the application code

This is quite simple: when you reload the code, the data is migrated at the right moment,
and the database schema is updated.
However, this method may not work for everyone.
You may not be able to restart Tarantool or update the code using the hot-reload mechanism.

**Method 2**: tarantool/migrations (only for a Tarantool Cartridge cluster)

This method is described in the README file of the
`tarantool/migrations <https://github.com/tarantool/migrations>`_ module.

..  note::

    There are also two other methods that we **do not recommend**,
    but you may find them useful for one reason or another.

    **Method 3**: the :ref:`tt <tt-cli>` utility

    Connect to the necessary instance using ``tt connect``.

    ..  code:: console

        $ tt connect admin:password@localhost:3301

    -   If your migration is written in a Lua file, you can execute it
        using ``dofile()``. Call this function and specify the path to the
        migration file as the first argument. It looks like this:

        ..  code-block:: tarantoolsession

            tarantool> dofile('0001-delete-space.lua')
            ---
            ...

    -   (or) Copy the migration script code,
        paste it into the console, and run it.

    You can also connect to the instance and execute the migration script in a single call:

    ..  code:: console

        $ tt connect admin:password@localhost:3301 -f 0001-delete-space.lua


    **Method 4**: applying migration with Ansible

    If you use the `Ansible role  <https://github.com/tarantool/ansible-cartridge>`_
    to deploy a Tarantool cluster, you can use ``eval``.
    You can find more information about it
    `in the Ansible role documentation <https://github.com/tarantool/ansible-cartridge/blob/master/doc/eval.md>`_.

..  toctree::
    :hidden:

    space_upgrade

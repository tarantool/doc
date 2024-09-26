..  _migrations:

Migrations
==========

TBD: rewrite

- what is migration: examples  изменение + первоначальное создание
- ce approach ?
- ee approach: centralized migration(s?) management
    - prereq: etcd, 3.x ee cluster w/etcd, tt-ee 2.4.0 || tcm,
        tarantool user with ~admin permissions
        advertise url required?
    - way to manage: tt and tcm (check diff implementation)
    - writing migrations:
        examples: create space (if_not_exists?), add index (with shard key), add index existing space,
        space upgrade: wait or just run in bg

    - general workflow + status
    - troubleshooting?





**Migration** refers to any change in a data schema: adding or removing a field,
creating or dropping an index, changing a field format, an so on. Space creation
is also a schema migration. You can use this fact to track the evolution of your
data schema since its initial state.

There are two types of migrations:

-   *simple migrations* don't require additional actions on existing data
-   *complex migrations* include both schema and data changes

In Tarantool, migrations are presented as Lua code that alters the data schema
using the built-in Lua API.

.. _migrations_simple:

Simple migrations
-----------------

In Tarantool, there are two types of schema migration that do not require data migration:

-   Creating an index. A new index can be created at any time. To learn more about
    index creation, see :ref:`concepts-data_model_indexes` and the :ref:`box_space-create_index` reference.
-   Adding a field to the end of a space. To add a field, update the space format so
    that it includes all its fields and also the new field. For example:

    .. code-block:: lua

        local users = box.space.users
        local fmt = users:format()

        table.insert(fmt, { name = 'age', type = 'number', is_nullable = true })
        users:format(fmt)

    The field must have the ``is_nullable`` parameter. Otherwise, an error occurs
    if the space contains tuples of old format.

    .. note::

        After creating a new field, you probably want to fill it with data.
        The `tarantool/moonwalker <https://github.com/tarantool/moonwalker>`_
        module is useful for this task.

.. _migrations_complex:

Complex migrations
------------------

Other types of migrations are more complex and require additional actions to
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

Tarantool offers the following features that make migrations easier and safer:

-   Transaction mechanism. It is useful when writing a migration,
    because it allows you to work with the data atomically. But before using
    the transaction mechanism, you should explore its limitations.
    For details, see the section about :ref:`transactions <atomic-atomic_execution>`.

-   ``space:upgrade()`` function (EE only). With the help of ``space:upgrade()``,
    you can enable compression and migrate, including already created tuples.
    For details, check the :ref:`Upgrading space schema <enterprise-space_upgrade>` section.

-   Centralized migration management mechanism (EE only). Implemented
    in the Enterprise version of the :ref:`tt <tt-cli>` utility and :ref:`tcm`,
    this mechanism enables migration execution and tracking in the replication
    clusters. For details, see :ref:`migrations_centralized`.

.. _migrations_apply:

Applying migrations
-------------------

The migration code is executed on a running Tarantool instance.
Important: no method guarantees you transactional application of migrations
on the whole cluster.

**Method 1**: include migrations in the application code

This is quite simple: when you reload the code, the data is migrated at the right moment,
and the database schema is updated.
However, this method may not work for everyone.
You may not be able to restart Tarantool or update the code using the hot-reload mechanism.


**Method 2**: the :ref:`tt <tt-cli>` utility

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

.. _migrations_centralized:

Centralized migration management
--------------------------------

..  admonition:: Enterprise Edition
    :class: fact

    Centralized migration management is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

Tarantool EE offers a mechanism for centralized migration management in replication
clusters that use etcd as a :ref:`configuration storage <configuration_etcd>`.
The mechanism uses the same etcd storage to store migrations and applies them
across the entire Tarantool cluster. This ensures migration consistency
in the cluster and enables migration history tracking.

The centralized migration management mechanism is implemented in the Enterprise
version of the :ref:`tt <tt-cli>` utility and in :ref:`tcm`.

To learn how to manage migrations in Tarantool EE clusters from the command line,
see :ref:`performing_migrations_tt`. To learn how to use the mechanism from the |tcm|
web interface, see the :ref:`tcm_migrations` |tcm| documentation page.

The ``tt`` implementation of the mechanism additionally includes commands for
troubleshooting migration issues. :ref:`troubleshooting_migrations_tt`.


..  toctree::

    space_upgrade
    performing_migrations_tt
    troubleshooting_migrations_tt

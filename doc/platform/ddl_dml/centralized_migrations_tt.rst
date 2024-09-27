..  _centralized_migrations_tt:

Centralized migrations with tt
==============================

**Example on GitHub:** `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations>`_

In this tutorial, you learn to use the centralized migration management mechanism
implemented in the Enterprise Edition of the :ref:`tt <tt-cli>` utility.

See also:

-   :ref:`tt migrations <tt-migrations>` for the full list of command-line options.
-   :ref:`tcm_cluster_migrations` to learn about managing migrations from |tcm_full_name|.

..  _centralized_migrations_tt_prereq:

Prerequisites
-------------

Before starting this tutorial:

-   Download and :ref:`install Tarantool Enterprise SDK <enterprise-install>`.
-   Install `etcd <https://etcd.io/>`__.

..  _centralized_migrations_tt_cluster:

Preparing a cluster
-------------------

The centralized migration mechanism works with Tarantool EE clusters that:

-   use etcd as a centralized configuration storage
-   use the `CRUD <https://github.com/tarantool/crud>`__ module for data sharding

..  _centralized_migrations_tt_cluster_etcd:

Setting up etcd
~~~~~~~~~~~~~~~

First, start up an etcd instance to use as a configuration storage:

.. code-block:: console

    $ etcd

etcd runs on the default port 2379.

Optionally, enable etcd authentication by executing the following script:

.. code-block:: bash

    #!/usr/bin/env bash

    etcdctl user add root:topsecret
    etcdctl role add app_config_manager
    etcdctl role grant-permission app_config_manager --prefix=true readwrite /myapp/
    etcdctl user add app_user:config_pass
    etcdctl user grant-role app_user app_config_manager
    etcdctl auth enable

It creates an etcd user ``app_user`` with read and write permissions to the ``/myapp``
prefix, in which the cluster configuration will be stored. The user's password is ``config_pass``.

.. note::

    If you don't enable etcd authentication, make ``tt migrations`` calls without
    the configuration storage credentials.

..  _centralized_migrations_tt_cluster_create:

Creating a cluster
~~~~~~~~~~~~~~~~~~

#.  Initialize a ``tt`` environment:

    .. code-block:: console

        $ tt init

#.   In the ``instances.enabled`` directory, create the ``myapp`` directory.
#.   Go to the ``instances.enabled/myapp`` directory and create application files:

    -    ``instances.yml``:

        ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/instances.yml
            :language: yaml
            :dedent:

    -    ``config.yaml``:

        ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/config.yaml
            :language: yaml
            :dedent:

    -   ``myapp-scm-1.rockspec``:

        ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/myapp-scm-1.rockspec
            :dedent:

4.  Create the ``source.yaml`` with a cluster configuration to publish to etcd:

    .. note::

        This configuration describes a typical CRUD-enabled sharded cluster with
        one router and two storage replica sets, each including one master and one read-only replica.

    ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/source.yaml
        :language: yaml
        :dedent:

#.  Publish the configuration to etcd:

    .. code-block:: console

        $ tt cluster publish "http://app_user:config_pass@localhost:2379/myapp/" source.yaml

The full cluster code is available on GitHub here: `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations/instances.enabled/myapp>`_.

..  _centralized_migrations_tt_cluster_start:

Building and starting the cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#.  Build the application:

    .. code-block:: console

        $ tt build myapp

#.  Start the cluster:

    .. code-block:: console

        $ tt start myapp

    To check that the cluster is up and running, use ``tt status``:

    .. code-block:: console

        $ tt status myapp

#.  Bootstrap vshard in the cluster:

    .. code-block:: console

        $ tt replicaset vshard bootstrap myapp

..  _centralized_migrations_tt_write:

Writing migrations
------------------

To perform migrations in the cluster, write them in Lua and publish to the cluster's
etcd configuration storage.

Each migration file must return a Lua table with one object named ``apply``.
This object has one field -- ``scenario`` -- that stores the migration function:

.. code-block:: lua

    local function apply_scenario()
        -- migration code
    end

    return {
        apply = {
            scenario = apply_scenario,
        },
    }

The migration unit is a single file: its ``scenario`` is executed as a whole. An error
that happens in any step of the ``scenario`` causes the entire migration to fail.

Migrations are executed in the lexicographical order. Thus, it's convenient to
use filenames that start with ordered numbers to define the migrations order, for example:

.. code-block:: text

    000001_create_space.lua
    000002_create_index.lua
    000003_alter_space.lua

The default location where ``tt`` searches for migration files is ``/migrations/scenario``.
Create this subdirectory inside the ``tt`` environment. Then, create two migration files:

-   ``000001_create_writers_space.lua``: create a space, define its format, and
    create a primary index.

    ..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000001_create_writers_space.lua
        :language: lua
        :dedent:

    .. note::

        Note the usage of the ``tt-migrations.helpers`` module.
        In this example, its function ``register_sharding_key`` is used
        to define a sharding key for the space.

-   ``000002_create_writers_index.lua``: add one more index.

    ..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000002_create_writers_index.lua
        :language: lua
        :dedent:

..  _centralized_migrations_tt_publish:

Publishing migrations
---------------------

To publish migrations to the etcd configuration storage, run ``tt migrations publish``:

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp
       • 000001_create_writes_space.lua: successfully published to key "000001_create_writes_space.lua"
       • 000002_create_writers_index.lua: successfully published to key "000002_create_writers_index.lua"

..  _centralized_migrations_tt_apply:

Applying migrations
-------------------

To apply published migrations to the cluster, run ``tt migrations apply`` providing
a cluster user's credentials:

.. code-block:: console

    $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp \
                          --tarantool-username=client --tarantool-password=secret

.. important::

    The cluster user must have enough access privileges to execute the migrations code.

The output should look as follows:

.. code-block:: console

       • router-001:
       •     000001_create_writes_space.lua: successfully applied
       •     000002_create_writers_index.lua: successfully applied
       • storage-001:
       •     000001_create_writes_space.lua: successfully applied
       •     000002_create_writers_index.lua: successfully applied
       • storage-002:
       •     000001_create_writes_space.lua: successfully applied
       •     000002_create_writers_index.lua: successfully applied

The migrations are applied on all replica set leaders. Read-only replicas
receive the changes from the corresponding replica set leaders.

Check the migrations status with ``tt migration status``:

.. code-block:: console

    $ tt migrations status http://app_user:config_pass@localhost:2379/myapp --tarantool-username=client --tarantool-password=secret
       • migrations centralized storage scenarios:
       •   000001_create_writes_space.lua
       •   000002_create_writers_index.lua
       • migrations apply status on Tarantool cluster:
       •   router-001:
       •     000001_create_writes_space.lua: APPLIED
       •     000002_create_writers_index.lua: APPLIED
       •   storage-001:
       •     000001_create_writes_space.lua: APPLIED
       •     000002_create_writers_index.lua: APPLIED
       •   storage-002:
       •     000001_create_writes_space.lua: APPLIED
       •     000002_create_writers_index.lua: APPLIED

To make sure that the space and indexes are created in the cluster, connect to the router
instance and retrieve the space information:

.. code-block:: $ tt connect myapp:router-001

.. code-block:: tarantoolsession

    myapp:router-001-a> require('crud').schema('writers')
    ---
    - indexes:
        0:
          unique: true
          parts:
          - fieldno: 1
            type: number
            exclude_null: false
            is_nullable: false
          id: 0
          type: TREE
          name: primary
        2:
          unique: true
          parts:
          - fieldno: 4
            type: number
            exclude_null: false
            is_nullable: false
          id: 2
          type: TREE
          name: age
      format: [{'name': 'id', 'type': 'number'}, {'type': 'number', 'name': 'bucket_id',
          'is_nullable': true}, {'name': 'name', 'type': 'string'}, {'name': 'age', 'type': 'number'}]
    ...

..  _centralized_migrations_tt_space_upgrade:

Complex migrations with space.upgrade()
---------------------------------------

Complex migrations require data migration along with schema migration. Insert some
tuples into the space before proceeding to the next steps:

.. code-block:: tarantoolsession

    myapp:router-001-a> require('crud').insert_object_many('writers', {
        {id = 1, name = 'Haruki Murakami', age = 75},
        {id = 2, name = 'Douglas Adams', age = 49},
        {id = 3, name = 'Eiji Mikage', age = 41},
    }, {noreturn = true})

The next migration changes the space format incompatibly: instead of one ``name``
field, the new format includes two fields ``first_name`` and ``last_name``.
To apply this migration, you need to change each tuple's structure preserving the stored
data. The :ref:`space.upgrade <enterprise-space_upgrade>` function helps with this task.

Create a new file ``000003_alter_writers_space.lua`` in ``/migrations/scenario``.
Prepare its initial structure the same way as in previous migrations:

.. code-block:: lua

    local function apply_scenario()
    --  migration code
    end
    return {
        apply = {
            scenario = apply_scenario,
        },
    }

Start the migration function with the new format description:

..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000003_alter_writers_space.lua
    :language: lua
    :start-at: local function apply_scenario()
    :end-at: box.space.writers.index.age:drop()
    :dedent:

.. note::

    ``box.space.writers.index.age:drop()`` drops an existing index. This is done
    because indexes rely on field numbers and may break during this format change.
    If you need the ``age`` field indexed, recreate the index after applying the
    new format.

Next, create a stored function that transforms tuples to fit the new format.
In this case, the functions extracts the first and the last name from the ``name`` field
and returns a tuple of the new format:

..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000003_alter_writers_space.lua
    :language: lua
    :start-at: box.schema.func.create
    :end-before: local future = space:upgrade
    :dedent:

Finally, call ``space:upgrade()`` with the new format and the transformation function
as its arguments. Here is the complete migration code:

..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000003_alter_writers_space.lua
    :language: lua
    :dedent:

Learn more about ``space.upgrade()`` execution in :ref:`enterprise-space_upgrade`.

Publish the new migration to etcd. Migrations that already exist in the storage are skipped.

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp
       • 000001_create_writes_space.lua: skipped, key "000001_create_writes_space.lua" already exists with the same content
       • 000002_create_writers_index.lua: skipped, key "000002_create_writers_index.lua" already exists with the same content
       • 000003_alter_writers_space.lua: successfully published to key "000003_alter_writers_space.lua"

.. note::

    You can also publish a single migration file by passing a path to it as an argument:

    .. code-block:: console

        $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp \
                                migrations/scenario/000003_alter_writers_space.lua

Apply the migrations:

.. code-block:: console

    $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp \
                          --tarantool-username=client --tarantool-password=secret

Connect to the router instance and check that the space and its tuples have the new format:

.. code-block:: $ tt connect myapp:router-001

.. code-block:: tarantoolsession

    myapp:router-001-a> require('crud').get('writers', 2)
    ---
    - rows: []
      metadata: [{'name': 'id', 'type': 'number'}, {'name': 'bucket_id', 'type': 'number'},
        {'name': 'first_name', 'type': 'string'}, {'name': 'last_name', 'type': 'string'},
        {'name': 'age', 'type': 'number'}]
    - null
    ...

..  _centralized_migrations_tt_new_instances:

Extending the cluster
---------------------

Having all migrations in a centralized etcd storage, you can extend the cluster
and consistently define the data schema on new instances on the fly.

Add one more storage replica set to the cluster. To do this, edit the cluster files in ``instances.enabled/myapp``:

-   ``instances.yml``: add the lines below to the end.

    ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/instances-3-storages.yml
        :language: yaml
        :start-at: storage-003-a:
        :dedent:

-   ``source.yaml``: add the lines below to the end.

    ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/source-3-storages.yaml
        :language: yaml
        :start-at: storage-003:
        :dedent:

Publish the new cluster configuration to etcd:

.. code-block:: console

    $ tt cluster publish "http://app_user:config_pass@localhost:2379/myapp/" source.yaml

Run ``tt start`` to start up the new instances:

.. code-block:: console

    $ tt start myapp
       • The instance myapp:router-001-a (PID = 61631) is already running.
       • The instance myapp:storage-001-a (PID = 61632) is already running.
       • The instance myapp:storage-001-b (PID = 61634) is already running.
       • The instance myapp:storage-002-a (PID = 61639) is already running.
       • The instance myapp:storage-002-b (PID = 61640) is already running.
       • Starting an instance [myapp:storage-003-a]...
       • Starting an instance [myapp:storage-003-b]...

Now the cluster contains three storage replica sets. The new one -- ``storage-003``--
is just started and has no data schema yet. Apply all stored migrations to the cluster
to load the same data schema to the new replica set:

.. code-block:: console

    $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp --tarantool-username=client --tarantool-password=secret
       • router-001:
       •     000001_create_writes_space.lua: skipped, already applied
       •     000002_create_writers_index.lua: skipped, already applied
       •     000003_alter_writers_space.lua: skipped, already applied
       • storage-001:
       •     000001_create_writes_space.lua: skipped, already applied
       •     000002_create_writers_index.lua: skipped, already applied
       •     000003_alter_writers_space.lua: skipped, already applied
       • storage-002:
       •     000001_create_writes_space.lua: skipped, already applied
       •     000002_create_writers_index.lua: skipped, already applied
       •     000003_alter_writers_space.lua: skipped, already applied
       • storage-003:
       •     000001_create_writes_space.lua: successfully applied
       •     000002_create_writers_index.lua: successfully applied
       •     000003_alter_writers_space.lua: successfully applied

To make sure that the space exists on the new instances, connect to ``storage-003-a``
and check ``box.space.writers``:

.. code-block:: console

    $ tt connect myapp:storage-003-a

.. code-block:: tarantoolsession

    myapp:storage-003-a> box.space.writers ~= nil
    ---
    - true
    ...

..  _centralized_migrations_tt_troubleshoot:

Troubleshooting migrations
--------------------------

.. warning::

    The options used for migration troubleshooting can cause migration inconsistency in the cluster.

Incorrect migration published
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Problem: an incorrect migration is published to etcd.
Solution: fix the migration file and publish it again with the ``--overwrite`` option:

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp --overwrite

If there are several migrations and the erroneous one isn't the last, add also ``--ignore-order-violation``:

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp --overwrite --ignore-order-violation

Incorrect migration applied
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the migration is already applied, publish the fixed version and apply it with
the ``--force-reapply`` option:

.. code-block:: console

    $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp \
                          --tarantool-username=client --tarantool-password=secret \
                          --force-reapply

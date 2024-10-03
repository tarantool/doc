..  _basic_migrations_tt:

Basic tt migrations tutorial
============================

**Example on GitHub:** `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations>`_

In this tutorial, you learn to define the cluster data schema using the centralized
migration management mechanism implemented in the Enterprise Edition of the :ref:`tt <tt-cli>` utility.

.. _basic_migrations_tt_prereq:

Prerequisites
-------------

Before starting this tutorial:

-   Download and :ref:`install Tarantool Enterprise SDK <enterprise-install>`.
-   Install `etcd <https://etcd.io/>`__.

..  _basic_migrations_tt_cluster:

Preparing a cluster
-------------------

The centralized migration mechanism works with Tarantool EE clusters that:

-   use etcd as a centralized configuration storage
-   use the `CRUD <https://github.com/tarantool/crud>`__ module or its Enterprise
    version for data distribution

..  _basic_migrations_tt_cluster_etcd:

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

..  _basic_migrations_tt_cluster_create:

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

#.  Create the ``source.yaml`` with a cluster configuration to publish to etcd:

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

..  _basic_migrations_tt_cluster_start:

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

..  _basic_migrations_tt_write:

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

..  _basic_migrations_tt_publish:

Publishing migrations
---------------------

To publish migrations to the etcd configuration storage, run ``tt migrations publish``:

.. code-block:: console

    $ tt migrations publish "http://app_user:config_pass@localhost:2379/myapp"
       • 000001_create_writes_space.lua: successfully published to key "000001_create_writes_space.lua"
       • 000002_create_writers_index.lua: successfully published to key "000002_create_writers_index.lua"

..  _basic_migrations_tt_apply:

Applying migrations
-------------------

To apply published migrations to the cluster, run ``tt migrations apply`` providing
a cluster user's credentials:

.. code-block:: console

    $ tt migrations apply "http://app_user:config_pass@localhost:2379/myapp" \
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

    $ tt migrations status "http://app_user:config_pass@localhost:2379/myapp" \
                           --tarantool-username=client --tarantool-password=secret
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

.. code-block:: console

    $ tt connect myapp:router-001-a

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

..  _basic_migrations_tt_next:

Next steps
----------

Learn to write and perform data migration in :ref:`upgrade_migrations_tt`.
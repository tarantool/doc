..  _centralized_migrations_tt:

Centralized migration management with tt
========================================

**Example on GitHub:** `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations>`_

In this tutorial, you learn to user the centralized migration management mechanism
implemented in the Enterprise Edition of the :ref:``tt <tt-cli>`` utility.


..  _centralized_migrations_tt_prereq:

Prerequisites
-------------

Before starting this tutorial:

-   Download and :ref:`install Tarantool Enterprise SDK <enterprise-install>.
-   Install `etcd <https://etcd.io/>`__

..  _centralized_migrations_tt_cluster:

Preparing a cluster
-------------------

Centralized migration mechanism works with Tarantool EE clusters that:

-   use etcd as a centralized configuration storage
-   use the `CRUD <https://github.com/tarantool/crud>`__ module for data sharding

Setting up etcd
~~~~~~~~~~~~~~~

First, start up an etcd instance to use as a configuration storage:

.. code-block::

    $ etcd

etcd runs on the default port 2379.

Optionally, you can enable etcd authentication by running the following script:

.. code-block:: bash

    #!/usr/bin/env bash

    etcdctl user add root:topsecret
    etcdctl role add app_config_manager
    etcdctl role grant-permission app_config_manager --prefix=true readwrite /myapp/
    etcdctl user add app_user:config_pass
    etcdctl user grant-role app_user app_config_manager
    etcdctl auth enable

It creates an etcd user ``app_user`` with read and write permissions to the ``/app``
prefix, in which the cluster configuration will be stored. The user's password is ``config_pass``

.. note::

    If you don't enable etcd authentication, you can make all ``tt migrations``
    call without the configuration storage credentials.


Creating a cluster
~~~~~~~~~~~~~~~~~~

#.  Initialize a ``tt`` environment:

    .. code-block:: console

        $ tt init

#.   In the ``instances.enabled`` directory, create the ``myapp`` directory.
#.   Go to the ``instances.enabled/myapp`` directory and create application files:

    -    ``instances.yml``:

        .. code-block:: yaml

            router-001-a:
            storage-001-a:
            storage-001-b:
            storage-002-a:
            storage-002-b:

    -    ``config.yaml``:

        .. code-block:: yaml

            config:
              etcd:
                endpoints:
                - http://localhost:2379
                prefix: /app/
                username: app_user
                password: config_pass
                http:
                  request:
                    timeout: 3

    -   ``app-scm-1.rockspec``:

        .. code-block:: text

            package = 'app'
            version = 'scm-1'

            source  = {
                url = '/dev/null',
            }

            dependencies = {
                'crud == 1.5.2',
            }

            build = {
                type = 'none';
            }

#.  Create the ``source.yaml`` with a cluster configuration to publish to etcd:

    .. note::

        This configuration describes a typical CRUD-enabled sharded cluster with
        one router and two storages, each including one master and one read-only replica.

    .. code-block:: yaml

        credentials:
          users:
            client:
              password: 'secret'
              roles: [super]
            replicator:
              password: 'secret'
              roles: [replication]
            storage:
              password: 'secret'
              roles: [sharding]

        iproto:
          advertise:
            peer:
              login: replicator
            sharding:
              login: storage

        sharding:
          bucket_count: 3000

        groups:
          routers:
            sharding:
              roles: [router]
            roles: [roles.crud-router]
            replicasets:
              router-001:
                instances:
                  router-001-a:
                    iproto:
                      listen:
                      - uri: localhost:3301
                      advertise:
                        client: localhost:3301
          storages:
            sharding:
              roles: [storage]
            roles: [roles.crud-storage]
            replication:
              failover: manual
            replicasets:
              storage-001:
                leader: storage-001-a
                instances:
                  storage-001-a:
                    iproto:
                      listen:
                        - uri: localhost:3302
                      advertise:
                        client: localhost:3302
                  storage-001-b:
                    iproto:
                      listen:
                      - uri: localhost:3303
                      advertise:
                        client: localhost:3303
              storage-002:
                leader: storage-002-a
                instances:
                  storage-002-a:
                    iproto:
                      listen:
                      - uri: localhost:3304
                      advertise:
                        client: localhost:3304
                  storage-002-b:
                    iproto:
                      listen:
                      - uri: localhost:3305
                      advertise:
                        client: localhost:3305

#.  Publish the configuration to etcd by running the following command:

    .. code-block:: console

        $ tt cluster publish "http://app_user:config_pass@localhost:2379/myapp/" source.yaml

The full cluster code is available on GitHub here: `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations/instances.enabled/myapp>`_

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

Now the cluster is ready.

..  _centralized_migrations_tt_write:

Writing migrations
------------------

To perform migrations in the cluster, you should write them in Lua and publish to etcd.

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
use filenames that start with ordered numbers to set the migrations order, for example:

.. code-block:: text

    000001_create_space.lua
    000002_create_index.lua
    000003_alter_space.lua

The default location where ``tt`` searches for migration files is ``/migrations/scenario``.
Create this subdirectory inside the ``tt`` environment. Then, create two migration files:

-   ``000001_create_writers_space.lua``: create a space, define its format, and
    create a primary index.

    .. code-block:: lua

        local helpers = require('tt-migrations.helpers')

        local function apply_scenario()
            local space = box.schema.space.create('writers')

            space:format({
                {name = 'id', type = 'number'},
                {name = 'bucket_id', type = 'number'},
                {name = 'name', type = 'string'},
                {name = 'age', type = 'number'},
            })

            space:create_index('primary', {parts = {'id'}})
            space:create_index('bucket_id', {parts = {'bucket_id'}})

            helpers.register_sharding_key('writers', {'id'})
        end

        return {
            apply = {
                scenario = apply_scenario,
            },
        }

    .. note::

        Note the usage of the ``tt-migrations.helpers`` module.
        In this example, its function ``register_sharding_key`` is used
        to define a sharding key for the space.

-   ``000002_create_writers_index.lua``: add one more index.

    .. code-block:: lua

        local function apply_scenario()
            local space = box.space['writers']

            space:create_index('age', {parts = {'age'}})
        end

        return {
            apply = {
                scenario = apply_scenario,
            },
        }

..  _centralized_migrations_tt_publish:

Publishing migrations
---------------------

To publish migrations to the etcd configuration storage, run ``tt migrations publish``:

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp
       • 000001_create_writes_space.lua: successfully published to key "000001_create_writes_space.lua"
       • 000002_create_writers_index.lua: successfully published to key "000002_create_writers_index.lua"


Applying migrations
-------------------

To apply stored migrations to the cluster, run ``tt migrations apply`` providing
a cluster user's credentials:

.. code-block:: console

    tt migrations apply http://app_user:config_pass@localhost:2379/myapp --tarantool-username=client --tarantool-password=secret

.. important::

    The cluster user must have enough access privileges to execute all functions
    used in migrations code.

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

The ``tt migration status`` allows checking which migrations are stored in etcd and
how they are applied to the cluster instances:

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

To make sure that the migrations are actually applied, connect to the router
instance and retrieve the information about spaces and indexes in the cluster:

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


Adding new migrations
---------------------

Complex migrations require data migration along with schema migration. Insert some
tuples into the space before proceeding to the next steps:

.. code-block:: tarantoolsession

    require('crud').insert_object_many('writers', {
        {id = 1, name = 'Haruki Murakami', age = 75},
        {id = 2, name = 'Douglas Adams', age = 49},
        {id = 3, name = 'Eiji Mikage', age = 41},
    }, {noreturn = true})

The next migration changes the space format incompatibly: instead of one ``name``
field, the new format includes two fields ``first_name`` and ``last_name``.
To apply this migration, you need to change each tuple's format preserving the stored
data. The :ref:`space.upgrade <enterprise-space_upgrade>` helps with this task.

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

.. code-block:: lua

    local function apply_scenario()

        local space = box.space['writers']

        local new_format = {
            {name = 'id', type = 'number'},
            {name = 'bucket_id', type = 'number'},
            {name = 'first_name', type = 'string'},
            {name = 'last_name', type = 'string'},
            {name = 'age', type = 'number'},
        }
        box.space.writers.index.age:drop()

    --  migration code

    end

.. note::

    ``box.space.writers.index.age:drop()`` drops an existing index. This is done
    because indexes rely on field numbers and may break during this format change.
    If you need the ``age`` field indexed, recreate the index after applying the
    new format.

Next, create a stored function that transforms tuples to fit the new format.
In this case, the functions extracts the first and the last name from the ``name`` field
and returns a tuple of the new format:

.. code-block:: lua

    box.schema.func.create('_writers_split_name', {
        language = 'lua',
        is_deterministic = true,
        body = [[
        function(t)
            local name = t[3]

            local split_data = {}
            local split_regex = '([^%s]+)'
            for v in string.gmatch(name, split_regex) do
                table.insert(split_data, v)
            end

            local first_name = split_data[1]
            assert(first_name ~= nil)

            local last_name = split_data[2]
            assert(last_name ~= nil)

            return {t[1], t[2], first_name, last_name, t[4]}
        end
        ]],
    })

Finally pass the new format and the transformation function name into a ``space:upgrade``
call and wait for it to complete:

.. code-block:: lua

    local function apply_scenario()

        -- space format

        box.schema.func.create('_writers_split_name', {
            language = 'lua',
            is_deterministic = true,
            body =
            -- data migration function
        })

        local future = space:upgrade({
            func = '_writers_split_name',
            format = new_format,
        })

        future:wait()
    end

Learn moew in space upgrade

The full ``000003_alter_writers_space.lua`` migration code is as follows:

.. code-block:: lua

    local function apply_scenario()
        local space = box.space['writers']

        local new_format = {
            {name = 'id', type = 'number'},
            {name = 'bucket_id', type = 'number'},
            {name = 'first_name', type = 'string'},
            {name = 'last_name', type = 'string'},
            {name = 'age', type = 'number'},
        }
        box.space.writers.index.age:drop()

        box.schema.func.create('_writers_split_name', {
            language = 'lua',
            is_deterministic = true,
            body = [[
            function(t)
                local name = t[3]

                local split_data = {}
                local split_regex = '([^%s]+)'
                for v in string.gmatch(name, split_regex) do
                    table.insert(split_data, v)
                end

                local first_name = split_data[1]
                assert(first_name ~= nil)

                local last_name = split_data[2]
                assert(last_name ~= nil)

                return {t[1], t[2], first_name, last_name, t[4]}
            end
            ]],
        })

        local future = space:upgrade({
            func = '_writers_split_name',
            format = new_format,
        })

        future:wait()
    end

    return {
        apply = {
            scenario = apply_scenario,
        },
    }

Publish the new migration to etcd. Migrations that already exist in the storage are skipped.

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp
       • 000001_create_writes_space.lua: skipped, key "000001_create_writes_space.lua" already exists with the same content
       • 000002_create_writers_index.lua: skipped, key "000002_create_writers_index.lua" already exists with the same content
       • 000003_alter_writers_space.lua: successfully published to key "000003_alter_writers_space.lua"

.. note::

    You can also publish a single migration file by passing a path to it as an argument:

    .. code-block:: console

        $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp migrations/scenario/000003_alter_writers_space.lua

Apply the migrations:

.. code-block::

    $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp --tarantool-username=client --tarantool-password=secret

Connect to the router instance and retrieve the information about spaces and indexes in the cluster:

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

Extending the cluster
---------------------

With centralized migrations mechanism, you can

how to write migration files? tt-migrtions.helpers

Migration workflow

prepare files
publish to etcd
apply
check status

Handling errors

stop
rollback - show examples with force apply?

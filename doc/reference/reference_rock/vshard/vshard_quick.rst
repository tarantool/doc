.. _vshard-quick-start:

===============================================================================
Quick start guide
===============================================================================

For installation instructions, check out the :ref:`vshard installation manual <vshard-install>`.

For a pre-configured development cluster, check out the ``example/`` directory in
the `vshard repository <https://github.com/tarantool/vshard/>`_.
This example includes 5 Tarantool instances and 2 replica sets:

* ``router_1`` – a ``router`` instance
* ``storage_1_a`` – a ``storage`` instance, the **master** of the **first** replica set
* ``storage_1_b`` – a ``storage`` instance, the **replica** of the **first** replica set
* ``storage_2_a`` – a ``storage`` instance, the **master** of the **second** replica set
* ``storage_2_b`` – a ``storage`` instance, the **replica** of the **second** replica set

All instances are managed using the ``tarantoolctl`` utility which comes with Tarantool.

Change the directory to ``example/`` and use ``make`` to run the development cluster:

.. code-block:: console

    $ cd example/
    $ make
    tarantoolctl stop storage_1_a  # stop the first storage instance
    Stopping instance storage_1_a...
    tarantoolctl stop storage_1_b
    <...>
    rm -rf data/
    tarantoolctl start storage_1_a # start the first storage instance
    Starting instance storage_1_a...
    Starting configuration of replica 8a274925-a26d-47fc-9e1b-af88ce939412
    I am master
    Taking on replicaset master role...
    Run console at unix/:./data/storage_1_a.control
    started
    mkdir ./data/storage_1_a
    <...>
    tarantoolctl start router_1 # start the router
    Starting instance router_1...
    Starting router configuration
    Calling box.cfg()...
    <...>
    Run console at unix/:./data/router_1.control
    started
    mkdir ./data/router_1
    Waiting cluster to start
    echo "vshard.router.bootstrap()" | tarantoolctl enter router_1
    connected to unix/:./data/router_1.control
    unix/:./data/router_1.control> vshard.router.bootstrap()
    ---
    - true
    ...
    unix/:./data/router_1.control>
    tarantoolctl enter router_1 # enter the admin console
    connected to unix/:./data/router_1.control
    unix/:./data/router_1.control>

Some ``tarantoolctl`` commands:

* ``tarantoolctl start router_1`` – start the router instance
* ``tarantoolctl enter router_1``  – enter the admin console

The full list of ``tarantoolctl`` commands for managing Tarantool instances is
available in the :ref:`tarantoolctl reference <tarantoolctl>`.

Essential ``make`` commands you need to know:

* ``make start`` – start all Tarantool instances
* ``make stop`` – stop all Tarantool instances
* ``make logcat`` – show logs from all instances
* ``make enter`` – enter the admin console on ``router_1``
* ``make clean`` – clean up all persistent data
* ``make test`` – run the test suite (you can also run ``test-run.py`` in the ``test`` directory)
* ``make`` – execute ``make stop``, ``make clean``, ``make start`` and ``make enter``

For example, to start all instances, use ``make start``:

.. code-block:: console

    $ make start
    $ ps x|grep tarantool
    46564   ??  Ss     0:00.34 tarantool storage_1_a.lua <running>
    46566   ??  Ss     0:00.19 tarantool storage_1_b.lua <running>
    46568   ??  Ss     0:00.35 tarantool storage_2_a.lua <running>
    46570   ??  Ss     0:00.20 tarantool storage_2_b.lua <running>
    46572   ??  Ss     0:00.25 tarantool router_1.lua <running>

To perform commands in the admin console, use the router's
:ref:`public API <vshard_api_reference-router_public_api>`:

.. code-block:: tarantoolsession

    unix/:./data/router_1.control> vshard.router.info()
    ---
    - replicasets:
        ac522f65-aa94-4134-9f64-51ee384f1a54:
          replica: &0
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3303
            uuid: 1e02ae8a-afc0-4e91-ba34-843a356b8ed7
          uuid: ac522f65-aa94-4134-9f64-51ee384f1a54
          master: *0
        cbf06940-0790-498b-948d-042b62cf3d29:
          replica: &1
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3301
            uuid: 8a274925-a26d-47fc-9e1b-af88ce939412
          uuid: cbf06940-0790-498b-948d-042b62cf3d29
          master: *1
      bucket:
        unreachable: 0
        available_ro: 0
        unknown: 0
        available_rw: 3000
      status: 0
      alerts: []
    ...

.. _vshard-config-cluster-example:

-------------------------------------------------------------------------------
Sample configuration
-------------------------------------------------------------------------------

The configuration of a simple sharded cluster can look like this:

.. code-block:: kconfig

    local cfg = {
        memtx_memory = 100 * 1024 * 1024,
        replication_connect_quorum = 0,
        bucket_count = 10000,
        rebalancer_disbalance_threshold = 10,
        rebalancer_max_receiving = 100,
        sharding = {
            ['cbf06940-0790-498b-948d-042b62cf3d29'] = {
                replicas = {
                    ['8a274925-a26d-47fc-9e1b-af88ce939412'] = {
                        uri = 'storage:storage@127.0.0.1:3301',
                        name = 'storage_1_a',
                        master = true
                    },
                    ['3de2e3e1-9ebe-4d0d-abb1-26d301b84633'] = {
                        uri = 'storage:storage@127.0.0.1:3302',
                        name = 'storage_1_b'
                    }
                },
            },
            ['ac522f65-aa94-4134-9f64-51ee384f1a54'] = {
                replicas = {
                    ['1e02ae8a-afc0-4e91-ba34-843a356b8ed7'] = {
                        uri = 'storage:storage@127.0.0.1:3303',
                        name = 'storage_2_a',
                        master = true
                    },
                    ['001688c3-66f8-4a31-8e19-036c17d489c2'] = {
                        uri = 'storage:storage@127.0.0.1:3304',
                        name = 'storage_2_b'
                    }
                },
            },
        },
    }

This cluster includes one ``router`` instance and two ``storage`` instances.
Each ``storage`` instance includes one master and one replica.
The ``sharding`` field defines the logical topology of a sharded Tarantool cluster.
All the other fields are passed to ``box.cfg()`` as they are, without modifications.
See the :ref:`Configuration reference <vshard-config-reference>` section for details.

On routers, call ``vshard.router.cfg(cfg)``:

.. code-block:: lua

    cfg.listen = 3300

    -- Start the database with sharding
    vshard = require('vshard')
    vshard.router.cfg(cfg)

On storages, call ``vshard.storage.cfg(cfg, instance_uuid)``:

.. code-block:: lua

    -- Get instance name
    local MY_UUID = "de0ea826-e71d-4a82-bbf3-b04a6413e417"

    -- Call a configuration provider
    local cfg = require('localcfg')

    -- Start the database with sharding
    vshard = require('vshard')
    vshard.storage.cfg(cfg, MY_UUID)

``vshard.storage.cfg()`` automatically calls ``box.cfg()`` and configures the listen
port and replication parameters.

For a sample configuration, see ``router.lua`` and ``storage.lua`` in the
``example/`` directory of the `vshard repository <https://github.com/tarantool/vshard>`_.

..  _vshard-quick-start:

Creating a sharded cluster
==========================

**Example on GitHub**: `sharded_cluster <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster>`_

In this tutorial, you get a sharded cluster up and running on your local machine and learn how to manage the cluster using the tt utility.
To enable sharding in the cluster, the :ref:`vshard <vshard>` module is used.

The cluster created in this tutorial includes 5 instances: one router and 4 storages, which constitute two replica sets.

.. image:: /book/admin/admin_instances_dev.png
    :align: left
    :width: 700
    :alt: Cluster topology


..  _vshard-quick-start-prerequisites:

Prerequisites
-------------

Before starting this tutorial:

*   :ref:`Install the tt <tt-installation>` utility.
*   `Install tarantool <https://www.tarantool.io/en/download/os-installation/>`_.

    .. NOTE::

        The tt utility provides the ability to install Tarantool software using the :ref:`tt install <tt-install>` command.


..  _vshard-quick-start-creating-app:

Creating a cluster application
------------------------------

The :ref:`tt create <tt-create>` command can be used to create an application from a predefined or custom template.
For example, the built-in ``vshard_cluster`` template enables you to create a ready-to-run sharded cluster application.

In this tutorial, the application layout is prepared manually:

1.  Create a tt environment in the current directory by executing the :ref:`tt init <tt-init>` command.

2.  Inside the empty ``instances.enabled`` directory of the created tt environment, create the ``sharded_cluster`` directory.

3.  Inside ``instances.enabled/sharded_cluster``, create the following files:

    -   ``instances.yml`` specifies instances to run in the current environment.
    -   ``config.yaml`` specifies the cluster's :ref:`configuration <configuration_overview>`.
    -   ``storage.lua`` contains code specific for :ref:`storages <vshard-architecture-storage>`.
    -   ``router.lua`` contains code specific for a :ref:`router <vshard-architecture-router>`.
    -   ``sharded_cluster-scm-1.rockspec`` specifies external dependencies required by the application.

    The next :ref:`vshard-quick-start-developing-app` section shows how to configure the cluster and write code for routing read and write requests to different storages.


..  _vshard-quick-start-developing-app:

Developing the application
--------------------------

..  _vshard-quick-start-configuring-instances:

Configuring instances to run
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Open the ``instances.yml`` file and add the following content:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/instances.yaml
    :language: yaml
    :dedent:

This file specifies instances to run in the current environment.


..  _vshard-quick-start-configuring-cluster:

Configuring the cluster
~~~~~~~~~~~~~~~~~~~~~~~

This section describes how to configure the cluster in the ``config.yaml`` file.

..  _vshard-quick-start-configuring-cluster-credentials:

Step 1: Configuring credentials
*******************************

Add the :ref:`credentials <configuration_reference_credentials>` configuration section:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [sharding]
    :dedent:

In this section, two users with the specified passwords are created:

*   The ``replicator`` user with the ``replication`` role.
*   The ``storage`` user with the ``sharding`` role.

These users are intended to maintain replication and sharding in the cluster.

..  IMPORTANT::

    It is not recommended to store passwords as plain text in a YAML configuration.
    Learn how to load passwords from safe storage such as external files or environment variables from :ref:`configuration_credentials_loading_secrets`.



..  _vshard-quick-start-configuring-cluster-advertise:

Step 2: Specifying advertise URIs
*********************************

Add the :ref:`iproto.advertise <configuration_reference_iproto_advertise>` section:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-after: roles: [sharding]
    :end-at: login: storage
    :dedent:

In this section, the following options are configured:

*   ``iproto.advertise.peer`` specifies how to advertise the current instance to other cluster members.
    In particular, this option informs other replica set members that the ``replicator`` user should be used to connect to the current instance.
*   ``iproto.advertise.sharding`` specifies how to advertise the current instance to a router and rebalancer.


..  _vshard-quick-start-configuring-cluster-bucket-count:

Step 3: Configuring bucket count
********************************

Specify the total number of :ref:`buckets <vshard-vbuckets>` in a sharded cluster using the ``sharding.bucket_count`` option:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-after: login: storage
    :end-at: bucket_count
    :dedent:


..  _vshard-quick-start-configuring-cluster-topology:

Step 4: Defining the cluster topology
*************************************

Define the cluster's topology inside the :ref:`groups <configuration_reference_groups>` section.
The cluster includes two groups:

*   ``storages`` includes two replica sets. Each replica set contains two instances.
*   ``routers`` includes one router instance.

Here is a schematic view of the cluster's topology:

.. code-block:: yaml

    groups:
      storages:
        replicasets:
          storage-a:
            # ...
          storage-b:
            # ...
      routers:
        replicasets:
          router-a:
            # ...

1.  To configure storages, add the following code inside the ``groups`` section:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
        :language: yaml
        :start-at: storages:
        :end-before: routers:
        :dedent:

    The main group-level options here are:

    *   ``app``: The ``app.module`` option specifies that code specific to storages should be loaded from the ``storage`` module. This is explained below in the :ref:`vshard-quick-start-storage-code` section.
    *   ``sharding``: The ``sharding.roles`` option specifies that all instances inside this group act as storages.
        A rebalancer is selected automatically from two master instances.
    *   ``replication``: The :ref:`replication.failover <configuration_reference_replication_failover>` option specifies that a leader in each replica set should be specified manually.
    *   ``replicasets``: This section configures two replica sets that constitute cluster storages.


2.  To configure a router, add the following code inside the ``groups`` section:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
        :language: yaml
        :start-at: routers:
        :end-at: 127.0.0.1:3300
        :dedent:

    The main group-level options here are:

    *   ``app``: The ``app.module`` option specifies that code specific to a router should be loaded from the ``router`` module. This is explained below in the :ref:`vshard-quick-start-router-code` section.
    *   ``sharding``: The ``sharding.roles`` option specifies that an instance inside this group acts as a router.
    *   ``replicasets``: This section configures one replica set with one router instance.


Resulting configuration
***********************

The resulting ``config.yaml`` file should look as follows:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :dedent:


..  _vshard-quick-start-storage-code:

Adding storage code
~~~~~~~~~~~~~~~~~~~

1.  Open the ``storage.lua`` file and create a space using the :ref:`box.schema.space.create() <box_schema-space_create>` function:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
        :language: lua
        :start-at: box.schema.create_space
        :end-before: box.space.bands:create_index('id'
        :dedent:

    Note that the created ``bands`` spaces includes the ``bucket_id`` field.
    This field represents a sharding key used to partition a dataset across different storage instances.

2.  Create two indexes based on the ``id`` and ``bucket_id`` fields:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
        :language: lua
        :start-at: box.space.bands:create_index('id'
        :end-at: box.space.bands:create_index('bucket_id'
        :dedent:

3.  Define the ``insert_band`` function that inserts a tuple into the created space:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
        :language: lua
        :start-at: function insert_band
        :end-before: function get_band
        :dedent:

4.  Define the ``get_band`` function that returns data without the ``bucket_id`` value:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
        :language: lua
        :start-at: function get_band
        :dedent:

The resulting ``storage.lua`` file should look as follows:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/storage.lua
    :language: lua
    :dedent:


..  _vshard-quick-start-router-code:

Adding router code
~~~~~~~~~~~~~~~~~~

1.  Open the ``router.lua`` file and load the ``vshard`` module as follows:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/router.lua
        :language: lua
        :start-at: local vshard
        :end-at: local vshard
        :dedent:

2.  Define the ``put`` function that specifies how the router selects the storage to write data:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/router.lua
        :language: lua
        :start-at: function put
        :end-before: function get
        :dedent:

    The following ``vshard`` router functions are used:

    *   :ref:`vshard.router.bucket_id_mpcrc32() <router_api-bucket_id_mpcrc32>`: Calculates a bucket ID value using a hash function.
    *   :ref:`vshard.router.callrw() <router_api-callrw>`: Inserts a tuple to a storage identified the generated bucket ID.

3.  Create the ``get`` function for getting data:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/router.lua
        :language: lua
        :start-at: function get
        :end-before: function insert_data
        :dedent:

    Inside this function, :ref:`vshard.router.callro() <router_api-callro>` is called to get data from a storage identified the generated bucket ID.

4.  Finally, create the ``insert_data()`` function that inserts sample data into the created space:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/router.lua
        :language: lua
        :start-at: function insert_data
        :dedent:

The resulting ``router.lua`` file should look as follows:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/router.lua
    :language: lua
    :dedent:



..  _vshard-quick-start-build-settings:

Configuring build settings
~~~~~~~~~~~~~~~~~~~~~~~~~~

Open the ``sharded_cluster-scm-1.rockspec`` file and add the following content:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/sharded_cluster-scm-1.rockspec
    :language: none
    :dedent:

The ``dependencies`` section includes the specified version of the ``vshard`` module.
To install dependencies, you need to :ref:`build the application <vshard-quick-start-building-app>`.


.. _vshard-quick-start-building-app:

Building the application
------------------------

In the terminal, open the :ref:`tt environment directory <vshard-quick-start-creating-app>`.
Then, execute the ``tt build`` command:

.. code-block:: console

    $ tt build sharded_cluster
       • Running rocks make
    No existing manifest. Attempting to rebuild...
       • Application was successfully built

This installs the ``vshard`` dependency defined in the :ref:`*.rockspec <vshard-quick-start-build-settings>` file to the ``.rocks`` directory.



..  _vshard-quick-start-working-cluster:

Working with the cluster
------------------------

.. _vshard-quick-start-working-starting-instances:

Starting instances
~~~~~~~~~~~~~~~~~~

To start all instances in the cluster, execute the ``tt start`` command:

.. code-block:: console

    $ tt start sharded_cluster
       • Starting an instance [sharded_cluster:storage-a-001]...
       • Starting an instance [sharded_cluster:storage-a-002]...
       • Starting an instance [sharded_cluster:storage-b-001]...
       • Starting an instance [sharded_cluster:storage-b-002]...
       • Starting an instance [sharded_cluster:router-a-001]...


.. _vshard-quick-start-working-bootstrap:

Bootstrapping a cluster
~~~~~~~~~~~~~~~~~~~~~~~

After starting instances, you need to bootstrap the cluster as follows:

1.  Connect to the router instance using ``tt connect``:

    ..  code-block:: console

        $ tt connect sharded_cluster:router-a-001
           • Connecting to the instance...
           • Connected to sharded_cluster:router-a-001

2.  Call :ref:`vshard.router.bootstrap() <router_api-bootstrap>` to perform the initial cluster bootstrap:

    ..  code-block:: console

        sharded_cluster:router-a-001> vshard.router.bootstrap()
        ---
        - true
        ...


.. _vshard-quick-start-working-status:

Checking status
~~~~~~~~~~~~~~~

To check the cluster's status, execute :ref:`vshard.router.info() <router_api-info>` on the router:

.. code-block:: console

    sharded_cluster:router-a-001> vshard.router.info()
    ---
    - replicasets:
        storage-b:
          replica:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3304
            name: storage-b-002
          bucket:
            available_rw: 500
          master:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3303
            name: storage-b-001
          name: storage-b
        storage-a:
          replica:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3302
            name: storage-a-002
          bucket:
            available_rw: 500
          master:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3301
            name: storage-a-001
          name: storage-a
      bucket:
        unreachable: 0
        available_ro: 0
        unknown: 0
        available_rw: 1000
      status: 0
      alerts: []
    ...

The output includes the following sections:

*   ``replicasets``: contains information about storages and their availability.
*   ``bucket``: displays the total number of read-write and read-only buckets that are currently available for this router.
*   ``status``: the number from 0 to 3 that indicates whether there are any issues with the cluster.
    0 means that there are no issues.
*   ``alerts``: might describe the exact issues related to bootstrapping a cluster, for example, connection issues, failover events, or unidentified buckets.


.. _vshard-quick-start-working-writing-selecting-data:

Writing and selecting data
~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  To insert sample data, call the :ref:`insert_data() <vshard-quick-start-router-code>` function on the router:

    .. code-block:: console

        sharded_cluster:router-a-001> insert_data()
        ---
        ...

    Calling this function :ref:`distributes data <vshard-quick-start-working-adding-data>` evenly across the cluster's nodes.

2.  To get a tuple by the specified ID, call the ``get()`` function:

    .. code-block:: console

        sharded_cluster:router-a-001> get(4)
        ---
        - [4, 'The Beatles', 1960]
        ...

3.  To insert a new tuple, call the ``put()`` function:

    .. code-block:: console

        sharded_cluster:router-a-001> put(11, 'The Who', 1962)
        ---
        ...




.. _vshard-quick-start-working-adding-data:

Checking data distribution
~~~~~~~~~~~~~~~~~~~~~~~~~~

To check how data is distributed across the cluster's nodes, follow the steps below:

1.  Connect to any storage in the ``storage-a`` replica set:

    ..  code-block:: console

        $ tt connect sharded_cluster:storage-a-001
           • Connecting to the instance...
           • Connected to sharded_cluster:storage-a-001

    Then, select all tuples in the ``bands`` space:

    .. code-block:: console

        sharded_cluster:storage-a-001> box.space.bands:select()
        ---
        - - [3, 11, 'Ace of Base', 1987]
          - [4, 42, 'The Beatles', 1960]
          - [6, 55, 'The Rolling Stones', 1962]
          - [9, 299, 'Led Zeppelin', 1968]
          - [10, 167, 'Queen', 1970]
          - [11, 70, 'The Who', 1962]
        ...


2.  Connect to any storage in the ``storage-b`` replica set:

    ..  code-block:: console

        $ tt connect sharded_cluster:storage-b-001
           • Connecting to the instance...
           • Connected to sharded_cluster:storage-b-001

    Select all tuples in the ``bands`` space to make sure it contains another subset of data:

    .. code-block:: console

        sharded_cluster:storage-b-001> box.space.bands:select()
        ---
        - - [1, 614, 'Roxette', 1986]
          - [2, 986, 'Scorpions', 1965]
          - [5, 755, 'Pink Floyd', 1965]
          - [7, 998, 'The Doors', 1965]
          - [8, 762, 'Nirvana', 1987]
        ...

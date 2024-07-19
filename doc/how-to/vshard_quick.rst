..  _vshard-quick-start:

Creating a sharded cluster
==========================

**Example on GitHub**: `sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_

In this tutorial, you get a sharded cluster up and running on your local machine and learn how to manage the cluster using the tt utility.
This cluster uses the following external modules:

-   :ref:`vshard <vshard>` enables sharding in the cluster.
-   `crud <https://github.com/tarantool/crud>`__ allows you to manipulate data in the sharded cluster.

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

2.  Inside the empty ``instances.enabled`` directory of the created tt environment, create the ``sharded_cluster_crud`` directory.

3.  Inside ``instances.enabled/sharded_cluster_crud``, create the following files:

    -   ``instances.yml`` specifies instances to run in the current environment.
    -   ``config.yaml`` specifies the cluster :ref:`configuration <configuration_overview>`.
    -   ``storage.lua`` contains code specific for :ref:`storages <vshard-architecture-storage>`.
    -   ``router.lua`` contains code specific for a :ref:`router <vshard-architecture-router>`.
    -   ``sharded_cluster_crud-scm-1.rockspec`` specifies external dependencies required by the application.

    The next :ref:`vshard-quick-start-developing-app` section shows how to configure the cluster and write code for routing read and write requests to different storages.


..  _vshard-quick-start-developing-app:

Developing the application
--------------------------

..  _vshard-quick-start-configuring-instances:

Configuring instances to run
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Open the ``instances.yml`` file and add the following content:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/instances.yaml
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

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [ sharding ]
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

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :start-after: roles: [ sharding ]
    :end-at: login: storage
    :dedent:

In this section, the following options are configured:

*   ``iproto.advertise.peer`` specifies how to advertise the current instance to other cluster members.
    In particular, this option informs other replica set members that the ``replicator`` user should be used to connect to the current instance.
*   ``iproto.advertise.sharding`` specifies how to advertise the current instance to a router and rebalancer.

The cluster topology defined in the :ref:`following section <vshard-quick-start-configuring-cluster-topology>` also specifies the ``iproto.advertise.client`` option for each instance.
This option accepts a URI used to advertise the instance to clients.
For example, :ref:`Tarantool Cluster Manager <tcm>` uses these URIs to :ref:`connect <tcm_connect_clusters>` to cluster instances.


..  _vshard-quick-start-configuring-cluster-bucket-count:

Step 3: Configuring bucket count
********************************

Specify the total number of :ref:`buckets <vshard-vbuckets>` in a sharded cluster using the :ref:`sharding.bucket_count <configuration_reference_sharding_bucket_count>` option:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :start-after: login: storage
    :end-at: bucket_count
    :dedent:


..  _vshard-quick-start-configuring-cluster-topology:

Step 4: Defining the cluster topology
*************************************

Define the cluster topology inside the :ref:`groups <configuration_reference_groups>` section.
The cluster includes two groups:

*   ``storages`` includes two replica sets. Each replica set contains two instances.
*   ``routers`` includes one router instance.

Here is a schematic view of the cluster topology:

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

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
        :language: yaml
        :start-at: storages:
        :end-at: client: '127.0.0.1:3305'
        :dedent:

    The main group-level options here are:

    *   ``roles``: This option enables the ``roles.crud-storage`` :ref:`role <configuration_application_roles_enable>` provided by the CRUD module for all storage instances.
    *   ``app``: The ``app.module`` option specifies that code specific to storages should be loaded from the ``storage`` module. This is explained below in the :ref:`vshard-quick-start-storage-code` section.
    *   ``sharding``: The :ref:`sharding.roles <configuration_reference_sharding_roles>` option specifies that all instances inside this group act as storages.
        A rebalancer is selected automatically from two master instances.
    *   ``replication``: The :ref:`replication.failover <configuration_reference_replication_failover>` option specifies that a leader in each replica set should be specified manually.
    *   ``replicasets``: This section configures two replica sets that constitute cluster storages.


2.  To configure a router, add the following code inside the ``groups`` section:

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
        :language: yaml
        :start-at: routers:
        :end-at: client: '127.0.0.1:3301'
        :dedent:

    The main group-level options here are:

    *   ``roles``: This option enables the ``roles.crud-router`` :ref:`role <configuration_application_roles_enable>` provided by the CRUD module for a router instance.
    *   ``app``: The ``app.module`` option specifies that code specific to a router should be loaded from the ``router`` module. This is explained below in the :ref:`vshard-quick-start-router-code` section.
    *   ``sharding``: The :ref:`sharding.roles <configuration_reference_sharding_roles>` option specifies that an instance inside this group acts as a router.
    *   ``replicasets``: This section configures a replica set with one router instance.


Resulting configuration
***********************

The resulting ``config.yaml`` file should look as follows:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :dedent:


..  _vshard-quick-start-storage-code:

Adding storage code
~~~~~~~~~~~~~~~~~~~

Open the ``storage.lua`` file and define a space and indexes inside :ref:`box.watch() <box-watch>` as follows:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/storage.lua
    :language: lua
    :dedent:

*   The :ref:`box.schema.create_space() <box_schema-space_create>` function creates a space.
    Note that the created ``bands`` space includes the ``bucket_id`` field.
    This field represents a sharding key used to partition a dataset across different storage instances.
*   :ref:`space_object:create_index() <box_space-create_index>` creates two indexes based on the ``id`` and ``bucket_id`` fields.



..  _vshard-quick-start-router-code:

Adding router code
~~~~~~~~~~~~~~~~~~

Open the ``router.lua`` file and load the ``vshard`` module as follows:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/router.lua
    :language: lua
    :start-at: local vshard
    :end-at: local vshard
    :dedent:



..  _vshard-quick-start-build-settings:

Configuring build settings
~~~~~~~~~~~~~~~~~~~~~~~~~~

Open the ``sharded_cluster_crud-scm-1.rockspec`` file and add the following content:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/sharded_cluster_crud-scm-1.rockspec
    :language: none
    :dedent:

The ``dependencies`` section includes the specified versions of the ``vshard`` and ``crud`` modules.
To install dependencies, you need to :ref:`build the application <vshard-quick-start-building-app>`.


.. _vshard-quick-start-building-app:

Building the application
------------------------

In the terminal, open the :ref:`tt environment directory <vshard-quick-start-creating-app>`.
Then, execute the ``tt build`` command:

.. code-block:: console

    $ tt build sharded_cluster_crud
       • Running rocks make
    No existing manifest. Attempting to rebuild...
       • Application was successfully built

This installs the ``vshard`` and ``crud`` modules defined in the :ref:`*.rockspec <vshard-quick-start-build-settings>` file to the ``.rocks`` directory.



..  _vshard-quick-start-working-cluster:

Working with the cluster
------------------------

.. _vshard-quick-start-working-starting-instances:

Starting instances
~~~~~~~~~~~~~~~~~~

To start all instances in the cluster, execute the ``tt start`` command:

.. code-block:: console

    $ tt start sharded_cluster_crud
       • Starting an instance [sharded_cluster_crud:storage-a-001]...
       • Starting an instance [sharded_cluster_crud:storage-a-002]...
       • Starting an instance [sharded_cluster_crud:storage-b-001]...
       • Starting an instance [sharded_cluster_crud:storage-b-002]...
       • Starting an instance [sharded_cluster_crud:router-a-001]...


.. _vshard-quick-start-working-bootstrap:

Bootstrapping a cluster
~~~~~~~~~~~~~~~~~~~~~~~

After starting instances, you need to bootstrap the cluster as follows:

1.  Connect to the router instance using ``tt connect``:

    ..  code-block:: console

        $ tt connect sharded_cluster_crud:router-a-001
           • Connecting to the instance...
           • Connected to sharded_cluster_crud:router-a-001

2.  Call :ref:`vshard.router.bootstrap() <router_api-bootstrap>` to perform the initial cluster bootstrap and distribute all buckets across the replica sets:

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:router-a-001> vshard.router.bootstrap()
        ---
        - true
        ...


.. _vshard-quick-start-working-status:

Checking the cluster status
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To check the cluster status, execute :ref:`vshard.router.info() <router_api-info>` on the router:

.. code-block:: tarantoolsession

    sharded_cluster_crud::router-a-001> vshard.router.info()
    ---
    - replicasets:
        storage-b:
          replica:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3305
            name: storage-b-002
          bucket:
            available_rw: 500
          master:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3304
            name: storage-b-001
          name: storage-b
        storage-a:
          replica:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3303
            name: storage-a-002
          bucket:
            available_rw: 500
          master:
            network_timeout: 0.5
            status: available
            uri: storage@127.0.0.1:3302
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

1.  To insert sample data, call ``crud.insert_many()`` on the router:

    .. code-block:: lua

        crud.insert_many('bands', {
            { 1, box.NULL, 'Roxette', 1986 },
            { 2, box.NULL, 'Scorpions', 1965 },
            { 3, box.NULL, 'Ace of Base', 1987 },
            { 4, box.NULL, 'The Beatles', 1960 },
            { 5, box.NULL, 'Pink Floyd', 1965 },
            { 6, box.NULL, 'The Rolling Stones', 1962 },
            { 7, box.NULL, 'The Doors', 1965 },
            { 8, box.NULL, 'Nirvana', 1987 },
            { 9, box.NULL, 'Led Zeppelin', 1968 },
            { 10, box.NULL, 'Queen', 1970 }
        })

    Calling this function :ref:`distributes data <vshard-quick-start-working-adding-data>` evenly across the cluster nodes.

2.  To get a tuple by the specified ID, call the ``crud.get()`` function:

    .. code-block:: tarantoolsession

        sharded_cluster_crud:router-a-001> crud.get('bands', 4)
        ---
        - rows:
          - [4, 161, 'The Beatles', 1960]
          metadata: [{'name': 'id', 'type': 'unsigned'}, {'name': 'bucket_id', 'type': 'unsigned'},
            {'name': 'band_name', 'type': 'string'}, {'name': 'year', 'type': 'unsigned'}]
        - null
        ...

3.  To insert a new tuple, call ``crud.insert()``:

    .. code-block:: tarantoolsession

        sharded_cluster_crud:router-a-001> crud.insert('bands', {11, box.NULL, 'The Who', 1962})
        ---
        - rows:
          - [11, 652, 'The Who', 1962]
          metadata: [{'name': 'id', 'type': 'unsigned'}, {'name': 'bucket_id', 'type': 'unsigned'},
            {'name': 'band_name', 'type': 'string'}, {'name': 'year', 'type': 'unsigned'}]
        - null
        ...




.. _vshard-quick-start-working-adding-data:

Checking data distribution
~~~~~~~~~~~~~~~~~~~~~~~~~~

To check how data is distributed across the replica sets, follow the steps below:

1.  Connect to any storage in the ``storage-a`` replica set:

    ..  code-block:: console

        $ tt connect sharded_cluster_crud:storage-a-001
           • Connecting to the instance...
           • Connected to sharded_cluster_crud:storage-a-001

    Then, select all tuples in the ``bands`` space:

    .. code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-001> box.space.bands:select()
        ---
        - - [1, 477, 'Roxette', 1986]
          - [2, 401, 'Scorpions', 1965]
          - [4, 161, 'The Beatles', 1960]
          - [5, 172, 'Pink Floyd', 1965]
          - [6, 64, 'The Rolling Stones', 1962]
          - [8, 185, 'Nirvana', 1987]
        ...


2.  Connect to any storage in the ``storage-b`` replica set:

    ..  code-block:: console

        $ tt connect sharded_cluster_crud:storage-b-001
           • Connecting to the instance...
           • Connected to sharded_cluster_crud:storage-b-001

    Select all tuples in the ``bands`` space to make sure it contains another subset of data:

    .. code-block:: tarantoolsession

        sharded_cluster_crud:storage-b-001> box.space.bands:select()
        ---
        - - [3, 804, 'Ace of Base', 1987]
          - [7, 693, 'The Doors', 1965]
          - [9, 644, 'Led Zeppelin', 1968]
          - [10, 569, 'Queen', 1970]
          - [11, 652, 'The Who', 1962]
        ...

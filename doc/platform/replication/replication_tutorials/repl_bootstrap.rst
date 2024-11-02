..  _replication-bootstrap:
..  _replication-master_replica_bootstrap:

Master-replica: manual failover
===============================

**Example on GitHub**: `manual_leader <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/manual_leader>`_

This tutorial shows how to configure and work with a replica set with manual failover.


..  _replication-tt-env:

Prerequisites
-------------

Before starting this tutorial:

1.  Install the :ref:`tt <tt-cli>` utility.

2.  Create a tt environment in the current directory by executing the :ref:`tt init <tt-init>` command.

3.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``manual_leader`` directory.

4.  Inside ``instances.enabled/manual_leader``, create the ``instances.yml`` and ``config.yaml`` files:

    -   ``instances.yml`` specifies instances to :ref:`run <replication-master_replica_starting>` in the current environment and should look like this:

        ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/instances.yml
            :language: yaml
            :end-at: instance002:
            :dedent:

    -   The ``config.yaml`` file is intended to store a :ref:`replica set configuration <replication-master_replica_configuring>`.



.. _replication-master_replica_configuring:

Configuring a replica set
-------------------------

This section describes how to configure a replica set in ``config.yaml``.

.. _replication-master_replica_configuring_failover_mode:

Step 1: Configuring a failover mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, set the :ref:`replication.failover <configuration_reference_replication_failover>` option to ``manual``:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
    :language: yaml
    :start-at: replication:
    :end-at: failover: manual
    :dedent:

.. _replication-master_replica_configuring_topology:

Step 2: Defining a replica set topology
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Define a replica set topology inside the :ref:`groups <configuration_reference_groups>` section:

-   The :ref:`leader <configuration_reference_replicasets_name_leader>` option sets ``instance001`` as a replica set leader.
-   The :ref:`iproto.listen <configuration_reference_iproto_listen>` option specifies an address used to listen for incoming requests and allows replicas to communicate with each other.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
    :language: yaml
    :start-at: groups:
    :end-at: 127.0.0.1:3302
    :dedent:


.. _replication-master_replica_configuring_credentials:

Step 3: Creating a user for replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the :ref:`credentials <configuration_reference_credentials>` section, create the ``replicator`` user with the ``replication`` role:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [replication]
    :dedent:


.. _replication-master_replica_configuring_advertise:

Step 4: Specifying advertise URIs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` to advertise the current instance to other replica set members:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
    :language: yaml
    :start-at: iproto:
    :end-at: login: replicator
    :dedent:

.. _replication-master_replica_configuring_result:

Resulting configuration
~~~~~~~~~~~~~~~~~~~~~~~

The resulting replica set configuration should look as follows:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
    :language: yaml
    :end-at: 127.0.0.1:3302
    :dedent:




.. _replication-master_replica_work:

Working with a replica set
--------------------------

.. _replication-master_replica_starting:

Starting instances
~~~~~~~~~~~~~~~~~~

1.  After configuring a replica set, execute the :ref:`tt start <tt-start>` command from the :ref:`tt environment directory <replication-tt-env>`:

    .. code-block:: console

        $ tt start manual_leader
           • Starting an instance [manual_leader:instance001]...
           • Starting an instance [manual_leader:instance002]...

2.  Check that instances are in the ``RUNNING`` status using the :ref:`tt status <tt-status>` command:

    .. code-block:: console

        $ tt status manual_leader
        INSTANCE                   STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
        manual_leader:instance001  RUNNING  8841  RW    ready   running  --
        manual_leader:instance002  RUNNING  8842  RO    ready   running  --


.. _replication-master_replica_status:

Checking a replica set status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Connect to ``instance001`` using :ref:`tt connect <tt-connect>`:

    .. code-block:: console

        $ tt connect manual_leader:instance001
           • Connecting to the instance...
           • Connected to manual_leader:instance001

2.  Make sure that the instance is in the ``running`` state by executing :ref:`box.info.status <box_introspection-box_info>`:

    .. code-block:: console

        manual_leader:instance001> box.info.status
        ---
        - running
        ...

3.  Check that the instance is writable using ``box.info.ro``:

    .. code-block:: console

        manual_leader:instance001> box.info.ro
        ---
        - false
        ...

4.  Execute ``box.info.replication`` to check a replica set status.
    For ``instance002``, ``upstream.status`` and ``downstream.status`` should be ``follow``.

    .. code-block:: console

        manual_leader:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660
            lsn: 7
            name: instance001
          2:
            id: 2
            uuid: 4cfa6e3c-625e-b027-00a7-29b2f2182f23
            lsn: 0
            upstream:
              status: follow
              idle: 0.3893879999996
              peer: replicator@127.0.0.1:3302
              lag: 0.00028800964355469
            name: instance002
            downstream:
              status: follow
              idle: 0.37777199999982
              vclock: {1: 7}
              lag: 0
        ...

    To see the diagrams that illustrate how the ``upstream`` and ``downstream`` connections look,
    refer to :ref:`Monitoring a replica set <replication-monitoring>`.


.. _replication-master_replica_add_data:

Adding data
~~~~~~~~~~~

To check that a replica (``instance002``) gets all updates from the master, follow the steps below:

1.  On ``instance001``, create a space and add data as described in :ref:`CRUD operation examples <box_space_examples>`.

2.  Open the second terminal, connect to ``instance002`` using ``tt connect``, and use the ``select`` operation to make sure data is replicated.

3.  Check that :ref:`box.info.vclock <box_introspection-box_info>` values are the same on both instances:

    -   ``instance001``:

        .. code-block:: console

            manual_leader:instance001> box.info.vclock
            ---
            - {1: 21}
            ...

    -   ``instance002``:

        .. code-block:: console

            manual_leader:instance002> box.info.vclock
            ---
            - {1: 21}
            ...

    .. vclock_0th_component_note_start

    .. NOTE::

        Note that a ``vclock`` value might include the ``0`` component that is related to local space operations and might differ for different instances in a replica set.

    .. vclock_0th_component_note_end



..  _replication-add_instances:

Adding instances
----------------

This section describes how to add a new replica to a replica set.

..  _replication-add_instances-update-config:

Adding an instance to the configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Add ``instance003`` to the ``instances.yml`` file:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/instances.yml
        :language: yaml
        :dedent:

2.  Add ``instance003`` with the specified ``iproto.listen`` option to the ``config.yaml`` file:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
        :language: yaml
        :start-at: groups:
        :end-at: 127.0.0.1:3303
        :dedent:


..  _replication-add_instances-start-instance:

Starting an instance
~~~~~~~~~~~~~~~~~~~~

1.  Open the third terminal to work with a new instance.
    Start ``instance003`` using ``tt start``:

    .. code-block:: console

        $ tt start manual_leader:instance003
           • Starting an instance [manual_leader:instance003]...

2.  Check a replica set status using ``tt status``:

    .. code-block:: console

        $ tt status manual_leader
        INSTANCE                   STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
        manual_leader:instance001  RUNNING  8841  RW    ready   running  --
        manual_leader:instance002  RUNNING  8842  RO    ready   running  --
        manual_leader:instance003  RUNNING  8856  RO    ready   running  --


..  _replication-add_instances-reload-config:

Reloading configuration
~~~~~~~~~~~~~~~~~~~~~~~

After you added ``instance003`` to the configuration and started it, you need to reload configurations on all instances.
This is required to allow ``instance001`` and ``instance002`` to get data from the new instance in case it becomes a master.

1.  Connect to ``instance003`` using ``tt connect``:

    .. code-block:: console

        $ tt connect manual_leader:instance003
           • Connecting to the instance...
           • Connected to manual_leader:instance001

2.  Reload configurations on all three instances using the ``reload()`` function provided by the :ref:`config <config-module>` module:

    -   ``instance001``:

        .. code-block:: console

            manual_leader:instance001> require('config'):reload()
            ---
            ...

    -   ``instance002``:

        .. code-block:: console

            manual_leader:instance002> require('config'):reload()
            ---
            ...

    -   ``instance003``:

        .. code-block:: console

            manual_leader:instance003> require('config'):reload()
            ---
            ...


3.  Execute ``box.info.replication`` to check a replica set status.
    Make sure that ``upstream.status`` and ``downstream.status`` are ``follow`` for ``instance003``.

    .. box_info_replication_manual_leader_start

    .. code-block:: console

        manual_leader:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660
            lsn: 21
            name: instance001
          2:
            id: 2
            uuid: 4cfa6e3c-625e-b027-00a7-29b2f2182f23
            lsn: 0
            upstream:
              status: follow
              idle: 0.052655000000414
              peer: replicator@127.0.0.1:3302
              lag: 0.00010204315185547
            name: instance002
            downstream:
              status: follow
              idle: 0.09503500000028
              vclock: {1: 21}
              lag: 0.00026917457580566
          3:
            id: 3
            uuid: 9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6
            lsn: 0
            upstream:
              status: follow
              idle: 0.77522099999987
              peer: replicator@127.0.0.1:3303
              lag: 0.0001838207244873
            name: instance003
            downstream:
              status: follow
              idle: 0.33186100000012
              vclock: {1: 21}
              lag: 0
                ...

    .. box_info_replication_manual_leader_end



..  _replication-controlled_failover:

Performing manual failover
--------------------------

This section shows how to perform manual failover and change a replica set leader.

.. _replication-controlled_failover_read_only:

Switching instances to read-only mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  In the ``config.yaml`` file, change the replica set leader from ``instance001`` to ``null``:

    .. code-block:: yaml

        replicaset001:
          leader: null

2.  Reload configurations on all three instances using :ref:`config:reload() <config-module>` and check that instances are in read-only mode.
    The example below shows how to do this for ``instance001``:

    .. code-block:: console

        manual_leader:instance001> require('config'):reload()
        ---
        ...
        manual_leader:instance001> box.info.ro
        ---
        - true
        ...
        manual_leader:instance001> box.info.ro_reason
        ---
        - config
        ...


3.  Make sure that :ref:`box.info.vclock <box_introspection-box_info>` values are the same on all instances:

    -   ``instance001``:

        .. code-block:: console

            manual_leader:instance001> box.info.vclock
            ---
            - {1: 21}
            ...

    -   ``instance002``:

        .. code-block:: console

            manual_leader:instance002> box.info.vclock
            ---
            - {1: 21}
            ...


    -   ``instance003``:

        .. code-block:: console

            manual_leader:instance003> box.info.vclock
            ---
            - {1: 21}
            ...


.. _replication-controlled_failover_new_leader:

Configuring a new leader
~~~~~~~~~~~~~~~~~~~~~~~~

1.  Change a replica set leader in ``config.yaml`` to ``instance002``:

    .. code-block:: yaml

        replicaset001:
          leader: instance002

2.  Reload configuration on all instances using :ref:`config:reload() <config-module>`.

3.  Make sure that ``instance002`` is a new master:

    .. code-block:: console

        manual_leader:instance002> box.info.ro
        ---
        - false
        ...

4.  Check replication status using ``box.info.replication``.


..  _replication-remove_instances:

Removing instances
------------------

This section describes the process of removing an instance from a replica set.

Before removing an instance, make sure it is in read-only mode.
If the instance is a master, perform :ref:`manual failover <replication-controlled_failover>`.

..  _replication-remove_instances-disconnect:

Disconnecting an instance
~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Clear the ``iproto`` option for ``instance003`` by setting its value to ``{}``:

    .. code-block:: yaml

        instance003:
          iproto: {}

2.  Reload configurations on ``instance001`` and ``instance002``:

    -   ``instance001``:

        .. code-block:: console

            manual_leader:instance001> require('config'):reload()
            ---
            ...

    -   ``instance002``:

        .. code-block:: console

            manual_leader:instance002> require('config'):reload()
            ---
            ...

3.  Check that the ``upstream`` section is missing for ``instance003`` by executing ``box.info.replication[3]``:

    .. code-block:: console

        manual_leader:instance001> box.info.replication[3]
        ---
        - id: 3
          uuid: 9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6
          lsn: 0
          downstream:
            status: follow
            idle: 0.4588760000006
            vclock: {1: 21}
            lag: 0
          name: instance003
        ...


..  _replication-remove_instances-stop:

Stopping an instance
~~~~~~~~~~~~~~~~~~~~

1.  Stop ``instance003`` using the :ref:`tt stop <tt-stop>` command:

    .. code-block:: console

        $ tt stop manual_leader:instance003
           • The Instance manual_leader:instance003 (PID = 15551) has been terminated.


2.  Check that ``downstream.status`` is ``stopped`` for ``instance003``:

    .. code-block:: console

        manual_leader:instance001> box.info.replication[3]
        ---
        - id: 3
          uuid: 9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6
          lsn: 0
          downstream:
            status: stopped
            message: 'unexpected EOF when reading from socket, called on fd 27, aka 127.0.0.1:3301,
              peer of 127.0.0.1:54185: Broken pipe'
            system_message: Broken pipe
          name: instance003
        ...


..  _replication-remove_instances-update-config:

Removing an instance from the configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Remove ``instance003`` from the ``instances.yml`` file:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/instances.yml
        :language: yaml
        :end-at: instance002
        :dedent:

2.  Remove ``instance003`` from ``config.yaml``:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
        :language: yaml
        :start-at: instances
        :end-at: 127.0.0.1:3302
        :dedent:

3.  Reload configurations on ``instance001`` and ``instance002``:

    -   ``instance001``:

        .. code-block:: console

            manual_leader:instance001> require('config'):reload()
            ---
            ...

    -   ``instance002``:

        .. code-block:: console

            manual_leader:instance002> require('config'):reload()
            ---
            ...


..  _replication-remove_instances-remove_cluster:

Removing an instance from the '_cluster' space
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To remove an instance from the replica set permanently, it should be removed from the :ref:`box.space._cluster <box_space-cluster>` system space:

1.  Select all the tuples in the ``box.space._cluster`` system space:

    .. code-block:: console

        manual_leader:instance002> box.space._cluster:select{}
        ---
        - - [1, '9bb111c2-3ff5-36a7-00f4-2b9a573ea660', 'instance001']
          - [2, '4cfa6e3c-625e-b027-00a7-29b2f2182f23', 'instance002']
          - [3, '9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6', 'instance003']
        ...

2.  Delete a tuple corresponding to ``instance003``:

    .. code-block:: console

        manual_leader:instance002> box.space._cluster:delete(3)
        ---
        - [3, '9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6', 'instance003']
        ...

3.  Execute ``box.info.replication`` to check the health status:

    .. code-block:: console

        manual_leader:instance002> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660
            lsn: 21
            upstream:
              status: follow
              idle: 0.73316000000159
              peer: replicator@127.0.0.1:3301
              lag: 0.00016212463378906
            name: instance001
            downstream:
              status: follow
              idle: 0.7269320000014
              vclock: {2: 1, 1: 21}
              lag: 0.00083398818969727
          2:
            id: 2
            uuid: 4cfa6e3c-625e-b027-00a7-29b2f2182f23
            lsn: 1
            name: instance002
        ...

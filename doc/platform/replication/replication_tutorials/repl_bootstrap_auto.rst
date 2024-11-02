..  _replication-bootstrap-auto:

Master-replica: automated failover
==================================

**Example on GitHub**: `auto_leader <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/auto_leader>`_

This tutorial shows how to configure and work with a replica set with automated failover.


..  _replication-automated-failover-tt-env:

Prerequisites
-------------

Before starting this tutorial:

1.  Install the :ref:`tt <tt-cli>` utility.

2.  Create a tt environment in the current directory by executing the :ref:`tt init <tt-init>` command.

3.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``auto_leader`` directory.

4.  Inside ``instances.enabled/auto_leader``, create the ``instances.yml`` and ``config.yaml`` files:

    -   ``instances.yml`` specifies instances to :ref:`run <replication-automated-failover-start-instances>` in the current environment and should look like this:

        ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/instances.yml
            :language: yaml
            :dedent:

    -   The ``config.yaml`` file is intended to store a :ref:`replica set configuration <replication-automated-failover-configure-cluster>`.




.. _replication-automated-failover-configure-cluster:

Configuring a replica set
-------------------------

This section describes how to configure a replica set in ``config.yaml``.

.. _replication-automated-failover_configuring_failover_mode:

Step 1: Configuring a failover mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, set the :ref:`replication.failover <configuration_reference_replication_failover>` option to ``election``:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
    :language: yaml
    :start-at: replication:
    :end-at: failover: election
    :dedent:

.. _replication-automated-failover_configuring_topology:

Step 2: Defining a replica set topology
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Define a replica set topology inside the :ref:`groups <configuration_reference_groups>` section.
The :ref:`iproto.listen <configuration_reference_iproto_listen>` option specifies an address used to listen for incoming requests and allows replicas to communicate with each other.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
    :language: yaml
    :start-at: groups:
    :end-at: 127.0.0.1:3303
    :dedent:


.. _replication-automated-failover_configuring_credentials:

Step 3: Creating a user for replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the :ref:`credentials <configuration_reference_credentials>` section, create the ``replicator`` user with the ``replication`` role:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [replication]
    :dedent:


.. _replication-automated-failover_configuring_advertise:

Step 4: Specifying advertise URIs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` to advertise the current instance to other replica set members:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
    :language: yaml
    :start-at: iproto:
    :end-at: login: replicator
    :dedent:

.. _replication-automated-failover_configuring_result:

Resulting configuration
~~~~~~~~~~~~~~~~~~~~~~~

The resulting replica set configuration should look as follows:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
    :language: yaml
    :end-at: 127.0.0.1:3303
    :dedent:




.. _replication-automated-failover-work:

Working with a replica set
--------------------------

.. _replication-automated-failover-start-instances:

Starting instances
~~~~~~~~~~~~~~~~~~

1.  After configuring a replica set, execute the :ref:`tt start <tt-start>` command from the :ref:`tt environment directory <replication-automated-failover-tt-env>`:

    .. code-block:: console

        $ tt start auto_leader
           • Starting an instance [auto_leader:instance001]...
           • Starting an instance [auto_leader:instance002]...
           • Starting an instance [auto_leader:instance003]...

2.  Check that instances are in the ``RUNNING`` status using the :ref:`tt status <tt-status>` command:

    .. code-block:: console

        $ tt status auto_leader
        INSTANCE                 STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
        auto_leader:instance001  RUNNING  9170  RO    ready   running  --
        auto_leader:instance002  RUNNING  9171  RO    ready   running  --
        auto_leader:instance003  RUNNING  9172  RW    ready   running  --



.. _replication-automated-failover-work-status:

Checking a replica set status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Connect to ``instance001`` using :ref:`tt connect <tt-connect>`:

    .. code-block:: console

        $ tt connect auto_leader:instance001
           • Connecting to the instance...
           • Connected to auto_leader:instance001

2.  Check the instance state in regard to :ref:`leader election <repl_leader_elect_process>` using :ref:`box.info.election <box_info_election>`.
    The output below shows that ``instance001`` is a follower while ``instance002`` is a replica set leader.

    .. code-block:: console

        auto_leader:instance001> box.info.election
        ---
        - leader_idle: 0.77491499999815
          leader_name: instance002
          state: follower
          vote: 0
          term: 2
          leader: 1
        ...

3.  Check that ``instance001`` is in read-only mode using ``box.info.ro``:

    .. code-block:: console

        auto_leader:instance001> box.info.ro
        ---
        - true
        ...

4.  Execute ``box.info.replication`` to check a replica set status.
    Make sure that ``upstream.status`` and ``downstream.status`` are ``follow`` for ``instance002`` and ``instance003``.

    .. code-block:: console

        auto_leader:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 4cfa6e3c-625e-b027-00a7-29b2f2182f23
            lsn: 9
            upstream:
              status: follow
              idle: 0.8257709999998
              peer: replicator@127.0.0.1:3302
              lag: 0.00012326240539551
            name: instance002
            downstream:
              status: follow
              idle: 0.81174199999805
              vclock: {1: 9}
              lag: 0
          2:
            id: 2
            uuid: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660
            lsn: 0
            name: instance001
          3:
            id: 3
            uuid: 9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6
            lsn: 0
            upstream:
              status: follow
              idle: 0.83125499999733
              peer: replicator@127.0.0.1:3303
              lag: 0.00010204315185547
            name: instance003
            downstream:
              status: follow
              idle: 0.83213399999659
              vclock: {1: 9}
              lag: 0
        ...

    To see the diagrams that illustrate how the ``upstream`` and ``downstream`` connections look,
    refer to :ref:`Monitoring a replica set <replication-monitoring>`.

.. _replication-automated-failover-add-data:

Adding data
~~~~~~~~~~~

To check that replicas (``instance001`` and ``instance003``) get all updates from the master (``instance002``), follow the steps below:

1.  Connect to ``instance002`` using ``tt connect``:

    .. code-block:: console

        $ tt connect auto_leader:instance002
           • Connecting to the instance...
           • Connected to auto_leader:instance002

2.  Create a space and add data as described in :ref:`CRUD operation examples <box_space_examples>`.

3.  Use the ``select`` operation on ``instance001`` and ``instance003`` to make sure data is replicated.

4.  Check that the ``1`` component of :ref:`box.info.vclock <box_introspection-box_info>` values are the same on all instances:

    -   ``instance001``:

        .. code-block:: console

            auto_leader:instance001> box.info.vclock
            ---
            - {0: 1, 1: 32}
            ...

    -   ``instance002``:

        .. code-block:: console

            auto_leader:instance002> box.info.vclock
            ---
            - {0: 1, 1: 32}
            ...

    -   ``instance003``:

        .. code-block:: console

            auto_leader:instance003> box.info.vclock
            ---
            - {0: 1, 1: 32}
            ...

..  include:: /platform/replication/replication_tutorials/repl_bootstrap.rst
    :start-after: vclock_0th_component_note_start
    :end-before: vclock_0th_component_note_end



..  _replication-automated-failover-testing:

Testing automated failover
--------------------------

To test how automated failover works if the current master is stopped, follow the steps below:

1.  Stop the current master instance (``instance002``) using the ``tt stop`` command:

    .. code-block:: console

        $ tt stop auto_leader:instance002
           • The Instance auto_leader:instance002 (PID = 24769) has been terminated.


2.  On ``instance001``, check  ``box.info.election``.
    In this example, a new replica set leader is ``instance001``.

    .. code-block:: console

        auto_leader:instance001> box.info.election
        ---
        - leader_idle: 0
          leader_name: instance001
          state: leader
          vote: 2
          term: 3
          leader: 2
        ...

3.  Check replication status using ``box.info.replication`` for ``instance002``:

    -   ``upstream.status`` is ``disconnected``.
    -   ``downstream.status`` is ``stopped``.

    .. box_info_replication_auto_leader_disconnected_start

    .. code-block:: console

        auto_leader:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 4cfa6e3c-625e-b027-00a7-29b2f2182f23
            lsn: 32
            upstream:
              peer: replicator@127.0.0.1:3302
              lag: 0.00032305717468262
              status: disconnected
              idle: 48.352504000002
              message: 'connect, called on fd 20, aka 127.0.0.1:62575: Connection refused'
              system_message: Connection refused
            name: instance002
            downstream:
              status: stopped
              message: 'unexpected EOF when reading from socket, called on fd 32, aka 127.0.0.1:3301,
                peer of 127.0.0.1:62204: Broken pipe'
              system_message: Broken pipe
          2:
            id: 2
            uuid: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660
            lsn: 1
            name: instance001
          3:
            id: 3
            uuid: 9a3a1b9b-8a18-baf6-00b3-a6e5e11fd8b6
            lsn: 0
            upstream:
              status: follow
              idle: 0.18620999999985
              peer: replicator@127.0.0.1:3303
              lag: 0.00012516975402832
            name: instance003
            downstream:
              status: follow
              idle: 0.19718099999955
              vclock: {2: 1, 1: 32}
              lag: 0.00051403045654297
        ...

    .. box_info_replication_auto_leader_disconnected_end

    The diagram below illustrates how the ``upstream`` and ``downstream`` connections look like:

    ..  image:: box_info_replication_instance002_disconnected.png
        :width: 600
        :align: center
        :alt: replication status on a new master


4.  Start ``instance002`` back using ``tt start``:

    .. code-block:: console

        $ tt start auto_leader:instance002
           • Starting an instance [auto_leader:instance002]...


..  _replication-automated-failover-new-leader:

Choosing a leader manually
--------------------------

1.  Make sure that :ref:`box.info.vclock <box_introspection-box_info>` values (except the ``0`` components) are the same on all instances:

    -   ``instance001``:

        .. code-block:: console

            auto_leader:instance001> box.info.vclock
            ---
            - {0: 2, 1: 32, 2: 1}
            ...

    -   ``instance002``:

        .. code-block:: console

            auto_leader:instance002> box.info.vclock
            ---
            - {0: 2, 1: 32, 2: 1}
            ...


    -   ``instance003``:

        .. code-block:: console

            auto_leader:instance003> box.info.vclock
            ---
            - {0: 3, 1: 32, 2: 1}
            ...

2.  On ``instance002``, run :ref:`box.ctl.promote() <box_ctl-promote>` to choose it as a new replica set leader:

    .. code-block:: console

        auto_leader:instance002> box.ctl.promote()
        ---
        ...

3.  Check ``box.info.election`` to make sure ``instance002`` is a leader now:

    .. code-block:: console

        auto_leader:instance002> box.info.election
        ---
        - leader_idle: 0
          leader_name: instance002
          state: leader
          vote: 1
          term: 4
          leader: 1
        ...



..  _replication-automated-failover-add-remove-instances:

Adding and removing instances
-----------------------------

The process of adding instances to a replica set and removing them is similar for all failover modes.
Learn how to do this from the :ref:`Master-replica: manual failover <replication-bootstrap>` tutorial:

-   :ref:`Adding instances <replication-add_instances>`
-   :ref:`Removing instances <replication-remove_instances>`

Before removing an instance from a replica set with :ref:`replication.failover <configuration_reference_replication_failover>` set to ``election``, make sure this instance is in read-only mode.
If the instance is a master, choose a :ref:`new leader manually <replication-automated-failover-new-leader>`.

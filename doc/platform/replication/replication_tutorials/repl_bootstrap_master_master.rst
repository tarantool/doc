..  _replication-bootstrap-master-master:

Master-master
=============

**Example on GitHub**: `master_master <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/master_master>`_

This tutorial shows how to configure and work with a master-master replica set.


..  _replication-master-master-tt-env:

Prerequisites
-------------

Before starting this tutorial:

1.  Install the :ref:`tt <tt-cli>` utility.

2.  Create a tt environment in the current directory by executing the :ref:`tt init <tt-init>` command.

3.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``master_master`` directory.

4.  Inside ``instances.enabled/master_master``, create the ``instances.yml`` and ``config.yaml`` files:

    -   ``instances.yml`` specifies instances to :ref:`run <replication-master-master-start-instances>` in the current environment and should look like this:

        ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/instances.yml
            :language: yaml
            :end-at: instance002:
            :dedent:

    -   The ``config.yaml`` file is intended to store a :ref:`replica set configuration <replication-master-master-configure-cluster>`.




.. _replication-master-master-configure-cluster:

Configuring a replica set
-------------------------

This section describes how to configure a replica set in ``config.yaml``.


.. _replication-master-master-configure-failover_mode:

Step 1: Configuring a failover mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, set the :ref:`replication.failover <configuration_reference_replication_failover>` option to ``off``:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
    :language: yaml
    :start-at: replication:
    :end-at: failover: off
    :dedent:



.. _replication-master-master-configure-topology:

Step 2: Defining a replica set topology
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Define a replica set topology inside the :ref:`groups <configuration_reference_groups>` section:

-   The ``database.mode`` option should be set to ``rw`` to make instances work in read-write mode.
-   The :ref:`iproto.listen <configuration_reference_iproto_listen>` option specifies an address used to listen for incoming requests and allows replicas to communicate with each other.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
    :language: yaml
    :start-at: groups:
    :end-at: 127.0.0.1:3302
    :dedent:


.. _replication-master-master-configure_credentials:

Step 3: Creating a user for replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the :ref:`credentials <configuration_reference_credentials>` section, create the ``replicator`` user with the ``replication`` role:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [replication]
    :dedent:


.. _replication-master-master-configure_advertise:

Step 4: Specifying advertise URIs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` to advertise the current instance to other replica set members:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
    :language: yaml
    :start-at: iproto:
    :end-at: login: replicator
    :dedent:


.. _replication-master-master-configure_result:

Resulting configuration
~~~~~~~~~~~~~~~~~~~~~~~

The resulting replica set configuration should look as follows:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
    :language: yaml
    :end-at: 127.0.0.1:3302
    :dedent:




.. _replication-master-master-work:

Working with a replica set
--------------------------

.. _replication-master-master-start-instances:

Starting instances
~~~~~~~~~~~~~~~~~~

1.  After configuring a replica set, execute the :ref:`tt start <tt-start>` command from the :ref:`tt environment directory <replication-master-master-tt-env>`:

    .. code-block:: console

        $ tt start master_master
           • Starting an instance [master_master:instance001]...
           • Starting an instance [master_master:instance002]...

2.  Check that instances are in the ``RUNNING`` status using the :ref:`tt status <tt-status>` command:

    .. code-block:: console

        $ tt status master_master
        INSTANCE                   STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
        master_master:instance001  RUNNING  9263  RW    ready   running  --
        master_master:instance002  RUNNING  9264  RW    ready   running  --


.. _replication-master-master-check-status:

Checking a replica set status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Connect to both instances using :ref:`tt connect <tt-connect>`.
    Below is the example for ``instance001``:

    .. code-block:: console

        $ tt connect master_master:instance001
           • Connecting to the instance...
           • Connected to master_master:instance001

        master_master:instance001>

2.  Check that both instances are writable using ``box.info.ro``:

    -   ``instance001``:

        .. code-block:: tarantoolsession

            master_master:instance001> box.info.ro
            ---
            - false
            ...

    -   ``instance002``:

        .. code-block:: tarantoolsession

            master_master:instance002> box.info.ro
            ---
            - false
            ...

3.  Execute ``box.info.replication`` to check a replica set status.
    For ``instance002``, ``upstream.status`` and ``downstream.status`` should be ``follow``.

    .. code-block:: tarantoolsession

        master_master:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: c3bfd89f-5a1c-4556-aa9f-461377713a2a
            lsn: 7
            name: instance001
          2:
            id: 2
            uuid: dccf7485-8bff-47f6-bfc4-b311701e36ef
            lsn: 0
            upstream:
              status: follow
              idle: 0.93246499999987
              peer: replicator@127.0.0.1:3302
              lag: 0.00016188621520996
            name: instance002
            downstream:
              status: follow
              idle: 0.8988360000003
              vclock: {1: 7}
              lag: 0
        ...

    To see the diagrams that illustrate how the ``upstream`` and ``downstream`` connections look,
    refer to :ref:`Monitoring a replica set <replication-monitoring>`.

..  include:: /platform/replication/replication_tutorials/repl_bootstrap.rst
    :start-after: vclock_0th_component_note_start
    :end-before: vclock_0th_component_note_end




.. _replication-master-master-add-data:

Adding data
~~~~~~~~~~~

To check that both instances get updates from each other, follow the steps below:

1.  On ``instance001``, create a space, format it, and create a primary index:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/myapp.lua
        :start-at: box.schema.space.create
        :end-at: box.space.bands:create_index
        :language: lua
        :dedent:

    Then, add sample data to this space:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/myapp.lua
        :start-at: Roxette
        :end-at: Scorpions
        :language: lua
        :dedent:

2.  On ``instance002``, use the ``select`` operation to make sure data is replicated:

    .. code-block:: tarantoolsession

        master_master:instance002> box.space.bands:select()
        ---
        - - [1, 'Roxette', 1986]
          - [2, 'Scorpions', 1965]
        ...

3.  Add more data to the created space on ``instance002``:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/myapp.lua
        :start-at: Ace of Base
        :end-at: The Beatles
        :language: lua
        :dedent:

4.  Get back to ``instance001`` and use ``select`` to make sure new records are replicated:

    .. code-block:: tarantoolsession

        master_master:instance001> box.space.bands:select()
        ---
        - - [1, 'Roxette', 1986]
          - [2, 'Scorpions', 1965]
          - [3, 'Ace of Base', 1987]
          - [4, 'The Beatles', 1960]
        ...

5.  Check that :ref:`box.info.vclock <box_introspection-box_info>` values are the same on both instances:

    -   ``instance001``:

        .. code-block:: tarantoolsession

            master_master:instance001> box.info.vclock
            ---
            - {2: 2, 1: 12}
            ...

    -   ``instance002``:

        .. code-block:: tarantoolsession

            master_master:instance002> box.info.vclock
            ---
            - {2: 2, 1: 12}
            ...



.. _replication-master-master-resolve-conflicts:

Resolving replication conflicts
-------------------------------

..  NOTE::

    To learn how to fix and prevent replication conflicts using trigger functions, see :ref:`Resolving replication conflicts <replication-problem_solving>`.

.. _replication-master-master_conflicting_records:

Inserting conflicting records
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To insert conflicting records to ``instance001`` and ``instance002``, follow the steps below:

1.  Stop ``instance001`` using the ``tt stop`` command:

    .. code-block:: console

        $ tt stop master_master:instance001

2.  On ``instance002``, insert a new record:

    .. code-block:: lua

        box.space.bands:insert { 5, 'incorrect data', 0 }

3.  Stop ``instance002`` using ``tt stop``:

    .. code-block:: console

        $ tt stop master_master:instance002

4.  Start ``instance001`` back:

    .. code-block:: console

        $ tt start master_master:instance001

5.  Connect to ``instance001`` and insert a record that should conflict with a record already inserted on ``instance002``:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/myapp.lua
        :start-at: Pink Floyd
        :end-at: Pink Floyd
        :language: lua
        :dedent:

6.  Start ``instance002`` back:

    .. code-block:: console

        $ tt start master_master:instance002

    Then, check ``box.info.replication`` on ``instance001``.
    ``upstream.status`` should be ``stopped`` because of the ``Duplicate key exists`` error:

    .. code-block:: tarantoolsession

        master_master:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: c3bfd89f-5a1c-4556-aa9f-461377713a2a
            lsn: 13
            name: instance001
          2:
            id: 2
            uuid: dccf7485-8bff-47f6-bfc4-b311701e36ef
            lsn: 2
            upstream:
              peer: replicator@127.0.0.1:3302
              lag: 115.99977827072
              status: stopped
              idle: 2.0342070000006
              message: Duplicate key exists in unique index "primary" in space "bands" with
                old tuple - [5, "Pink Floyd", 1965] and new tuple - [5, "incorrect data",
                0]
            name: instance002
            downstream:
              status: stopped
              message: 'unexpected EOF when reading from socket, called on fd 24, aka 127.0.0.1:3301,
                peer of 127.0.0.1:58478: Broken pipe'
              system_message: Broken pipe
        ...

    The diagram below illustrates how the ``upstream`` and ``downstream`` connections look like:

    ..  image:: box_info_replication_master_master_stopped.png
        :width: 600
        :align: center
        :alt: replication status on a new master


.. _replication-master-master-reseed-replica:

Reseeding a replica
~~~~~~~~~~~~~~~~~~~

To resolve a replication conflict, ``instance002`` should get the correct data from ``instance001`` first.
To achieve this, ``instance002`` should be rebootstrapped:

1.  Select all the tuples in the :ref:`box.space._cluster <box_space-cluster>` system space to get a UUID of ``instance002``:

    .. code-block:: tarantoolsession

        master_master:instance001> box.space._cluster:select()
        ---
        - - [1, 'c3bfd89f-5a1c-4556-aa9f-461377713a2a', 'instance001']
          - [2, 'dccf7485-8bff-47f6-bfc4-b311701e36ef', 'instance002']
        ...

2.  In the ``config.yaml`` file, change the following ``instance002`` settings:

    *   Set ``database.mode`` to ``ro``.
    *   Set ``database.instance_uuid`` to a UUID value obtained in the previous step.

    .. code-block:: yaml

        instance002:
          database:
            mode: ro
            instance_uuid: 'dccf7485-8bff-47f6-bfc4-b311701e36ef'

3.  Reload configurations on both instances using the :ref:`config:reload() <config_api_reference_reload>` function:

    -   ``instance001``:

        .. code-block:: tarantoolsession

            master_master:instance001> require('config'):reload()
            ---
            ...

    -   ``instance002``:

        .. code-block:: tarantoolsession

            master_master:instance002> require('config'):reload()
            ---
            ...

4.  Delete write-ahead logs and snapshots stored in the ``var/lib/instance002`` directory.

    .. NOTE::

        ``var/lib`` is the default directory used by tt to store write-ahead logs and snapshots.
        Learn more from :ref:`Configuration <tt-config>`.

5.  Restart ``instance002`` using the :ref:`tt restart <tt-restart>` command:

    .. code-block:: console

        $ tt restart master_master:instance002

6.  Connect to ``instance002`` and make sure it received the correct data from ``instance001``:

    .. code-block:: tarantoolsession

        master_master:instance002> box.space.bands:select()
        ---
        - - [1, 'Roxette', 1986]
          - [2, 'Scorpions', 1965]
          - [3, 'Ace of Base', 1987]
          - [4, 'The Beatles', 1960]
          - [5, 'Pink Floyd', 1965]
        ...


.. _replication-master-master-resolve-conflict:

Restarting replication
~~~~~~~~~~~~~~~~~~~~~~

After :ref:`reseeding a replica <replication-master-master-reseed-replica>`, you need to resolve a replication conflict that keeps replication stopped:

1.  Execute ``box.info.replication`` on ``instance001``.
    ``upstream.status`` is still stopped:

    .. code-block:: tarantoolsession

        master_master:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: c3bfd89f-5a1c-4556-aa9f-461377713a2a
            lsn: 13
            name: instance001
          2:
            id: 2
            uuid: dccf7485-8bff-47f6-bfc4-b311701e36ef
            lsn: 2
            upstream:
              peer: replicator@127.0.0.1:3302
              lag: 115.99977827072
              status: stopped
              idle: 1013.688243
              message: Duplicate key exists in unique index "primary" in space "bands" with
                old tuple - [5, "Pink Floyd", 1965] and new tuple - [5, "incorrect data",
                0]
            name: instance002
            downstream:
              status: follow
              idle: 0.69694700000036
              vclock: {2: 2, 1: 13}
              lag: 0
        ...

    The diagram below illustrates how the ``upstream`` and ``downstream`` connections look like:

    ..  image:: box_info_replication_master_master_follow_stopped.png
        :width: 600
        :align: center
        :alt: replication status after reseeding a replica


2.  In the ``config.yaml`` file, clear the ``iproto`` option for ``instance001`` by setting its value to ``{}`` to disconnect this instance from ``instance002``.
    Set ``database.mode`` to ``ro``:

    .. code-block:: yaml

        instance001:
          database:
            mode: ro
          iproto: {}

3.  Reload configuration on ``instance001`` only:

    .. code-block:: tarantoolsession

        master_master:instance001> require('config'):reload()
        ---
        ...

4.  Change ``database.mode`` values back to ``rw`` for both instances and restore ``iproto.listen`` for ``instance001``.
    The ``database.instance_uuid`` option can be removed for ``instance002``:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
        :language: yaml
        :start-at: instance001
        :end-at: 127.0.0.1:3302
        :dedent:

5.  Reload configurations on both instances one more time:

    -   ``instance001``:

        .. code-block:: tarantoolsession

            master_master:instance001> require('config'):reload()
            ---
            ...

    -   ``instance002``:

        .. code-block:: tarantoolsession

            master_master:instance002> require('config'):reload()
            ---
            ...

6.  Check ``box.info.replication``.
    ``upstream.status`` should be ``follow`` now.

    .. code-block:: tarantoolsession

        master_master:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: c3bfd89f-5a1c-4556-aa9f-461377713a2a
            lsn: 13
            name: instance001
          2:
            id: 2
            uuid: dccf7485-8bff-47f6-bfc4-b311701e36ef
            lsn: 2
            upstream:
              status: follow
              idle: 0.86873800000012
              peer: replicator@127.0.0.1:3302
              lag: 0.0001060962677002
            name: instance002
            downstream:
              status: follow
              idle: 0.058662999999797
              vclock: {2: 2, 1: 13}
              lag: 0
        ...



.. _replication-master-master-add-remove-instances:

Adding and removing instances
-----------------------------

The process of adding instances to a replica set and removing them is similar for all failover modes.
Learn how to do this from the :ref:`Master-replica: manual failover <replication-bootstrap>` tutorial:

-   :ref:`Adding instances <replication-add_instances>`
-   :ref:`Removing instances <replication-remove_instances>`

Before removing an instance from a replica set with :ref:`replication.failover <configuration_reference_replication_failover>` set to ``off``, make sure this instance is in read-only mode.

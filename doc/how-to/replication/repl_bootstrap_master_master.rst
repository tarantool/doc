..  _replication-bootstrap-master-master:

Master-master
=============

**Example on GitHub**: `master_master <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/master_master>`_


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
    :end-at: listen: 127.0.0.1:3302
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
    :end-at: peer: replicator@
    :dedent:


.. _replication-master-master-configure_result:

Resulting configuration
~~~~~~~~~~~~~~~~~~~~~~~

The resulting replica set configuration should look as follows:

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
    :language: yaml
    :end-at: listen: 127.0.0.1:3302
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
        INSTANCE                      STATUS      PID
        master_master:instance001     RUNNING     30818
        master_master:instance002     RUNNING     30819


.. _replication-master-master-check-status:

Checking a replica set status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Connect to both instances using :ref:`tt connect <tt-connect>`.
    Below is the example for ``instance001``:

    .. code-block:: console

        $ tt connect master_master:instance001
           • Connecting to the instance...
           • Connected to master_master:instance001

2.  Check that both instances are writable using ``box.info.ro``:

    -   ``instance001``:

        .. code-block:: console

            master_master:instance001> box.info.ro
            ---
            - false
            ...

    -   ``instance002``:

        .. code-block:: console

            master_master:instance002> box.info.ro
            ---
            - false
            ...

3.  Execute ``box.info.replication`` to check a replica set status.
    For ``instance002``, ``upstream.status`` and ``downstream.status`` should be ``follow``.

    .. code-block:: console

        master_master:instance001> box.info.replication
        ---
        - 1:
            id: 1
            uuid: 4cfa6e3c-625e-b027-00a7-29b2f2182f23
            lsn: 7
            upstream:
              status: follow
              idle: 0.21281599999929
              peer: replicator@127.0.0.1:3302
              lag: 0.00031614303588867
            name: instance002
            downstream:
              status: follow
              idle: 0.21800899999653
              vclock: {1: 7}
              lag: 0
          2:
            id: 2
            uuid: 9bb111c2-3ff5-36a7-00f4-2b9a573ea660
            lsn: 0
            name: instance001
        ...




.. _replication-master-master-add-data:

Adding data
~~~~~~~~~~~

To check that both instances get updates from each other, follow the steps below:

1.  On ``instance001``, create a space and format it as described in :ref:`CRUD operation examples <box_space_examples>`. Add sample data to this space.

2.  On ``instance002``, use the ``select`` operation to make sure data is replicated.

3.  Add more data to the created space on ``instance002``.

4.  Get back to ``instance001`` and use ``select`` to make sure new data is replicated.

5.  Check that :ref:`box.info.vclock <box_introspection-box_info>` values are the same on both instances:

    -   ``instance001``:

        .. code-block:: console

            master_master:instance001> box.info.vclock
            ---
            - {2: 8, 1: 12}
            ...

    -   ``instance002``:

        .. code-block:: console

            master_master:instance002> box.info.vclock
            ---
            - {2: 8, 1: 12}
            ...





.. _repl_supervised_failover:

Supervised failover
===================

..  admonition:: Enterprise Edition
    :class: fact

    Supervised failover is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

**Example on GitHub**: `supervised_failover <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/supervised_failover>`_

Tarantool provides the ability to control leadership in a replica set using an external failover coordinator.
A failover coordinator reads a cluster configuration from a file or an :ref:`etcd-based configuration storage <configuration_etcd>`, polls instances for their statuses, and appoints a leader for each replica set depending on availability and health or instances.
To increase fault tolerance, you can run two or more failover coordinators and store their state in etcd.


.. _supervised_failover_overview:

Overview
--------

The main steps of using an external failover coordinator for a newly configured cluster might look as follows:

1.  :ref:`Configure a cluster <supervised_failover_configuration>` to work with an external coordinator.
    The main step is setting the ``replication.failover`` option to ``supervised`` for all replica sets that should be managed by the external coordinator.

2.  Start a configured cluster.
    When an external coordinator is still not running, instances in a replica set start in the following modes:

    -   If a replica set is already :ref:`bootstrapped <replication_stages>`, all instances are started in read-only mode.
    -   If a replica set is not bootstrapped, one instance is started in read-write mode.

3.  :ref:`Start a failover coordinator <supervised_failover_start_coordinator>`.
    You can start two or more failover coordinators to increase :ref:`fault tolerance <supervised_failover_overview_fault_tolerance>`.
    In this case, one coordinator is active and others are passive.

When a cluster and failover coordinators are up and running, a failover coordinator :ref:`appoints one instance to be a master <supervised_failover_overview_appoint_master>` if there is no master instance in a replica set.
Then, the following events may occur:

-   If a master instance fails, a failover coordinator performs an :ref:`automated failover <supervised_failover_overview_perform_failover>`.
-   If an active failover coordinator fails, another coordinator becomes active and performs read-write appointments.


.. _supervised_failover_overview_appoint_master:

Appointing a master instance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A failover coordinator uses so-called appointments to switch an instance to read-write mode.
For each appointment, there is a read-write deadline, which is renewed periodically to prevent split-brain.

A failover coordinator appoints a master instance as follows:

-   If a replica set has no read-write instance, a failover coordinator appoints one to be a master instance.
-   If a replica set has one read-write instance and there is no previous appointment, a failover coordinator creates an appointment for this instance and sets a read-write deadline.
-   If a replica set has one read-write instance and there is a previous appointment, a failover coordinator waits for its deadline.

Note that a failover coordinator doesn't work with replica sets with two or more read-write instances.
In this case, a coordinator logs a warning to stdout and doesn't perform any appointments.

..  NOTE::

    :ref:`anonymous replicas <configuration_reference_replication_anon>` are not considered candidates to be master.


.. _supervised_failover_overview_perform_failover:

Performing a failover
~~~~~~~~~~~~~~~~~~~~~

A failover coordinator monitors the statuses of instances by sending requests to instances each ``probe_interval`` seconds.
While an appointment for a master instance exists and a read-write deadline has not expired, a failover coordinator does nothing.
If all attempts to renew the deadline are failed during some time interval, a leader switches to read-only mode.

..  NOTE::

    If a remote etcd-based storage is used to maintain the state of failover coordinators, you can also perform a :ref:`manual failover <supervised_failover_manual>`.




.. _supervised_failover_overview_fault_tolerance:

Active and passive coordinators
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To increase fault tolerance, you can :ref:`run <supervised_failover_start_coordinator>` two or more failover coordinators.
In this case, only one coordinator is active and used to control leadership in a replica set.
Other coordinators are passive.
Passive coordinators don't perform any read-write appointments and decline all the existing appointments.

To maintain the state of coordinators, Tarantool uses a stateboard -- a remote etcd-based storage.
This storage uses the same connection settings as a :ref:`centralized etcd-based configuration storage <configuration_etcd>`.
If a cluster configuration is stored in the ``<prefix>/config/*`` keys in etcd, a failover coordinator looks into ``<prefix>/failover/*`` for its state.
Here are a few examples of keys used for different purposes:

-   ``<prefix>/failover/info/by-uuid/<uuid>``: contains a state of a failover coordinator identified by the specified ``uuid``.
-   ``<prefix>/failover/active/lock``: a unique identifier (UUID) of an active failover coordinator.
-   ``<prefix>/failover/active/term``: a kind of fencing token allowing to have an order in which coordinators become active (took the lock) over time.
-   ``<prefix>/failover/command/<id>``: a key used to perform a :ref:`manual failover <supervised_failover_manual>`.



.. _supervised_failover_configuration:

Configuring a cluster
---------------------

To configure a cluster to work with an external failover coordinator, follow the steps below:

1.  (Optional) If you need to run :ref:`several failover coordinators <supervised_failover_overview_choose_coordinator>` to increase fault tolerance, set up an etcd-based configuration storage as described in :ref:`configuration_etcd`.

2.  Set the :ref:`replication.failover <configuration_reference_replication_failover>` option to ``supervised``:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/supervised_failover/source.yaml
        :language: yaml
        :start-at: replication:
        :end-at: failover: supervised
        :dedent:

3.  Grant a user used for replication :ref:`permissions <configuration_credentials_managing_users_roles_granting_privileges>` to execute the ``failover.execute`` function:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/supervised_failover/source.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: failover.execute
        :dedent:

4.  Create the ``failover.execute`` function in the application code.
    For example, you can create a :ref:`custom role <application_roles>` for this purpose:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/supervised_failover/supervised_instance.lua
        :language: lua
        :dedent:

    Then, you need to enable this role for all storage instances:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/supervised_failover/source.yaml
        :language: yaml
        :start-at: supervised_instance
        :end-before: groups:
        :dedent:

5.  (Optional) Configure options that control how a failover coordinator works in the ``failover`` section:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/supervised_failover/source.yaml
        :language: yaml
        :start-after: failover: supervised
        :end-before: supervised_instance
        :dedent:

You can find the full example in GitHub: `supervised_failover <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/supervised_failover>`_.


.. _supervised_failover_start_coordinator:

Starting a failover coordinator
-------------------------------

To start a failover coordinator, you need to execute the ``tarantool`` command with the :ref:`--failover <tarantool_cli_failover>` option.
This command accepts the path to a cluster configuration file:

..  code-block:: console

    tarantool --failover --config instances.enabled/supervised_failover/config.yaml

If a cluster's configuration is stored in etcd, ``config.yaml`` contains :ref:`connection options to an etcd storage <etcd_local_configuration>`.

You can run two or more failover coordinators to increase fault tolerance.
In this case, only one coordinator is active and used to control leadership in a replica set.
Learn more from :ref:`supervised_failover_overview_fault_tolerance`.


.. _supervised_failover_manual:

Performing manual failover
--------------------------

If an etcd-based storage is used to maintain the state of failover coordinators, you can perform a manual failover.
External tools can use the ``<prefix>/failover/command/<id>`` key to choose a new master.
For example, the tt utility provides the :ref:`tt cluster failover <tt-cluster-failover>` command for managing a supervised failover.

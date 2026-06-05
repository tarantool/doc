.. _box_ctl-make_bootstrap_leader:

box.ctl.make_bootstrap_leader()
===============================

.. function:: make_bootstrap_leader([opts])

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Make the instance a bootstrap leader of a replica set.

    To be able to make the instance a bootstrap leader manually, the effective bootstrap strategy should be ``supervised``.
    This is the case when ``box.cfg{bootstrap_strategy = 'supervised'}`` is used or when :ref:`replication.bootstrap_strategy <configuration_reference_replication_bootstrap_strategy>` in the YAML configuration is set to ``supervised`` or ``native``.
    With ``native``, the configuration logic normally calls ``box.ctl.make_bootstrap_leader()`` automatically.

    In this case, the instances do not choose a bootstrap leader automatically but wait for it to be appointed manually.
    Configuration fails if no bootstrap leader is appointed during a :ref:`replication.connect_timeout <configuration_reference_replication_connect_timeout>`.

    :param table opts: optional parameters. The following option is available:

                       -   ``graceful`` (boolean) -- if ``true``, request a graceful bootstrap.
                           If the local database is absent, the instance checks whether a bootstrap leader exists on connected peers and takes this role only if no bootstrap leader is found.
                           If the local database already exists, the call is a no-op.
                           The default value is ``false``.

    ..  NOTE::

        The ``graceful`` option is available since :doc:`3.4.0 </release/3.4.0>`.
        It doesn't protect an unbootstrapped replica set from two instances that simultaneously try to bootstrap it gracefully.

    ..  NOTE::

        When a new instance joins a replica set configured with the ``supervised`` or ``native`` bootstrap strategy,
        this instance doesn't choose the bootstrap leader automatically but joins to the instance on which
        ``box.ctl.make_bootstrap_leader()`` was executed last time.

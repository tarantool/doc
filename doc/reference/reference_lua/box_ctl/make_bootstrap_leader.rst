.. _box_ctl-make_bootstrap_leader:

box.ctl.make_bootstrap_leader()
===============================

.. function:: make_bootstrap_leader()

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Make the instance a bootstrap leader of a replica set.

    To be able to make the instance a bootstrap leader manually, the :ref:`replication.bootstrap_strategy <configuration_reference_replication_bootstrap_strategy>` configuration option should be set to ``supervised``.
    In this case, the instances do not choose a bootstrap leader automatically but wait for it to be appointed manually.
    Configuration fails if no bootstrap leader is appointed during a :ref:`replication.connect_timeout <configuration_reference_replication_connect_timeout>`.

    ..  NOTE::

        When a new instance joins a replica set configured with the ``supervised`` bootstrap strategy,
        this instance doesn't choose the bootstrap leader automatically but joins to the instance on which
        ``box.ctl.make_bootstrap_leader()`` was executed last time.

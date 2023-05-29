..  _admin-upgrades:

Upgrades
========

This section describes the general upgrade process for Tarantool. There are two
main upgrade scenarios for different use cases:

*   :doc:`Live upgrade <upgrades/upgrade_cluster>` (without downtime) for replication clusters.
*   :doc:`Upgrade with downtime <upgrades/upgrade_standalone>` for standalone instances.

If required, you can also to downgrade to an earlier version using a similar procedure.

For information about backwards compatibility,
see the :ref:`compatibility guarantees <compatibility_guarantees>` description.

There are also specifics that come up when upgrading from or to certain versions.
They are described in the dedicated pages inside this section.

..  toctree::
    :maxdepth: 1

    upgrades/upgrades_standalone
    upgrades/upgrades_cluster
    upgrades/1.6-1.10
    upgrades/1.6-2.0-downtime
    upgrades/2.10.1
    upgrades/2.10.4


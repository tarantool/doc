..  _admin-upgrades:

Upgrades
========

This section describes the general upgrade process for Tarantool. There are two
main upgrade scenarios for different use cases:

*   :doc:`Live upgrade <upgrades/upgrade_cluster>` (without downtime) for replication clusters.
*   :doc:`Upgrade with downtime <upgrades/upgrade_standalone>` for standalone instances.

You can also downgrade to an earlier version using a similar procedure.

For information about backwards compatibility,
see the :ref:`compatibility guarantees <compatibility_guarantees>` description.

Upgrading from or to certain versions can involve specific steps or slightly differ
from the general upgrade procedure. Such version-specific cases are described on
the dedicated pages inside this section.

This section includes the following topics:

..  toctree::
    :maxdepth: 1

    upgrades/upgrade_standalone
    upgrades/upgrade_cluster
    upgrades/1.6-1.10
    upgrades/1.6-2.0-downtime
    upgrades/2.10.1
    upgrades/2.10.4
    upgrades/2.11.0


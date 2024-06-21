:noindex:
:fullwidth:

..  _replication:

Replication
===========

Replication allows multiple Tarantool instances to work on copies of the same
databases. The databases are kept in sync because each instance can communicate
its changes to all the other instances.

This section includes the following topics:

..  toctree::
    :maxdepth: 2
    :numbered: 0

    repl_architecture
    repl_sync
    repl_leader_elect
    supervised_failover

For practical guides to replication, see :ref:`Replication tutorials <how-to-replication>`.
You can learn about bootstrapping a replica set, adding instances to the replica set, or removing them.

:noindex:
:fullwidth:

..  _replication:

Replication
===========

Replication allows multiple Tarantool instances to work on copies of the same
databases. The databases are kept in sync because each instance can communicate
its changes to all the other instances.

This chapter includes the following sections:

..  toctree::
    :maxdepth: 2
    :numbered: 0

    repl_architecture
    repl_sync
    repl_leader_elect

For practical guides to replication, see the :ref:`How-to section <how-to-replication>`.
You can learn about :ref:`bootstrapping a replica set <replication-bootstrap>`,
:ref:`adding instances <replication-add_instances>` to the replica set
or :ref:`removing them <replication-remove_instances>`,
:ref:`using synchronous replication <how-to-repl_sync>`
and :ref:`managing leader elections <how-to-repl_leader_elect>`.

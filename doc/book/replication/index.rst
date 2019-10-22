.. _replication:

********************************************************************************
Replication
********************************************************************************

Replication allows multiple Tarantool instances to work on copies of the same
databases. The databases are kept in sync because each instance can communicate
its changes to all the other instances.

This chapter includes the following sections:

.. toctree::
   :maxdepth: 2
   :numbered: 0

   repl_architecture
   repl_bootstrap
   repl_add_instances
   repl_remove_instances
   repl_monitoring
   repl_recover
   repl_reseed
   repl_duplicates

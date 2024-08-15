.. _box_introspection-box_info:

-------------------------------------------------------------------------------
Submodule box.info
-------------------------------------------------------------------------------

.. module:: box.info

The ``box.info`` submodule provides access to information about a running Tarantool instance.
Below is a list of all ``box.info`` functions and members.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 30 70
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_info/info`
           - Get all keys and values provided by the ``box.info`` submodule

        *  - :doc:`./box_info/cluster`
           - Information about the cluster to which the current instance belongs

        *  - :doc:`./box_info/config`
           - The instance's state in regard to configuration

        *  - :doc:`./box_info/election`
           - The current state of this replica set node in regard to leader election

        *  - :doc:`./box_info/gc`
           - Get information about the Tarantool garbage collector

        *  - :doc:`./box_info/hostname`
           - The hostname that identifies a machine the current instance is running on

        *  - :doc:`./box_info/id`
           - A numeric identifier of the current instance within the replica set

        *  - :doc:`./box_info/listen`
           - A real address to which an instance is bound

        *  - :doc:`./box_info/lsn`
           - A log sequence number (LSN) for the latest entry in the instance's write-ahead log (WAL)

        *  - :doc:`./box_info/memory`
           - Get information about memory usage for the current instance

        *  - :doc:`./box_info/name`
           - The name of the current instance

        *  - :doc:`./box_info/package`
           - The package name

        *  - :doc:`./box_info/pid`
           - Get a process ID of the current instance

        *  - :doc:`./box_info/replicaset`
           - Information about the replica set to which the current instance belongs

        *  - :doc:`./box_info/replication`
           - Statistics for all instances in the replica set

        *  - :doc:`./box_info/replication_anon`
           - List all the anonymous replicas following the instance

        *  - :doc:`./box_info/ro`
           - The current mode of the instance (writable or read-only)

        *  - :doc:`./box_info/ro_reason`
           - The reason why the current instance is read-only

        *  - :doc:`./box_info/schema_version`
           - The database schema version

        *  - :doc:`./box_info/signature`
           - The sum of all ``lsn`` values from each vector clock for all instances in the replica set

        *  - :doc:`./box_info/sql`
           - Get information about the cache for all SQL prepared statements

        *  - :doc:`./box_info/status`
           - The current state of the instance

        *  - :doc:`./box_info/synchro`
           - The current state of synchronous replication

        *  - :doc:`./box_info/uptime`
           - The number of seconds since the instance started

        *  - :doc:`./box_info/uuid`
           - A globally unique identifier of the current instance

        *  - :doc:`./box_info/vclock`
           - A table with the vclock values of all instances in a replica set which have made data changes

        *  - :doc:`./box_info/version`
           - The Tarantool version

        *  - :doc:`./box_info/vinyl`
           - (Deprecated) Get runtime statistics for the vinyl storage engine


..  toctree::
    :hidden:

    box_info/info
    box_info/cluster
    box_info/config
    box_info/election
    box_info/gc
    box_info/hostname
    box_info/id
    box_info/listen
    box_info/lsn
    box_info/memory
    box_info/name
    box_info/package
    box_info/pid
    box_info/replicaset
    box_info/replication
    box_info/replication_anon
    box_info/ro
    box_info/ro_reason
    box_info/schema_version
    box_info/signature
    box_info/sql
    box_info/status
    box_info/synchro
    box_info/uptime
    box_info/uuid
    box_info/vclock
    box_info/version
    box_info/vinyl

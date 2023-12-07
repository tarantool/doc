.. _replication-reseed:

================================================================================
Reseeding a replica
================================================================================

If any of a replica's write-ahead log or snapshot files are corrupted or deleted, you can "re-seed" the replica.
This procedure works only if the master's write-ahead logs are present.

1.  Stop the replica using the :ref:`tt stop <tt-stop>` command.

2.  Delete write-ahead logs and snapshots stored in the ``var/lib/<instance_name>`` directory.

    .. NOTE::

        ``var/lib`` is the default directory used by tt to store write-ahead logs and snapshots.
        Learn more from :ref:`Configuration <tt-config>`.

3.  Start the replica using the :ref:`tt start <tt-start>` command.
    The replica should catch up with the master by retrieving all the master's tuples.

4.  (Optional) If you're reseeding a replica after a replication conflict, you also need to :ref:`restart replication <replication-master-master-resolve-conflict>`.

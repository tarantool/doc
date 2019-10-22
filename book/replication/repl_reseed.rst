.. _replication-reseed:

================================================================================
Reseeding a replica
================================================================================

If any of a replica's .xlog/.snap/.run files are corrupted or deleted, you can
"re-seed" the replica:

1. Stop the replica and destroy all local database files (the ones with
   extensions .xlog/.snap/.run/.inprogress).

2. Delete the replica's record from the following locations:

   a. the ``replication`` parameter at all running instances in the replica set.
   b. the ``box.space._cluster`` tuple on the master instance.

   See section :ref:`Removing instances <replication-remove_instances>` for
   details.

3. Restart the replica with the same instance file to contact the master again.
   The replica will then catch up with the master by retrieving all the master’s
   tuples.

.. NOTE::

   Remember that this procedure works only if the master’s WAL files are
   present.

..  _concepts-data_model-persistence:
..  _index-box_persistence:

Persistence
===========

To ensure data persistence, Tarantool records updates to the database in the so-called
:ref:`write-ahead log (WAL) <internals-wal>` files.
When a power outage occurs or the Tarantool instance is killed incidentally,
the in-memory database is lost.
In such case, Tarantool restores the data from WAL files
by reading them and redoing the requests.
This is called the "recovery process".
You can change the timing of the WAL writer or turn it off by setting
the :ref:`wal.mode <configuration_reference_wal_mode>`.

Tarantool also maintains a set of :ref:`snapshot files <internals-snapshot>`.
These files contain an on-disk copy of the entire data set for a given moment.
Instead of reading every WAL file since the databases were created, the recovery
process can load the latest snapshot file and then read the WAL files,
produced after the snapshot file was made.
After creating a new snapshot, the earlier WAL files can be removed to free up space.

To force immediate creation of a snapshot file, use the
:doc:`box.snapshot() </reference/reference_lua/box_snapshot>` function.
To enable the automatic creation of snapshot files, use Tarantool's
:ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>`.
The checkpoint daemon sets intervals for forced snapshots. It makes sure that the states
of both memtx and vinyl storage engines are synchronized and saved to disk,
and automatically removes earlier WAL files.

Snapshot files can be created even if there is no WAL file.

..  NOTE::

     The memtx engine takes only regular snapshots with the interval set in
     the checkpoint daemon configuration.

     The vinyl engine runs checkpointing in the background at all times.

See the :ref:`Internals <internals-data_persistence>` section for more details
about the WAL writer and the recovery process.
To learn more about the configuration of the checkpoint daemon and WAL, check the :ref:`Persistence <configuration_persistence>` page.
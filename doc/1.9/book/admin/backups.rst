.. _admin-backups:

================================================================================
Backups
================================================================================

Tarantool storage architecture is append-only: files are only appended to, and
are never overwritten. Old files are removed by garbage collection after a
checkpoint. You can configure the amount of past checkpoints preserved by garbage
collection by configuring Tarantool's
:ref:`checkpoint daemon <book_cfg_checkpoint_daemon>`. Backups can be taken at any
time, with minimal overhead on database performance.

.. _admin-backups-hot_backup_memtx:

--------------------------------------------------------------------------------
Hot backup (memtx)
--------------------------------------------------------------------------------

This is a special case when there are only in-memory tables.

The last :ref:`snapshot file <index-box_persistence>` is a backup of the entire
database; and the :ref:`WAL <internals-wal>` files
that are made after the last snapshot are incremental backups. Therefore taking
a backup is a matter of copying the snapshot and WAL files.

1. Use ``tar`` to make a (possibly compressed) copy of the latest .snap and .xlog
   files on the :ref:`memtx_dir <cfg_basic-memtx_dir>` and
   :ref:`wal_dir <cfg_basic-wal_dir>` directories.

2. If there is a security policy, encrypt the .tar file.

3. Copy the .tar file to a safe place.

Later, restoring the database is a matter of taking the .tar file and putting
its contents back in the ``memtx_dir`` and ``wal_dir`` directories.

.. _admin-backups-hot_backup_vinyl_memtx:

--------------------------------------------------------------------------------
Hot backup (vinyl/memtx)
--------------------------------------------------------------------------------

Vinyl stores its files in :ref:`vinyl_dir <cfg_basic-vinyl_dir>`, and creates a
folder for each database space. Dump and compaction processes are append-only and
create new files. Old files are garbage collected after each checkpoint.

To take a mixed backup:

1. Issue ``box.backup.start()`` on the :ref:`administrative console <admin-security>`.
   This will suspend garbage collection till the next ``box.backup.stop()`` and
   will return a list of files to back up.

2. Copy the files from the list to a safe location. This will include memtx
   snapshot files, vinyl run and index files, at a state consistent with the
   last checkpoint.

3. Resume garbage collection with ``box.backup.stop()``.

.. _admin-backups-cont_remote_backup_memtx:

--------------------------------------------------------------------------------
Continuous remote backup (memtx)
--------------------------------------------------------------------------------

The :ref:`replication <replication>` feature is useful for backup as
well as for load balancing.

Therefore taking a backup is a matter of ensuring that any given replica is
up to date, and doing a cold backup on it. Since all the other replicas continue
to operate, this is not a cold backup from the end user’s point of view. This
could be done on a regular basis, with a ``cron`` job or with a Tarantool fiber.

.. _admin-backups-cont_backup_memtx:

--------------------------------------------------------------------------------
Continuous backup (memtx)
--------------------------------------------------------------------------------

The logged changes done since the last cold backup must be secured, while the
system is running.

For this purpose, you need a file copy utility that will do the copying
remotely and continuously, copying only the parts of a write ahead log file
that are changing.
One such utility is `rsync <https://en.wikipedia.org/wiki/Rsync>`_.

Alternatively, you need an ordinary file copy utility, but there should be
frequent production of new snapshot files or new WAL files as changes occur,
so that only the new files need to be copied.

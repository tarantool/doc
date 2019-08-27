.. _admin-backups:

================================================================================
Backups
================================================================================

Tarantool has an append-only storage architecture: it appends data to files but
it never overwrites earlier data. The
:ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`
removes old files after a
checkpoint. You can prevent or delay the garbage collector's action
by configuring the
:ref:`checkpoint daemon <book_cfg_checkpoint_daemon>`. Backups can be taken at
any time, with minimal overhead on database performance.

.. _admin-backups-backup_start:

--------------------------------------------------------------------------------
backup.start() and backup.stop()
--------------------------------------------------------------------------------

Two functions are helpful for backups in certain situations.

``box.backup.start()`` informs the server that activities related to the removal
of outdated backups must be suspended and returns a table with the names of
snapshot and vinyl files that should be copied. Example:

.. code-block:: tarantoolsession

    tarantool> box.backup.start()
    ---
    - - ./00000000000000000015.snap
      - ./00000000000000000000.vylog
      - ./513/0/00000000000000000002.index
      - ./513/0/00000000000000000002.run
    ...

.. NOTE::

    To guarantee an opportunity to copy this files Tarantool will not delete them.
    But there will be no read-only mode and checkpoints will continue by schedule
    as usual.

Later ``box.backup.stop()`` informs the server that
normal operations may resume. Starting with Tarantool 1.10.1 there is a new
optional argument, ``box.backup.start(n)``, where ``n`` indicates the checkpoint
to use relative to the latest checkpoint -- for example ``n = 0`` means
"backup will be based on the latest checkpoint", ``n = 1`` means "backup will
be based on the first checkpoint before the latest checkpoint
(counting backwards)", and so on,
and the default value for ``n`` is zero.

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
create new files. The Tarantool garbage collector may remove old files after each
checkpoint.

To take a mixed backup:

1. Issue :ref:`box.backup.start() <admin-backups-backup_start>` on the
   :ref:`administrative console <admin-security>`. This will suspend
   garbage collection till the next ``box.backup.stop()`` and
   will return a list of files to back up.

2. Copy the files from the list to a safe location. This will include memtx
   snapshot files, vinyl run and index files, at a state consistent with the
   last checkpoint.

3. Issue ``box.backup.stop()`` so the garbage collector can continue.

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

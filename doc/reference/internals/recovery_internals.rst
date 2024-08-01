.. _internals-recovery_process:

--------------------------------------------------------------------------------
The recovery process
--------------------------------------------------------------------------------

The recovery process begins when ``box.cfg{}`` happens for the
first time after the Tarantool server instance starts.

The recovery process must recover the databases
as of the moment when the instance was last shut down. For this it may
use the latest snapshot file and any WAL files that were written
after the snapshot. One complicating factor is that Tarantool
has two engines -- the memtx data must be reconstructed entirely
from the snapshot and the WAL files, while the vinyl data will
be on disk but might require updating around the time of a checkpoint.
(When a snapshot happens, Tarantool tells the vinyl engine to
make a checkpoint, and the snapshot operation is rolled back if
anything goes wrong, so vinyl's checkpoint is at least as fresh
as the snapshot file.)

**Step 1**

Read the configuration parameters in the ``box.cfg{}`` request.
Parameters which affect recovery may include :ref:`work_dir <cfg_basic-work_dir>`,
:ref:`wal_dir <cfg_basic-wal_dir>`, :ref:`memtx_dir <cfg_basic-memtx_dir>`,
:ref:`vinyl_dir <cfg_basic-vinyl_dir>`
and :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`.

**Step 2**

Find the latest snapshot file. Use its data to reconstruct the in-memory
databases. Instruct the vinyl engine to recover to the latest checkpoint.

There are actually two variations of the reconstruction procedure for memtx
databases, depending on whether the recovery process is "default".

If the recovery process is default (``force_recovery`` is ``false``),
memtx can read data in the snapshot with all indexes disabled.
First, all tuples are read into memory. Then, primary keys are built in bulk,
taking advantage of the fact that the data is already sorted by primary key
within each space.

If the recovery process is non-default (``force_recovery`` is ``true``),
Tarantool performs additional checking. Indexes are enabled at
the start, and tuples are added one by one. This means that any unique-key
constraint violations will be caught, and any duplicates will be skipped.
Normally there will be no constraint violations or duplicates, so these checks
are only made if an error has occurred.

**Step 3**

Find the WAL file that was made at the time of, or after, the snapshot file.
Read its log entries until the log-entry LSN is greater than the LSN of the
snapshot, or greater than the LSN of the vinyl checkpoint. This is the
recovery process's "start position"; it matches the current state of the
engines.

**Step 4**

Redo the log entries, from the start position to the end of the WAL. The
engine skips a redo instruction if it is older than the engine's checkpoint.

**Step 5**

For the memtx engine, re-create all secondary indexes.

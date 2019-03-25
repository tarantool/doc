.. _internals:

.. _internals-data_persistence:

.. _internals-wal:

--------------------------------------------------------------------------------
Data persistence and the WAL file format
--------------------------------------------------------------------------------

To maintain data persistence, Tarantool writes each data change request (insert,
update, delete, replace, upsert) into a write-ahead log (WAL) file in the
:ref:`wal_dir <cfg_basic-wal_dir>` directory. A new WAL file is created for every
:ref:`rows_per_wal <cfg_binary_logging_snapshots-rows_per_wal>` records, or for every
:ref:`wal_max_size <cfg_binary_logging_snapshots-wal_max_size>` bytes.
Each data change request gets assigned a continuously growing 64-bit log sequence
number. The name of the WAL file is based on the log sequence number of the first
record in the file, plus an extension ``.xlog``.

Apart from a log sequence number and the data change request (formatted as in
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>`),
each WAL record contains a header, some metadata, and then the data formatted
according to `msgpack <https://en.wikipedia.org/wiki/MessagePack>`_ rules.
For example, this is what the WAL file looks like after the first INSERT request
("s:insert({1})") for the sandbox database created in our
:ref:`"Getting started" exercises <getting_started>`.
On the left are the hexadecimal bytes that you would see with:

.. code-block:: console

   $ hexdump 00000000000000000000.xlog

and on the right are comments.

.. code-block:: none

   Hex dump of WAL file       Comment
   --------------------       -------
   58 4c 4f 47 0a             "XLOG\n"
   30 2e 31 33 0a             "0.13\n" = version
   53 65 72 76 65 72 3a 20    "Server: "
   38 62 66 32 32 33 65 30 2d [Server UUID]\n
   36 39 31 34 2d 34 62 35 35
   2d 39 34 64 32 2d 64 32 62
   36 64 30 39 62 30 31 39 36
   0a
   56 43 6c 6f 63 6b 3a 20    "Vclock: "
   7b 7d                      "{}" = vclock value, initially blank
   ...                        (not shown = tuples for system spaces)
   d5 ba 0b ab                Magic row marker always = 0xab0bbad5
   19                         Length, not including length of header, = 25 bytes
   00                           Record header: previous crc32
   ce 8c 3e d6 70               Record header: current crc32
   a7 cc 73 7f 00 00 66 39      Record header: padding
   84                         msgpack code meaning "Map of 4 elements" follows
   00 02                         element#1: tag=request type, value=0x02=IPROTO_INSERT
   02 01                         element#2: tag=server id, value=0x01
   03 04                         element#3: tag=lsn, value=0x04
   04 cb 41 d4 e2 2f 62 fd d5 d4 element#4: tag=timestamp, value=an 8-byte "Float64"
   82                         msgpack code meaning "map of 2 elements" follows
   10 cd 02 00                   element#1: tag=space id, value=512, big byte first
   21 91 01                      element#2: tag=tuple, value=1-element fixed array={1}

A tool for reading .xlog files is Tarantool's :ref:`xlog module <xlog>`.

Tarantool processes requests atomically: a change is either accepted and recorded
in the WAL, or discarded completely. Let's clarify how this happens, using the
REPLACE request as an example:

1. The server instance attempts to locate the original tuple by primary key. If found, a
   reference to the tuple is retained for later use.

2. The new tuple is validated. If for example it does not contain an indexed
   field, or it has an indexed field whose type does not match the type
   according to the index definition, the change is aborted.

3. The new tuple replaces the old tuple in all existing indexes.

4. A message is sent to the writer process running in the WAL thread, requesting that
   the change be recorded in the WAL. The instance switches to work on the next
   request until the write is acknowledged.

5. On success, a confirmation is sent to the client. On failure, a rollback
   procedure is begun. During the rollback procedure, the transaction processor
   rolls back all changes to the database which occurred after the first failed
   change, from latest to oldest, up to the first failed change. All rolled back
   requests are aborted with :errcode:`ER_WAL_IO <ER_WAL_IO>` error. No new
   change is applied while rollback is in progress. When the rollback procedure
   is finished, the server restarts the processing pipeline.

One advantage of the described algorithm is that complete request pipelining is
achieved, even for requests on the same value of the primary key. As a result,
database performance doesn't degrade even if all requests refer to the same
key in the same space.

The transaction processor thread communicates with the WAL writer thread using
asynchronous (yet reliable) messaging; the transaction processor thread, not
being blocked on WAL tasks, continues to handle requests quickly even at high
volumes of disk I/O. A response to a request is sent as soon as it is ready,
even if there were earlier incomplete requests on the same connection. In
particular, SELECT performance, even for SELECTs running on a connection packed
with UPDATEs and DELETEs, remains unaffected by disk load.

The WAL writer employs a number of durability modes, as defined in configuration
variable :ref:`wal_mode <index-wal_mode>`. It is possible to turn the write-ahead
log completely off, by setting
:ref:`wal_mode <cfg_binary_logging_snapshots-wal_mode>` to *none*. Even
without the write-ahead log it's still possible to take a persistent copy of the
entire data set with the :ref:`box.snapshot() <box-snapshot>` request.

An .xlog file always contains changes based on the primary key.
Even if the client requested an update or delete using
a secondary key, the record in the .xlog file will contain the primary key.

.. _internals-snapshot:

--------------------------------------------------------------------------------
The snapshot file format
--------------------------------------------------------------------------------

The format of a snapshot .snap file is nearly the same as the format of a WAL .xlog file.
However, the snapshot header differs: it contains the instance's global unique identifier
and the snapshot file's position in history, relative to earlier snapshot files.
Also, the content differs: an .xlog file may contain records for any data-change
requests (inserts, updates, upserts, and deletes), a .snap file may only contain records
of inserts to memtx spaces.

Primarily, the .snap file's records are ordered by space id. Therefore the records of
system spaces -- such as ``_schema``, ``_space``, ``_index``, ``_func``, ``_priv``
and ``_cluster`` -- will be at the start of the .snap file, before the records of
any spaces that were created by users.

Secondarily, the .snap file's records are ordered by primary key within space id.

.. _internals-recovery_process:

--------------------------------------------------------------------------------
The recovery process
--------------------------------------------------------------------------------

The recovery process begins when box.cfg{} happens for the
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

Step 1
    Read the configuration parameters in the ``box.cfg{}`` request.
    Parameters which affect recovery may include :ref:`work_dir <cfg_basic-work_dir>`,
    :ref:`wal_dir <cfg_basic-wal_dir>`, :ref:`memtx_dir <cfg_basic-memtx_dir>`,
    :ref:`vinyl_dir <cfg_basic-vinyl_dir>`
    and :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`.

Step 2
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

Step 3
    Find the WAL file that was made at the time of, or after, the snapshot file.
    Read its log entries until the log-entry LSN is greater than the LSN of the
    snapshot, or greater than the LSN of the vinyl checkpoint. This is the
    recovery process's "start position"; it matches the current state of the
    engines.

Step 4
    Redo the log entries, from the start position to the end of the WAL. The
    engine skips a redo instruction if it is older than the engine's checkpoint.

Step 5
    For the memtx engine, re-create all secondary indexes.


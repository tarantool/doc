..  _internals-data_persistence:

File formats
============

.. _internals-wal:

The WAL file format
-------------------

To maintain :ref:`data persistence <concepts-data_model-persistence>`, Tarantool writes each data change request (insert,
update, delete, replace, upsert) to a write-ahead log (WAL) file in the
:ref:`wal.dir <configuration_reference_wal_dir>` directory.
Each data change request is assigned a continuously growing 64-bit log sequence
number. The name of the WAL file is based on the log sequence number of the first
record in the file, plus an extension ``.xlog``.
A new WAL file is created
when the current one reaches the :ref:`wal_max_size <cfg_binary_logging_snapshots-wal_max_size>` size.

Each WAL record contains:

*   a log sequence number
*   a data change request (formatted as in :ref:`Tarantool's binary protocol <internals-box_protocol>`)

*   a header
*   some metadata
*   the data formatted according to `msgpack <https://en.wikipedia.org/wiki/MessagePack>`_ rules.

To see the hexadecimal bytes of the given WAL file, use the ``hexdump`` command:

..  code-block:: console

    $ hexdump 00000000000000000000.xlog

For example, the WAL file after the first INSERT request might look the following way:

..  code-block:: none

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

Tarantool processes requests atomically: a change is either accepted and recorded
in the WAL, or discarded completely. To clarify how this happens, see the example with the REPLACE request below:

#. The server instance attempts to locate the original tuple by primary key. If found, a
   reference to the tuple is retained for later use.

#. The new tuple is validated. If for example it does not contain an indexed
   field, or it has an indexed field whose type does not match the type
   according to the index definition, the change is aborted.

#. The new tuple replaces the old tuple in all existing indexes.

#. A message is sent to the WAL writer running in a separate thread, requesting that
   the change be recorded in the WAL. The instance switches to work on the next
   request until the write is acknowledged.

#. On success, a confirmation is sent to the client. On failure, a rollback
   procedure begins. During the rollback procedure, the transaction processor
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
asynchronous (yet reliable) messaging.
The transaction processor thread, not being blocked on WAL tasks, continues to handle requests quickly even at high
volumes of disk I/O. A response to a request is sent as soon as it is ready,
even if there were earlier incomplete requests on the same connection. In
particular, SELECT performance, even for SELECTs running on a connection packed
with UPDATEs and DELETEs, remains unaffected by disk load.

The WAL writer employs a number of durability modes, as defined in configuration
variable :ref:`wal.mode <configuration_reference_wal_mode>`.
It is possible to turn the write-ahead log completely off, by setting the ``wal_mode`` option to *none*.
Even without the write-ahead log it's still possible to take a persistent copy of the
entire data set with the :ref:`box.snapshot() <box-snapshot>` request.

An ``.xlog`` file always contains changes based on the primary key.
Even if the client requested an update or delete using
a secondary key, the record in the .xlog file contains the primary key.

..  _internals-snapshot:

The snapshot file format
------------------------

The format of a snapshot (``.snap``) file is the following:

*   The snapshot header contains the instance's global unique identifier
    and the snapshot file's position in history, relative to earlier snapshot files.

*   The snapshot content contains the records of inserts to memtx spaces.
    That differs from the content of an ``.xlog`` file that may contain records for any data-change requests
    (inserts, updates, upserts, and deletes).

Primarily, the records in the snapshot file have the following order:

*   System spaces (id >= 256 && id <= 511), ordered by ID.
*   Non-system spaces, ordered by ID.

Secondarily, the .snap file's records are ordered by primary key within space ID.

..  _box_protocol-xlog:

Example
-------

The header of a ``.snap`` or ``.xlog`` file might look in the following way:

..  code-block:: none

    <type>\n                  SNAP\n or XLOG\n
    <version>\n               currently 0.13\n
    Server: <server_uuid>\n   where UUID is a 36-byte string
    VClock: <vclock_map>\n    e.g. {1: 0}\n
    \n

After the file header come the data tuples.
Tuples begin with a row marker ``0xd5ba0bab`` and
the last tuple may be followed by an EOF marker
``0xd510aded``.
Thus, between the file header and the EOF marker, there
may be data tuples that have this form:

..  code-block:: none

    0            3 4                                         17
    +-------------+========+============+===========+=========+
    |             |        |            |           |         |
    | 0xd5ba0bab  | LENGTH | CRC32 PREV | CRC32 CUR | PADDING |
    |             |        |            |           |         |
    +-------------+========+============+===========+=========+
       MP_FIXEXT2    MP_INT     MP_INT       MP_INT      ---

    +============+ +===================================+
    |            | |                                   |
    |   HEADER   | |                BODY               |
    |            | |                                   |
    +============+ +===================================+
         MP_MAP                     MP_MAP


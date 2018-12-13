.. _box_introspection-box_stat:

--------------------------------------------------------------------------------
Submodule `box.stat`
--------------------------------------------------------------------------------

The ``box.stat`` submodule provides access to request and network statistics.

Use ``box.stat()`` to show the average number of requests per second,
and the total number of requests since startup, broken down by request type.

Use ``box.stat.net()``  to see network activity: the number of packets sent
and received, and the average number of requests per second.

.. _box_introspection-box_stat_vinyl:

Use ``box.stat.vinyl()`` to see vinyl-storage-engine activity, for example
``box.stat.vinyl().tx`` has the number of commits and rollbacks.
Details are at :ref:`the end of this section <box_introspection-box_stat_vinyl_details>`.

.. _box_introspection-box_stat_reset:

Use ``box.stat.reset()`` to reset the statistics of ``box.stat()``,
``box.stat.net()``, ``box.stat.vinyl()`` and
:ref:`box.space.index <box_space-space_index>`.

.. code-block:: tarantoolsession

    tarantool> box.stat()
    ---
    - DELETE:
        total: 1873949
        rps: 123
      SELECT:
        total: 1237723
        rps: 4099
      INSERT:
        total: 0
        rps: 0
      EVAL:
        total: 0
        rps: 0
      CALL:
        total: 0
        rps: 0
      REPLACE:
        total: 1239123
        rps: 7849
      UPSERT:
        total: 0
        rps: 0
      AUTH:
        total: 0
        rps: 0
      ERROR:
        total: 0
        rps: 0
      UPDATE:
        total: 0
        rps: 0
    ...
    tarantool> box.stat().DELETE -- a selected item of the table
    ---
    - total: 0
      rps: 0
    ...
    tarantool> box.stat.net()
    ---
    - SENT:
        total: 0
        rps: 0
      RECEIVED:
        total: 0
        rps: 0
    ...
    tarantool> box.stat.vinyl().tx.commit -- a selected item of the table
    ---
    - 1047632
    ...

.. _box_introspection-box_stat_vinyl_details:

Here are details about the ``box.stat.vinyl()`` items.

.. _box_introspection-box_stat_vinyl_regulator:

Re ``box.stat.vinyl().regulator``:
The vinyl regulator decides when to take or delay actions for
disk IO, grouping activity in batches so that it is
consistent and efficient. The regulator is invoked by
the vinyl scheduler, once per second, and updates
related variables whenever it is invoked.
``box.stat.vinyl().regulator.dump_bandwidth`` is
the estimated average rate at which dumps are done.
Initially this will appear as 10485760 (10 megabytes per second).
Only significant dumps (larger than one megabyte) are used for estimating.
``box.stat.vinyl().regulator.dump_watermark``
is the point when dumping must occur.
The value is slightly smaller than the amount of memory
that is allocated for vinyl trees, which is the
:ref:`vinyl_memory <cfg_storage-vinyl_memory>` parameter.
``box.stat.vinyl().regulator.write_rate``
is the actual average rate at which recent writes to disk are done.
Averaging is done over a 5-second time window, so if there has
been no activity for 5 seconds then regulator.write_rate = 0.
The write_rate may be slowed when a dump is in progress
or when the user has set
:ref:`snap_io_rate_limit <cfg_binary_logging_snapshots-snap_io_rate_limit>`.

Re ``box.stat.vinyl().disk``:
Since vinyl is an on-disk storage engine
(unlike memtx which is an in-memory storage engine),
it can handle large databases -- but if a database is
larger than the amount of memory that is allocated for vinyl,
then there will be more disk activity.
``box.stat.vinyl().disk.dump`` has
the amount of data from recent changes that has been dumped, and the count of dumps.
A "dump" is explained in section :ref:`Storing data with vinyl <engines-algorithm_filling_lsm>`:
"Sooner or later the number of elements in an LSM tree exceeds the L0 size and that’s
when L0 gets written to a file on disk (called a 'run') and then cleared for storing new elements.
This operation is called a 'dump'."
Thus it can be predicted that a dump will occur if the
size of L0
(which is :ref:`memory.level0 <box_introspection-box_stat_vinyl_memory>`)
is approaching the
maximum
(which is :ref:`regulator.dump_watermark <box_introspection-box_stat_vinyl_regulator>`)
and a
dump is not already in progress. In fact Tarantool will
try to arrange a dump before this hard limit is reached.
A dump will also occur during a  :ref:`snapshot <box-snapshot>` operation.
``box.stat.vinyl().disk.compact``
is the amount of data from recent changes that has been
:ref:`compacted <box_index-compact>`.
This is divided into disk.compact.in (the amount that is being
compacted), disk.compact.queue (the amount tht is waiting to be
compacted), and disk.compact.out (the amount that has been compacted,
which is presumably smaller than disk.compact.in).
``box.stat.vinyl().disk.data`` and ``box.stat.vinyl().disk.index``
are the amount of data that has gone into files in a subdirectory
of :ref:`vinyl_dir <cfg_basic-vinyl_dir>`,
with names like :samp:`{lsn}.run`
and :samp:`{lsn}.index`. The size of the run will be
related to the output of disk.dump.

.. _box_introspection-box_stat_vinyl_memory:

Re ``box.stat.vinyl().memory``:
Although the vinyl storage engine is not "in-memory", Tarantool does
need to have memory for write buffers and for caches.
``box.stat.vinyl().memory.tuple_cache``
is the number of bytes that are being used for tuples (data).
``box.stat.vinyl().memory.tx``
is transactional memory. This will usually be 0.
``box.stat.vinyl().memory.level0``
is the "level0" memory area, sometimes abbreviated "L0", which is the
area that vinyl can use for in-memory storage of an LSM tree.
Therefore we can say that "L0 is becoming full" when the
amount in memory.level0 is close to the maximum, which is
:ref:`regulator.dump_watermark <box_introspection-box_stat_vinyl_regulator>`.
We can expect that "L0 = 0" immediately after a dump.
``box.stat.vinyl().memory.page_index`` and  ``box.stat.vinyl().memory.bloom_filter``
have the current amount being used for index-related structures.
The size is a function of the number and size of keys,
plus :ref:`page_size <cfg_storage-vinyl_page_size>`,
plus :ref:`bloom_fpr <cfg_storage-vinyl_bloom_fpr>`.
This is not a count of bloom filter "hits"
(the number of reads that could be avoided because the
bloom filter predicts their presence in a run file) --
that statistic can be found with
:ref:`index_object:stat() <box_index-stat>`.

.. _box_introspection-box_stat_vinyl_tx:

Re ``box.stat.vinyl().tx``:
This is about requests that affect transactional activity
("tx" is used here as an abbreviation for "transaction").
``box.stat.vinyl().tx.conflict``
counts conflicts that caused a transaction to roll back.
``box.stat.vinyl().tx.commit``
is the count of commits (successful transaction ends).
It includes implicit commits, for example any insert causes a commit unless it is within a begin-end block.
``box.stat.vinyl().tx.rollback``
is the count of rollbacks (unsuccessful transaction ends).
This is not merely a count of explicit
:ref:`box.rollback <box-rollback>` requests --
it includes requests that ended in errors.
For example, after an attempted insert request that causes
a "Duplicate key exists in unique index" error, tx.rollback
is incremented.
``box.stat.vinyl().tx.statements``
will usually be 0.
``box.stat.vinyl().tx.transactions``
is the number of transactions that are currently running.
``box.stat.vinyl().tx.gap_locks``
is the number of gap locks that are outstanding during execution of a request.
For a low-level description of Tarantool's implementation of gap locking, see
`Gap locks in Vinyl transaction manager <https://github.com/tarantool/tarantool/issues/2671>`_.
``box.stat.vinyl().tx.read_views``
shows whether a transaction has entered a read-only state
to avoid conflict temporarily. This will usually be 0.

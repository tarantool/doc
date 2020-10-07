.. _box_introspection-box_stat:

--------------------------------------------------------------------------------
Submodule `box.stat`
--------------------------------------------------------------------------------

The ``box.stat`` submodule provides access to request and network statistics.

Use ``box.stat()`` to show the average number of requests per second,
and the total number of requests since startup, broken down by request type.

Use ``box.stat.net()`` to see network activity: the number of bytes sent
and received, the number of connections, and the number of active requests
(current, average, and total).

.. _box_introspection-box_stat_vinyl:

Use ``box.stat.vinyl()`` to see vinyl-storage-engine activity, for example
``box.stat.vinyl().tx`` has the number of commits and rollbacks.
See details at :ref:`the end of this section <box_introspection-box_stat_vinyl_details>`.

.. _box_introspection-box_stat_reset:

Use ``box.stat.reset()`` to reset the statistics of ``box.stat()``,
``box.stat.net()``, ``box.stat.vinyl()`` and
:ref:`box.space.index <box_space-space_index>`.

In the tables that ``box.stat()`` returns:

* ``total`` stands for "total number of requests processed per second since
  the server started",
* ``rps`` stands for "average number of requests per second in the last 5 seconds".

"ERROR" is the count of requests that resulted in an error.

In the tables that ``box.stat.net()`` returns:

* ``SENT.rps`` and ``RECEIVED.rps`` -- average number of bytes sent/received per
  second in the last 5 seconds
* ``SENT.total`` and ``RECEIVED.total`` -- total number of bytes sent/received
  since the server started
* ``CONNECTIONS.rps`` -- number of connections opened per second in the last 5 seconds
* ``CONNECTIONS.total`` -- total number of connections opened since the server started
* ``REQUESTS.current`` -- number of requests in progress, which can be
  limited by :ref:`box.cfg.net_msg_max <cfg_networking-net_msg_max>`
* ``REQUESTS.rps`` -- number of requests processed per second in the last 5 seconds
* ``REQUESTS.total`` -- total number of requests processed since startup

.. code-block:: tarantoolsession

    tarantool> box.stat() -- return 10 tables
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
    tarantool> box.stat().DELETE -- total + requests per second from one table
    ---
    - total: 0
      rps: 0
    ...
    tarantool> box.stat.net() -- 4 tables
    ---
    - SENT:
        total: 0
        rps: 0
      CONNECTIONS:
        current: 0
        rps: 0
        total: 0
      REQUESTS:
        current: 0
        rps: 0
        total: 0
      RECEIVED:
        total: 0
        rps: 0
    ...
    tarantool> box.stat.vinyl().tx.commit -- one item of the vinyl table
    ---
    - 1047632
    ...

.. _box_introspection-box_stat_vinyl_details:

Here are details about the ``box.stat.vinyl()`` items.

.. _box_introspection-box_stat_vinyl_regulator:

**Details about box.stat.vinyl().regulator:**
The vinyl regulator decides when to take or delay actions for
disk IO, grouping activity in batches so that it is
consistent and efficient. The regulator is invoked by
the vinyl scheduler, once per second, and updates
related variables whenever it is invoked.

* ``box.stat.vinyl().regulator.dump_bandwidth`` is
  the estimated average rate at which dumps are done.
  Initially this will appear as 10485760 (10 megabytes per second).
  Only significant dumps (larger than one megabyte) are used for estimating.

* ``box.stat.vinyl().regulator.dump_watermark``
  is the point when dumping must occur.
  The value is slightly smaller than the amount of memory
  that is allocated for vinyl trees, which is the
  :ref:`vinyl_memory <cfg_storage-vinyl_memory>` parameter.

* ``box.stat.vinyl().regulator.write_rate``
  is the actual average rate at which recent writes to disk are done.
  Averaging is done over a 5-second time window, so if there has
  been no activity for 5 seconds then ``regulator.write_rate = 0``.
  The ``write_rate`` may be slowed when a dump is in progress
  or when the user has set
  :ref:`snap_io_rate_limit <cfg_binary_logging_snapshots-snap_io_rate_limit>`.

* ``box.stat.vinyl().regulator.rate_limit`` is the write rate limit,
  in bytes per second, imposed on transactions by
  the regulator based on the observed dump/compaction performance.

.. _box_introspection-box_stat_vinyl_disk:

**Details about box.stat.vinyl().disk:**
Since vinyl is an on-disk storage engine
(unlike memtx which is an in-memory storage engine),
it can handle large databases -- but if a database is
larger than the amount of memory that is allocated for vinyl,
then there will be more disk activity.

* ``box.stat.vinyl().disk.data`` and ``box.stat.vinyl().disk.index``
  are the amount of data that has gone into files in a subdirectory
  of :ref:`vinyl_dir <cfg_basic-vinyl_dir>`,
  with names like ``{lsn}.run``
  and ``{lsn}.index``. The size of the run will be
  related to the output of ``scheduler.dump_*``.

* ``box.stat.vinyl().disk.data_compacted``
  Sum size of data stored at the last LSM tree level, in bytes,
  without taking disk compression into account. It can be thought of as the
  size of disk space that the user data would occupy if there were no compression,
  indexing, or space increase caused by the LSM tree design.

.. _box_introspection-box_stat_vinyl_memory:

**Details about box.stat.vinyl().memory:**
Although the vinyl storage engine is not "in-memory", Tarantool does
need to have memory for write buffers and for caches:

* ``box.stat.vinyl().memory.tuple_cache``
  is the number of bytes that are being used for tuples (data).
* ``box.stat.vinyl().memory.tx``
  is transactional memory. This will usually be 0.
* ``box.stat.vinyl().memory.level0``
  is the "level0" memory area, sometimes abbreviated "L0", which is the
  area that vinyl can use for in-memory storage of an LSM tree.

Therefore we can say that "L0 is becoming full" when the
amount in ``memory.level0`` is close to the maximum, which is
:ref:`regulator.dump_watermark <box_introspection-box_stat_vinyl_regulator>`.
We can expect that "L0 = 0" immediately after a dump.
``box.stat.vinyl().memory.page_index`` and  ``box.stat.vinyl().memory.bloom_filter``
have the current amount being used for index-related structures.
The size is a function of the number and size of keys,
plus :ref:`vinyl_page_size <cfg_storage-vinyl_page_size>`,
plus :ref:`vinyl_bloom_fpr <cfg_storage-vinyl_bloom_fpr>`.
This is not a count of bloom filter "hits"
(the number of reads that could be avoided because the
bloom filter predicts their presence in a run file) --
that statistic can be found with
:ref:`index_object:stat() <box_index-stat>`.

.. _box_introspection-box_stat_vinyl_tx:

**Details about box.stat.vinyl().tx:**
This is about requests that affect transactional activity
("tx" is used here as an abbreviation for "transaction"):

* ``box.stat.vinyl().tx.conflict``
  counts conflicts that caused a transaction to roll back.
* ``box.stat.vinyl().tx.commit``
  is the count of commits (successful transaction ends).
  It includes implicit commits, for example any insert causes a commit unless
  it is within a begin-end block.
* ``box.stat.vinyl().tx.rollback``
  is the count of rollbacks (unsuccessful transaction ends).
  This is not merely a count of explicit
  :ref:`box.rollback <box-rollback>` requests --
  it includes requests that ended in errors.
  For example, after an attempted insert request that causes
  a "Duplicate key exists in unique index" error, ``tx.rollback``
  is incremented.
* ``box.stat.vinyl().tx.statements``
  will usually be 0.
* ``box.stat.vinyl().tx.transactions``
  is the number of transactions that are currently running.
* ``box.stat.vinyl().tx.gap_locks``
  is the number of gap locks that are outstanding during execution of a request.
  For a low-level description of Tarantool's implementation of gap locking, see
  `Gap locks in Vinyl transaction manager <https://github.com/tarantool/tarantool/issues/2671>`_.
* ``box.stat.vinyl().tx.read_views``
  shows whether a transaction has entered a read-only state
  to avoid conflict temporarily. This will usually be 0.

**Details about box.stat.vinyl().scheduler:**
This primarily has counters related to tasks that the scheduler has arranged
for dumping or compaction:
(most of these items are reset to 0 when the server restarts or when
:ref:`box.stat.reset() <box_introspection-box_stat_reset>` occurs):

* ``box.stat.vinyl().scheduler.compaction_*``
  is the amount of data from recent changes that has been
  :ref:`compacted <box_index-compact>`.
  This is divided into ``scheduler.compaction_input`` (the amount that is being
  compacted), ``scheduler.compaction_queue`` (the amount that is waiting to be
  compacted),
  ``scheduler.compaction_time`` (total time spent by all worker threads performing compaction, in seconds),
  and ``scheduler.compaction_output`` (the amount that has been compacted,
  which is presumably smaller than ``scheduler.compaction_input``).

* ``box.stat.vinyl().scheduler.tasks_*``
  is about dump/compaction tasks, in three categories,
  ``scheduler.tasks_inprogress`` (currently running),
  ``scheduler.tasks_completed`` (successfully completed)
  ``scheduler.tasks_failed`` (aborted due to errors).

* ``box.stat.vinyl().scheduler_dump_*`` has
  the amount of data from recent changes that has been dumped,
  including ``dump_time`` (total time spent by all worker threads performing dumps, in seconds),
  and ``dump_count`` (the count of completed dumps),
  ``dump_input`` and ``dump_output``.

  A "dump" is explained in section :ref:`Storing data with vinyl <engines-algorithm_filling_lsm>`:

    Sooner or later the number of elements in an LSM tree exceeds the L0 size and that is
    when L0 gets written to a file on disk (called a 'run') and then cleared for storing new elements.
    This operation is called a 'dump'.

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

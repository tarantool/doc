.. _box-snapshot:

-------------------------------------------------------------------------------
                             Function `box.snapshot`
-------------------------------------------------------------------------------

.. function:: box.snapshot()

    Take a snapshot of all data and store it in
    :ref:`memtx_dir <cfg_basic-memtx_dir>`:samp:`/{<latest-lsn>}.snap`.
    To take a snapshot, Tarantool first enters the delayed garbage collection
    mode for all data. In this mode, tuples which were allocated before the
    snapshot has started are not freed until the snapshot has finished. To
    preserve consistency of the primary key, used to iterate over tuples, a
    copy-on-write technique is employed. If the master process changes part
    of a primary key, the corresponding process page is split, and the snapshot
    process obtains an old copy of the page.
    In effect, the snapshot process uses multi-version concurrency control
    in order to avoid copying changes which are superseded while it is running.

    Since a snapshot is written sequentially, one can expect a very high write
    performance (averaging to 80MB/second on modern disks), which means an average
    database instance gets saved in a matter of minutes.
    
    .. NOTE::
    
       As long as there are any changes to the parent index memory through
       concurrent updates, there are going to be page splits, and therefore you
       need to have some extra free memory to run this command. 10% of
       :ref:`memtx_memory <cfg_storage-memtx_memory>` is, on average, sufficient.
       This statement waits until a snapshot is taken and returns operation result.

    .. NOTE::
    
       **Change notice:** Prior to Tarantool version 1.6.6, the snapshot process
       caused a fork, which could cause occasional latency spikes. Starting with
       Tarantool version 1.6.6, the snapshot process creates a consistent
       read view and this view is written to the snapshot file by a separate thread
       (the "Write Ahead Log" thread).

       Although ``box.snapshot()`` does not cause a fork, there is a separate fiber
       which may produce snapshots at regular intervals -- see the discussion of
       the :ref:`checkpoint daemon <book_cfg_checkpoint_daemon>`.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.info.version
        ---
        - 1.7.0-1216-g73f7154
        ...
        tarantool> box.snapshot()
        ---
        - ok
        ...
        tarantool> box.snapshot()
        ---
        - error: can't save snapshot, errno 17 (File exists)
        ...

    Taking a snapshot does not cause the server to start a new write-ahead log.
    Once a snapshot is taken, old WALs can be deleted as long as all replicated
    data is up to date. But the WAL which was current at the time ``box.snapshot()``
    started must be kept for recovery, since it still contains log records
    written after the start of ``box.snapshot()``.

    An alternative way to save a snapshot is to send a SIGUSR1 signal to the instance.
    While this approach could be handy, it is not recommended for use
    in automation: a signal provides no way to find out whether the snapshot
    was taken successfully or not.


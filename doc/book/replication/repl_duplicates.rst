.. _replication-duplicates:

================================================================================
Preventing duplicate actions
================================================================================

Tarantool guarantees that every update is applied only once on every replica.
However, due to the asynchronous nature of replication, the order of updates is
not guaranteed. We now analyze this problem with more details, provide
examples of replication going out of sync, and suggest solutions.

.. _replication-replication_stops:

--------------------------------------------------------------------------------
Replication stops
--------------------------------------------------------------------------------

In a replica set of two masters, suppose master #1 tries to do something that
master #2 has already done. For example, try to insert a tuple
with the same unique key:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:insert{1, 'data'}

This would cause an error saying ``Duplicate key exists in unique index
'primary' in space 'tester'`` and the replication would be stopped.
(This is the behavior when the
:ref:`replication_skip_conflict <cfg_replication-replication_skip_conflict>`
configuration parameter has its default recommended value, ``false``.)

.. code-block:: console

    $ # error messages from master #1
    2017-06-26 21:17:03.233 [30444] main/104/applier/rep_user@100.96.166.1 I> can't read row
    2017-06-26 21:17:03.233 [30444] main/104/applier/rep_user@100.96.166.1 memtx_hash.cc:226 E> ER_TUPLE_FOUND:
    Duplicate key exists in unique index 'primary' in space 'tester'
    2017-06-26 21:17:03.233 [30444] relay/[::ffff:100.96.166.178]/101/main I> the replica has closed its socket, exiting
    2017-06-26 21:17:03.233 [30444] relay/[::ffff:100.96.166.178]/101/main C> exiting the relay loop

    $ # error messages from master #2
    2017-06-26 21:17:03.233 [30445] main/104/applier/rep_user@100.96.166.1 I> can't read row
    2017-06-26 21:17:03.233 [30445] main/104/applier/rep_user@100.96.166.1 memtx_hash.cc:226 E> ER_TUPLE_FOUND:
    Duplicate key exists in unique index 'primary' in space 'tester'
    2017-06-26 21:17:03.234 [30445] relay/[::ffff:100.96.166.178]/101/main I> the replica has closed its socket, exiting
    2017-06-26 21:17:03.234 [30445] relay/[::ffff:100.96.166.178]/101/main C> exiting the relay loop

If we check replication statuses with ``box.info``, we will see that replication
at master #1 is stopped (``1.upstream.status = stopped``). Additionally, no data
is replicated from that master (section ``1.downstream`` is missing in the
report), because the downstream has encountered the same error:

.. code-block:: tarantoolsession

    # replication statuses (report from master #3)
    tarantool> box.info
    ---
    - version: 1.7.4-52-g980d30092
      id: 3
      ro: false
      vclock: {1: 9, 2: 1000000, 3: 3}
      uptime: 557
      lsn: 3
      vinyl: []
      cluster:
        uuid: 34d13b1a-f851-45bb-8f57-57489d3b3c8b
      pid: 30445
      status: running
      signature: 1000012
      replication:
        1:
          id: 1
          uuid: 7ab6dee7-dc0f-4477-af2b-0e63452573cf
          lsn: 9
          upstream:
            peer: replicator@192.168.0.101:3301
            lag: 0.00050592422485352
            status: stopped
            idle: 445.8626639843
            message: Duplicate key exists in unique index 'primary' in space 'tester'
        2:
          id: 2
          uuid: 9afbe2d9-db84-4d05-9a7b-e0cbbf861e28
          lsn: 1000000
          upstream:
            status: follow
            idle: 201.99915885925
            peer: replicator@192.168.0.102:3301
            lag: 0.0015020370483398
          downstream:
            vclock: {1: 8, 2: 1000000, 3: 3}
        3:
          id: 3
          uuid: e826a667-eed7-48d5-a290-64299b159571
          lsn: 3
      uuid: e826a667-eed7-48d5-a290-64299b159571
    ...

When replication is later manually resumed:

.. code-block:: tarantoolsession

    # resuming stopped replication (at all masters)
    tarantool> original_value = box.cfg.replication
    tarantool> box.cfg{replication={}}
    tarantool> box.cfg{replication=original_value}

... the faulty row in the write-ahead-log files is skipped.

.. _replication-runs_out_of_sync:

--------------------------------------------------------------------------------
Replication runs out of sync
--------------------------------------------------------------------------------

In a master-master cluster of two instances, suppose we make the following
operation:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:upsert({1}, {{'=', 2, box.info.uuid}})

When this operation is applied on both instances in the replica set:

.. code-block:: tarantoolsession

    # at master #1
    tarantool> box.space.tester:upsert({1}, {{'=', 2, box.info.uuid}})
    # at master #2
    tarantool> box.space.tester:upsert({1}, {{'=', 2, box.info.uuid}})

... we can have the following results, depending on the order of execution:

* each master’s row contains the UUID from master #1,
* each master’s row contains the UUID from master #2,
* master #1 has the UUID of master #2, and vice versa.

.. _replication-commutative_changes:

--------------------------------------------------------------------------------
Commutative changes
--------------------------------------------------------------------------------

The cases described in the previous paragraphs represent examples of
**non-commutative** operations, i.e. operations whose result depends on the
execution order. On the contrary, for **commutative operations**, the
execution order does not matter.

Consider for example the following command:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:upsert{{1, 0}, {{'+', 2, 1)}

This operation is commutative: we get the same result no matter in which order
the update is applied on the other masters.

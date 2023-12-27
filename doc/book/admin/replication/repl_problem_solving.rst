.. _replication-problem_solving:


Resolving replication conflicts
===============================

Tarantool guarantees that every update is applied only once on every replica.
However, due to the asynchronous nature of replication, the order of updates is not guaranteed.
This topic describes how to solve problems in :ref:`master-master <replication-bootstrap-master-master>` replication.


.. _replication-problem_solving_replacing_primary_key:

Replacing the same primary key
------------------------------

**Case 1:** You have two instances of Tarantool. For example, you try to make a
``replace`` operation with the same primary key on both instances at the same time.
This causes a conflict over which tuple to save and which one to discard.

Tarantool :ref:`trigger functions <triggers>` can help here to implement the
rules of conflict resolution on some condition. For example, if you have a
timestamp, you can declare saving the tuple with the bigger one.

First, you need a :ref:`before_replace() <box_space-before_replace>` trigger on
the space which may have conflicts. In this trigger, you can compare the old and new
replica records and choose which one to use (or skip the update entirely,
or merge two records together).

Then you need to set the trigger at the right time before the space starts
to receive any updates. The way you usually set the ``before_replace`` trigger
is right when the space is created, so you need a trigger to set another trigger
on the system space ``_space``, to capture the moment when your space is created
and set the trigger there. This can be an :ref:`on_replace() <box_space-on_replace>`
trigger.

The difference between ``before_replace`` and ``on_replace`` is that ``on_replace``
is called after a row is inserted into the space, and ``before_replace``
is called before that.

To set a ``_space:on_replace()`` trigger correctly, you also need the right timing. The best
timing to use it is when ``_space`` is just created, which is
the :ref:`box.ctl.on_schema_init() <box_ctl-on_schema_init>` trigger.

You also need to utilize ``box.on_commit`` to get access to the space being
created. The resulting snippet would be the following:

.. code-block:: lua

    local my_space_name = 'my_space'
    local my_trigger = function(old, new) ... end -- your function resolving a conflict
    box.ctl.on_schema_init(function()
        box.space._space:on_replace(function(old_space, new_space)
            if not old_space and new_space and new_space.name == my_space_name then
                box.on_commit(function()
                    box.space[my_space_name]:before_replace(my_trigger)
                end
            end
        end)
    end)



.. _replication-duplicates:

Preventing duplicate insert
---------------------------

.. _replication-replication_stops:

**Case 2:** In a replica set of two masters, both of them try to insert data by the same unique key:

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


To learn how to resolve a replication conflict by reseeding a replica, see :ref:`Resolving replication conflicts <replication-master-master-resolve-conflicts>`.


.. _replication-runs_out_of_sync:

Replication runs out of sync
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Commutative changes
~~~~~~~~~~~~~~~~~~~

The cases described in the previous paragraphs represent examples of
**non-commutative** operations, that is operations whose result depends on the
execution order. On the contrary, for **commutative operations**, the
execution order does not matter.

Consider for example the following command:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:upsert{{1, 0}, {{'+', 2, 1)}

This operation is commutative: we get the same result no matter in which order
the update is applied on the other masters.

.. _replication_trigger_usage:

Trigger usage
~~~~~~~~~~~~~

The logic and the snippet setting a trigger will be the same here as in :ref:`case 1 <replication-problem_solving_replacing_primary_key>`.
But the trigger function will differ.
Note that the trigger below assumes that tuple has a timestamp in the second field.

.. code-block:: lua

    local my_space_name = 'test'
    local my_trigger = function(old, new, sp, op)
        -- op:  ‘INSERT’, ‘DELETE’, ‘UPDATE’, or ‘REPLACE’
        if new == nil then
            print("No new during "..op, old)
            return -- deletes are ok
        end
        if old == nil then
            print("Insert new, no old", new)
            return new  -- insert without old value: ok
        end
        print(op.." duplicate", old, new)
        if op == 'INSERT' then
            if new[2] > old[2] then
                -- Creating new tuple will change op to ‘REPLACE’
                return box.tuple.new(new)
            end
            return old
        end
        if new[2] > old[2] then
            return new
        else
            return old
        end
        return
    end

    box.ctl.on_schema_init(function()
        box.space._space:on_replace(function(old_space, new_space)
            if not old_space and new_space and new_space.name == my_space_name then
                box.on_commit(function()
                    box.space[my_space_name]:before_replace(my_trigger)
                end)
            end
        end)
    end)

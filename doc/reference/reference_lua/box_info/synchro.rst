..  _box_info_synchro:

================================================================================
box.info.synchro
================================================================================

..  module:: box.info

..  data:: synchro

    Since version :doc:`2.8.1 </release/2.8.1>`.
    Show the current state of synchronous replication.

    In :ref:`synchronous replication <repl_sync>`, a transaction is considered committed only after achieving
    the required quorum number.
    While the transactions are collecting confirmations from remote nodes, these transactions are waiting in the queue.

    The following information is provided:

    *   ``queue``:

        -   ``owner`` -- ID of the replica that owns the synchronous transaction queue.
            Once an owner instance appears, all other instances become read-only.
            If the ``owner`` field is ``0``, then every instance is writeable,
            but they can't create any synchronous transactions.
            To claim or reclaim the queue, use :ref:`box.ctl.promote() <box_ctl-promote>` on the instance that you want
            to promote.
            With elections enabled, the instance runs ``box.ctl.promote()`` automatically after winning the elections.
            Since version :doc:`2.10.0 </release/2.10.0>`.

        -   ``term`` -- current queue term.
            It contains the term of the last ``PROMOTE``.
            Usually it is equal to :ref:`box.info.election.term <box_info_election>`.
            However, the queue term value may be less than the corresponding one in the election term.
            It can happen when a new round of elections started, but no one has promoted yet.
            Since version :doc:`2.10.0 </release/2.10.0>`.

        -   ``len`` -- current number of entries that are waiting in the queue.

        -   ``busy`` -- the boolean value is set to ``true`` if there is a synchronous transaction in progress.
            Until the active transaction is complete, any other incoming synchronous transactions will be delayed.
            Since version :doc:`2.10.0 </release/2.10.0>`.

    *   ``quorum`` -- evaluated value of the
        :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>` configuration option.
        Since version :doc:`2.5.3 </release/2.5.3>`, the option can be set as a dynamic formula.
        In this case, the value in the ``quorum`` member depends on the current number of replicas.

    **Example 1:**

    In this example, the ``quorum`` field is equal to ``1``.
    This means that the synchronous transactions work like asynchronous.
    `1` means that successful WAL write to the master is enough to commit.

    ..  code-block:: tarantoolsession

        tarantool> box.info.synchro
        ---
        - queue:
            owner: 1
            term: 2
            len: 0
            busy: false
          quorum: 1
        ...

    **Example 2:**

    First, set a quorum number and a timeout for synchronous replication using the following command:

    ..  code-block:: tarantoolsession

        tarantool> box.cfg{
                 > replication_synchro_quorum=2,
                 > replication_synchro_timeout=1000
                 > }

    Next, check the current state of synchronous replication:

    ..  code-block:: tarantoolsession

        tarantool> box.info.synchro
        ---
        - queue:
            owner: 1
            term: 2
            len: 0
            busy: false
          quorum: 2
        ...

    Create a space called ``sync`` and enable synchronous replication on this space.
    Then, create an index.

    ..  code-block:: tarantoolsession

        tarantool> s = box.schema.space.create("sync", {is_sync=true})
        tarantool> _ = s:create_index('pk')

    After that, use ``box.ctl.promote`` function to claim the queue:

    ..  code-block:: tarantoolsession

        tarantool> box.ctl.promote()

    Next, use the ``replace`` command:

    ..  code-block:: tarantoolsession

        tarantool> require('fiber').new(function() box.space.sync:replace{1} end)
        ---
        - status: suspended
          name: lua
          id: 119
        ...
        tarantool> require('fiber').new(function() box.space.sync:replace{1} end)
        ---
        - status: suspended
          name: lua
          id: 120
        ...
        tarantool> require('fiber').new(function() box.space.sync:replace{1} end)
        ---
        - status: suspended
          name: lua
          id: 121
        ...

    If you use the ``box.info.synchro`` command again,
    you will see that now there are 3 transactions waiting in the queue:

    ..  code-block:: tarantoolsession

        tarantool> box.info.synchro
        ---
        - queue:
            owner: 1
            term: 2
            len: 3
            busy: false
          quorum: 2
        ...
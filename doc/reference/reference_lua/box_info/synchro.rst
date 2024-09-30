..  _box_info_synchro:

box.info.synchro
================

..  module:: box.info

..  data:: synchro

    Since version :doc:`2.8.1 </release/2.8.1>`.

    The current state of synchronous replication.

    In :ref:`synchronous replication <repl_sync>`, transaction is considered committed only after achieving
    the required quorum number.
    While transactions are collecting confirmations from remote nodes, these transactions are waiting in the queue.

    The following information is provided:

    *   ``queue``:

        -   ``owner`` (since version :doc:`2.10.0 </release/2.10.0>`) -- ID of the replica that owns the synchronous
            transaction queue. Once an owner instance appears, all other instances become read-only.
            If the ``owner`` field is ``0``, then every instance may be writable,
            but they can't create any synchronous transactions.
            To claim or reclaim the queue, use :ref:`box.ctl.promote() <box_ctl-promote>` on the instance that you want
            to promote.
            With elections enabled, an instance runs ``box.ctl.promote()`` command automatically after winning the elections.
            To clear the ownership, call :ref:`box.ctl.demote() <box_ctl-demote>` on the synchronous queue owner.

            ..  note::

                When Raft election is enabled and :ref:`replication.election_mode <configuration_reference_replication_election_mode>`
                is set to ``candidate``, the new Raft leader claims the queue automatically.
                It means that the value of ``box.info.synchro.queue.owner`` becomes equal to :ref:`box.info.election.leader <box_info_election>`.
                When Raft enabled, no manual intervention with ``box.ctl.promote()`` or ``box.ctl.demote()`` is required.

        -   ``term`` (since version :doc:`2.10.0 </release/2.10.0>`) -- current queue term.
            It contains the term of the last ``PROMOTE`` request.
            Usually, it is equal to :ref:`box.info.election.term <box_info_election>`.
            However, the queue term value may be less than the election term.
            It can happen when a new round of elections has started, but no instance has been promoted yet.

        -   ``len`` -- the number of entries that are currently waiting in the queue.

        -   ``busy`` (since version :doc:`2.10.0 </release/2.10.0>`) -- the boolean value is ``true``
            when the instance is processing or writing some system request that modifies the queue
            (for example, ``PROMOTE``, ``CONFIRM``, or ``ROLLBACK``).
            Until the request is complete, any other incoming synchronous transactions and system requests
            will be delayed.

        -   ``age`` (since version :doc:`3.2.0 </release/3.2.0>`) -- the time in seconds that the oldest entry currently
            present in the queue has spent waiting for the quorum to collect.

        -   ``confirm_lag`` (since version :doc:`3.2.0 </release/3.2.0>`) -- the time in seconds that the latest successfully
            confirmed entry waited for the quorum to collect.

    *   ``quorum`` -- the resulting value of the
        :ref:`replication_synchro_quorum <cfg_replication-replication_synchro_quorum>` configuration option.
        Since version :doc:`2.5.3 </release/2.5.3>`, the option can be set as a dynamic formula.
        In this case, the value of the ``quorum`` member depends on the current number of replicas.

    **Example 1:**

    In this example, the ``quorum`` field is equal to `1`.
    That is, synchronous transactions work like asynchronous ones.
    `1` means that a successful WAL writing to the master is enough to commit.

    ..  code-block:: console

        instance001> box.info.synchro
        ---
        - queue:
            owner: 1
            confirm_lag: 0
            term: 2
            age: 0
            len: 0
            busy: false
          quorum: 1
        ...

    **Example 2:**

    First, set a quorum number and a timeout for synchronous replication in the configuration file (``config.yaml``):

    ..  code-block:: yaml

        replication:
          synchro_quorum: 2
          synchro_timeout: 1000

    Check the current state of synchronous replication:

    ..  code-block:: console

        app:instance001> box.info.synchro
        ---
        - queue:
            owner: 2
            confirm_lag: 0
            term: 28
            age: 0
            len: 0
            busy: false
          quorum: 2
        ...

    Create a space called ``sync`` and enable synchronous replication on this space.
    Then, create an index.

    ..  code-block:: console

        app:instance001> s = box.schema.space.create("sync", {is_sync=true})
        app:instance001> _ = s:create_index('pk')

    After that, use ``box.ctl.promote()`` function to claim a queue:

    ..  code-block:: console

        app:instance001> box.ctl.promote()

    Next, perform data manipulations:

    ..  code-block:: console

        app:instance001> require('fiber').new(function() box.space.sync:replace{1} end)
        ---
        - status: suspended
          name: lua
          id: 127
        ...
        app:instance001> require('fiber').new(function() box.space.sync:replace{1} end)
        ---
        - status: suspended
          name: lua
          id: 128
        ...
        app:instance001> require('fiber').new(function() box.space.sync:replace{1} end)
        ---
        - status: suspended
          name: lua
          id: 129
        ...

    If you call the ``box.info.synchro`` command again,
    you will see that now there are 3 transactions waiting in the queue:

    ..  code-block:: console

        app:instance001> box.info.synchro
        ---
        - queue:
            owner: 1
            confirm_lag: 0
            term: 29
            age: 0
            len: 0
            busy: false
          quorum: 2
        ...

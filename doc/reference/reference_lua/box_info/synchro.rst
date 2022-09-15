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
            Once the owner instance appears, all other instances become read-only.
            If the ``owner`` field is ``0``, then every instance is writeable,
            but it can't create any synchronous transactions.
            To claim or re-claim the queue, use :ref:`box.ctl.promote() <box_ctl-promote>` on the instance that you want
            to promote.
            Since version :doc:`2.10.0 </release/2.10.0>`.

        -   ``term`` -- current queue term.
            It contains the term of the last ``PROMOTE``.
            Usually it is equal to :ref:`box.info.election.term <box_info_election>`.
            However, the queue term value may be less than the corresponding one in election term.
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

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> box.info.synchro
        ---
        - queue:
            len: 0
          quorum: 1
        ...
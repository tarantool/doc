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

        -   ``len`` -- current number of entries that are waiting in the queue.

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
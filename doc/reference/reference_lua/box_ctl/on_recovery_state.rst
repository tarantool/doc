..  _box_ctl-on_recovery_state:

===============================================================================
box.ctl.on_recovery_state()
===============================================================================

..  module:: box.ctl

..  function:: on_recovery_state(trigger-function)

    **Since:** :doc:`2.11.0 </release/2.11.0>`

    Create a :ref:`trigger <triggers>` executed on different stages of a node :ref:`recovery <internals-recovery_process>` or initial configuration.
    Note that you need to set the ``box.ctl.on_recovery_state`` trigger before the initial :ref:`box.cfg <box_introspection-box_cfg>` call.

    :param function     trigger-function: a trigger function

    :return: ``nil`` or a function pointer

    A registered trigger function is run on each of the supported recovery
    state and receives the state name as a parameter:

    *   ``snapshot_recovered``: the node has recovered the snapshot files.
    *   ``wal_recovered``: the node has recovered the WAL files.
    *   ``indexes_built``: the node has built secondary indexes for memtx spaces.
        This stage might come before any actual data is recovered. This means that the
        indexes are available right after the first tuple is recovered.
    *   ``synced``: the node has synced with enough remote peers.
        This means that the node changes the state from :ref:`orphan <internals-replication-orphan_status>` to ``running``.

    All these states are passed during the initial ``box.cfg`` call when recovering
    from the snapshot and WAL files.
    Note that the ``synced`` state might be reached after the initial ``box.cfg`` call finishes.
    For example, if :ref:`replication_sync_timeout <cfg_replication-replication_sync_timeout>`
    is set to 0, the node finishes ``box.cfg`` without reaching ``synced`` and stays ``orphan``.
    Once the node is synced with enough remote peers, the ``synced`` state is reached.

    .. NOTE::

        When bootstrapping a fresh cluster with no data, all the instances in this cluster
        execute triggers on the same stages for consistency.
        For example, ``snapshot_recovered`` and ``wal_recovered``
        run when the node finishes a cluster's bootstrap or finishes joining to an existing cluster.


    **Example:**

    The example below shows how to :ref:`log <log-module>` a specified message when each state is reached.

    ..  literalinclude:: /code_snippets/test/triggers/on_recovery_state_test.lua
        :language: lua
        :lines: 7-11
        :dedent:

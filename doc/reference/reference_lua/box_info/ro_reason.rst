..  _box_info_ro-reason:

================================================================================
box.info.ro_reason
================================================================================

..  module:: box.info

..  data:: ro_reason

    Since: :doc:`2.10.0 </release/2.10.0>`

    The reason why the current instance is read-only.
    To get whether the current instance is writable or read-only, use :ref:`box_info_ro`.
    If the instance is in writable mode, ``box.info.ro_reason`` returns ``nil``.

    The possible values returned by ``ro_reason``:

    *   ``election`` -- the instance is not the leader.
        See :ref:`box.info.election <box_info_election>` for details.

    *   ``synchro`` -- the instance is not the owner of the synchronous transaction queue.
        For details, see :ref:`box.info.synchro <box_info_synchro>`.

    *   ``config`` -- the instance is is :ref:`configured <configuration>` to be read only.

    *   ``orphan`` -- the instance is in ``orphan`` state.
        For details, see :ref:`the orphan status page <internals-replication-orphan_status>`.

    :rtype: string

    **Example**

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info.ro
        ---
        - true
        ...
        sharded_cluster_crud:storage-a-002> box.info.ro_reason
        ---
        - config
        ...

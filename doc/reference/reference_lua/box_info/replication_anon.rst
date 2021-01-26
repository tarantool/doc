.. _box_info_replication-anon:

================================================================================
box.info.replication_anon()
================================================================================

.. module:: box.info

.. function:: replication_anon()

    List all the :ref:`anonymous replicas <cfg_replication-replication_anon>`
    following the instance.

    The output is similar to the one produced by ``box.info.replication`` with
    an exception that anonymous replicas are indexed by their uuid strings
    rather than server ids, since server ids have no meaning for anonymous
    replicas.

    Notice that when you issue a plain ``box.info.replication_anon``, the only
    info returned is the number of anonymous replicas following the current
    instance. In order to see the full stats, you have to call
    ``box.info.replication_anon()``. This is done to not overload the ``box.info``
    output with excess info, since there may be lots of anonymous replicas.

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.info.replication_anon
      ---
      - count: 2
      ...

      tarantool> box.info.replication_anon()
      ---
      - 3a6a2cfb-7e47-42f6-8309-7a25c37feea1:
          id: 0
          uuid: 3a6a2cfb-7e47-42f6-8309-7a25c37feea1
          lsn: 0
          downstream:
            status: follow
            idle: 0.76203499999974
            vclock: {1: 1}
        f58e4cb0-e0a8-42a1-b439-591dd36c8e5e:
          id: 0
          uuid: f58e4cb0-e0a8-42a1-b439-591dd36c8e5e
          lsn: 0
          downstream:
            status: follow
            idle: 0.0041349999992235
            vclock: {1: 1}
      ...

    Notice that anonymous replicas hide their ``lsn`` from the others, so an
    anonymous replica ``lsn`` will always be reported as zero, even if an anonymous
    replica performs some local space operations.
    To find out the ``lsn`` of a specific anonymous replica, you have to issue ``box.info.lsn`` on
    it.

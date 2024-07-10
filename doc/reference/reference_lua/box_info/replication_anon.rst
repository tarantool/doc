.. _box_info_replication-anon:

================================================================================
box.info.replication_anon()
================================================================================

.. module:: box.info

.. function:: replication_anon()

    List all the :ref:`anonymous replicas <configuration_reference_replication_anon>`
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

    ..  code-block:: tarantoolsession

        anonymous_replica:instance001> box.info.replication_anon
        ---
        - count: 1
        ...

        anonymous_replica:instance001> box.info.replication_anon()
        ---
        - 44237cb4-de83-4347-b6db-46274b940acf:
            id: 0
            uuid: 44237cb4-de83-4347-b6db-46274b940acf
            lsn: 0
            downstream:
              status: follow
              idle: 0.81613899999866
              vclock: {1: 7}
              lag: 0
            name: null
        ...

    Notice that anonymous replicas hide their ``lsn`` from the others, so an
    anonymous replica ``lsn`` will always be reported as zero, even if an anonymous
    replica performs some local space operations.
    To find out the ``lsn`` of a specific anonymous replica, you have to issue ``box.info.lsn`` on
    it.

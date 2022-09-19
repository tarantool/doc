.. _box_info_replication:

================================================================================
box.info.replication
================================================================================

..  module:: box.info

..  data:: replication

    The **replication** section of ``box.info()`` is a table array with
    statistics for all instances in the replica set that the current instance
    belongs to (see also :ref:`"Monitoring a replica set" <replication-monitoring>`):

    In the following, *n* is the index number of one table item, for example
    :samp:`replication[1]`, which has data about server instance number 1,
    which may or may not be the same as the current instance
    (the "current instance" is what is responding to ``box.info``).

    * :samp:`replication[{n}].id` is a short numeric identifier of instance *n*
      within the replica set.
      This value is stored in the :ref:`box.space._cluster <box_space-cluster>`
      system space.
    * :samp:`replication[{n}].uuid` is a globally unique identifier of instance
      *n*. This value is stored in the :ref:`box.space._cluster <box_space-cluster>`
      system space.
    * :samp:`replication[{n}].lsn` is the
      :ref:`log sequence number <replication-mechanism>`
      (LSN) for the latest entry in instance *n*'s
      :ref:`write ahead log <index-box_persistence>` (WAL).
    * :samp:`replication[{n}].upstream` appears (is not nil)
      if the current instance is following or intending to follow instance *n*,
      which ordinarily means
      :samp:`replication[{n}].upstream.status` = ``follow``,
      :samp:`replication[{n}].upstream.peer` = url of instance *n* which is
      being followed, :samp:`replication[{n}].lag and idle` = the instance's
      speed, described later.
      Another way to say this is: :samp:`replication[{n}].upstream` will appear
      when :samp:`replication[{n}].upstream.peer` is not of the current instance,
      and is not read-only, and was specified in ``box.cfg{replication={...}}``,
      so it is shown in :ref:`box.cfg.replication <cfg_replication-replication>`.
    * :samp:`replication[{n}].upstream.status` is the replication status of the
      connection with instance *n*:

      * ``auth`` means that :ref:`authentication <authentication>` is happening.
      * ``connecting`` means that connection is happening.
      * ``disconnected`` means that it is not connected to the replica set
        (due to network problems, not replication errors).
      * ``follow`` means that the current instance's role is "replica" (read-only,
        or not read-only but acting as a replica for this remote peer in a
        master-master configuration), and is receiving or able to receive data
        from instance *n*'s (upstream) master.
      * ``stopped`` means that replication was stopped due to a replication
        error (for example :ref:`duplicate key <error_codes>`).
      * ``sync`` means that the master and replica are synchronizing to have
        the same data.

    .. _box_info_replication_upstream_idle:

    * :samp:`replication[{n}].upstream.idle` is the time (in seconds) since
      the last event was received.
      This is the primary indicator of replication health.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    .. _box_info_replication_upstream_peer:

    * :samp:`replication[{n}].upstream.peer` contains instance *n*'s
      :ref:`URI <index-uri>` for example 127.0.0.1:3302.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    .. _box_info_replication_upstream_lag:

    * :samp:`replication[{n}].upstream.lag` is the time difference between the
      local time of instance *n*, recorded when the event was received, and
      the local time at another master recorded when the event was written to
      the :ref:`write ahead log <internals-wal>` on that master.
      See more in :ref:`Monitoring a replica set <replication-monitoring>`.

    * :samp:`replication[{n}].upstream.message` contains an error message in
      case of a :ref:`degraded state <replication-recover>`, otherwise it is nil.

    * :samp:`replication[{n}].downstream` appears (is not nil)
      with data about an instance that is following instance *n*
      or is intending to follow it, which ordinarily means
      :samp:`replication[{n}].downstream.status` = ``follow``,

    * :samp:`replication[{n}].downstream.vclock` contains the
      :ref:`vector clock <replication-vector>`, which is a table of
      '**id**, **lsn**' pairs, for example
      :code:`vclock: {1: 3054773, 4: 8938827, 3: 285902018}`.
      (Notice that the table may have multiple pairs although ``vclock`` is
      a singular name).

      Even if instance *n* is :ref:`removed <replication-remove_instances>`,
      its values will still appear here; however,
      its values will be overridden if an instance joins later with the same UUID.
      Vector clock pairs will only appear if ``lsn > 0``.

      :samp:`replication[{n}].downstream.vclock` may be the same as the current
      instance's vclock (``box.info.vclock``) because this is for all known
      vclock values of the cluster.
      A master will know what is in a replica's copy of vclock
      because, when the master makes a data change, it sends
      the change information to the replica (including the master's
      vector clock), and the replica replies with what is in its entire
      vector clock table.

      Also the replica sends its entire vector clock table in response
      to a master's heartbeat message, see the heartbeat-message examples
      in section :ref:`Binary protocol -- replication <box_protocol-heartbeat>`.

    * :samp:`replication[{n}].downstream.idle` is the time (in seconds) since the
      last time that instance *n* sent events through the downstream replication.

    * :samp:`replication[{n}].downstream.status` is the replication status for
      downstream replications:

      * ``stopped`` means that downstream replication has stopped,
      * ``follow`` means that downstream replication is in progress (instance
        *n* is ready to accept data from the master or is currently doing so).

    * :samp:`replication[{n}].downstream.message` and
      :samp:`replication[{n}].downstream.system_message`
      will be nil unless a problem occurs with the connection.
      For example, if instance *n* goes down, then one may see
      ``status = 'stopped'``, ``message = 'unexpected EOF when reading
      from socket'``, and ``system_message = 'Broken pipe'``.
      See also :ref:`degraded state <replication-recover>`.


    For better understanding, see the following diagram illustrating the ``upstream`` and ``downstream`` connections within the replica set of three instances:

    ..  image:: /concepts/replication/images/replication.svg
        :align: left


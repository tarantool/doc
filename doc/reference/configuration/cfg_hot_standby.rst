.. confval:: hot_standby

    Since version 1.7.4. Whether to start the server in **hot standby** mode.

    Hot standby is a feature which provides a simple form of failover without
    :ref:`replication <replication>`.

    The expectation is that there will be two instances of the server using the
    same configuration. The first one to start will be the "primary" instance.
    The second one to start will be the "standby" instance.

    To initiate the standby instance, start a second instance of the Tarantool
    server on the same computer with the same
    :ref:`box.cfg <box_introspection-box_cfg>` configuration settings --
    including the same directories and same non-null URIs -- and with the
    additional configuration setting ``hot_standby = true``.
    Expect to see a notification ending with the words
    ``I> Entering hot standby mode``.
    This is fine. It means that the standby instance is ready to take over if the
    primary instance goes down.

    The standby instance will initialize and will try to take a lock on
    :ref:`wal_dir <cfg_basic-wal_dir>`,
    but will fail because the primary instance has made a lock on ``wal_dir``.
    So the standby instance goes into a loop, reading the write ahead log which
    the primary instance is writing (so the two instances are always in sync),
    and trying to take the lock.
    If the primary instance goes down for any reason, the lock will be released.
    In this case, the standby instance will succeed in taking the lock,
    will connect on the :ref:`listen <cfg_basic-listen>` address and will become
    the primary instance.
    Expect to see a notification ending with the words
    ``I> ready to accept requests``.

    Thus there is no noticeable downtime if the primary instance goes down.

    Hot standby feature has no effect:

    * if :ref:`wal_dir_rescan_delay = a large number <cfg_binary_logging_snapshots-wal_dir_rescan_delay>`
      (on Mac OS and FreeBSD);
      on these platforms, it is designed so that the loop repeats every
      ``wal_dir_rescan_delay`` seconds.
    * if :ref:`wal_mode = 'none' <cfg_binary_logging_snapshots-wal_mode>`;
      it is designed to work with ``wal_mode = 'write'`` or ``wal_mode = 'fsync'``.
    * for spaces created with :ref:`engine = 'vinyl' <box_schema-space_create>`;
      it is designed to work for spaces created with ``engine = 'memtx'``.

    | Type: boolean
    | Default: false
    | Dynamic: no

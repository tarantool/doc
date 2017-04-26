    Local hot standby is a feature which provides a simple form of failover without
    replication.
    
    The expectation is that there will be two instances of the server using the
    same configuration. The first one to start will be the "primary" instance.
    The second one to start will be the "standby" instance.

    To initiate the standby instance, start a second instance of the Tarantool
    server on the same computer with the same
    :ref:`box.cfg <box_introspection-box_cfg>` configuration settings --
    including the same directories and same non-null URIs.
    The standby instance
    will initialize and will try to connect on listen address,
    but will fail because the primary instance has already taken it.
    Expect to see a warning with the words
    ``W> binary: [URI] is already in use, will retry binding after [n] seconds``.

    This is fine. It means that the second instance is ready to take over if the
    first instance goes down.

    So the
    standby instance goes into a loop, reading the write ahead log which the
    primary instance is writing (so the two instances are always in synch),
    and trying to connect on the port. If the primary instance goes down for any
    reason, the port will become free so the standby instance will succeed in
    connecting, and will become the primary instance.

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


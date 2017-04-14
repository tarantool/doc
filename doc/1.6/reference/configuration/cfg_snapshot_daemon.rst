* :ref:`checkpoint_count <cfg_snapshot_daemon-checkpoint_count>`
* :ref:`checkpoint_interval <cfg_snapshot_daemon-checkpoint_interval>`

The snapshot daemon is a fiber which is constantly running. At intervals, it may
make new snapshot (.snap) files and then may remove old snapshot files. If the
snapshot daemon removes an old snapshot file, it will also remove any
write-ahead log (.xlog) files that are older than the snapshot file and contain
information that is present in the snapshot file.

The :ref:`checkpoint_interval <cfg_snapshot_daemon-checkpoint_interval>` and
:ref:`checkpoint_count <cfg_snapshot_daemon-checkpoint_count>` configuration
settings determine how long the intervals are, and how many snapshots should
exist before removals occur.

.. _cfg_snapshot_daemon-checkpoint_interval:

.. confval:: checkpoint_interval

    The interval between actions by the snapshot daemon, in seconds. If
    ``checkpoint_interval`` is set to a value greater than zero, and there is
    activity which causes change to a database, then the snapshot daemon will
    call :ref:`box.snapshot <box-snapshot>` every ``checkpoint_interval``
    seconds, creating a new snapshot file each time.

    For example:

    .. code-block:: lua

        box.cfg{checkpoint_interval=3600}
        
    will cause the snapshot daemon to create a new database snapshot once
    per hour.

    | Type: integer
    | Default: 0 (disabled)
    | Dynamic: yes

.. _cfg_snapshot_daemon-checkpoint_count:

.. confval:: checkpoint_count

    The maximum number of snapshots that may exist on the ``memtx_dir`` directory
    before the snapshot daemon will remove old snapshots. If ``checkpoint_count``
    equals zero, then the snapshot daemon does not remove old snapshots.
    For example:

    .. code-block:: lua

        box.cfg{
            checkpoint_interval = 3600,
            checkpoint_count  = 10
        }

    will cause the snapshot daemon to create a new snapshot each hour until
    it has created ten snapshots. After that, it will remove the oldest snapshot
    (and any associated write-ahead-log files) after creating a new one.

    | Type: integer
    | Default: 6
    | Dynamic: yes

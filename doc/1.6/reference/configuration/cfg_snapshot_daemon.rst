* :ref:`snapshot_count <cfg_snapshot_daemon-snapshot_count>`
* :ref:`snapshot_period <cfg_snapshot_daemon-snapshot_period>`

The checkpoint daemon is a fiber which is constantly running. At intervals, it may
make new snapshot (.snap) files and then may remove old snapshot files. If the
checkpoint daemon removes an old snapshot file, it will also remove any
write-ahead log (.xlog) files that are older than the snapshot file and contain
information that is present in the snapshot file.

The :ref:`snapshot_period <cfg_snapshot_daemon-snapshot_period>` and
:ref:`snapshot_count <cfg_snapshot_daemon-snapshot_count>` configuration
settings determine how long the intervals are, and how many snapshots should
exist before removals occur.

.. _cfg_snapshot_daemon-snapshot_period:

.. confval:: snapshot_period

    The interval between actions by the checkpoint daemon, in seconds. If
    ``snapshot_period`` is set to a value greater than zero, and there is
    activity which causes change to a database, then the checkpoint daemon will
    call :ref:`box.snapshot <box-snapshot>` every ``snapshot_period``
    seconds, creating a new snapshot file each time.

    For example:

    .. code-block:: lua

        box.cfg{snapshot_period=3600}

    will cause the checkpoint daemon to create a new database snapshot once
    per hour.

    | Type: integer
    | Default: 0 (disabled)
    | Dynamic: yes

.. _cfg_snapshot_daemon-snapshot_count:

.. confval:: snapshot_count

    The maximum number of snapshots that may exist on the ``snap_dir`` directory
    before the checkpoint daemon will remove old snapshots. If ``snapshot_count``
    equals zero, then the checkpoint daemon does not remove old snapshots.
    For example:

    .. code-block:: lua

        box.cfg{
            snapshot_period = 3600,
            snapshot_count  = 10
        }

    will cause the checkpoint daemon to create a new snapshot each hour until
    it has created ten snapshots. After that, it will remove the oldest snapshot
    (and any associated write-ahead-log files) after creating a new one.

    | Type: integer
    | Default: 6
    | Dynamic: yes

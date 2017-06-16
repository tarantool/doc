* :ref:`checkpoint_count <cfg_checkpoint_daemon-checkpoint_count>`
* :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>`

The checkpoint daemon is a fiber which is constantly running. At intervals, it may
make new snapshot (.snap) files and then may delete old snapshot files. If the
checkpoint daemon deletes an old snapshot file, then it will also delete any
write-ahead log (.xlog) files which are older than the snapshot file and which contain
information that is present in the snapshot file.
It will also delete obsolete vinyl .run files.

Exceptions: the checkpoint daemon will not delete a file
if a backup is ongoing and the file has not been backed up
(see :ref:`"Hot backup" <admin-backups-hot_backup_vinyl_memtx>`),
or if replication is ongoing and the file has not been relayed to a replica
(see :ref:`"Replication architecture" <index-replication_architecture>`),
or if a replica is connecting.

The :ref:`checkpoint_interval <cfg_checkpoint_daemon-checkpoint_interval>` and
:ref:`checkpoint_count <cfg_checkpoint_daemon-checkpoint_count>` configuration
settings determine how long the intervals are, and how many snapshots should
exist before deletions occur.

.. _cfg_checkpoint_daemon-checkpoint_interval:

.. confval:: checkpoint_interval

    The interval between actions by the checkpoint daemon, in seconds. If
    ``checkpoint_interval`` is set to a value greater than zero, and there is
    activity which causes change to a database, then the checkpoint daemon will
    call :ref:`box.snapshot <box-snapshot>` every ``checkpoint_interval``
    seconds, creating a new snapshot file each time. If ``checkpoint_interval``
    is set to zero, then the checkpoint daemon is disabled.

    For example:

    .. code-block:: lua

        box.cfg{checkpoint_interval=60}
        
    will cause the checkpoint daemon to create a new database snapshot once
    per minute, if there is activity.

    | Type: integer
    | Default: 3600 (one hour)
    | Dynamic: yes

.. _cfg_checkpoint_daemon-checkpoint_count:

.. confval:: checkpoint_count

    The maximum number of snapshots that may exist on the ``memtx_dir`` directory
    before the checkpoint daemon will delete old snapshots. If ``checkpoint_count``
    equals zero, then the checkpoint daemon does not delete old snapshots.
    For example:

    .. code-block:: lua

        box.cfg{
            checkpoint_interval = 3600,
            checkpoint_count  = 10
        }

    will cause the checkpoint daemon to create a new snapshot each hour until
    it has created ten snapshots. After that, it will delete the oldest snapshot
    (and any associated write-ahead-log files) after creating a new one.

    | Type: integer
    | Default: 2
    | Dynamic: yes

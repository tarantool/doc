================================================================================
Submodule box.backup
================================================================================

The box.backup submodule contains two functions that are helpful for
:ref:`backup <admin-backups>` in certain situations.

.. _reference_lua-box_backup-backup_start:

.. function:: backup.start([n])

    Informs the server that activities related to the removal of outdated
    backups must be suspended.

    To guarantee an opportunity
    to copy these files, Tarantool will not delete them. But there will be no
    read-only mode and checkpoints will continue by schedule as usual.

    :param number n: optional argument starting with Tarantool 1.10.1 that
      indicates the checkpoint
      to use relative to the latest checkpoint. For example ``n = 0`` means
      “backup will be based on the latest checkpoint”, ``n = 1`` means "backup
      will be based on the first checkpoint before the latest checkpoint (counting
      backwards)", and so on. The default value for n is zero.

    **Return:**  a table with the names of snapshot and vinyl files that should
    be copied

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.backup.start()
        ---
        - - ./00000000000000000015.snap
          - ./00000000000000000000.vylog
          - ./513/0/00000000000000000002.index
          - ./513/0/00000000000000000002.run
        ...

.. _reference_lua-box_backup-backup_stop:

.. function:: backup.stop()

    informs the server that normal operations may resume.


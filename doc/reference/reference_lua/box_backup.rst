-------------------------------------------------------------------------------
Submodule box.backup
-------------------------------------------------------------------------------

===============================================================================
                                  Overview
===============================================================================

The box.backup submodule contains two functions that are helpful for
:ref:`backup <admin-backups>` in certain situations.

===============================================================================
                                  Contents
===============================================================================

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +------------------------------------------+----------------------------------+
    | Name                                     | Use                              |
    +==========================================+==================================+
    | :ref:`box.backup.start()                 | ask server to suspend activities |
    | <reference_lua-box_backup-backup_start>` | before the removal of outdated   |
    |                                          | backups                          |
    +------------------------------------------+----------------------------------+
    | :ref:`box.backup.stop()                  | inform server that normal        |
    | <reference_lua-box_backup-backup_start>` | operations may resume            |
    +------------------------------------------+----------------------------------+

.. toctree::
    :hidden:

    box_backup/box_backup_start
    box_backup/box_backup_stop
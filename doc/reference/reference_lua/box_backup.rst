-------------------------------------------------------------------------------
Submodule box.backup
-------------------------------------------------------------------------------

The box.backup submodule contains two functions that are helpful for
:ref:`backup <admin-backups>` in certain situations.

Below is a list of all ``box.backup`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_backup/start`
           - Ask server to suspend activities before the removal of outdated backups

        *  - :doc:`./box_backup/stop`
           - Inform server that normal operations may resume


..  toctree::
    :hidden:

    box_backup/start
    box_backup/stop
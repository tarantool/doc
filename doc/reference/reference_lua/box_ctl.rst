.. _box_ctl:

-------------------------------------------------------------------------------
                                Submodule box.ctl
-------------------------------------------------------------------------------

The ``wait_ro`` (wait until read-only) and ``wait_rw`` (wait until read-write) functions
are useful during server initialization.
To see whether a function is already in read-only or read-write mode, check :ref:`box.info.ro <box_introspection-box_info>`.

A particular use is for :doc:`box.once() </reference/reference_lua/box_once>`.
For example, when a replica is initializing, it may call
a ``box.once()`` function while the server is still in
read-only mode, and fail to make changes that are necessary
only once before the replica is fully initialized.
This could cause conflicts between a master and a replica
if the master is in read-write mode and the replica is in
read-only mode.
Waiting until "read only mode = false" solves this problem.

Below is a list of all ``box.ctl`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_ctl/wait_ro`
           - Wait until ``box.info.ro`` is true

        *  - :doc:`./box_ctl/wait_rw`
           - Wait until ``box.info.ro`` is false

        *  - :doc:`./box_ctl/on_schema_init`
           - Create a "schema_init trigger"

        *  - :doc:`./box_ctl/on_shutdown`
           - Create a "shutdown trigger"

        *  - :doc:`./box_ctl/is_recovery_finished`
           - Check if recovery has finished

        *  - :doc:`./box_ctl/promote`
           - Wait, then choose replication leader

..  toctree::
    :hidden:

    box_ctl/wait_ro
    box_ctl/wait_rw
    box_ctl/on_schema_init
    box_ctl/on_shutdown
    box_ctl/is_recovery_finished
    box_ctl/promote

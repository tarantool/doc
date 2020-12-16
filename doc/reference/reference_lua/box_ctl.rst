.. _box_ctl:

-------------------------------------------------------------------------------
                                Submodule `box.ctl`
-------------------------------------------------------------------------------

===============================================================================
                                  Overview
===============================================================================

The ``box.ctl`` submodule contains two functions: ``wait_ro``
(wait until read-only)
and ``wait_rw`` (wait until read-write).
The functions are useful during initialization of a server.

A particular use is for :ref:`box_once() <box-once>`.
For example, when a replica is initializing, it may call
a ``box.once()`` function while the server is still in
read-only mode, and fail to make changes that are necessary
only once before the replica is fully initialized.
This could cause conflicts between a master and a replica
if the master is in read-write mode and the replica is in
read-only mode.
Waiting until "read only mode = false" solves this problem.

To see whether a function is already in read-only or
read-write mode, check :ref:`box.info.ro <box_introspection-box_info>`.

===============================================================================
                                 Contents
===============================================================================

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+-------------------------------------+
    | Name                                 | Use                                 |
    +======================================+=====================================+
    | :ref:`box.ctl.wait_ro <ctl-wait_ro>` | Wait until ``box.info.ro`` is true  |
    +--------------------------------------+-------------------------------------+
    | :ref:`box.ctl.wait_ro <ctl-wait_rw>` | Wait until ``box.info.ro`` is false |
    +--------------------------------------+-------------------------------------+

.. toctree::
    :hidden:

    box_ctl/box_ctl_wait_ro
    box_ctl/box_ctl_wait_rw
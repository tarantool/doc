.. _box-module:

-------------------------------------------------------------------------------
                                Module `box`
-------------------------------------------------------------------------------

As well as executing Lua chunks or defining your own functions, you can exploit
Tarantool's storage functionality with the ``box`` module and its submodules.

Every submodule contains one or more Lua functions. A few submodules contain
members as well as functions. The functions allow data definition (create
alter drop), data manipulation (insert delete update upsert select replace), and
introspection (inspecting contents of spaces, accessing server configuration).

To catch errors that functions in ``box`` submodules may throw, use :ref:`pcall <error_handling>`.

The contents of the ``box`` module can be inspected at runtime
with ``box``, with no arguments. The ``box`` module contains:

.. toctree::
    :maxdepth: 1

    box_backup
    ../../book/box/box_cfg
    ../../book/box/box_ctl
    box_error
    ../../book/box/box_index
    ../../book/box/box_info
    box_once
    ../../book/box/box_schema
    ../../book/box/box_session
    ../../book/box/box_slab
    ../../book/box/box_space
    ../../book/box/box_stat
    box_snapshot
    ../../book/box/box_tuple
    ../../book/box/box_txn_management
    ../../book/box/box_sql


.. // moved to "User Guide > 5. Server administration":
.. // /book/box/triggers

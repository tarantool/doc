.. _box-module:

-------------------------------------------------------------------------------
                                Module box
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
    :maxdepth: 3
    :includehidden:

    box_stat
    box_cfg

    box_backup
    box_ctl
    box_error
    box_index
    box_info
    box_schema
    box_schema_sequence
    box_session
    box_slab
    box_space
    box_tuple

    box_txn_management
    box_sql
    box_once
    box_snapshot

    box_null


.. // moved to "User Guide > 5. Server administration":
.. // /book/box/triggers

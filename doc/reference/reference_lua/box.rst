.. _index-box_library:

-------------------------------------------------------------------------------
                                Module `box`
-------------------------------------------------------------------------------

As well as executing Lua chunks or defining their own functions, you can exploit
Tarantool's storage functionality with the ``box`` module and its submodules.

The contents of the ``box`` library can be inspected at runtime
with ``box``, with no arguments. The submodules inside the box library are:

.. toctree::
    :maxdepth: 1

    ../../book/box/box_schema
    ../../book/box/box_space
    ../../book/box/box_index
    ../../book/box/box_session
    ../../book/box/box_tuple
    ../../book/box/box_cfg
    ../../book/box/box_slab
    ../../book/box/box_info
    ../../book/box/box_stat

.. // moved to "User Guide > 5. Server administration":  
.. // /book/box/triggers

Every submodule contains one or more Lua functions. A few submodules contain
members as well as functions. The functions allow data definition (create
alter drop), data manipulation (insert delete update upsert select replace), and
introspection (inspecting contents of spaces, accessing server configuration).

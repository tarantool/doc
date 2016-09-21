.. _index-box_library:

-------------------------------------------------------------------------------
                                Module `box`
-------------------------------------------------------------------------------

As well as executing Lua chunks or defining their own functions, you can exploit
Tarantool's storage functionality with the ``box`` module and its submodules.

The contents of the ``box`` library can be inspected at runtime
with ``box``, with no arguments. The submodules inside the box library are:
``box.schema``, ``box.tuple``, ``box.space``, ``box.index``,
``box.cfg``, ``box.info``, ``box.slab``, ``box.stat``.
Every submodule contains one or more Lua functions. A few submodules contain
members as well as functions. The functions allow data definition (create
alter drop), data manipulation (insert delete update upsert select replace), and
introspection (inspecting contents of spaces, accessing server configuration).

.. toctree::
    :maxdepth: 1

    /book/box/box_schema
    /book/box/box_space
    /book/box/box_index
    /book/box/box_session
    /book/box/box_tuple
    
.. // moved to "User Guide > 5. Server administration":  
.. // /book/box/box_introspection
.. // /book/box/triggers

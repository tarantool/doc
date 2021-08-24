.. _engines-chapter:

Storage engines
===============

A storage engine is a set of low-level routines which actually store and
retrieve :term:`tuple <tuple>` values. Tarantool offers a choice of two storage engines:

*   :doc:`memtx <memtx>` is the in-memory storage engine used by default.
*   :doc:`vinyl <vinyl>` is the on-disk storage engine.

Below you can find comparing of the two engines in brief.
All the details on how each engine works you can find in the dedicated
sections:

.. toctree::
   :maxdepth: 1

   memtx
   vinyl

.. _vinyl_diff:

Difference between memtx and vinyl storage engines
--------------------------------------------------

The primary difference between memtx and vinyl is that memtx is an in-memory
engine while vinyl is an on-disk engine. An in-memory storage engine is
generally faster (each query is usually run under 1 ms), and the memtx engine
is justifiably the default for Tarantool. But on-disk engine such as vinyl is
preferable when the database is larger than the available memory, and adding more
memory is not a realistic option.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | Option                                      | memtx                                                | vinyl                                                |
    +=============================================+======================================================+======================================================+
    | Supported index type                        | TREE, HASH, :ref:`RTREE <box_index-rtree>` or BITSET | TREE                                                 |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | Temporary spaces                            | Supported                                            | Not supported                                        |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | :ref:`random() <box_index-random>` function | Supported                                            | Not supported                                        |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | :ref:`alter() <box_index-alter>` function   | Supported                                            | Supported starting from the 1.10.2 release           |
    |                                             |                                                      | (the primary index cannot be modified)               |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | :ref:`len() <box_space-len>` function       | Returns the number of tuples in the space            | Returns the maximum approximate number of tuples in  |
    |                                             |                                                      | the space                                            |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | :ref:`count() <box_index-count>` function   | Takes a constant amount of time                      | Takes a variable amount of time depending on a state |
    |                                             |                                                      | of a DB                                              |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | :ref:`delete() <box_space-delete>` function | Returns the deleted tuple, if any                    | Always returns nil                                   |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+
    | yield                                       | Does not yield on the select requests unless the     | Yields on the select requests or on its equivalents: |
    |                                             | transaction is committed to WAL                      | get() or pairs()                                     |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+

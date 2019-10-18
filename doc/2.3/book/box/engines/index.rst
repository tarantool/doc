.. _engines-chapter:

********************************************************************************
Storage engines
********************************************************************************

A storage engine is a set of very-low-level routines which actually store and
retrieve tuple values. Tarantool offers a choice of two storage engines:

* memtx (the in-memory storage engine) is the default and was the first to
  arrive.

* vinyl (the on-disk storage engine) is a working key-value engine and will
  especially appeal to users who like to see data go directly to disk, so that
  recovery time might be shorter and database size might be larger.

  On the other hand, vinyl lacks some functions and options that are available
  with memtx. Where that is the case, the relevant description in this manual
  contains a note beginning with the words "Note re storage engine".

Further in this section we discuss the details of storing data using
the vinyl storage engine.

To specify that the engine should be vinyl, add the clause ``engine = 'vinyl'``
when creating a space, for example:

.. code-block:: lua

    space = box.schema.space.create('name', {engine='vinyl'})

.. _vinyl_diff:

================================================================================
Differences between memtx and vinyl storage engines
================================================================================

The primary difference between memtx and vinyl is that memtx is an "in-memory"
engine while vinyl is an "on-disk" engine. An in-memory storage engine is
generally faster (each query is usually run under 1 ms), and the memtx engine
is justifiably the default for Tarantool, but on-disk engine such as vinyl is
preferable when the database is larger than the available memory and adding more
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
    |                                             | transaction is commited to WAL                       | get() or pairs()                                     |
    +---------------------------------------------+------------------------------------------------------+------------------------------------------------------+

.. include:: vinyl.rst

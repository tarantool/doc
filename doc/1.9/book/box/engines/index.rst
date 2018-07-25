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

.. include:: vinyl.rst

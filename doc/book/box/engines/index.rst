:fullwidth:

.. _engines-chapter:

Storage engines
===============

A storage engine is a set of low-level routines which actually store and
retrieve :term:`tuple <tuple>` values. Tarantool offers a choice of two storage engines:

*   :doc:`memtx <memtx>` is the in-memory storage engine used by default.
*   :doc:`vinyl <vinyl>` is the on-disk storage engine.

All the details on the engines you can find in the dedicated sections:

.. toctree::
   :maxdepth: 1

   memtx
   vinyl
   memtx_vinyl_diff

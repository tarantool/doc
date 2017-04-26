.. _index-two_storage_engines:

A storage engine is a set of very-low-level routines which actually store and
retrieve tuple values. Tarantool 1.6.9 has only one storage engine; however,
in a future version there will be a choice of two storage engines:

* memtx (the in-memory storage engine) is the default and was the first to
  arrive.

* vinyl (the on-disk storage engine) is a working key-value engine and will
  especially appeal to users who like to see data go directly to disk, so that
  recovery time might be shorter and database size might be larger. On the other
  hand, vinyl lacks some functions and options that are available with memtx.
  The vinyl storage engine is now working in the latest Tarantool version.

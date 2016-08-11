.. _vinyl_diff:

--------------------------------------------------------------------------------
        Differences between memtx and vinyl storage engines
--------------------------------------------------------------------------------

The primary difference between memtx and vinyl is that memtx is an "in-memory"
engine while vinyl is an "on-disk" engine. An in-memory storage engine is
generally faster, and the memtx engine is justifiably the default for Tarantool,
but there are two situations where an on-disk engine such as vinyl would be
preferable:

1. when the database is larger than the available memory and adding more
   memory is not a realistic option;
2. when the server frequently goes down due to errors or a simple desire to
   save power -- bringing the server back up and restoring a memtx database
   into memory takes time.

Here are behavior differences which affect programmers. All of these differences
have been noted elsewhere in sentences that begin with the words
"Note re storage engine: vinyl".

With memtx, the index type can be TREE or HASH or RTREE or BITSET. |br|
With vinyl, the only index type is TREE.

With memtx, :ref:`create_index <box_space-create_index>` can be done at any time. |br|
With vinyl, secondary indexes must be created before tuples are inserted.

With memtx, for index searches, ``nil`` is considered to be equal to any scalar. |br|
With vinyl, ``nil`` or missing parts are not allowed.

With memtx, temporary spaces are supported. |br|
With vinyl, they are not.

With memtx, the :ref:`alter() <box_index-alter>` and :ref:`len() <box_space-len>`
and :ref:`random() <box_index-random>` and :ref:`auto_increment() <box_space-auto_increment>`
and :ref:`truncate() <box_space-truncate>` functions are supported. |br|
With vinyl, they are not.

With memtx, the :ref:`count() <box_index-count>` function takes a constant
amount of time. |br|
With vinyl, it takes a variable amount of time depending on index size.

With memtx, delete will return deleted tuple, if any. |br|
With vinyl, delete will always return nil.

It was explained :ref:`earlier <index-yields_must_happen>` that memtx does not
"yield" on a select request, it yields only on data-change requests. However,
vinyl does yield on a select request, or on an equivalent such as ``get()`` or
``pairs()``. This has significance for :ref:`cooperative multitasking <atomic-cooperative_multitasking>`.

For more about vinyl, see Appendix D :ref:`vinyl <index-vinyl>`.

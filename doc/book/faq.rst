.. _faq:

-------------------------------------------------------------------------------
FAQ
-------------------------------------------------------------------------------

.. container:: faq

    :Q: Why Tarantool?
    :A: Tarantool is the latest generation of a family of in-memory data servers
        developed for web applications. It is the result of practical experience
        and trials within Mail.Ru since development began in 2008.

    :Q: Why Lua?
    :A: Lua is a lightweight, fast, extensible multi-paradigm language. Lua also
        happens to be very easy to embed. Lua coroutines relate very closely to
        Tarantool fibers, and Lua architecture works well with Tarantool
        internals. Lua acts well as a stored program language for Tarantool,
        although connecting with other languages is also easy.

    :Q: What's the key advantage of Tarantool?
    :A: | Tarantool provides a rich database feature set (HASH, TREE, RTREE,
          BITSET indexes, secondary indexes, composite indexes, transactions,
          triggers, asynchronous replication) in a flexible environment of a
          Lua interpreter.
        | These two properties make it possible to be a fast, atomic and
          reliable in-memory data server which handles non-trivial
          application-specific logic. The advantage over traditional SQL servers
          is in performance: low-overhead, lock-free architecture means
          Tarantool can serve an order of magnitude more requests per second, on
          comparable hardware. The advantage over NoSQL alternatives is in
          flexibility: Lua allows flexible processing of data stored in a
          compact, denormalized format.

    :Q: Who is developing Tarantool?
    :A: There is an engineering team employed by Mail.Ru -- check out our commit
        logs on `github.com/tarantool <http://github.com/tarantool/>`_. The
        development is fully open. Most of the connectors' authors, and the
        maintainers for different distributions, come from the wider community.

    :Q: Are there problems associated with being an in-memory server?
    :A: The principal storage engine (memtx) is designed for RAM plus persistent
        storage. It is immune to data loss because there is a write-ahead log.
        Its memory-allocation and compression techniques ensure there is no
        waste. And if Tarantool runs out of memory, then it will stop accepting
        updates until more memory is available, but will continue to handle read
        and delete requests without difficulty. However, for databases which are
        much larger than the available RAM space, Tarantool has a second storage
        engine (vinyl) which is only limited by the available disk space.

    :Q: Can I store (large) BLOBs in Tarantool?
    :A: Starting with Tarantool 1.7, there is no "hard" limit for the maximal
        tuple size. Tarantool, however, is designed for high-velocity workload
        with a lot of small chunks.
        For example, when you change an existing tuple, Tarantool creates a new
        version of the tuple in memory.
        Thus, an optimal tuple size is within kilobytes.

    :Q: I delete data from vinyl, but disk usage stays the same. What gives?
    :A: Data you write to vinyl is persisted in append-only run files.
        These files are immutable, and to perform a delete, a deletion marker
        (tombstone) is written to a newer run file instead. On compaction,
        new and old run files are merged, and a new run file is produced.
        Independently, the checkpoint manager keeps track of all run files
        involved in a checkpoint, and deletes obsolete files once they are
        no longer needed.

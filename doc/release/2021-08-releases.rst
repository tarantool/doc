Tarantool Releases in August 2021
=================================

Date: 2021-08-19

Introduction
------------

Meet the new Tarantool releases of August 2021:
:tarantool-release:`2.8.2`,
:tarantool-release:`2.7.3`, and :tarantool-release:`1.10.11`.

Automated Raft-based failover out of the box
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Raft-based failover algorithm is now a part of Tarantool, available out of the box.
Use it to improve data safety and reliability of Tarantool applications.

Using interactive transactions with any programming language
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Write applications with interactive transactions in the programming language of your choice.

Interactive transactions are now part of iproto
and can be used by applications in any programming language.

Compatibility
-------------

Tarantool 2.x is backward compatible with Tarantool 1.10.x regarding the binary
data layout, client-server protocol, and replication protocol.

`Upgrade <https://www.tarantool.io/en/doc/latest/book/admin/upgrades/>`__
using the ``box.schema.upgrade()`` procedure to unlock all the new
features of the 2.x series.

Some changes are labeled as **[Breaking change]**. It means that the
old behavior was considered error-prone and therefore changed to protect
users from unintended mistakes. However, there is a small probability
that someone can rely on the old behavior, and this label is to bring
attention to the things that have been changed.

New and updated features
------------------------

Core
~~~~


-   The information about the state of synchronous replication is now available via the
    ``box.info.synchro`` interface (:tarantool-release:`2.7.3`, :tarantool-issue:`5191`).

LuaJIT
~~~~~~

-   Introduced support for ``LJ_DUALNUM`` mode in ``luajit-gdb.py``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6224`).

Lua
~~~

-   Introduced the new method ``table.equals``. It compares two tables by value with
    respect to the ``__eq`` metamethod
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`).

Logging
^^^^^^^

-   The ``log`` module now supports symbolic representation of log levels.
    Now it is possible to specify levels the same way as in
    the ``box.cfg{}`` call
    (:tarantool-release:`2.8.2`, :tarantool-issue:`5882`).

    For example, instead of

    ..  code-block:: lua

        require('log').cfg{level = 6}

    it is possible to use

    ..  code-block:: lua
        
        require('log').cfg{level = 'verbose'}

SQL
~~~

-   Descriptions of type mismatch error and inconsistent type error have
    become more informative
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6176`).

-   Removed explicit cast from ``BOOLEAN`` to numeric types and vice
    versa
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`4770`).

-   Removed explicit cast from ``VARBINARY`` to numeric types and vice
    versa
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`4772`, :tarantool-issue:`5852`).

-   Fixed a bug where a string that is not ``NULL``-terminated
    could not be cast to ``BOOLEAN``, even if the conversion would be
    successful according to the rules
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`).

Build
~~~~~

-   Fedora 34 builds are now supported
    (:tarantool-release:`2.8.2`, :tarantool-issue:`6074`).

-   Fedora 28 and 29 builds are no longer supported.

Bugs fixed
----------

Core
~~~~

-   **[Breaking change]** ``fiber.wakeup()`` in Lua and
    ``fiber_wakeup()`` in C became NOP on the currently running fiber.
    Previously they allowed “ignoring” the next yield or sleep, which
    resulted in unexpected erroneous wake-ups. Calling these functions
    right before ``fiber.create()`` in Lua or ``fiber_start()`` in C
    could lead to a crash (in debug build) or undefined behaviour (in
    release build) (:tarantool-issue:`6043`).
    
    There was a single use case for the previous behaviour: rescheduling
    in the same event loop iteration, which is not the same as
    ``fiber.sleep(0)`` in Lua and ``fiber_sleep(0)`` in C. It could be
    done in the following way:
    
    in C:
    
    ..  code:: c
    
        fiber_wakeup(fiber_self());
        fiber_yield();

    and in Lua:

    ..  code:: lua

        fiber.self():wakeup()
        fiber.yield()

    To get the same effect in C, one can now use ``fiber_reschedule()``.
    In Lua, it is now impossible to reschedule the current fiber directly
    in the same event loop iteration. One can reschedule self
    through a second fiber, but it is strongly discouraged:

    ..  code:: lua
    
        -- do not use this code
        local self = fiber.self()
        fiber.new(function() self:wakeup() end)
        fiber.sleep(0)

-   Fixed memory leak on ``box.on_commit()`` and
    ``box.on_rollback()`` (:tarantool-issue:`6025`).

-   ``fiber_join()`` now checks if the argument is a joinable fiber.
    The absence of this check could lead to unpredictable results. Note that
    the change affects the C level only; in the Lua interface, ``fiber:join()``
    protection is already enabled
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`).

-   Now Tarantool yields when it scans ``.xlog`` files for the latest
    applied vclock and finds the right place to
    start recovering from. It means that the instance becomes responsive
    right after the ``box.cfg`` call even if an empty ``.xlog`` was not
    created on the previous exit.

    This fix also prevents the relay from timing out when a freshly subscribed
    replica needs rows from the end of a relatively long (hundreds of
    MBs) ``.xlog`` file
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5979`).

-   The counter in ``x.yM rows processed`` log messages no longer
    resets on each newly recovered ``xlog``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`).

-   Fixed a crash in JSON update on tuple/space, where the update included
    two or more operations that accessed fields in reversed order and
    these fields didn’t exist. Example:
    ``box.tuple.new({1}):update({{'=', 4, 4}, {'=', 3, 3}})``
    (:tarantool-release:`2.8.2`, :tarantool-issue:`6069`).

-   Fixed invalid results of the ``json`` module’s ``encode``
    function when it was used from the Lua garbage collector. For
    example, this could happen in functions used as ``ffi.gc()``
    (:tarantool-issue:`6050`).

-   Added a check for user input of the number of iproto threads: value
    must be greater than zero and less than or equal to 1000
    (:tarantool-release:`2.8.2`, :tarantool-issue:`6005`).

-   Changing a listed address can no longer cause iproto threads to close
    the same socket several times
    (:tarantool-release:`2.8.2`).

-   Tarantool now always removes the Unix socket correctly when it exits
    (:tarantool-release:`2.8.2`).

-   Simultaneously updating a key in different transactions
    does not longer result in a MVCC crash
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6131`).

-   Fixed a bug where memtx MVCC crashed during reading uncommitted DDL
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5515`).

-   Fixed a bug where memtx MVCC crashed if an index was created in the
    transaction thread
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6137`).

-   Fixed a MVCC segmentation fault that arose
    when updating the entire space concurrently
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5892`).

-   Fixed a bug with failed assertion after a stress update of the same
    key
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6193`).

-   Fixed a crash where ``box.snapshot`` could be called during an incomplete
    transaction
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6229`).

-   Fixed console client connection failure in case of request timeout
    (:tarantool-issue:`6249`).

-   Added a missing broadcast to ``net.box.future:discard()`` so that now
    fibers waiting for a request result wake up when the request is
    discarded (:tarantool-issue:`6250`).

-   ``box.info.uuid``, ``box.info.cluster.uuid``, and
    ``tostring(decimal)`` with any decimal number in Lua could sometimes
    return garbage if there were ``__gc`` handlers in the user’s code
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6259`).

-   Fixed an error message that appeared in a particular case during
    MVCC operation (:tarantool-issue:`6247`).

-   Fixed a repeatable read violation after delete
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6206`).

-   Fixed a bug where the MVCC engine didn't track the ``select{}`` hash
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6040`).

-   Fixed a crash in MVCC after a drop of space with several indexes
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6274`).

-   Fixed a bug where the GC could leave tuples in secondary indexes
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6234`).

-   Disallow yields after DDL operations in MVCC mode. It fixes a crash
    that took place when several transactions referred to system spaces
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5998`).

-   Fixed a bug in MVCC that happened on rollback after a DDL operation
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5998`).

-   Fixed a bug where rollback resulted in unserializable behavior
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6325`).

Vinyl
~~~~~

-   Fixed possible keys divergence during secondary index build, which
    might lead to missing tuples
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6045`).

-   Fixed the race between Vinyl garbage collection and compaction that
    resulted in a broken vylog and recovery failure
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5436`).

Replication
~~~~~~~~~~~

-   Fixed the use after free in the relay thread when using elections
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6031`).

-   Fixed a possible crash when a synchronous transaction was followed by
    an asynchronous transaction right when its confirmation was being
    written
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6057`).

-   Fixed an error where a replica, while attempting to subscribe to a foreign
    cluster with a different replicaset UUID, didn’t notice it is impossible
    and instead became stuck in an infinite retry loop printing
    a ``TOO_EARLY_SUBSCRIBE`` error
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6094`).

-   Fixed an error where a replica, while attempting to join a cluster with
    exclusively read-only replicas available, just booted its own replicaset,
    instead of failing or retrying. Now it fails with
    an error about the other nodes being read-only so they can’t register
    the new replica
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5613`).

-   Fixed error reporting associated with transactions
    received from remote instances via replication.
    Any error raised while such a transaction was being applied was always reported as
    ``Failed to write to disk`` regardless of what really happened. Now the
    correct error is shown. For example, ``Out of memory``, or
    ``Transaction has been aborted by conflict``, and so on
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6027`).

-   Fixed replication occasionally stopping with ``ER_INVALID_MSGPACK``
    when the replica is under high load (:tarantool-issue:`4040`).

-   Fixed a cluster sometimes being unable to bootstrap if it contains
    nodes with ``election_mode`` set to ``manual`` or ``voter``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6018`).

-   Fixed a possible crash when ``box.ctl.promote()`` was called in a
    cluster with more than three instances. The crash happened in the debug build.
    In the release build, it could lead to undefined behaviour. It was likely to happen
    if a new node was added shortly before the promotion
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5430`).

-   Fixed a rare error appearing when MVCC
    (``box.cfg.memtx_use_mvcc_engine``) was enabled and more than one
    replica joined the cluster. The join could fail with the error
    ``"ER_TUPLE_FOUND: Duplicate key exists in unique index 'primary' in space '_cluster'"``.
    The same could happen at the bootstrap of a cluster having more than three nodes
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5601`).

Raft
~~~~

-   Fixed a rare crash with leader election enabled (any mode except
    ``off``), which could happen if a leader resigned from its role while
    another node was writing something elections-related to WAL.
    The crash was in the debug build, and in the release
    build it would lead to undefined behaviour
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6129`).

-   Fixed an error where a new replica in a Raft cluster tried to join
    from a follower instead of a leader and failed with the error
    ``ER_READONLY`` (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6127`).

..  _luajit-1:

LuaJIT
~~~~~~

-   Fixed optimization for single-char strings in the ``IR_BUFPUT`` assembly
    routine.

-   Fixed slots alignment in the ``lj-stack`` command output when ``LJ_GC64``
    is enabled (:tarantool-issue:`5876`).

-   Fixed dummy frame unwinding in the ``lj-stack`` command.

-   Fixed detection of inconsistent renames even in the presence of sunk
    values (:tarantool-issue:`4252`, :tarantool-issue:`5049`, :tarantool-issue:`5118`).

-   Fixed the VM register allocation order provided by LuaJIT frontend in case
    of ``BC_ISGE`` and ``BC_ISGT`` (:tarantool-issue:`6227`).

..  _lua-1:

Lua
~~~

-   When an error occurs during encoding call results, the auxiliary
    lightuserdata value is not removed from the main Lua coroutine stack.
    Before the fix, it led to undefined behaviour during the next
    usage of this Lua coroutine (:tarantool-issue:`4617`).

-   Fixed a Lua C API misuse when the error is raised during call results
    encoding in an unprotected coroutine and expected to be caught in a
    different, protected coroutine (:tarantool-issue:`6248`).

Triggers
^^^^^^^^

-   Fixed a possible crash in case trigger removes itself. Fixed a
    possible crash in case someone destroys a trigger when it
    yields (:tarantool-issue:`6266`).

..  _sql-1:

SQL
~~~

-   User-defined functions can now return a VARBINARY result to SQL
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6024`).

-   Fixed assert when a DOUBLE value greater than -1.0 and less
    than 0.0 is cast to INTEGER and UNSIGNED
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`6225`).

-   Removed spontaneous conversion from INTEGER to DOUBLE in a field of the
    NUMBER type
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5335`).

-   All arithmetic operations can now accept numeric values only
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-issue:`5756`).

MVCC
~~~~

-   Fixed MVCC interaction with ephemeral spaces: TX manager now ignores them
    (:tarantool-release:`2.8.2`, :tarantool-issue:`6095`).

-   Fixed loss of tuples after a conflict exception
    (:tarantool-release:`2.8.2`, :tarantool-issue:`6132`).

-   Fixed a segfault during update/delete of the same tuple
    (:tarantool-release:`2.8.2`, :tarantool-issue:`6021`).

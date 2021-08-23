Tarantool Releases in August 2021
=================================

Date: 2021-08-19

Introduction
------------

Meet the new Tarantool releases in August 2021:
versions :tarantool-release:`2.8.2`,
:tarantool-release:`2.7.3` and :tarantool-release:`1.10.11`.

Automated Raft-based failover out of the box
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Raft-based failover algorithm is now a part of Tarantool, available out of the box.
Use it to improve the data safety and reliability of Tarantool applications.

The ability to use interactive transactions with any programming language
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Write applications with interactive transactions in the programming language of your choice.

Interactive transactions are now a part of iproto,
enabling applications in any programming language to use them.

Compatibility
-------------

Tarantool 2.x is backward compatible with Tarantool 1.10.x in the binary
data layout, client-server protocol, and replication protocol.

`Upgrade <https://www.tarantool.io/en/doc/latest/book/admin/upgrades/>`__
using the ``box.schema.upgrade()`` procedure to unlock all the new
features of the 2.x series.

There are changes labeled with **[Breaking change]**. It means that the
old behavior was considered error-prone and therefore changed to protect
users from unintended mistakes. However, there is a little probability
that someone can lean on the old behavior, and this label is to bring
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

-   The ``log`` module now supports the symbolic representation of log levels.
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

-   Fixed a bug due to which a string that is not ``NULL`` terminated
    could not be cast to ``BOOLEAN``, even if the conversion should be
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
    Previously they allowed to “ignore” the next yield or sleep, which
    resulted in unexpected spurious wake-ups. Calling these functions
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
    In Lua, it is impossible now to reschedule the current fiber directly
    in the same event loop iteration. One can reschedule self
    through a second fiber, but it is strongly discouraged to do so:

    ..  code:: lua
    
        -- do not use this code
        local self = fiber.self()
        fiber.new(function() self:wakeup() end)
        fiber.sleep(0)

-   Fixed memory leak on ``box.on_commit()`` and
    ``box.on_rollback()`` (:tarantool-issue:`6025`).

-   ``fiber_join()`` now checks if the argument is a joinable fiber.
    The absence of this check could lead to unpredictable results. Note that
    the issue affects C level only; in Lua interface ``fiber:join()`` the
    protection already is turned on.

-   Now Tarantool yields when it scans ``.xlog`` files for the latest
    applied vclock and when it finds the right place in ``.xlog``\ s to
    start recovering. It means that the instance becomes responsive
    right after the ``box.cfg`` call even when an empty ``.xlog`` was not
    created on the previous exit.

    This fix also prevents the relay from timing out when a freshly subscribed
    replica needs rows from the end of a relatively long (hundreds of
    MBs) ``.xlog`` (:tarantool-issue:`5979`).

-   The counter in ``x.yM rows processed`` log messages will no longer
    reset on each newly recovered ``xlog``.

-   Fixed a crash in JSON update on tuple/space, where update included
    two or more operations, which accessed fields in reversed order, and
    these fields didn’t exist. Example:
    ``box.tuple.new({1}):update({{'=', 4, 4}, {'=', 3, 3}})`` (:tarantool-issue:`6069`).

-   Fixed invalid results of the ``json`` module’s ``encode``
    function when it was used from the Lua garbage collector. For
    instance, this could happen in functions used as ``ffi.gc()``
    (:tarantool-issue:`6050`).

-   Added a check for user input of the number of iproto threads: value
    must be greater than zero and less than or equal to 1000 (:tarantool-issue:`6005`).

-   Changing a listed address can no longer cause iproto threads to close
    the same socket several times.

-   Tarantool now always removes the Unix socket correctly when it exits.

-   Now simultaneously updating a key in different transactions do not result in a crash in MVCC
    (:tarantool-issue:`6131`).

-   Fixed a bug when memtx MVCC crashed during reading uncommitted DDL
    (:tarantool-issue:`5515`).

-   Fixed a bug when memtx MVCC crashed if an index was created in
    transaction (:tarantool-issue:`6137`).

-   Fixed segmentation fault with MVCC when the entire space was updated
    concurrently (:tarantool-issue:`5892`).

-   Fixed a bug with failed assertion after the stress update of the same
    key (:tarantool-issue:`6193`).

-   Fixed a crash if ``box.snapshot` is called during an incomplete
    transaction (:tarantool-issue:`6229`).

-   Fixed console client connection breakage if request timed out
    (:tarantool-issue:`6249`).

-   Added missing broadcast to ``net.box.future:discard()`` so that now
    fibers waiting for a request result are woken up when the request is
    discarded (:tarantool-issue:`6250`).

-   ``box.info.uuid``, ``box.info.cluster.uuid``, and
    ``tostring(decimal)`` with any decimal number in Lua sometimes could
    return garbage if ``__gc`` handlers are used in the user’s code
    (:tarantool-issue:`6259`).

-   Fixed an error message that happened in a particular case during
    MVCC operation (:tarantool-issue:`6247`).

-   Fixed a repeatable read violation after delete (:tarantool-issue:`6206`).

-   Fixed a bug when the MVCC engine didn't track hash ``select{}``
    (:tarantool-issue:`6040`).

-   Fixed a crash in MVCC after a drop of space with several indexes
    (:tarantool-issue:`6274`).

-   Fixed a bug when GC at some state could leave tuples in secondary
    indexes (:tarantool-issue:`6234`).

-   Disallow yields after DDL operations in MVCC mode. It fixes crash
    which takes place when several transactions refer to system spaces
    (:tarantool-issue:`5998`).

-   Fixed bug in MVCC connected which happens on rollback after DDL
    operation (:tarantool-issue:`5998`).

-   Fixed a bug when rollback resulted in unserializable behaviour
    (:tarantool-issue:`6325`).

Vinyl
~~~~~

-   Fixed possible keys divergence during secondary index build which
    might lead to missing tuples in it (:tarantool-issue:`6045`).

-   Fixed a race between Vinyl garbage collection and compaction
    resulting in broken vylog and recovery (:tarantool-issue:`5436`).

Replication
~~~~~~~~~~~

-   Fixed use after free in relay thread when using elections (:tarantool-issue:`6031`).

-   Fixed a possible crash when a synchronous transaction was followed by
    an asynchronous transaction right when its confirmation was being
    written (:tarantool-issue:`6057`).

-   Fixed an error when a replica, at attempt to subscribe to a foreign
    cluster (with different replicaset UUID), didn’t notice it is impossible,
    and instead was stuck in an infinite retry loop printing
    a ``too earle subscribe`` error (:tarantool-issue:`6094`).

-   Fixed an error when a replica, at attempt to join a cluster with
    exclusively read-only replicas available, just booted its own replicaset,
    instead of failing or retrying. Now it fails with
    an error about the other nodes being read-only so they can’t register
    it (:tarantool-issue:`5613`).

-   If an error occurred during the appliance of a transaction received
    from a remote instance via replication, it was always reported as
    ``Failed to write to disk`` regardless of what really happened. Now the
    correct error is shown. For example, ``Out of memory``, or
    ``Transaction has been aborted by conflict``, and so on (:tarantool-issue:`6027`).

-   Fixed replication occasionally stopping with ``ER_INVALID_MSGPACK``
    when the replica is under high load (:tarantool-issue:`4040`).

-   Fixed a cluster sometimes being unable to bootstrap if it contains
    nodes with ``election_mode`` ``manual`` or ``voter`` (:tarantool-issue:`6018`).

-   Fixed a possible crash when ``box.ctl.promote()`` was called in a
    cluster with more than three instances, happened in debug build. In release
    build, it could lead to undefined behaviour. It was likely to happen
    if a new node was added shortly before the promotion (:tarantool-issue:`5430`).

-   Fixed a rare error appearing when MVCC
    (``box.cfg.memtx_use_mvcc_engine``) was enabled, and more than one
    replica joined the cluster. The join could fail with the error
    ``"ER_TUPLE_FOUND: Duplicate key exists in unique index   'primary' in space '_cluster'"``.
    The same could happen at the bootstrap of a cluster having more than three nodes
    (:tarantool-issue:`5601`).

Raft
~~~~

-   Fixed a rare crash with the leader election enabled (any mode except
    ``off``), which could happen if a leader resigned from its role at
    the same time as some other node was writing something related to the
    elections to WAL. The crash was in debug build, and in the release
    build it would lead to undefined behaviour (:tarantool-issue:`6129`).

-   Fixed an error when a new replica in a Raft cluster tried to join
    from a follower instead of a leader and failed with an error
    ``ER_READONLY`` (:tarantool-issue:`6127`).

..  _luajit-1:

LuaJIT
~~~~~~

-   Fixed optimization for single-char strings in ``IR_BUFPUT`` assembly
    routine.

-   Fixed slots alignment in ``lj-stack`` command output when ``LJ_GC64``
    is enabled (:tarantool-issue:`5876`).

-   Fixed dummy frame unwinding in ``lj-stack`` command.

-   Fixed detection of inconsistent renames even in the presence of sunk
    values (:tarantool-issue:`4252`, :tarantool-issue:`5049`, :tarantool-issue:`5118`).

-   Fixed the order VM registers are allocated by LuaJIT frontend in case
    of ``BC_ISGE`` and ``BC_ISGT`` (:tarantool-issue:`6227`).

..  _lua-1:

Lua
~~~

-   When an error occurs during encoding call results, the auxiliary
    lightuserdata value is not removed from the main Lua coroutine stack.
    Before the fix, it led to undefined behaviour during the next
    usage of this Lua coroutine (:tarantool-issue:`4617`).

-   Fixed Lua C API misuse when the error is raised during call results
    encoding on unprotected coroutine and expected to be caught on the
    different one that is protected (:tarantool-issue:`6248`).

Triggers
^^^^^^^^

-   Fixed possible crash in case trigger removes itself. Fixed
    possible crash in case someone destroys trigger when it’s
    yield (:tarantool-issue:`6266`).

..  _sql-1:

SQL
~~~

-   User-defined functions can now return VARBINARY to SQL as a result
    (:tarantool-issue:`6024`).

-   Fixed assert on a cast of DOUBLE value greater than -1.0 and less
    than 0.0 to INTEGER and UNSIGNED (:tarantool-issue:`6255`).

-   Removed spontaneous conversion from INTEGER to DOUBLE in a field of
    NUMBER type (:tarantool-issue:`5335`).

-   All arithmetic operations can now only accept numeric values
    (:tarantool-issue:`5756`).

MVCC
~~~~

-   Fixed MVCC interaction with ephemeral spaces: TX manager now ignores
    them (:tarantool-issue:`6095`).

-   Fixed a loss of tuple after a conflict exception (:tarantool-issue:`6132`).

-   Fixed a segfault in update/delete of the same tuple (:tarantool-issue:`6021`).

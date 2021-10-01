Tarantool Releases in August 2021
=================================

Date: 2021-08-19

Introduction
------------

Meet the new Tarantool releases of August 2021:
:tarantool-release:`2.8.2`,
:tarantool-release:`2.7.3`,
:tarantool-release:`1.10.11`.

Also, check the new Tarantool beta release of August 2021:
:tarantool-release:`2.10.0-beta1`.

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

Some changes are labeled as **[Breaking change]**.
It means that the old behavior was considered error-prone
and therefore changed to protect users from unintended mistakes.
However, there is a small probability that someone can rely on the old behavior,
and this label is to bring attention to the things that have been changed.

New and updated features
------------------------

Core
~~~~


-   The information about the state of synchronous replication is now available via the
    ``box.info.synchro`` interface
    (:tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5191`).

-   The UUID field type is now part of the ``SCALAR`` field type
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6042`).

-   The ``UUID`` field type is now available in SQL. A new UUID can be generated
    using the new SQL built-in function ``UUID()``
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5886`).

-   **[Breaking change]** The ``timeout()`` method of the ``net.box`` connection,
    marked deprecated more than four years ago (in ``1.7.4``), has been dropped.
    It negatively affected the performance of hot ``net.box`` methods, such as ``call()`` and ``select()``
    if they were called without a specified timeout
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6242`).

-   Improved ``net.box`` performance by up to 70% by rewriting hot code paths in C
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6241`).

-   Introduced compact tuples that allow saving 4 bytes per tuple in case of small userdata
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5385`)

-   Now streams and interactive transactions over streams are implemented in iproto.
    Every stream is associated with its ID, which is unique within one connection.
    All requests with the same non-zero stream ID belong to the same stream.
    All requests in the stream are processed synchronously.
    The next request will not start executing until the previous one is completed.
    If a request's stream ID is ``0``, it does not belong to any stream and is processed in the old way.

    In ``net.box``, a stream is an object above the connection that has the same methods
    but allows executing requests sequentially. The ID is generated on the client side automatically.
    If a user writes their own connector and wants to use streams, they must transmit the ``stream_id`` over the iproto protocol.

    The primary purpose of streams is transactions via iproto.
    As each stream can start a transaction, several transactions can be multiplexed over one connection.
    There are multiple ways to begin, commit, and rollback a transaction.
    One can do that using the appropriate stream methods, ``call``, ``eval``,
    or ``execute`` with the SQL transaction syntax. Users can mix these methods.
    For example, one might start a transaction using ``stream:begin()``,
    and commit it with ``stream:call('box.commit')`` or ``stream:execute('COMMIT')``.
    If any request fails during the transaction, it will not affect the other requests in the transaction.
    If a disconnect occurs while there is an active transaction in the stream,
    that transaction will be rolled back if it hasn't been committed before the connection failure.

-   Added the new ``memtx_allocator`` option to ``box.cfg{}``.
    It allows selecting an appropriate allocator for memtx tuples if necessary.
    The possible values are ``system`` for the malloc allocator and ``small`` for the default small allocator.

    Implemented the system allocator based on malloc. The slab allocator, which is used for tuple allocation,
    has a particular disadvantage---it is prone to unresolvable fragmentation on specific workloads (size migration).
    In this case, the user should be able to choose another allocator.
    The system allocator is based on the malloc function but restricted by the same quota as the slab allocator.
    The system allocator does not alloc all the memory at the start. Instead, it allocates memory as needed,
    checking that the quota is not exceeded
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5419`).

Replication
~~~~~~~~~~~

-   Introduced the ``box.info.replication[n].downstream.lag`` field to monitor the state of replication.
    This represents the lag between the moment when the main node writes a certain transaction to its WAL
    and the moment it receives an ack for this transaction from the replica
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5447`).

-   Introduced ``on_election`` triggers. The triggers can be registered via the ``box.ctl.on_election()`` interface
    and run asynchronously each time ``box.info.election`` changes
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5819`).


LuaJIT
~~~~~~

-   Introduced support for ``LJ_DUALNUM`` mode in ``luajit-gdb.py``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6224`).

-   Introduced preliminary support of GNU/Linux ARM64 and MacOS M1 (:tarantool-release:`2.10.0-beta1`).
    In the scope of this activity, the following issues have been resolved:

    *   Introduced support for the full 64-bit range of lightuserdata values (:tarantool-issue:`2712`).

    *   Fixed memory remapping issue when the page left 47-bit segments (:tarantool-issue:`2712`).

    *   Fixed M1 architecture detection (:tarantool-issue:`6065`).

    *   Fixed variadic arguments handling in FFI on M1 (:tarantool-issue:`6066`).

    *   Fixed ``table.move`` misbehaviour in case of table reallocation (:tarantool-issue:`6084`).

    *   Fixed Lua stack inconsistency when ``xpcall`` is called on ARM64 with the invalid second argument
        (:tarantool-issue:`6093`).

    *   Fixed ``BC_USETS`` bytecode semantics for closed upvalues and gray strings.

    *   Fixed side exit jump target patching with regard to the range values of a particular instruction
        (:tarantool-issue:`6098`).

    *   Fixed the issue on ARM64 where the current Lua coroutine wasn't restored on the exception path
        (:tarantool-issue:`6189`).

Lua
~~~

-   Introduced the new method ``table.equals``. It compares two tables by value with
    respect to the ``__eq`` metamethod
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`).

Digest
~~~~~~

-   Introduced new hash types---``xxhash32`` and ``xxhash64``---in the digest module.
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`2003`).

Fiber
~~~~~

-   Introduced ``fiber_object:info()`` to get info from a fiber.
    Works as ``require(fiber).info()`` but only for one fiber
    (:tarantool-release:`2.10.0-beta1`).

-   Introduced ``fiber_object:csw()`` to get ``csw`` from a fiber.
    Also, now ``csw`` (Context SWitch) of the new fiber is always equal to zero.
    Previously, it could be greater than zero
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5799`).

-   Changed ``fiber.info()`` to hide backtraces of idle fibers
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`4235`).

Logging
~~~~~~~

-   The ``log`` module now supports symbolic representation of log levels.
    Now it is possible to specify levels the same way as in
    the ``box.cfg{}`` call
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5882`).

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
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6176`).

-   Removed explicit cast from ``BOOLEAN`` to numeric types and vice
    versa
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`4770`).

    For example, ``CAST(FALSE AS INTEGER)`` was ``0`` in version 2.8.
    Now it causes an error.

-   Removed explicit cast from ``VARBINARY`` to numeric types and vice
    versa
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`4772`, :tarantool-issue:`5852`).

-   Fixed a bug where a string that is not ``NULL``-terminated
    could not be cast to ``BOOLEAN``, even if the conversion would be
    successful according to the rules
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.10.0-beta1`, :tarantool-release:`2.7.3`).

-   Now a numeric value can be cast to another numeric type only if the cast is precise.
    In addition, a ``UUID`` value cannot be implicitly cast to ``STRING/VARBINARY``.
    Also, a ``STRING/VARBINARY`` value cannot be implicitly cast to a ``UUID``
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`4470`).

-   Now any number can be compared to any other number, and values of any scalar type
    can be compared to any other value of the same type.
    A value of a non-numeric scalar type cannot be compared with a value of any other scalar type
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`4230`).

-   Removed SQL built-in functions from the ``_func`` system space
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6106`).

-   The function is now looked up first in SQL built-in functions and then in user-defined functions
    (:tarantool-release:`2.10.0-beta1`).

-   Fixed incorrect error message in case of misuse of the function setting the default value
    (:tarantool-release:`2.10.0-beta1`).

-   The ``TYPEOF()`` function with ``NULL`` as an argument now returns ``NULL``
    if the type cannot be determined from context.
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5956`).
    Also, ``TYPEOF(-NaN)`` will now return ``DOUBLE``,
    and ``TYPEOF(map_column)`` will now return ``VARBINARY`` instead of ``map``.

    For example, ``SELECT TYPEOF(NULL)`` was ``BOOLEAN`` in version 2.8.
    Now it is ``NULL``.

-   Reworked the ``SCALAR`` and ``NUMBER`` types in SQL.
    Removed the implicit cast from ``SCALAR`` to any other scalar type.
    Also, removed the implicit cast from ``NUMBER`` values to any other numeric type.
    It means that arithmetic and bitwise operations and concatenation are no longer allowed
    for ``SCALAR`` and ``NUMBER`` values. In addition, any ``SCALAR`` value can now be compared with values
    of any other scalar type using the ``SCALAR`` rules
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6221`).

-   The field type ``DECIMAL`` is now available in SQL.
    Added an implicit cast from ``INTEGER`` and ``DOUBLE`` to ``DECIMAL`` and vice versa.
    ``DECIMAL`` can participate in arithmetic operations and comparisons with other defined numeric types
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`4415`).

-   **[Breaking change]** The argument types of SQL built-in functions are now checked in most cases during parsing.
    In addition, the number of arguments is now always checked during parsing
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6105`).

-   **[Breaking change]** for the ``NUMBER`` data type  (:tarantool-release:`2.10.0-beta1`).
    Arithmetic (``+ * - / % & | ~``) operations and bit-shift operations (``>> <<``) are now illegal.

    For example, ``SELECT number_column + 1`` was legal in version 2.8.
    Now it causes an error.

-   **[Breaking change]** for the ``SCALAR`` data type  (:tarantool-release:`2.10.0-beta1`).
    Arithmetic (``+ * - / % & | ~``) operations and bit-shift operations (``>> <<``) are now illegal.
    Concatenation (``||``) operations are now illegal.
    Values in ``SCALAR`` columns now have data type ``SCALAR``, not the value's data type.

    For example, ``TYPEOF(CAST(1 AS SCALAR))`` was ``INTEGER`` in version 2.8.
    Now it is ``SCALAR``.

-   **[Breaking change]**: Arithmetic operators must now have numeric operands.
    String operands are illegal.

    For example, ``SELECT 1 + '1'`` was ``2`` in version 2.8.
    Now it causes an error.

-   **[Breaking change]** in operations on SCALAR columns.
    Since the type of a value no longer determines whether an operation is valid,
    comparisons and functions that require a specific type no longer work.

    For example, table ``T`` has only one row with a scalar column containing ``'a'``.
    ``UPPER(scalar_column)`` was ``'A'`` in version 2.8.
    Now it causes an error.


-   **[Breaking change]** for the ``HEX()`` function (:tarantool-release:`2.10.0-beta1`).
    ``STRING`` arguments are no longer acceptable; only ``VARBINARY`` arguments are allowed.

    For example, ``HEX('a')`` was ``'41'`` in version 2.8.
    Now it causes an error.

-   **[Breaking change]** for the ``POSITION()`` function (:tarantool-release:`2.10.0-beta1`).
    ``VARBINARY`` arguments are no longer acceptable; only ``STRING`` arguments are allowed.

    For example, ``POSITION(X'41',X'41')`` was ``1`` in version 2.8.
    Now it causes an error.


Luarocks
~~~~~~~~

-   Set ``FORCE_CONFIG=false`` for luarocks config to allow loading project-side ``.rocks/config-5.1.lua``
    (:tarantool-release:`2.10.0-beta1`).

Build
~~~~~

-   Fedora 34 builds are now supported
    (:tarantool-release:`2.8.2`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6074`).

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
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.10.0-beta1`, :tarantool-release:`2.7.3`).

-   Now Tarantool yields when it scans ``.xlog`` files for the latest
    applied vclock and finds the right place to
    start recovering from. It means that the instance becomes responsive
    right after the ``box.cfg`` call even if an empty ``.xlog`` was not
    created on the previous exit.

    This fix also prevents the relay from timing out when a freshly subscribed
    replica needs rows from the end of a relatively long (hundreds of
    MBs) ``.xlog`` file
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5979`).

-   The counter in ``N rows processed`` log messages no longer
    resets on each newly recovered ``xlog``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`).

-   Fixed wrong type specification when printing fiber state change.
    It could lead to negative fiber IDs in the logs
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5846`).

    For example,

    ..  code-block:: none

        main/-244760339/cartridge.failover.task I> Instance state changed

    instead of proper

    ..  code-block:: none

        main/4050206957/cartridge.failover.task I> Instance state changed


-   Fiber IDs are now switched to monotonically increasing unsigned 8-byte integers, so
    there is no ID wrapping anymore. It allows detecting fiber precedence by ID
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5846`).

-   Fixed a crash in JSON update on tuple/space, where the update included
    two or more operations that accessed fields in reversed order and
    these fields didn’t exist. Example:
    ``box.tuple.new({1}):update({{'=', 4, 4}, {'=', 3, 3}})``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6069`).

-   Fixed invalid results of the ``json`` module’s ``encode``
    function when it was used from the Lua garbage collector. For
    example, this could happen in functions used as ``ffi.gc()``
    (:tarantool-issue:`6050`).

-   Added a check for user input of the number of iproto threads: value
    must be greater than zero and less than or equal to 1000
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6005`).

-   Changing a listed address can no longer cause iproto threads to close
    the same socket several times
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.10.0-beta1`)

-   Tarantool now always removes the Unix socket correctly when it exits
    (:tarantool-release:`2.8.2`).

-   Simultaneously updating a key in different transactions
    does not longer result in a MVCC crash
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6131`).

-   Fixed a bug where memtx MVCC crashed during reading uncommitted DDL
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5515`).

-   Fixed a bug where memtx MVCC crashed if an index was created in the
    transaction thread
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6137`).

-   Fixed a MVCC segmentation fault that arose
    when updating the entire space concurrently
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5892`).

-   Fixed a bug with failed assertion after a stress update of the same
    key
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6193`).

-   Fixed a crash where ``box.snapshot`` could be called during an incomplete
    transaction
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6229`).

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
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6206`).

-   Fixed a bug where the MVCC engine didn't track the ``select{}`` hash
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6040`).

-   Fixed a crash in MVCC after a drop of space with several indexes
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6274`).

-   Fixed a bug where the GC could leave tuples in secondary indexes
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6234`).

-   Disallow yields after DDL operations in MVCC mode. It fixes a crash
    that took place when several transactions referred to system spaces
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5998`).

-   Fixed a bug in MVCC that happened on rollback after a DDL operation
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5998`).

-   Fixed a bug where rollback resulted in unserializable behavior
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`, :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6325`).

Vinyl
~~~~~

-   Fixed possible keys divergence during secondary index build, which
    might lead to missing tuples
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6045`).

-   Fixed the race between Vinyl garbage collection and compaction that
    resulted in a broken vylog and recovery failure
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5436`).

Replication
~~~~~~~~~~~

-   Fixed the use after free in the relay thread when using elections
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6031`).

-   Fixed a possible crash when a synchronous transaction was followed by
    an asynchronous transaction right when its confirmation was being
    written
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6057`).

-   Fixed an error where a replica, while attempting to subscribe to a foreign
    cluster with a different replicaset UUID, didn’t notice it is impossible
    and instead became stuck in an infinite retry loop printing
    a ``TOO_EARLY_SUBSCRIBE`` error
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6094`).

-   Fixed an error where a replica, while attempting to join a cluster with
    exclusively read-only replicas available, just booted its own replicaset,
    instead of failing or retrying. Now it fails with
    an error about the other nodes being read-only so they can’t register
    the new replica
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5613`).

-   Fixed error reporting associated with transactions
    received from remote instances via replication.
    Any error raised while such a transaction was being applied was always reported as
    ``Failed to write to disk`` regardless of what really happened. Now the
    correct error is shown. For example, ``Out of memory``, or
    ``Transaction has been aborted by conflict``, and so on
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6027`).

-   Fixed replication occasionally stopping with ``ER_INVALID_MSGPACK``
    when the replica is under high load (:tarantool-issue:`4040`).

-   Fixed a cluster sometimes being unable to bootstrap if it contains
    nodes with ``election_mode`` set to ``manual`` or ``voter``
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6018`).

-   Fixed a possible crash when ``box.ctl.promote()`` was called in a
    cluster with more than three instances. The crash happened in the debug build.
    In the release build, it could lead to undefined behaviour. It was likely to happen
    if a new node was added shortly before the promotion
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5430`).

-   Fixed a rare error appearing when MVCC
    (``box.cfg.memtx_use_mvcc_engine``) was enabled and more than one
    replica joined the cluster. The join could fail with the error
    ``"ER_TUPLE_FOUND: Duplicate key exists in unique index 'primary' in space '_cluster'"``.
    The same could happen at the bootstrap of a cluster having more than three nodes
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5601`).

Raft
~~~~

-   Fixed a rare crash with leader election enabled (any mode except
    ``off``), which could happen if a leader resigned from its role while
    another node was writing something elections-related to WAL.
    The crash was in the debug build, and in the release
    build it would lead to undefined behaviour
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6129`).

-   Fixed an error where a new replica in a Raft cluster tried to join
    from a follower instead of a leader and failed with the error
    ``ER_READONLY`` (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6127`).

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

Lua
~~~

-   Fixed a bug where multibyte characters broke ``space:fselect()`` output
    (:tarantool-release:`2.10.0-beta1`).

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

SQL
~~~

-   User-defined functions can now return a VARBINARY result to SQL
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6024`).

-   Fixed assert when a DOUBLE value greater than -1.0 and less
    than 0.0 is cast to INTEGER and UNSIGNED
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6225`).

-   Removed spontaneous conversion from INTEGER to DOUBLE in a field of the
    NUMBER type
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5335`).

-   All arithmetic operations can now accept numeric values only
    (:tarantool-release:`2.8.2`, :tarantool-release:`2.7.3`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`5756`).

-   Now ``QUOTE()`` returns the argument if the argument is DOUBLE, which is the same behavior as
    with other numeric types.
    For types different from numeric, the function returns a STRING
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6239`).

-   The ``TRIM()`` function now does not lose collation
    when executed with the keywords BOTH, LEADING, or TRAILING
    (:tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6299`).

MVCC
~~~~

-   Fixed MVCC interaction with ephemeral spaces: TX manager now ignores them
    (:tarantool-release:`2.8.2`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6095`).

-   Fixed loss of tuples after a conflict exception
    (:tarantool-release:`2.8.2`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6132`).

-   Fixed a segfault during update/delete of the same tuple
    (:tarantool-release:`2.8.2`,
    :tarantool-release:`2.10.0-beta1`, :tarantool-issue:`6021`).


Compatibility guarantees
========================

Backwards compatibility is guaranteed between all versions in the same :term:`release series`.
It is also appreciated but not guaranteed between different release series (major number changes).

*   Pre-releases and releases of one release series are compatible in all
    senses defined below (any release with any release).

*   Pre-releases and releases of consequent series are compatible by data
    layout, binary protocol and replication protocol.

*   No guarantees are given regarding compatibility between
    pre-releases/releases of non-consequent release series if the opposite
    is not stated in the :ref:`release notes <release_notes>`.

*   No guarantees are given regarding compatibility between alpha/beta
    versions and between alpha/beta and pre-release/release even within one series.

Binary data layout
------------------

A newer release (its runtime) is backward compatible with an older one.
It means a more recent release should work on top of data
(``*.xlog``, ``*.snap``, ``*.vylog``, ``*.run``) from the older one.
All functionality of the older release is working in this configuration.
It should work between :term:`release series` as well.

An attempt to use a new feature results in one of these options:

*   The attempt is successful.

*   There is a meaningful error about the old data layout until the database schema upgrade.
    It does not lead to a service outage or data corruption.
    An instance can upgrade the data layout using the :ref:`box.schema.upgrade() <admin-upgrades>` call
    to enable all new release features (when all instances of the replicaset are run on the same Tarantool version).

Binary protocol
---------------

The binary protocol evolves without breaking compatibility with old clients.
All binary protocol requests operational in an older release should work on a newer one.
They do not change the meaning.
Responses have the same format, but mappings may contain fields not present in the older release.

``net.box`` client of the older release is able to work
with the newer one, except the features introduced in the newer release.
``net.box`` client of the newer release is fully operational with the server
running under the older one, except the features not implemented in the older release.

Replication protocol
--------------------

An instance run on a newer release may work as:

*   upstream (master) of an instance with an older release

*   downstream (replica) without a database schema upgrade.

The database schema upgrade (``box.schema.upgrade()``) must be performed when all replicaset instances
run on the same Tarantool version.
The upgrade does not cause downtime if the application does not lean on internal schema representation.

Lua code
--------

If a code is run on an older release, it will operate with the same effect on a
newer one. However, only meaningful code counts.
If any code throws an error but starts doing something useful, the change is considered compatible.

A room for new functionality is still here: adding new options, more
fields to a returning table, and more returning values (multireturn).

Adding a new built-in module or a new global value is considered as the compatible change.

Adding a new field to an existing metatable is okay if it is not listed in the Lua 5.1 Reference Manual. Otherwise, it should be proven that it may not break any meaningful code.

Examples of compatible changes:

*   Add ``__pairs``, ``__ipairs`` to a metatable of a userdata.
    It is not from Lua 5.1, and the userdata has no default behaviour for ``pairs()`` and `ipairs()` calls.

*   Add ``__lt``, ``__le`` metamethod
    (if the attempt to use ``<``, ``<=`` and so on leads to an error before the change).

Examples of NOT compatible changes:

*   Add ``__pairs``, ``__ipairs`` to a metatable of a table or cdata
    (it already has its own behavior before the change).

*   Add ``__eq`` metamethod (``==`` already returns some result`).

SQL code
--------

If any request is run with the same effect, the change is
compatible (except the requests that always lead to an error).

Examples of compatible changes:

*   Add a new keyword.
*   Add a new type.
*   Add a new built-in function.
*   Add a new system table that starts from underscore.
*   Add a new collation.
*   Add an implicit or explicit cast rule for a set of operations {X} and a list
    of types [Y] if [operation from {X}]([list of values of [Y] types]) had no
    meaning before the change.

Technically, those changes may break a working code in case of a name clash,
but the probability of it is negligible.

Examples of NOT compatible changes:

*   Change how data is stored in the database.
*   Change the result of working implicit or explicit cast.
*   Change of a literal type.

C code
------

If a module or a C stored procedure is run on an older release,
it will operate with the same effect on a newer one.

It is okay to add a new function or structure to the public C API.
It must use one of the Tarantool prefixes (``box_``, ``fiber_``, ``luaT_``, ``luaM_`` and so on) or introduce a new one.

A symbol from a used library must not be exported directly
because the library may be used in a module by itself, and the clash can lead to problems.
Exception: when the whole public API of the library is exported (as for libcurl).

Do not introduce new functions or structures with the ``lua_`` and ``luaL_`` prefixes.
Those prefixes are for the Lua runtime.
Use ``luaT_`` for Tarantool specific functions, and ``luaM_`` for general-purpose ones.


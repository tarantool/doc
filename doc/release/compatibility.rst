..  _compatibility_guarantees:

Compatibility guarantees
========================

Backwards compatibility is guaranteed between all versions in the same :term:`release series`.
It is also appreciated but not guaranteed between different release series (major number changes).
Pre-releases and releases of one release series are compatible in all
senses defined below (any release with any release):

*   Pre-releases and releases of consequent series are compatible by data
    layout, binary protocol, and replication protocol.

*   No guarantees are given regarding compatibility between
    pre-releases/releases of non-consequent release series if the opposite
    is not stated in the :doc:`release notes <notes>`.

*   No guarantees are given regarding compatibility between alpha/beta
    versions and between alpha/beta and pre-release/release even within one series.

..  _cg_data_layout:

Binary data layout
------------------

Any newer release (its runtime) is backward compatible with any older one.
It means the more recent release can work on top of data
(``*.xlog``, ``*.snap``, ``*.vylog``, ``*.run``) from the older one.
All functionality of the older release can work in this configuration.
The same compatibility is maintained between :term:`release series` as well.

An attempt to use a new feature results in one of the options:

*   The attempt is successful.

*   There is an error message about the old data layout.
    The error does not lead to service outage or data corruption.
    There is a way to avoid the message, if an instance upgrades the data layout
    by calling the :ref:`box.schema.upgrade() <admin-upgrades>`. The call enables
    all new release features (when all instances of the replicaset are processed on the same Tarantool version).

..  _cg_binary_protocol:

Binary protocol
---------------

All binary protocol requests operational in an older release keep working in a newer one.
Responses have the same format, but mappings may contain fields not present in the older release.

A ``net.box`` client of an older release can work
with a server running a newer release. However, ``net.box`` features introduced in the newer release won't work.
A ``net.box`` client of a newer release is fully operational with a server
running a older release. However, only the features implemented in the older release will work.

..  _cg_replication_protocol:

Replication protocol
--------------------

An instance running on a newer release can work as:

*   upstream (master) of an instance with an older release

*   downstream (replica) without database schema upgrade.

The database schema upgrade (``box.schema.upgrade()``) must be performed when all replicaset instances
run on the same Tarantool version.
An application should not lean on internal schema representation because it can be changed with the upgrade.

..  _cg_lua_code:

Lua code
--------

If a code is processed on an older release, it will operate with the same effect on a
newer one. However, only meaningful code counts.
If any code throws an error but starts doing something useful, the change is considered compatible.

There is still room for new functionality: adding new options (fields in a table argument),
new arguments to the end, more fields to a return table, and more return values (multireturn).

Adding a new built-in module or a new global value is considered as a compatible change.

Adding a new field to an existing metatable is okay if the field is not listed
in the `Lua 5.1 Reference Manual <https://www.lua.org/manual/5.1/>`_.
Otherwise, it should be proven that it won't break any meaningful code.

Examples of compatible changes:

*   Add ``__pairs``, ``__ipairs`` to a metatable of a userdata/cdata object.
    The fields are not from Lua 5.1, and the userdata/cdata has no default behaviour
    for ``pairs()`` and ``ipairs()`` calls.

*   Add or extend the ``__lt`` or ``__le`` metamethod
    (if the attempt to use ``<``, ``<=`` etc. leads to an error before the change).

*   Extend existing ``__eq`` metamethod implementation
    (if the attempt to use it leads to an error before the change).

Examples of **incompatible** changes:

*   Add ``__pairs``, ``__ipairs`` to a metatable of a table
    (it already has a defined behavior before the change).

*   Add the ``__eq`` metamethod (any pair of Lua objects already has a defined behavior).


..  _cg_sql_code:

SQL code
--------

If any request is processed on an older release, it will operate with the same effect on a
newer one (except the requests that always lead to an error).

Examples of compatible changes:

*   Add a new keyword.
*   Add a new type.
*   Add a new built-in function.
*   Add a new system table that has a name starting with an underscore.
*   Add a new collation.
*   Add an implicit or explicit cast rule for a set of operations {X} and a list
    of types [Y] if [operation from {X}]([list of values of [Y] types]) had not been
    implemented before the change.
*   Change the order of tuples in the result set of ``SELECT`` in case ``ORDER BY`` is not specified.

Technically, those changes may break some working code in case of a name clash,
but the probability of it is negligible.

Examples of **incompatible** changes:

*   Change the result of working implicit or explicit cast.
*   Change of a literal type.

..  _cg_c_code:

C code
------

If a module or a C stored procedure runs on an older release,
it will operate with the same effect on a newer one.

It is okay to add a new function or structure to the public C API.
It must use one of the Tarantool prefixes (``box_``, ``fiber_``, ``luaT_``, ``luaM_`` and so on) or some new prefix.

A symbol from a used library must not be exported directly
because the library may be used in a module by itself, and the clash can lead to problems.
Exception: when the whole public API of the library is exported (as for libcurl).

Do not introduce new functions or structures with the ``lua_`` and ``luaL_`` prefixes.
Those prefixes are for the Lua runtime.
Use ``luaT_`` for Tarantool-specific functions, and ``luaM_`` for general-purpose ones.


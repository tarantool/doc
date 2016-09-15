--------------------------------------------------------------------------------
Appendix B. Version-specific changes
--------------------------------------------------------------------------------

This appendix summarizes significant changes introduced in specific versions of
Tarantool.

For smaller feature changes and bug fixes, see closed
`milestones <https://github.com/tarantool/tarantool/milestones?state=closed>`_
at GitHub.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Changes in Tarantool version 1.7
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The disk-based storge engine, which was called `sophia` or `phia`
in earlier versions, is superseded by the `vinyl` storage engine.

There are new types for indexed fields.

The LuaJIT version is updated.

Automatic replication cluster bootstrap (to make it easier
to configure a new replication cluster) is supported.

The ``space_object:inc()`` function is removed.

The ``space_object:dec()`` function is removed.








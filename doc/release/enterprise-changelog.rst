..  _release-enterprise-changelog:

Enterprise SDK changelog
========================

Versioning policy
-----------------

A :ref:`Tarantool Enterprise SDK <tarantool_enterprise>` version consists of two parts:

..  code-block:: text

    <TARANTOOL_BASE_VERSION>-r<REVISION>


For example: ``2.11.1-0-gc42d9735b-r589``.

-   ``TARANTOOL_BASE_VERSION`` is the Enterprise version.
-   ``REVISION`` is the SDK revision. Besides Tarantool itself, it includes the ``tt`` utility, a set of open and closed source modules, and examples. Learn more from :ref:`Package contents <enterprise-package-contents>`.


r710
----

metrics 1.7.0 -> 1.8.1
~~~~~~~~~~~~~~~~~~~~~~

This release adds selector-based filtering for custom metrics.
Custom metrics can now be associated with hierarchical selectors and controlled via ``metrics.set_filter()`` or ``metrics.cfg()`` include/exclude options.
Unknown include/exclude entries are treated as custom selectors, while built-in metric group names keep the existing behavior.

**Added:**

* ``metrics.namespace()`` and ``metrics.set_filter()`` to mark custom collectors/callbacks with selectors and filter them at collection time.

**Fixed:**

* ``metrics.cfg{exclude = {'all'}}`` so it excludes custom metric selectors in addition to built-in metric groups.


r709
----

cartridge 2.16.7 -> 2.17.1
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Added:**

* Support for Tarantool ``election_mode = 'manual'`` in Cartridge stateful
  failover, including single-instance replicasets.
* Added runtime Lua API helpers:

  * ``require('cartridge.lua-api.failover').switch_to_manual_election_mode()``
  * ``require('cartridge.lua-api.failover').switch_to_off_election_mode()``

  to migrate a stateful replicaset between Tarantool
  ``election_mode = 'off'`` and ``election_mode = 'manual'``.
* `Documentation <https://www.tarantool.io/en/doc/2.11/book/cartridge/cartridge_dev/#failover-architecture>`__ for migrating a stateful replicaset to Tarantool manual
  election mode, including restart-based migration, runtime helpers, rollback,
  and fencing recommendations.

**Changed:**

* Updated ``vshard`` dependency to ``0.1.41``.


**Fixed:**

* A race condition during instance shutdown where ``membership.leave()``
  could execute before roles were stopped, causing errors.
* When ``box.ctl.promote()`` returns ``ER_INTERFERING_PROMOTE`` during failover,
  retry promotion 3 times with a 1 second delay so the new master will not be
  stuck in read-only mode.
* A stateful failover race when adding a brand new replicaset: if the
  state provider has no appointment yet for this replicaset, ``failover.cfg()``
  now falls back to ``topology.get_leaders_order(...)[1]``
  (``failover_priority[1]``) for the initial appointment. This prevents the
  future leader from being switched to ``read_only=true`` and avoids deadlock
  during topology apply.


tt-ee 2.12.0 -> 2.13.0
~~~~~~~~~~~~~~~~~~~~~~

This release adds cluster worker configuration management and fixes incorrect
error reporting in ``tt start`` when directory permissions are insufficient.

**Added:**

* ``tt cluster worker publish``: publish (upload) a worker configuration to etcd or Tarantool-based configuration storage.
* ``tt cluster worker show``: display a worker configuration stored in etcd or Tarantool-based configuration storage.
* ``tt cluster worker delete``: delete a worker configuration from etcd or Tarantool-based configuration storage.

**Fixed:**

* ``tt start``: fixed a bug where an error did not appear when access rights to
  the ``var`` directive were insufficient.


vshard 0.1.40 -> 0.1.41
~~~~~~~~~~~~~~~~~~~~~~~~

VShard 0.1.41 is fully compatible with the previous VShard versions.

**Added:**

* A new storage configuration option: ``rebalancer_bucket_send_timeout``. It specifies the timeout in seconds for sending a single bucket during rebalancing.
  This can be used to limit how long a bucket may be unavailable for writes while it is being sent.

**Changed:**

* Improved rebalancer bucket selection: the rebalancer now prefers buckets that have no active RW requests on top of them.

**Fixed:**

* An issue where duplicated active buckets could appear due to delayed stray TCP `#214 <https://github.com/tarantool/vshard/issues/214>`__.
* An issue where RW requests could break replication after a master switch during rebalancing `#573 <https://github.com/tarantool/vshard/issues/573>`__.
* An issue where master switches during rebalancing could lead to duplicated active buckets `#576 <https://github.com/tarantool/vshard/issues/576>`__.


r708
----

This release updates the platform’s key dependencies: Tarantool 2.11.9, a bugfix release of the 2.11 branch focused on
improving stability and predictability. It also improves diagnostics and error handling for WAL failures, fixes hangs and
WAL maintenance issues in Core, and delivers a large set of fixes in LuaJIT and the Datetime module. In addition, major
ecosystem components (``crud``, ``vshard``, ``metrics``, ``tt-ee``, ``cartridge``, ``http``) have been updated and refined,
including safer behavior during rebalancing, fault-tolerant reads, and changes to HTTP TLS/mTLS configuration.

Tarantool 2.11.8 -> 2.11.9
~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a bugfix release: 34 issues have been fixed since 2.11.8 (r702).

* The 2.x series is the previous stable branch; upgrading to 3.x is recommended.
* To upgrade from Tarantool 2.x to 3.x, see the `upgrade procedure <https://www.tarantool.io/en/doc/latest/admin/upgrades/upgrade_cluster/#admin-upgrades-replication-cluster>`__.

When upgrading the SDK, it is recommended to:

* before starting the upgrade, ensure that all replica sets are healthy and in a consistent state;
* perform the upgrade sequentially, verifying the cluster state after upgrading each component;
* do not run data rebalancing while passing through CRUD 1.7.0 until the upgrade is fully completed.

Core
^^^^

**Added:**

* A new built-in system event ``box.wal_error`` that is emitted every time Tarantool fails to commit a transaction to the write-ahead log (WAL) (`gh-9405 <https://github.com/tarantool/tarantool/issues/9405>`__).

**Fixed:**

* An issue where SSL errors were logged incorrectly when a client connection was closed.
* A bug that could cause Tarantool to hang when using ``box.watch`` (`gh-9632 <https://github.com/tarantool/tarantool/issues/9632>`__).
* A bug where ``.xlog.inprogress`` files were not removed automatically on server startup when ``wal_dir`` was set and differed from the default (`gh-12081 <https://github.com/tarantool/tarantool/issues/12081>`__).
* A bug where a local space could not be truncated if the ``_truncate`` space was configured as synchronous (`gh-12585 <https://github.com/tarantool/tarantool/issues/12585>`__).

Leader election
^^^^^^^^^^^^^^^

* If an ``ER_WAL_IO`` error occurs while writing to WAL, the current leader steps down immediately on the first such error.

LuaJIT
^^^^^^

**Added:**

* Support for ``ffi.abi("dualnum")`` to detect LuaJIT mode (dual-number: distinguishing int64 integers from double).
* New flags ``misc.memprof.available`` and ``misc.sysprof.available`` to detect whether the corresponding profiler is available in the current build.
  See `LuaJIT memory profiler <https://www.tarantool.io/en/doc/latest/tooling/luajit_memprof/>`__ and `LuaJIT platform profiler <https://www.tarantool.io/en/doc/latest/tooling/luajit_sysprof/>`__ for details.

**Fixed:**

* Incorrect ``IR_TBAR`` generation on aarch64.
* Stack overflow handling when exiting a trace.
* Dangling references to ``CType``.
* VM state shutdown after early OOM.
* ``IR_MUL`` generation on x86/x64.
* Incorrect merging of ``stp``/``ldp`` instructions on aarch64.
* SCEV record invalidation when returning to a lower frame.
* Build on macOS 15 / Clang 16.
* ``IR_HREFK`` generation on aarch64.
* Stack checks in varargs calls in GC64 builds.
* Stack checks in ``pcall()``/``xpcall()`` in GC64 builds.
* Allocation limit in non-JIT builds.
* OOM handling when growing the stack in ``coroutine.resume()`` and ``lua_checkstack()``.
* Recording loops with step ``-0`` or control values ``NaN``.
* Error message generation when an error occurs while handling another error.
* Dangling reference for an FFI callback.
* ``BC_UNM`` for argument ``-0`` in ``dual-number`` mode.
* Unary minus narrowing in ``dual-number`` mode.
* Recording of ``string.byte()``, ``string.sub()``, and ``string.find()``.
* Missing type conversion for ``BC_FORI`` slots in ``dual-number`` mode.
* Various corner cases in ``VM events``.
* Recording of constructor index resolution in the JIT compiler.
* UBSan warning in ``unpack()``.

Datetime module
^^^^^^^^^^^^^^^

**Fixed:**

* A crash due to an ``assert`` when parsing an ambiguous date: when the input contains both the day of year (``yday``, which implicitly defines month and day of month) and a calendar month (without day of month). Such cases are now detected and reported as an error.
* ``tzoffset`` calculations for cases like ``new({timestamp=x, tz='Zone'})``.
* An inconsistency between dates created with ``new({tzoffset=x})`` and ``d:set({tzoffset=x})`` when ``d.tz ~= ''`` precedes ``set()``.
* ``datetime.new()`` and ``datetime_object:set()`` now validate that ``timestamp`` is within the allowed range.
* ``timestamp`` type checking in ``set()``.

For backward compatibility, the option ``compat.datetime_setfn_timestamp_type_check`` has been added. It is disabled by default (the “old” behavior), meaning no type check is performed. The “new” behavior with type checking is planned to become the default in 4.x.

..  note::

    The modules listed below have changes in this release.
    If a module is not listed, it was not updated.

crud 1.6.1 -> 1.7.5
~~~~~~~~~~~~~~~~~~~

..  note::

    Starting with CRUD 1.6.0, a vulnerability that allowed performing operations without sufficient privileges has been fixed.
    CRUD now strictly enforces access rights: a user can perform only the actions allowed by their privileges.
    If the application needs access to service spaces, the corresponding privileges must be granted explicitly.

    See details in :ref:`Reading and writing data with CRUD <authentication-users_minimal_priv-crud_read_write>`.

    Safe mode and rolling-upgrade compatibility details are described in
    :ref:`Upgrading the crud module <admin-upgrades-crud>` (see :ref:`Compatibility limitation during upgrade <admin-upgrades-crud-safe-mode>` and :ref:`Upgrade order <admin-upgrades-crud-order>`).

**Added:**

* ``crud.locate()`` to determine where a tuple is stored (memtx or vinyl). Works for spaces managed by the enterprise module ``cooler``.
* ``crud.len`` now supports options: ``mode``, ``balance``, ``prefer_replica``, ``request_timeout``.
* Safe mode to prevent writing data to the wrong replica set during vshard rebalancing.
* Metric ``tnt_crud_router_cache_clear_ts`` to help properly disable safe mode in a cluster.
* Automatic switch to safe mode when rebalancing starts.
* Ability to manually switch back to fast mode (``fast mode``).
* Metric ``tnt_crud_storage_nil_bucket_id_compat_total`` to track operations performed without ``bucket_ref`` (compatibility mode with older routers).

**Fixed:**

* Read-only operations (``get``, ``select``, ``pairs``, ``count``, ``min``, ``max``) are now executed via healthy replicas even if all master nodes in the cluster are unavailable.
* Storage compatibility with routers < 1.7.0: ``bucket_id = nil`` is now handled correctly in ``get``, ``update``, and ``delete``. In this case, storage skips bucket referencing and logs a rate-limited warning about reduced rebalancing safety during rolling upgrades.
* ``bucket_ref`` errors in ``crud.*_many`` methods are now returned as an array.
* ``bucket_unref`` was moved out of the transaction.
* Prevented duplicate metrics from being created on repeated ``init`` calls.
* Prevented duplicate triggers on the ``_crud_settings_local`` space on repeated ``init`` calls.
* A deadlock in ``crud.schema()`` after a schema reload error.
* Removed metric ``tnt_crud_storage_safe_mode_enabled`` from the router.
* Removed ``wrap_box_space_func_result`` wrapper to reduce allocations and speed up storage calls.
* Optimize ``crud.select()`` and ``crud.pairs()`` pagination with ``after`` cursor by using native ``after`` option on Tarantool 2.10+ for O(1) cursor positioning.

**Changed:**

* When switching to safe mode, the practice of marking/stopping iproto fibers in fast mode was discontinued; operation correctness on storage is validated via ``yield_checks`` in tests.
* Switching to safe mode was moved from the ``on_commit`` trigger to ``on_replace``.
* Vinyl spaces always operate in safe mode.

vshard 0.1.37 -> 0.1.40
~~~~~~~~~~~~~~~~~~~~~~~

Version 0.1.40 is fully compatible with previous vshard versions.

**Added:**

* Ability to disable the log rate limiter via the ``consts`` module.
* Calling ``vshard.router.info()`` and ``vshard.storage.info()`` is now allowed even when the router or storage is disabled. The functions now also return a new boolean field: ``is_enabled``.
* Improved logging for rebalancer and recovery related activities.

**Fixed:**

* An issue where the old master node could not discover the new master instance within a replica set.
* Connection leak: connections were not released by the garbage collector after reconfiguration or reload.
* Transaction limitation when working with ``_bucket``: previously, the ``on_commit`` trigger on ``_bucket`` blocked writes to other spaces within the same transaction (for example, from ``on_replace`` triggers).
  Such scenarios are now allowed: ``on_commit`` skips changes related to “foreign” spaces.
* An issue where a user error was masked by the ``Transaction is active...`` error when calling a persistent function that throws an error and does not close a transaction on Tarantool versions earlier than 3.0.0-beta1-18.
  Now, vshard automatically closes such transactions and returns the original user error.
* An issue where a connection to a replica was not automatically restored when it was closed either by vshard or by the user.

metrics 1.6.2 -> 1.7.0
~~~~~~~~~~~~~~~~~~~~~~

* ``graphite``: added support for sending metrics to multiple servers.
* Removing a replica via ``box.space._cluster:delete()`` does not remove that replica’s information from metrics; it disappears only after a cluster restart.
* Backward compatibility with the previous plugin version is preserved.
* Behavior changes:

  - ``init`` now assigns a unique name to the created ``fiber`` based on the input ``graphite server`` options (if provided).
  - Added ``stop()`` to stop all ``fibers`` started by the plugin.

tt-ee v2.11.0 -> v2.12.0
~~~~~~~~~~~~~~~~~~~~~~~~

**Added:**

* ``tt pack``: added support for nested ``.packignore`` files in the root of a tt environment.
* ``tt status``: added the ``--format`` option to output status in JSON and YAML formats (machine-readable output).

**Changed:**

* ``tt export``: changed the default behavior for compound fields (arrays and maps): they are now exported in JSON format by default. To restore the previous behavior, use ``--compound-value-format=ignore``.

**Fixed:**

* Integrity checking for an application using the Cartridge directory layout (a single application whose root directory is the environment root).
* An issue with Tarantool 3.5+: the instance did not stop when the periodic integrity check failed.
* Minor fixes identified by the Svacer static analyzer and CVE scanners.

cartridge 2.16.4 -> 2.16.7
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Changed:**

* Do not expand the file tree by default on the code page.
* Update vshard dependency to 0.1.40.
* Update membership dependency to 2.5.3.
* Update cartridge-metrics-role dependency to 0.1.3.
* Update graphql dependency to 0.3.1.
* Update http dependency to 1.9.0.

**Fixed:**

* Refactor synchronous spaces monitoring to consider the actual failover mode.
  Sync spaces warning is now logged when failover is configured in a mode that doesn't support them (eventual, stateful without ``synchro_mode``), instead of unconditionally at instance startup.
* Added ``is_sync_spaces_supported()`` function to ``cartridge.failover module``.
* Sync spaces are now detected dynamically, allowing detection of spaces added at runtime.


http 1.8.0 -> 1.9.0
~~~~~~~~~~~~~~~~~~~

The release introduces a new ``ssl_verify_client`` option and changes default behavior with provided ``ca_file`` parameter.
Also a few bugs were fixed.

**Added:**

* New ``ssl_verify_client`` option.

**Fixed:**

* Do not recreate server if it's address and port were not changed.
* Server doesn't change after updating parameters on config reload.

**Breaking change:**

Mutual TLS with ``ca_file`` option enabled by default.

:ref:`Module http <http-module>` documentation.

r703
----

-   Bumped ``checks`` version to 3.4.0.
-   Bumped Cartridge version to `2.16.4 <https://github.com/tarantool/cartridge/releases/tag/2.16.4>`__.
-   Bumped ``vshard`` version to `0.1.37 <https://github.com/tarantool/vshard/releases/tag/0.1.37>`__.

r702
----

-   Bumped ``tarantool-2.11`` series to 2.11.8.

r696
----
-   Moved CI files from ``sdk-ci`` repository.

r695
----

-   Bumped ``tt-ee`` version to v2.11.0.

r694
----

-   Replaced Cartridge EE with Cartridge CE `2.16.3 <https://github.com/tarantool/cartridge/releases/tag/2.16.3>`__.
-   Added CRUD CE `1.6.1 <https://github.com/tarantool/crud/releases/tag/1.6.1>`__.
-   Added  ``expirationd`` CE `1.7.0 <https://github.com/tarantool/expirationd/releases/tag/1.7.0>`__.
-   Added ``ddl`` CE `1.7.1 <https://github.com/tarantool/ddl/releases/tag/1.7.1>`__.
-   Bumped ``metrics`` version to `1.5.0 <https://github.com/tarantool/metrics/releases/tag/1.5.0>`__.
-   Added ``migrations`` CE `1.1.0 <https://github.com/tarantool/migrations/releases/tag/1.1.0>`__.
-   Added ``vshard`` CE `0.1.36 <https://github.com/tarantool/vshard/releases/tag/0.1.36>`__.
-   Moved to Community Edition modules.

r693
----

-   Fixed ``glibc`` package URL to archived.

r692
----

-   Added manual trigger job to run tests to generate ``certificate of compliance``. Ready for Astra Linux.

r691
----

-   Bumped Cartridge version to `2.16.2 <https://github.com/tarantool/cartridge/releases/tag/2.16.2>`__.
-   Bumped ``metrics`` version to `1.4.0 <https://github.com/tarantool/metrics/releases/tag/1.4.0>`__.
-   Bumped ``http`` version to 1.8.0.
-   Bumped ``crud-ee`` version to 1.7.4.

r690
----

-   Bumped ``tt-ee`` version to v2.10.1.

r689
----

-   Bumped Cartridge version to `2.16.0 <https://github.com/tarantool/cartridge/releases/tag/2.16.0>`__.

r688
----

-   Bumped ``vshard-ee`` version to 0.1.34.

r687
----

-   Bumped Cartridge version to `2.15.4 <https://github.com/tarantool/cartridge/releases/tag/2.15.4>`__.

r686
----

-   Bumped ``tt-ee`` version to v2.10.0.

r685
----

-   Bumped ``migrations-ee`` version to 1.3.2.

r684
----

-   Bumped ``tarantool-2.11`` series to 2.11.7.

r683
----

-   Bumped Kafka version to `1.6.10 <https://github.com/tarantool/kafka/releases/tag/1.6.10>`__.

r682
----

-   Bumped Cartridge version to `2.15.3 <https://github.com/tarantool/cartridge/releases/tag/2.15.3>`__.

r681
----

-   Bumped ``vshard-ee`` version to 0.1.33.

r680
----

-   Bumped ``tt-ee`` version to v2.9.1.

r679
----

-   Bumped ``tt-ee`` version to v2.9.0.
-   Bumped Cartridge version to `2.15.2 <https://github.com/tarantool/cartridge/releases/tag/2.15.2>`__.
-   Bumped ``membership`` version to `2.5.2 <https://github.com/tarantool/membership/releases/tag/2.5.2>`__.

r677
----

-   Bumped Cartridge version to `2.15.1 <https://github.com/tarantool/cartridge/releases/tag/2.15.1>`__.
-   Bumped ``tt-ee`` version to v2.8.1.
-   Bumped ``vshard-ee`` version to 0.1.32.

r673
----

-   Bumped Cartridge version to `2.15.0 <https://github.com/tarantool/cartridge/releases/tag/2.15.0>`__.
-   Bumped ``membership`` version to 2.5.1.
-   Bumped ``expirationd-ee`` version to 1.8.0.

r672
----

-   Bumped ``tarantool-2.11`` series to 2.11.6.
-   Bumped ``tt-ee`` version to v2.8.0.
-   Bumped ``migrations-ee`` version to 1.3.1.

r669
----

-   Bumped Cartridge version to `2.14.0 <https://github.com/tarantool/cartridge/releases/tag/2.14.0>`__.
-   Bumped ``membership`` version to `2.4.6 <https://github.com/tarantool/membership/releases/tag/2.4.6>`__.

r662
----

-   Bumped ``vshard-ee`` version to 0.1.31.
-   Bumped ``tt-ee`` version to v2.7.0.

r660
----

-   Bumped ``tt-ee`` version to v2.6.0.
-   Bumped Cartridge version to `2.13.0 <https://github.com/tarantool/cartridge/releases/tag/2.13.0>`__.
-   Bumped ``vshard`` version to `0.1.30 <https://github.com/tarantool/vshard/releases/tag/0.1.30>`__.
-   Bumped ``http`` version to `1.7.0 <https://github.com/tarantool/http/releases/tag/1.7.0>`__.

r659
----

-   Bumped ``tarantool-2.11`` series to 2.11.5.
-   Bumped ``tt-ee`` version to v2.5.2.
-   Updated Kafka to `1.6.9 <https://github.com/tarantool/kafka/releases/tag/1.6.9>`__.
-   Bumped ``tt-ee`` version to v2.5.1.
-   Bumped ``tt-ee`` version to v2.5.0.

r654
----

-   Moved ``cartridge-auth-extension`` to **stable** directory.
-   Bumped ``crud-ee`` version to 1.7.1.
-   Bumped ``migrations-ee`` version to 1.3.0.

r653
----

-   Bumped Cartridge version to `2.12.4 <https://github.com/tarantool/cartridge/releases/tag/2.12.4>`__.
-   Bumped ``vshard`` version to `0.1.29 <https://github.com/tarantool/vshard/releases/tag/0.1.29>`__.
-   Bumped ``http`` version to `1.6.0 <https://github.com/tarantool/http/releases/tag/1.6.0>`__.

r652
----

-   Bumped ``tarantool-2.11`` series to 2.11.4.
-   Bumped Cartridge version to `2.12.3 <https://github.com/tarantool/cartridge/releases/tag/2.12.3>`__.

r650
----

-   Bumped ``tt-ee`` version to v2.4.0.
-   Bumped ``queue`` version to `1.4.2 <https://github.com/tarantool/queue/releases/tag/1.4.2>`__.
-   Added Migration Guide to bundle.

r647
----

-   Updated Oracle to 1.5.0 for x86_64.
-   Updated ``oci`` to 21.14 for x86_64.

r646
----

-   Moved to Enterprise Edition modules.
-   Fixed Docker image due to CentOS 7 EOL.
-   Fixed CI/CD workflows running inside CentOS 7.

r643
----

-   Bumped ``tt-ee`` version to v2.3.1.
-   Enabled ``tt`` bash completion.
-   Updated Kafka to `1.6.8 <https://github.com/tarantool/kafka/releases/tag/1.6.8>`__.

r640
----

-   Updated Docker image.
-   Updated CMake to 3.20.6.
-   Installed dependencies for building OpenSSL.
-   Fixed installation of Python 3.6.

r639
----

-   Enabled back ``aarch64`` jobs.
-   Temporary disabled ``aarch64`` jobs.

r637
----

-   Updated ``metrics`` to `1.1.0 <https://github.com/tarantool/metrics/releases/tag/1.1.0>`__.
-   Updated ``queue`` to `1.4.1 <https://github.com/tarantool/queue/releases/tag/1.4.1>`__.
-   Updated CRUD to `1.5.2 <https://github.com/tarantool/crud/releases/tag/1.5.2>`__.

r636
----

-   Updated Cartridge to `2.11.0 <https://github.com/tarantool/cartridge/releases/tag/2.11.0>`__.
-   Updated ``ddl`` to `1.7.1 <https://github.com/tarantool/ddl/releases/tag/1.7.1>`__.
-   Updated ``vshard`` to `0.1.27 <https://github.com/tarantool/vshard/releases/tag/0.1.27>`__.

r635
----

-   Adjusted CI workflows for ``1.x-2.x`` development branch.
-   Deleted ``tarantool-master`` submodule.

r633
----

-   Updated CRUD to `1.5.1 <https://github.com/tarantool/crud/releases/tag/1.5.1>`__.
-   Updated ``sideservice`` to 0.2.1.
-   Updated ``httpgo`` to 0.2.2.
-   Updated ``httpgo-crud`` to 0.1.1.

r632
----

-   Updated ``cartridge-cli`` to `2.12.12 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.12>`__.
-   ``tt`` used instead of ``tarantoolctl`` for build/test routines.
-   Made Tarantool and bundle versions correct.
-   Bumped ``tarantool-2.11`` to 2.11.3.

r628
----

-   Updated Cartridge to `2.10.0  <https://github.com/tarantool/cartridge/releases/tag/2.10.0>`__.
-   Updated ``membership`` to `2.4.4  <https://github.com/tarantool/membership/releases/tag/2.4.4>`__.
-   Updated ``ddl`` to `1.7.0  <https://github.com/tarantool/ddl/releases/tag/1.7.0>`__.
-   Updated ``graphqlapi`` to `0.0.11 <https://github.com/tarantool/graphqlapi/releases/tag/0.0.11>`__.

r627
----

-   Updated ``expirationd`` to `1.6.0 <https://github.com/tarantool/expirationd/releases/tag/1.6.0>`__.
-   Updated ``sharded-queue`` to `1.0.0 <https://github.com/tarantool/sharded-queue/releases/tag/1.0.0>`__.
-   Dropped building MacOS bundles.
-   Updated ``cartridge-cli`` to `2.12.11 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.11>`__.

r623
----

-   Updated ``tt-ee`` to 2.2.1.
-   Updated CRUD to `1.5.0 <https://github.com/tarantool/crud/releases/tag/1.5.0>`__.
-   Updated ``membership`` to `2.4.3 <https://github.com/tarantool/membership/releases/tag/2.4.3>`__.
-   Updated Cartridge to `2.9.0 <https://github.com/tarantool/cartridge/releases/tag/2.9.0>`__.

r619
----

-   Updated bundle ``tt-ee`` aarch64.
-   Updated ``tt-ee`` to 2.2.0.
-   Fixed running Tarantool tests on RED OS.

r616
----

-   Updated CRUD to `1.4.3 <https://github.com/tarantool/crud/releases/tag/1.4.3>`__.
-   Updated ``luatest`` to `1.0.1 <https://github.com/tarantool/luatest/releases/tag/1.0.1>`__.
-   Updated ``migrations`` to `0.7.0 <https://github.com/tarantool/migrations/releases/tag/0.7.0>`__.
-   Updated ``tt-ee`` to 2.1.2.

r613
----

-   Updated Cartridge to `2.8.5 <https://github.com/tarantool/cartridge/releases/tag/2.8.5>`__.
-   Updated CRUD to `1.4.2 <https://github.com/tarantool/crud/releases/tag/1.4.2>`__.
-   Added ``frontend-core`` `8.2.2 <https://github.com/tarantool/frontend-core/releases/tag/8.2.2>`__.
-   Updated ``membership`` to `2.4.2 <https://github.com/tarantool/membership/releases/tag/2.4.2>`__.
-   Updated ``sideservice`` to 0.2.0.
-   Updated ``tt-ee`` to 2.1.1.
-   Updated ``vshard`` to `0.1.26 <https://github.com/tarantool/vshard/releases/tag/0.1.26>`__.

r609
----

-   Updated ``httpgo`` to 0.2.1.
-   Added ``httpgo-crud`` 0.1.0.
-   Updated ``tarantool-2.11`` to 2.11.2.

r606
----

-   Updated ``tarantool-master`` to ``3.0.0-beta1``.

r605
----

-   Updated Cartridge to `2.8.4 <https://github.com/tarantool/cartridge/releases/tag/2.8.4>`__.
-   Updated CRUD to `1.4.1 <https://github.com/tarantool/crud/releases/tag/1.4.1>`__.
-   Updated ``ddl`` to `1.6.5 <https://github.com/tarantool/ddl/releases/tag/1.6.5>`__.
-   Added ``httpgo`` 0.2.0.
-   Updated ``tt-ee`` to 2.0.0.

r598
----

-   Updated ``cartridge-cli`` to `2.12.9 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.7>`__.
-   Updated ``tt-ee`` to 1.3.1.

r595
----

-   Updated ``tt-ee`` to 1.3.0.
-   Updated Cartridge to `2.8.3 <https://github.com/tarantool/cartridge/releases/tag/2.8.3>`__.
-   Updated ``cartridge-cli-extensions`` to `1.1.2 <https://github.com/tarantool/cartridge-cli-extensions/releases/tag/1.1.2>`__.
-   Updated CRUD to `1.3.0 <https://github.com/tarantool/crud/releases/tag/1.3.0>`__.
-   Updated ``queue`` to `1.3.3 <https://github.com/tarantool/queue/releases/tag/1.3.3>`__.
-   Updated ``sharded-queue`` to `0.1.1 <https://github.com/tarantool/sharded-queue/releases/tag/0.1.1>`__.
-   Updated ``membership`` to `2.4.1 <https://github.com/tarantool/membership/releases/tag/2.4.1>`__.
-   Added tests for Astra Linux 1.7.


r589
----

-   Updated ``tarantool-2.10`` to 2.10.8.
-   Updated ``tarantool-master`` to ``3.0.0-alpha3``.
-   Updated ``migrations`` to 0.6.0.
-   Updated ``tt-ee`` to 1.2.0.
-   Updated ``space-explorer`` to 1.1.8.
-   Updated ``cartridge-metrics-role`` to `0.1.1 <https://github.com/tarantool/cartridge-metrics-role/releases/tag/0.1.1>`__.
-   Updated Cartridge to `2.8.2 <https://github.com/tarantool/cartridge/releases/tag/2.8.2>`__.
-   Updated ``expirationd`` to `1.5.0 <https://github.com/tarantool/expirationd/releases/tag/1.5.0>`__.
-   Added ``sideservice`` 0.1.0.

r579
----

-   Updated ``cartridge-cli`` to `2.12.7 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.7>`__.
-   Updated ``tarantool-2.11`` to 2.11.1.

r577
----

-   Added CRUD `1.2.0 <https://github.com/tarantool/crud/releases/tag/1.2.0>`__.
-   Added ``ddl`` `1.6.3 <https://github.com/tarantool/ddl/releases/tag/1.6.3>`__.
-   Added ``sharded-queue`` `0.1.0 <https://github.com/tarantool/sharded-queue/releases/tag/0.1.0>`__.
-   Added ``ddl`` `1.6.4 <https://github.com/tarantool/ddl/releases/tag/1.6.4>`__.
-   Updated ``tt-ee`` to 1.1.2.
-   Updated ``cartridge-cli`` to `2.12.6 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.6>`__.

r563
----

-   Updated ``tarantool-2.10`` to 2.10.7.
-   Updated ``tarantool-2.11`` to 2.11.0.
-   Added Kafka `1.6.6 <https://github.com/tarantool/kafka/releases/tag/1.6.6>`__.
-   Added ``vshard`` `0.1.24 <https://github.com/tarantool/vshard/releases/tag/0.1.24>`__.
-   Added ``metrics`` `1.0.0 <https://github.com/tarantool/metrics/releases/tag/1.0.0>`__.
-   Added ``cartridge-metrics-role`` `0.1.0 <https://github.com/tarantool/cartridge-metrics-role/releases/tag/0.1.0>`__.
-   Added Cartridge `2.8.0 <https://github.com/tarantool/cartridge/releases/tag/2.8.0>`__.
-   Added ``http`` `1.5.0 <https://github.com/tarantool/http/releases/tag/1.5.0>`__.

r557
----

-   Added checks `3.3.0 <https://github.com/tarantool/checks/releases/tag/3.3.0>`__.
-   Updated ``cartridge-cli`` to `2.12.5 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.5>`__.

r553
----

-   Added ``tt-ee`` and ``tt`` environment configuration.
-   Added CRUD `1.1.1 <https://github.com/tarantool/crud/releases/tag/1.1.1>`__.
-   Added ``avro-schema`` `3.1.1 <https://github.com/tarantool/avro-schema/releases/tag/3.1.0>`__.
-   Added ``expirationd`` `1.4.0 <https://github.com/tarantool/expirationd/releases/tag/1.4.0>`__.
-   Added ``graphql`` `0.3.0 <https://github.com/tarantool/graphql/releases/tag/0.3.0>`__.
-   Added ``graphqlapi`` `0.0.10 <https://github.com/tarantool/graphqlapi/releases/tag/0.0.10>`__.
-   Added ``metrics`` `0.17.0 <https://github.com/tarantool/metrics/releases/tag/0.17.0>`__.
-   Added ``migrations`` `0.5.0 <https://github.com/tarantool/migrations/releases/tag/0.5.0>`__.
-   Added Oracle 1.4.0.
-   Added Cartridge `2.7.9 <https://github.com/tarantool/cartridge/releases/tag/2.7.9>`__.
-   Added ``vshard`` `0.1.23 <https://github.com/tarantool/vshard/releases/tag/0.1.23>`__.
-   Added Kafka `1.6.5 <https://github.com/tarantool/kafka/releases/tag/1.6.5>`__.

r549
----

-   Updated ``tarantool-2.10`` to 2.10.6.

r545
----

-   Updated ``tarantool-2.11`` to 2.11.0-rc2.

r543
----

-   Added the ``tarantool-2.11`` submodule.

r542
----

-   Updated ``tarantool-1.10`` to 1.10.15.

r541
----

-   Updated ``tarantool-master`` to ``3.0.0-entrypoint``.

r540
----

-   Updated ``tarantool-2.10`` to 2.10.5.

r539
----

-   Added ``vshard`` `0.1.22 <https://github.com/tarantool/vshard/releases/tag/0.1.22>`__.

r538
----

-   Updated ``tarantool-2.8`` to apply 2 hotfixes.

r537
----

-   Fixed non-interactive installation of the ``brew`` package.
-   Changed the owner of the ``/usr/local/bin`` directory.
-   Installed ``awscli@1`` instead of ``awscli`` since it takes much less
    time.

r536
----

-   Added the missing property ``2.10`` for scope ``CACHE`` in ``CMakeLists.txt``.

r535
----

-   Added ``expirationd`` `1.3.1 <https://github.com/tarantool/expirationd/releases/tag/1.3.1>`__.

r534
----

-   Added CRUD `1.0.0 <https://github.com/tarantool/crud/releases/tag/1.0.0>`__.

r533
----

-   Used runners with label ``regular`` for builds and the tagged release
    workflow.

r532
----

-   Added ``http`` `1.4.0 <https://github.com/tarantool/http/releases/tag/1.4.0>`__.
-   Added ``space-explorer`` 1.1.7.
-   Added ``checks`` `3.2.0 <https://github.com/tarantool/checks/releases/tag/3.2.0>`__.
-   Added ``metrics`` `0.16.0 <https://github.com/tarantool/metrics/releases/tag/0.16.0>`__.
-   Added Cartridge `2.7.8 <https://github.com/tarantool/cartridge/releases/tag/2.7.8>`__.

r531
----

-   Added the ``-DENABLE_LTO=ON``  flag for ``tarantool-ee@master`` branch to
    CMakeLists.txt.

r530
----

-   Upgraded ``devtoolset`` from 8 to 9. It was required for upgrading ``ld`` from
    2.30 to 2.31+ for LTO.


r529
----

-  Updated tarantool’s ``master`` branch to a recent revision.

r528
----

-  Fixed code style in the Linux and MacOS workflows.

r527
----

-  Reliably installed packages in MacOS builds.

r526
----

-   Refactored the way that GC64 builds are defined in the build workflow.
    There are no changes to the composition of resulting bundles.

r525
----

-   Added alerting failures in builds on stable branches and integration testing
    to VK Teams chats.

r524
----

-   Updated to fresh tarantool master (``2.11.0-entrypoint-107-ga18449d``)

r523
----

-   Added Cartridge `2.7.7 <https://github.com/tarantool/cartridge/releases/tag/2.7.7>`__.

r522
----

-   Outdated workflow runs are now canceled to save CI time.

r521
----

-   Added CRUD `0.14.1 <https://github.com/tarantool/crud/releases/tag/0.14.1>`__.
-   Added ``expirationd`` `1.3.0 <https://github.com/tarantool/expirationd/releases/tag/1.3.0>`__.
-   Added ``metrics`` `0.15.1 <https://github.com/tarantool/metrics/releases/tag/0.15.1>`__.
-   Added ``queue`` `1.2.2 <https://github.com/tarantool/queue/releases/tag/1.2.2>`__.

r520
----

Release SDK by tags:

-   Run workflow in SDK docker container.
-   Uploaded SDK files for 1.10, 2.8, 2.10 versions to release folder.
-   Added consistency check for all versions.

r519
----

*   On feature branches, SDK is now rebuilt only on relevant changes.

r518
----

*   Added ``frontend-core`` `8.2.1 <https://github.com/tarantool/frontend-core/releases/tag/8.2.1>`__.
*   Added ``vshard`` `0.1.21 <https://github.com/tarantool/vshard/releases/tag/0.1.21>`__.
*   Added ``http`` `1.3.0 <https://github.com/tarantool/http/releases/tag/1.3.0>`__.
*   Added Cartridge `2.7.6 <https://github.com/tarantool/cartridge/releases/tag/2.7.6>`__.

r517
----

*   Updated Tarantool EE to 2.10.4.

r516
----

*   Updated bundled OpenSSL to version 1.1.1q.

r515
----

*   Removed support of Tarantool 2.7.
*   Started using ``tarantool/actions/prepare-checkout`` to make builds more stable.

r514
----

*   Remove the local registry and setup using GitHub registry.
*   Sync rocks cache to S3 and back.
*   Setup using shared runners.
*   Refactor and format ``ci-linux.yml`` and ``ci-macos.yml``.

r513
----

*   Removed Kafka 1.5.0 due to a build issue with Tarantool 2.10.3 and higher.
*   Updated Kafka to version `1.6.2 <https://github.com/tarantool/kafka/releases/tag/1.6.2>`__.

r512
----

* Updated ``tuple-keydef`` to version `0.0.3 <https://github.com/tarantool/tuple-keydef/releases/tag/0.0.3>`__.

r511
----

*   Enabled parallel build of rocks for MacOS in CI.

r510
----

*   Updated Tarantool to 2.10.3.
*   Added a readable error for the case when the flight recoder fails
    to write data due to insufficient free space on the disk device.
    Previously, it was sending a ``SIGBUS`` error.
*   Fixed a crash in the flight recorder caused by non-thread-safe log
    recording from multiple threads.

r502
----

*   Updated Tarantool to 2.10.2.
*   Increased resolution of stored entries in flight recorder.
*   Fixed a bug in the flight recorder that resulted in skipping log entries in case
    ``box.cfg.log_level`` is less than ``flightrec_log_level``.

r498
----

*   Updated Tarantool to 2.10.1.
*   Updated Cyrus SASL to version 2.1.28.
*   Updated OpenLDAP to version 2.5.13.
*   Updated LZ4 to version 1.9.3. Fixed `CVE-2021-3520 <https://github.com/advisories/GHSA-gmc7-pqv9-966m>`__.
*   Fixed replication reconnect failure after disabling SSL encryption.
*   Fixed a crash that occurred while tyring to start an instance that has
    a compressed ``memtx`` space.
*   Fixed `CVE-2022-29242 <https://www.cve.org/CVERecord?id=CVE-2022-29242>`__ in GOST SSL engine.
*   Fixed a bug in the flight recorder reader implementation that resulted in
    a hang or error while trying to open an empty section.

r467
----

Breaking changes
~~~~~~~~~~~~~~~~

*   Default audit log format was changed to CSV.

Functionality added or changed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enterprise
^^^^^^^^^^

*   Implemented user-defined audit events. Now it's possible to log custom
    messages to the audit log from Lua.

*   **[Breaking change]** Switched the default audit log format to CSV. The
    format can be switched back to JSON using the new ``box.cfg.audit_format``
    configuration option.

*   Implemented the audit log filter. Now, it's possible to enable logging only
    for a subset of all audit events using the new ``box.cfg.audit_filter``
    configuration option.

Core
^^^^

*   Implement constraints and foreign keys. Now a user can create function constraints and foreign key relations
    (:tarantool-issue:`6436`).
*   Changed log level of some information messages from critical to info
    (:tarantool-issue:`4675`).
*   Added predefined system events: ``box.status``, ``box.id``, ``box.election``
    and ``box.schema`` (:tarantool-issue:`6260`).
*   Introduced transaction isolation levels in Lua and IPROTO (:tarantool-issue:`6930`).

Vinyl
^^^^^

*   Disabled the deferred DELETE optimization in Vinyl to avoid possible
    performance degradation of secondary index reads. Now, to enable the
    optimization, one has to set the ``defer_deletes`` flag in space options
    (:tarantool-issue:`4501`).

Lua
^^^

*   Added support of console autocompletion for ``net.box`` objects ``stream``
    and ``future`` (:tarantool-issue:`6305`).

Datetime
^^^^^^^^

*   Parse method to allow converting string literals in extended iso-8601
     or rfc3339 formats (:tarantool-issue:`6731`).
*   The range of supported years has been extended in all parsers to cover
     fully -5879610-06-22..5879611-07-11 (:tarantool-issue:`6731`).

Build
^^^^^

*   Added bundling of *GNU libunwind* to support backtrace feature on
    *AARCH64* architecture and distributives that don't provide *libunwind*
    package.
*   Re-enabled backtrace feature for all *RHEL* distributions by default, except
    for *AARCH64* architecture and ancient *GCC* versions, which lack compiler
    features required for backtrace (gh-4611).

Bugs fixed
~~~~~~~~~~

Enterprise
^^^^^^^^^^

*   Disabled audit log unless explicitly configured. Before this change,
    audit events were written to stderr if ``box.cfg.audit_log`` wasn't set. Now,
    audit log is disabled in this case.
*   Disabled audit logging of replicated events. Now, replicated events
    (for example, user creation) are logged only on the origin, never on a
    replica.

Core
^^^^

*   Banned DDL operations in space on_replace triggers, since they could lead
    to a crash (:tarantool-issue:`6920`).
*   Fixed a bug due to which all fibers created with ``fiber_attr_setstacksize()``
    leaked until the thread exit. Their stacks also leaked except when
    ``fiber_set_joinable(..., true)`` was used.
*   Fixed a crash in mvcc connected with secondary index conflict (:tarantool-issue:`6452`).
*   Fixed a bug which resulted in wrong space count (:tarantool-issue:`6421`).
*   Select in RO transaction now reads confirmed data, like a standalone (auotcommit) select does
    (:tarantool-issue:`6452`).

Replication
^^^^^^^^^^^

*   Fixed potential obsolete data write in synchronous replication
    due to race in accessing terms while disk write operation is in
    progress and not yet completed.
*   Fixed replicas failing to bootstrap when master is just re-started (:tarantool-issue:`6966`).

Lua
^^^

*   Fixed the behavior of tarantool console on SIGINT. Now Ctrl+C discards
    the current input and prints the new prompt (:tarantool-issue:`2717`).

Triggers
^^^^^^^^

*   Fixed assertion or segfault when MP_EXT received via net.box (:tarantool-issue:`6766`).
*   Now ROUND() properly support INTEGER and DECIMAL as the first
    argument (:tarantool-issue:`6988`).

Datetime
^^^^^^^^

*   Intervals received after datetime arithmetic operations may be improperly
    normalized if result was negative

    ..  code-block:: tarantoolsession

        tarantool> date.now() - date.now()
        ---
        - -1.000026000 seconds
        ...

    I.e. 2 immediately called ``date.now()`` produce very close values, whose
    difference should be close to 0, not 1 second (gh-6882).

Net.box
^^^^^^^

*   Changed the type of the error returned by net.box on timeout
    from ``ClientError`` to ``TimedOut`` (:tarantool-issue:`6144`).

r457
----

-   Fixed some binary protocol encryption bugs.

r455
----

-   Added :ref:`binary protocol encryption <enterprise-iproto-encryption>`.
-   Added :ref:`tuple field compression <tuple_compression>`.
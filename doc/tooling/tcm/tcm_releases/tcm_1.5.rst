.. _tcm_releases_1_5:

Tarantool Cluster Manager 1.5
=============================

Release date: August 28, 2025

Latest release in series: 1.5.3

|tcm_full_name| 1.5.0 introduces a new UI page for configuring TCF clusters and includes important fixes that enhance reliability, compliance, and user experience.


.. _tcm_releases_1_5_0_tcf_config:

TCF cluster configuration in UI
-------------------------------

|tcm| 1.5.0 adds a dedicated settings page for managing TCF cluster parameters directly through the web interface.
You can now retrieve and modify key fields that define cluster behavior and failover logic without editing configuration files manually.

The new page allows configuring the following parameters:

- ``dml_users`` -- a list of users with DML access
- ``cluster1``, ``cluster2`` -- settings for connected clusters
- ``replication_user``, ``replication_password`` -- replication credentials
- ``failover_timeout`` -- delay before switching to a failover node
- ``initial_status`` -- default service state on startup
- ``max_suspect_counts`` -- the threshold for marking a node as failed
- ``health_check_delay`` -- interval between health checks
- ``enable_system_check`` --  toggles system-level health monitoring
- ``status_ttl`` -- time-to-live for service status data


.. _tcm_releases_1_5_0_testing:

Testing improvements
--------------------

To make tests more efficient and predictable, all occurrences of ``time.Sleep`` were replaced with ``require.Eventually``.
This change improves test speed and reliability. Additionally, HTTP checks and tuple insertion operations in tests were updated for better performance and accuracy.



.. _tcm_releases_1_5_0_fixes:

Fixes and compliance updates
----------------------------

This release includes multiple fixes across different modules:

- CRUD and Explorer -- data types used during operations have been corrected to comply with FSTEC security requirements, ensuring strict typing and better protection of sensitive data.
- Authentication -- the system no longer relies on etcd for storing authentication parameters. Instead, it uses local configuration to improve startup reliability and simplify setup.
- Logging -- fixed issues with log output by switching to the ``slog`` logging system.
- UI -- resolved display issues in the ``OperationStatus`` component.
- Tuples -- fixed an error that caused tab refresh failures in clusters with a large number of spaces.
- ``utils`` — the ``FilterSlices`` function to correctly filter slices. Since version 1.5.1.
- :ref:`Audit log <tcm_audit_log>` documentation now contains only necessary event types. Since version 1.5.1.
- fixed issue when adding a new role, the **Permissions** drop-down list had multiple empty lines at the bottom. Since version 1.5.2.
-

.. _tcm_releases_1_5_1:

Migrations section
------------------

Since version 1.5.1, |tcm| includes a new ``migrations`` section with a ``duration`` field.
This field allows specifying the maximum execution time for long-running migrations, preventing them from being interrupted by the default timeout.

.. _tcm_releases_1_5_3:

Cluster reliability
-------------------

|tcm| 1.5.3 improves overall cluster stability, fault tolerance, and configuration handling.
The cluster now automatically reconnects after transient failures and continuously monitors node health to detect degraded or unavailable instances faster.
Configuration changes are applied correctly without disrupting cluster operation.
Quorum and health check logic were reworked to better tolerate partial failures. Unavailable nodes are now excluded from quorum calculations,
preventing cluster-wide outages when only a minority of nodes becomes unavailable.

The following issues were fixed:

- incorrect quorum calculation when some nodes were down.
- unstable health check behavior under partial failures.
- ``cluster not found`` error when adding or editing cluster settings.


Migration management improvements
---------------------------------

Also, |tcm| 1.5.3 makes migration handling safer and more predictable.
Applied migrations are now automatically locked from editing. Executed migrations are clearly marked as read-only in the interface,
and the UI displays an explanatory message to indicate that modifications are not allowed.
This prevents accidental changes to already executed migrations and ensures migration history consistency.

.. _tcm_releases_1_5:

Tarantool Cluster Manager 1.5
=============================

Release date: August 28, 2025

Latest release in series: 1.5.1

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
- UI -- resolved display issues in the ``OperationStatus ``component.
- Tuples -- fixed an error that caused tab refresh failures in clusters with a large number of spaces.


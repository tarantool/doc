.. _tcm_releases_1_6:

Tarantool Cluster Manager 1.6
=============================

Release date: February 6, 2026

Latest release in series: 1.6.0

This release introduces support for TDB workers in the cluster dashboard with integrated health monitoring,
adds TLS configuration guides for secure connections, improves audit log configuration and validation,
and introduces a feature flag for managing the Tuples tab. It also includes important fixes for LDAP authentication,
TLS configuration parsing, and a memory leak in SSL cluster connections.

.. _tcm_releases_1_6_workers_tdb:

TDB workers monitoring in cluster dashboard
--------------------------------------------

|tcm| adds support for TDB workers in the cluster dashboard with integrated health monitoring and visibility.

Workers are automatically discovered from etcd and continuously monitored via dedicated health check endpoints.
Their metrics are proxied through TCM and exposed individually, allowing detailed operational insight.

The interface displays workers directly in the stateboard with clear status indicators and a details panel.
Each worker can be in one of four states: healthy, degraded, unhealthy, or no connection, helping administrators quickly detect and diagnose issues.

.. _tcm_releases_1_6_audit_log:

Audit log configuration improvements
------------------------------------

The audit log configuration is now safer and more predictable.

Protocol values are validated during startup. If an invalid protocol is specified, the system automatically falls back to default settings and emits a warning.
Audit log parameters can be set in advance at the system bootstrap stage by specifying them in the ``auditlog`` field of the initial-settings section in the configuration file.
These settings will be applied automatically if the audit log has not been configured yet.

.. _tcm_releases_1_6_explorer:

Explorer enhancements
---------------------

A feature flag has been introduced to control the visibility of the **Tuples** tab in the Explorer interface.

The tab is displayed only when the corresponding feature flag is enabled and the CRUD module is available.
The flag can be configured either in the application configuration file or via command-line arguments at startup

.. _tcm_releases_1_6_fixes:

Stability and reliability fixes
-------------------------------

This release also includes several fixes that improve system stability and security.

LDAP authentication behavior has been adjusted, including logout handling, anonymous binding to Active Directory, and the preservation of authorization method settings after a restart.
TLS configuration parsing has been fixed to ensure cipher suites and curve preferences are correctly recognized in both configuration files and command-line arguments.
Missing schema attributes for cluster configuration have been added, and configuration validation feedback in the editor has been improved.

Additionally, a memory leak that could occur when SSL-enabled cluster connections became unavailable has been resolved, resulting in more stable cluster operation.

.. _tcm_releases_1_7:

Tarantool Cluster Manager 1.7
=============================

Release date: February 11, 2026

Latest release in series: 1.7.3

The |tcm| 1.7.x release includes a range of improvements and bug fixes aimed at enhancing the stability, usability,
and configurability of the system. Key updates include a fix for the **Metrics** tab and export functionality, improvements to session management,
better handling of audit log paths, enhanced visibility into migration status, and refinements to LDAP authentication.

.. _tcm_releases_1_7_3_metrics:

Metrics fix
-----------

A bug was fixed in 1.7.3 release that prevented the **Metrics** tab from displaying data and disabled the ability to export metrics.

.. _tcm_releases_1_7_2_websession:

WebSession improvements
-----------------------

In 1.7.2 the `websession` component has been updated to correctly handle user session creation.
Users can now create the number of sessions specified in the configuration.

.. _tcm_releases_1_7_2_audit_log:

AuditLog path handling
----------------------

The `auditlog` component now has improved support in version 1.7.2 for absolute paths in its configuration.
When a relative path is provided, the audit log file is now saved relative to the application’s working directory.

Read more about :ref:`Audit log <tcm_audit_log>`.

.. _tcm_releases_1_7_1_migration:

Migration handling
------------------

In 1.7.1 the migration handling has been updated to improve visibility into the state of applied migrations.
If a migration is reapplied, the system now logs a warning message in the logs.

.. _tcm_releases_1_7_1_test_fix:

Connection Test Fix
-------------------

A bug in the "test connection" functionality for Tarantool and etcd services has been fixed. Previously,
the function did not correctly report the connection status for these services.

.. _tcm_releases_1_7_cluster_management:

Default cluster management
--------------------------

You can now control automatic creation of the default cluster using one of the following options:

- ``TCM_DEFAULT_CLUSTER`` environment variable
- ``default-cluster`` configuration parameter
- ``--default-cluster`` command-line flag

This allows administrators to explicitly enable or disable default cluster auto-creation depending on deployment requirements.

.. _tcm_releases_1_7_improve_ldap:

LDAP authentication improvements
--------------------------------

Error handling has been improved for LDAP authentication when the **Automatically add non-existent users** option is disabled.

It is also now possible to create a user via the UI with LDAP authentication enabled, simplifying user management in LDAP-based environments.

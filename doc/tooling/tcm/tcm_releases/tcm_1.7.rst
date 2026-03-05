.. _tcm_releases_1_7:

Tarantool Cluster Manager 1.7
=============================

Release date: February 11, 2026

Latest release in series: 1.7.1

This release introduces control over automatic default cluster creation,
improves LDAP authentication handling, and enhances user management capabilities in the UI.

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

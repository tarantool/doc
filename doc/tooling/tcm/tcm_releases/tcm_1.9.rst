.. _tcm_releases_1_9:

Tarantool Cluster Manager 1.9
=============================

Release date: April 17, 2026

Latest release in series: 1.9.1

|tcm| 1.9.0 expands cluster connectivity options, simplifies first-time setup by allowing initial user and role provisioning from configuration,
and improves observability in **Stateboard** when `vshard` issues occur. The release also includes fixes for migration storage connectivity
in split-configuration setups and corrects password handling during cluster connection tests.

.. _tcm_releases_1_9_instances_connection:

Connect to instances via iproto.listen.uri
-------------------------------------------

TCM can now connect to a cluster instance using `iproto.listen.uri`.
This provides more flexibility in environments where instance endpoints are defined through `iproto.listen.uri` rather
than alternative connection parameters, and helps align |tcm| connectivity with the instance’s actual listen configuration.

.. _tcm_releases_1_9_boostrap:

Bootstrap users and roles on first launch
-----------------------------------------

TCM 1.9.0 introduces the ability to create users and roles on the very first |tcm| launch using the initial-settings field in the configuration.
Roles can be created with an explicit ID or without one, allowing you to either keep stable identifiers across environments or let the system generate them as needed.

.. _tcm_releases_1_9_boostrap:

Stateboard router indicators for vshard errors
----------------------------------------------

**Stateboard** tab now provides a router indicator response when `vshard` errors occur.
This change improves diagnostics by making routing-related problems more visible and easier to interpret during incident investigation.

.. _tcm_releases_1_9_fixed:

Fixes
-----
-   Fixed a migration storage connection error that could occur when cluster configuration and |tcm| configuration are stored in different configuration storages.
-   Fixed incorrect password handling during `Test connection` when creating or updating a cluster, ensuring the test uses the intended credentials.
-   Fixed a bug where, after a failed migration, the resulting migration status was not properly recorded or displayed, ensuring accurate state tracking and more reliable migration workflows.

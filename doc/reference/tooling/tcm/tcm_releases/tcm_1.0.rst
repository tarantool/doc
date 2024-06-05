.. _tcm_releases_1_0:

Tarantool Cluster Manager 1.0
=============================

Release date: December 26, 2023

Releases in series: 1.0.4, 1.0.3, 1.0.2, 1.0.1, 1.0.0

1.0 is the first public release series of |tcm_full_name|. It was introduced as a
part of the :ref:`Tarantool EE 3.0 release <3-0-tarantool_cluster_manager>`.
Below is an overview of key features of TCM 1.0.

.. _tcm_releases_1_0_clusters:

Multiple connected clusters
---------------------------

|tcm| works as a standalone application. You can connect any number of Tarantool EE
3.0+ clusters to a single |tcm| instance and switch between them on the fly.

To connect a cluster to |tcm|, you need to provide the endpoint URLs and connection
parameters of its centralized configuration storage (for example, etcd).
To learn more, see :ref:`tcm_connect_clusters`.

.. _tcm_releases_1_0_stateboard:

Cluster stateboard
------------------

The cluster *stateboard* is a main |tcm| page that visualizes the information about
the selected cluster:

-   Cluster topology visualized as a table or a graph
-   Tarantool versions running on instances
-   Memory statistics
-   Errors and warnings that happen on instances

From the stateboard, you can navigate to specific instances to view their details
or connect to their interactive consoles.

To learn more, see :ref:`tcm_cluster_monitoring`.

.. _tcm_releases_1_0_config:

Cluster configuration management
--------------------------------

|tcm| includes a visual editor for cluster configuration. It allows editing cluster
configurations as a YAML file in the browser. Once you're done editing the configuration,
you can send the changes to the configuration storage in one click or save them locally
to continue editing them later.

To learn more, see :ref:`tcm_configuring_clusters`.

.. _tcm_releases_1_0_access:

Role-based access control
-------------------------

|tcm| features its own role-based access control system. It defines users that can
log into |tcm| and their permissions to perform various actions or access clusters
in its web interface.

You can use built-in roles or create new ones with permissions you need. Users'
access can be limited to specific clusters and operations on them, for example,
editing the configuration or calling stored functions.
To learn more, see :ref:`tcm_access_control`.

|tcm| also supports LDAP authentication.

.. _tcm_releases_1_0_audit:

Audit logging
-------------

|tcm| has a built-in audit logging mechanism. When enabled, it records information
about events that occur in |tcm| and users' actions to dedicated audit log files.
You can define events to write to the audit log and adjust logging parameters, such
as filename, log rotation, or compression.

To learn more, see :ref:`tcm_audit_log`.

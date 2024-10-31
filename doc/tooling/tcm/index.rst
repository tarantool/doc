..  _tcm:

Tarantool Cluster Manager
=========================

.. ee_note_tcm_start

..  admonition:: Enterprise Edition
    :class: fact

    |tcm_full_name| is a part of the `Enterprise Edition <https://www.tarantool.io/compare/>`_.

.. ee_note_tcm_end

|tcm_full_name| (|tcm|) is a web-based visual tool for configuring, managing, and
monitoring Tarantool EE clusters. It provides a GUI for working with clusters
and individual instances, from monitoring their state to executing commands interactively
in an instance's console.

|tcm| is a standalone application included in the Tarantool Enterprise Edition
:ref:`distribution package <enterprise-package-contents>`. It is shipped as ready-to-run
executable for Linux platforms.

|tcm| works only with Tarantool EE clusters that use centralized configuration in
:ref:`etcd <configuration_etcd>` or a Tarantool-based configuration storage.
When you create or edit a cluster's configuration in |tcm|, it publishes the saved
configuration to the storage. This ensures consistent and reliable configuration storage.
A single |tcm| installation can connect to multiple Tarantool EE clusters and
switch between them in one click.

To provide enterprise-grade security, |tcm| features its own role-based access control.
You can create users and assign them roles that include required permissions.
For example, a user can be an administrator of a specific cluster or only have the right
to read data. LDAP authorization is supported as well.

.. toctree::
    :maxdepth: 1

    tcm_ui_overview
    tcm_connect_clusters
    tcm_cluster_management/index
    tcm_cluster_data_access
    tcm_access_control/index
    tcm_audit_log
    tcm_configuration
    tcm_backend_store
    tcm_dev_mode
    tcm_configuration_reference
    Releases <tcm_releases/index>

..  _tcm:

Tarantool Cluster Manager
=========================

..  admonition:: Enterprise Edition
    :class: fact

    |tcm_full_name| is a part of the `Enterprise Edition <https://www.tarantool.io/compare/>`_.

|tcm_full_name| (|tcm|) is a web-based visual tool for configuring, managing, and
monitoring Tarantool EE clusters. It provides a GUI for working with clusters
and individual instances, from monitoring their state to executing commands interactively
in an instance's console.

|tcm| is a standalone application included in the Tarantool Enterprise Edition
distribution package. It is shipped as an executable that is ready to run on Linux
and macOS platforms.

|tcm| works only with Tarantool EE clusters that use :ref:`etcd as a configuration storage <configuration_etcd>`.
When you create or edit a cluster's configuration in |tcm|, it publishes the saved
configuration to etcd. This ensures consistent and reliable configuration storage.
A single |tcm| installation can connect to multiple Tarantool EE clusters and
switch between them in one click.

To provide enterprise-grade security, |tcm| features its own role-based access control.
You can create users and assign them roles that include required permissions.
For example, a user can be an administrator of a specific cluster or only have the right
to read data. LDAP authorization is supported as well.

.. toctree::

    tcm_access_control

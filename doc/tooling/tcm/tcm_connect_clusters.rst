..  _tcm_connect_clusters:

Connecting clusters
===================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| works with clusters that:

*   run on Tarantool EE 3.0 or later
*   use :ref:`centralized configuration <configuration_etcd>` storage: etcd or Tarantool-based.

A single |tcm| installation can have multiple connected clusters. A connection to
|tcm| doesn't affect the cluster's functioning. You can connect clusters to |tcm|
and disconnect them on the fly.

There are two scenarios of cluster connection to |tcm|:

-   Connect an existing cluster.
-   Add a new cluster and :ref:`write its configuration <getting_started_tcm_cluster_config>` from scratch in the |tcm|
    web interface.

In both cases, you need to deploy Tarantool and start the cluster instances using
the :ref:`tt-cli` or another suitable way.

To add a cluster to |tcm|, you can use two ways:

-   Use the |tcm| web interface as described on this page.
-   Specify the ``initial-settings.clusters`` section of the |tcm| configuration.
    To learn more, see :ref:`tcm_configuration_initial`.

..  _tcm_connect_clusters_parameters:

Connection parameters
---------------------

When connecting a cluster to |tcm|, you need to provide two sets of connection parameters:
for the cluster instances and for the centralized configuration storage.

..  _tcm_connect_clusters_parameters_storage:

Configuration storage connection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The cluster configuration can be stored in either an :ref:`etcd <configuration_etcd>`
cluster or a separate Tarantool-based storage. In both cases, the following connection
parameters are required:

*   A key prefix used to identify the cluster in the configuration storage.
    A prefix must be unique for each cluster in storage.
*   URIs of all instances of the configuration storage.
*   The credentials for accessing the configuration storage: an `etcd user <https://etcd.io/docs/v3.5/op-guide/authentication/rbac/>`__
    or a :ref:`Tarantool user <authentication>`.

Additionally, if SSL or TLS encryption is enabled for the configuration storage,
provide the corresponding encryption configuration: keys, certificates, and other
parameters. For the complete list of parameters, consult the `etcd documentation <https://etcd.io/docs/v3.5/op-guide/configuration/#security>`__
or Tarantool :ref:`enterprise-iproto-encryption`.

..  _tcm_connect_clusters_parameters_tarantool:

Cluster connection
~~~~~~~~~~~~~~~~~~

For interaction with the cluster instances, |tcm| needs the following access parameters:

*   A :ref:`Tarantool user <authentication>` that exists in the cluster and their password.
    |tcm| connects to the cluster on behalf of this user.
*   An :ref:`SSL configuration <enterprise-iproto-encryption>` if the traffic encryption
    is enabled on the cluster.

Managing connected clusters
---------------------------

Administrators can add new clusters, edit, and remove existing ones from |tcm|.

Connected clusters are listed on the **Clusters** page.

..  _tcm_connect_clusters_connect_preconf:

Connecting a pre-configured cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you already have a cluster and want to connect it to |tcm|,
follow these steps:

#.  Go to **Clusters**  and click **Add**.
#.  Fill in the general cluster information:

    *   Specify an arbitrary name.
    *   Optionally, provide a description and select a color to mark this cluster in |tcm|.
    *   Optionally, enter the URLs of additional services for the cluster. For example,
        a Grafana dashboard that monitors the cluster metrics, or a syslog server
        for viewing the cluster logs. |tcm| provides quick access to these URLs on
        the cluster **Stateboard** page.

3.  Provide the details of the cluster configuration storage:

    *    Storage type: **etcd** or **tarantool**.
    *    The **Prefix** specified in the cluster configuration.
    *    The URIs of the configuration storage instances.
    *    The credentials for accessing the configuration storage.
    *    The SSL/TLS parameters if the connection encryption is enabled on the storage.

4.  Provide the credentials for accessing the cluster: a Tarantool user's name, their password,
    and SSL parameters in case :ref:`traffic encryption <enterprise-iproto-encryption>`
    is enabled on the cluster.

.. _tcm_connect_clusters_connect_new:

Adding a new cluster
~~~~~~~~~~~~~~~~~~~~

If you don't have a cluster yet, you can add one in |tcm| and write its configuration
from scratch using the :ref:`built-in configuration editor <tcm_configuring_clusters>`.

.. important::

    When adding a new cluster, you need to have a storage for its configuration up
    and running so that |tcm| can connect to it. Cluster instances can be deployed later.

To add a new cluster:

#.  Go to **Clusters**  and click **Add**.
#.  Fill in the general cluster information:

    *   Specify an arbitrary name.
    *   Optionally, provide a description and select a color to mark this cluster in |tcm|.
    *   Optionally, enter the URLs of additional services for the cluster. For example,
        a Grafana dashboard that monitors the cluster metrics, or a syslog server
        for viewing the cluster logs. |tcm| provides quick access to these URLs on
        the cluster **Stateboard** page.

#.  Select the type of the cluster configuration storage: **etcd** or **tarantool**.
#.  Define a unique **Prefix** for identifying this cluster in the configuration storage.
#.  Provide the connection details for the cluster configuration storage:

    *    The URIs of configuration storage instances.
    *    The credentials for accessing the configuration storage.
    *    The SSL/TLS parameters if the connection encryption is enabled on the storage.

#.  Provide the cluster credentials: a username, a password, and SSL parameters in
    case :ref:`traffic encryption <enterprise-iproto-encryption>` is enabled on
    the cluster.

Once you add the cluster:

*   Set up the cluster configuration using the |tcm| :ref:`configuration editor <tcm_configuring_clusters>`.
*   Deploy Tarantool on the cluster nodes using the :ref:`tt-cli` or other suitable tools.
*   Start the cluster using the :ref:`tt-cli` or other suitable tools.

..  _tcm_connect_clusters_edit:

Editing a connected cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To edit a connected cluster, go to **Clusters** and click **Edit** in the **Actions**
menu of the corresponding table row.

..  _tcm_connect_clusters_disconnect:

Disconnecting a cluster
~~~~~~~~~~~~~~~~~~~~~~~

To disconnect a cluster from |tcm|, go to **Clusters** and click **Disconnect**
in the **Actions** menu of the corresponding table row.

.. note::

    Disconnecting a cluster does not affect its functioning. The only
    thing that changes is that it's no longer shown in |tcm|.
    You can connect this cluster again at any time.
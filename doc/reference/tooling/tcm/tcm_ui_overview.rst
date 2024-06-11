..  _tcm_ui_overview:

Web interface overview
======================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name|

The |tcm| web interface is available on the hostname and port defined by the
``http.host`` and ``http.port`` :ref:`configuration options <tcm_configuration>`.
If TLS is enabled, it user the ``https`` protocol, otherwise the protocol is ``http``.
When started locally with default configuration, |tcm| is available at ``http://127.0.0.1:8080``.

The set of |tcm| pages that a user sees and controls available on these pages are
defined by the user's :ref:`permissions <tcm_access_control_permissions>`.


..  _tcm_ui_overview_login:

Logging into TCM
----------------

To log into |tcm| after bootstrap, use the following credentials:

-   **Username**: ``admin``
-   **Password**: the initial password is shown in the |tcm| boot log in
    a message like this:

    .. code-block:: text

        Jun 11 11:24:08.900 WRN Generated super admin credentials login=admin password=jS9PsdkEJBYNhdMtSswMlxDR1vdbfc1N

image

After logging in with the default password:

#.  Adjust the :ref:`password policy <tcm_access_control_password_policy>`
    in accordance to the security requirements that apply in your organization.
#.  Change the password` of ``admin`` on the :ref:`User settings <tcm_ui_overview_user_settings>` page.


..  _tcm_ui_overview_page_structure:

Page structure
--------------

The |tcm| web interface consists of three parts:

#.  **Navigation page** on the left shows the lost of pages available to the user.
    The navigation pane can be collapsed by clicking the cross icon at its top.
#.  **Header** at the top provides access to notifications and :ref:`user settings <tcm_ui_overview_user_settings>.
#.  **Working area** displays the contents of the selected page.

image


..  _tcm_ui_overview_groups:

Page groups
-----------

For easier navigation, |tcm| pages are grouped in the navigation pane by their content.
There are the following page groups:

-   **Cluster**: interaction with the selected cluster.
-   **Clusters**: interaction with all connected clusters in general.
-   **Users**: access management.
-   **Tools**: |tcm| administration.
-   **Settings**: runtime management of |tcm| settings.

..  _tcm_ui_overview_cluster:

Cluster
-------

The **Cluster** group includes pages used for interaction with a particular cluster.
To switch between clusters, click the **Cluster** group name and select a connected
cluster from the drop-down list.

..  _tcm_ui_overview_cluster_stateboard:

Stateboard
~~~~~~~~~~

The cluster **Stateboard** is a main page for monitoring the cluster state
and interacting with its instances.

image

On this page, you can:

-   view and edit the cluster topology
-   group and filter instances based on various criteria
-   view memory statistics and Tarantool versions running on instances
-   start and stop instances
-   navigate to :ref:`instance pages <tcm_ui_overview_instance>`
    by clicking instance names in the cluster topology list.

Learn more about using the cluster stateboard in :ref:`tcm_cluster_monitoring`.

..  _tcm_ui_overview_instance:

Instance page
-------------

The instance page opens when you click an instance name on the **Stateboard**.

image

It provides a set of tabs for performing actions on the selected Tarantool instance.
On these tabs, you can:

-   **Details** and **State** tabs: view instance details as a human-readable table
    or as a console output of ``box.cfg``, ``box.info``, and other built-in functions).
-   **SQL** and **Terminal** tabs: run SQL and Lua commands on the instance.
-   **Logs** tab: view instance logs.
-   **Slab stats** tab: view :ref:`slab allocator <memtx-memory>` statistics.
-   **Funcs**: manage and call stored functions.
-   **Metrics**: view instance metrics

image

The instance page has an **Actions** menu at the top that allows you to:

-   navigate to the :ref:`instance explorer <tcm_ui_overview_instance_explorer>`
-   edit the instance configuration
-   remove the instance
-   promote the instance
-   start and stop the instance

..  _tcm_ui_overview_cluster_config:

Configuration
~~~~~~~~~~~~~

The cluster **Configuration** page provides an

Learn more in :ref:`tcm_configuring_clusters`.

..  _tcm_ui_overview_cluster_tuples:

Tuples
~~~~~~

.. important::

    The access to stored data on the **Tuples** page is supported only for sharded
    clusters with the `CRUD <https://github.com/tarantool/crud>`__ module.

The **Tuples** page provides access to data stored in user spaces of the selected
cluster.

image

On this page, you can:

-   view the list of user spaces, their size and engines
-   view and edit tuples stored in user spaces

..  _tcm_ui_overview_cluster_metrics:

Cluster metrics
~~~~~~~~~~~~~~~

The **Cluster metrics** page provides access to the selected cluster's :ref:`metrics <metrics-reference>`.

image

Learn more in :ref:`tcm_cluster_metrics`.


..  _tcm_ui_overview_instance_explorer:

Instance explorer
~~~~~~~~~~~~~~~~~

The instance **Explorer** provides access to all spaces of a specific instance,
including system spaces.

image

On this page, you can:

-   view and edit instance spaces, their size and engines
-   view and edit tuples stored in all spaces of the instance

..  _tcm_ui_overview_clusters:

Clusters
--------

The **Clusters** group includes pages used for managing |tcm|'s cluster connections.

..  _tcm_ui_overview_clusters_clusters:

Clusters
~~~~~~~~

The **Clusters** page lists Tarantool clusters that are connected to |tcm|.

image

On this page, you can:

-   connect Tarantool clusters to |tcm|
-   edit cluster connections
-   disconnect clusters

Learn more in :ref:`tcm_connect_clusters`.

..  _tcm_ui_overview_clusters_acl:

ACL
~~~

The **ACL** page displays the |tcm| access control list.

image

On this page, you can add and delete ACL entries. Learn more in :ref:`tcm_access_control_acl`.

..  _tcm_ui_overview_users:

Users
-----

The **Users** group includes pages related to users' access to |tcm|.

..  _tcm_ui_overview_users_users:

Users
~~~~~

..  _tcm_ui_overview_users_roles:

Roles
~~~~~

..  _tcm_ui_overview_users_sessions:

Sessions
~~~~~~~~

..  _tcm_ui_overview_tools:

Tools
-----

The **Tools** groups include pages used for monitoring the |tcm| functioning

..  _tcm_ui_overview_tools_audit_log:

Audit log
~~~~~~~~~

..  _tcm_ui_overview_tools_metrics:

TCM metrics
~~~~~~~~~~~


..  _tcm_ui_overview_settings:

Settings
--------

Password policy
Audit settings
LDAP

..  _tcm_ui_overview_user_settings:

User settings
-------------

..  _tcm_ui_overview_onboard:

Onboarding
----------

..  _tcm_ui_overview:

Web interface overview
======================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end


The |tcm_full_name| web interface is available on the hostname and port defined by the
``http.host`` and ``http.port`` :ref:`configuration options <tcm_configuration>`.
If TLS is enabled, it user the ``https`` protocol, otherwise the protocol is ``http``.
When started locally with default configuration, |tcm| is available at ``http://127.0.0.1:8080``.

The exact set of |tcm| pages that a particular user sees and controls available
on these pages are defined by the user's :ref:`permissions <tcm_access_control_permissions>`.


..  _tcm_ui_login:

Logging into TCM
----------------

To log into |tcm| after bootstrap, use the following credentials:

-   **Username**: ``admin``
-   **Password**: the initial password is shown in the |tcm| boot log in
    a message like this:

    .. code-block:: text

        Jun 11 11:24:08.900 WRN Generated super admin credentials login=admin password=jS9PsdkEJBYNhdMtSswMlxDR1vdbfc1N

.. image:: _images/tcm_ui_login.png
    :align: left
    :width: 700
    :alt: TCM login page

After logging in with the default password:

#.  Adjust the :ref:`password policy <tcm_access_control_password_policy>`
    in accordance to the security requirements that apply in your organization.
#.  Change the ``admin`` user's password on the :ref:`User settings <tcm_ui_user_settings>` page.

To log out of |tcm|, click the user's name in the header and click **Log out**.

..  _tcm_ui_page_structure:

Page structure
--------------

The |tcm| web interface consists of three parts:

#.  **Navigation page** on the left shows the lost of pages available to the user.
    The navigation pane can be collapsed by clicking the cross icon at its top.
#.  **Header** at the top provides access to notifications and :ref:`user settings <tcm_ui_user_settings>.
#.  **Working area** displays the contents of the selected page.

.. image:: _images/tcm_ui_sections.png
    :align: left
    :width: 700
    :alt: TCM UI parts: navigation pane, header, working area


..  _tcm_ui_groups:

Page groups
-----------

For easier navigation, |tcm| pages are grouped in the navigation pane by their content.
There are the following page groups:

-   **Cluster**: interaction with the selected cluster.
-   **Clusters**: interaction with all connected clusters in general.
-   **Users**: access management.
-   **Tools**: |tcm| administration.
-   **Settings**: runtime management of |tcm| settings.

..  _tcm_ui_onboarding:

Onboarding
----------

The **Onboarding** item of the navigation pane starts the interactive onboarding
tutorial. It takes the user through main |tcm| features in the web interface.

..  _tcm_ui_cluster:

Cluster
-------

The **Cluster** group includes pages used for interaction with a particular cluster.
To switch between clusters, click the **Cluster** group name and select a connected
cluster from the drop-down list.

..  _tcm_ui_cluster_stateboard:

Stateboard
~~~~~~~~~~

The cluster **Stateboard** is a main page for monitoring the cluster state
and interacting with its instances.

.. image:: _images/tcm_ui_stateboard.png
    :align: left
    :width: 700
    :alt: TCM stateboard

On this page, you can:

-   view and edit the cluster topology
-   group and filter instances based on various criteria
-   view memory statistics and Tarantool versions running on instances
-   start and stop instances
-   navigate to :ref:`instance pages <tcm_ui_instance>`
    by clicking instance names in the cluster topology list.

Learn more about using the cluster stateboard in :ref:`tcm_cluster_monitoring`.

..  _tcm_ui_instance:

Instance page
~~~~~~~~~~~~~

The instance page opens when you click an instance name on the **Stateboard**.

.. image:: /_images/tcm_ui_instance.png
    :align: left
    :width: 700
    :alt: TCM instance page

It provides a set of tabs for performing actions on the selected Tarantool instance.
On these tabs, you can:

-   **Details** and **State** tabs: view instance details as a human-readable table
    or as a console output of ``box.cfg``, ``box.info``, and other built-in functions).
-   **SQL** and **Terminal** tabs: run SQL and Lua commands on the instance.
-   **Logs** tab: view instance logs.
-   **Slab stats** tab: view :ref:`slab allocator <memtx-memory>` statistics.
-   **Funcs**: manage and call stored functions.
-   **Metrics**: view instance metrics

The instance page has an **Actions** menu at the top that allows you to:

-   navigate to the :ref:`instance explorer <tcm_ui_instance_explorer>`
-   edit the instance configuration
-   remove the instance
-   promote the instance
-   start and stop the instance

..  _tcm_ui_cluster_config:

Configuration
~~~~~~~~~~~~~

The cluster **Configuration** page provides an

.. image:: /_images/tcm_ui_config.png
    :align: left
    :width: 700
    :alt: TCM cluster configuration page

Learn more in :ref:`tcm_configuring_clusters`.

..  _tcm_ui_cluster_tuples:

Tuples
~~~~~~

.. important::

    The access to stored data on the **Tuples** page is supported only for sharded
    clusters with the `CRUD <https://github.com/tarantool/crud>`__ module.

The **Tuples** page provides access to data stored in user spaces of the selected
cluster.

.. image:: /_images/tcm_ui_tuples.png
    :align: left
    :width: 700
    :alt: TCM tuples page

On this page, you can:

-   view the list of user spaces, their size and engines
-   view and edit tuples stored in user spaces

..  _tcm_ui_cluster_metrics:

Cluster metrics
~~~~~~~~~~~~~~~

The **Cluster metrics** page provides access to the selected cluster's :ref:`metrics <metrics-reference>`.

.. image:: /_images/tcm_ui_cluster_metrics.png
    :align: left
    :width: 700
    :alt: TCM cluster metrics page

Learn more in :ref:`tcm_cluster_metrics`.


..  _tcm_ui_instance_explorer:

Instance explorer
~~~~~~~~~~~~~~~~~

The instance **Explorer** provides access to all spaces of a specific instance,
including system spaces.

.. image:: /_images/tcm_ui_instance_explorer.png
    :align: left
    :width: 700
    :alt: TCM instance explorer

On this page, you can:

-   view and edit instance spaces, their size and engines
-   view and edit tuples stored in all spaces of the instance

..  _tcm_ui_clusters:

Clusters
--------

The **Clusters** group includes pages used for managing |tcm|'s cluster connections.

..  _tcm_ui_clusters_clusters:

Clusters
~~~~~~~~

The **Clusters** page lists Tarantool clusters that are connected to |tcm|.

.. image:: /_images/tcm_ui_clusters.png
    :align: left
    :width: 700
    :alt: TCM clusters page

On this page, you can:

-   connect Tarantool clusters to |tcm|
-   edit cluster connections
-   disconnect clusters

Learn more in :ref:`tcm_connect_clusters`.

..  _tcm_ui_clusters_acl:

ACL
~~~

The **ACL** page displays the |tcm| access control list.

.. image:: /_images/tcm_ui_acl.png
    :align: left
    :width: 700
    :alt: TCM ACL page

On this page, you can add and delete ACL entries. Learn more in :ref:`tcm_access_control_acl`.

..  _tcm_ui_users:

Users
-----

The **Users** group includes pages related to users' access to |tcm|.

..  _tcm_ui_users_users:

Users
~~~~~

The **Users** page lists |tcm| users.

image

On this page, you can:

-   add, edit, and delete users
-   manage users' secrets (passwords and API tokens)
-   revoke users' sessions

Learn more in :ref:`tcm_access_control_users`.

..  _tcm_ui_users_roles:

Roles
~~~~~

The **Roles** page lists |tcm| user roles.

image

On this page, you can add, edit, and delete roles. Learn more in :ref:`tcm_access_control_roles`.

..  _tcm_ui_users_sessions:

Sessions
~~~~~~~~

The **Roles** page lists active sessions of |tcm| users.

image

On this page, you can view and revoke sessions. Learn more in :ref:`tcm_access_control_sessions`.

..  _tcm_ui_tools:

Tools
-----

The **Tools** group includes service pages used for |tcm| maintenance and monitoring.

..  _tcm_ui_tools_audit_log:

Audit log
~~~~~~~~~

The **Audit log page** displays the |tcm| :ref:`audit log <tcm_audit_log>`.

image

..  _tcm_ui_tools_metrics:

TCM metrics
~~~~~~~~~~~

The **TCM metrics** page provides access to the |tcm| metrics.

..  _tcm_ui_settings:

Settings
--------

The **Settiings** group includes service pages where you can configure various |tcm| features.

..  _tcm_ui_settings_policy:

Password policy
~~~~~~~~~~~~~~~

On the **Password policy** page, you can configure the requirements to users' passwords,
such as minimal length, required symbols, expiration, and other settings.
Learn more in :ref:`tcm_access_control_password_policy`.

image

..  _tcm_ui_settings_audit:

Audit settings
~~~~~~~~~~~~~~

On the **Audit settings** page, you can configure how |tcm| records events to its
audit log: whether audit log is enabled, which events are recorded, and so on.
Learn more in :ref:`tcm_audit_log`.

image
..  _tcm_ui_settings_ldap:

LDAP
~~~~

On the **Audit settings** page, you can manage |tcm| LDAP configurations.

image

..  _tcm_ui_user_settings:

User settings
-------------

The user settings dialog opens when you click **Settings** under the user's name
in the header. In this dialog, you can:

-   **General** tab: switch the color theme
-   **Change password** tab: change your password
-   **API tokens tab**: generate and delete :ref:`API tokens <tcm_access_control_api_tokens>`
-   **Sessions** tab: view and revoke your user's sessions
-   **About** tab: view |tcm| information about switch between development and production mode

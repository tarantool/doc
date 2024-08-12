..  _tcm_cluster_users:

Managing cluster users and roles
================================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides a visual interface for managing Tarantool users and roles
on connected clusters.

.. note::

    This page describes management of :ref:`Tarantool users and roles <access_control>`
    on instances of connected clusters. To learn to manage |tcm| users, see :ref:`tcm_access_control`.

The :ref:`Tarantool access model <access_control>` defines user access to entities
inside a single instance. Thus, to create or alter a cluster-wide user or role, you need to
do this on all cluster instances. In replication clusters, changes in access model
are possible only on read-write instances (replica set leaders). Changes made on
a leader instance are propagated to all instances of its replica set automatically.

Operations on cluster access model are possible only if the :ref:`user <tcm_connect_clusters_parameters_tarantool>`
that |tcm| uses to connect to the cluster has the privileges to manage users and roles.

You can also manage Tarantool users and roles from |tcm| using the Lua API
as described in :ref:`access_control`. To do this, connect to instance consoles
from the **Terminal** tab of the instance page.

..  _tcm_cluster_users_users:

Managing cluster users
----------------------

The tools for managing cluster users are located on the **Users** tab
of the :ref:`instance page <tcm_ui_instance>`.

.. important::

    To ensure the access model consistency across the cluster, repeat all user
    management operations on all read-write instances of the cluster.

To create a user on a cluster:

#.  Go to **Stateboard**.
#.  Find a replica set leader in the instances list and click it to open the instance page.
#.  Go to the **Users** tab and click **Add user**.

To edit or delete a user, click the corresponding button in the **Users** table.

To edit a user's privileges:

#.  Click the lock icon against the username in the **Users** table.
#.  In the privileges dialog:

    -   Click **Add** to grant privileges
    -   Click the trash bin icon to revoke a privilege

..  _tcm_cluster_users_roles:

Managing cluster roles
----------------------

The tools for managing cluster roles are located on the **Users** tab
of the :ref:`instance page <tcm_ui_instance>`.

.. important::

    To ensure the access model consistency across the cluster, repeat all role
    management operations on all read-write instances of the cluster.

To create a role on a cluster:

#.  Go to **Stateboard**.
#.  Find a replica set leader in the instances list and click it to open the instance page.
#.  Go to the **Users** tab and click **Add role**.

To delete a role, click the trash bin icon in the **Roles** table.

To edit a roles's privileges:

#.  Click the lock icon against the role name in the **Roles** table.
#.  In the privileges dialog:

    -   Click **Add** to grant privileges
    -   Click the trash bin icon to revoke a privilege

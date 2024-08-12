..  _tcm_cluster_users:

Managing cluster users and roles
================================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides a visual interface for managing Tarantool users and roles
on connected clusters. The tools for managing cluster users and roles are located on
the **Users** tab of the :ref:`instance page <tcm_ui_instance>`.

.. note::

    This page describes management of :ref:`Tarantool users and roles <access_control>`
    on instances of connected clusters. To learn about TCM users, see :ref:`tcm_access_control`.

The :ref:`Tarantool access model <access_control>` defines user access to entities
inside a single instance. Thus, to create or alter a user on a cluster, you need to
do this on all cluster instances. In replication clusters, changes in access model
are possible only on read-write instances (replica set leaders). Changes made on
a leader instance are propagated to all instances of the same replica set automatically.

.. important::

    To ensure the access model consistency across the cluster, repeat all user
    management operations on all read-write instances of the cluster.

Operations on cluster access model are possible only if the user that |tcm| uses
to connect to the cluster has the privileges to manage users and roles.

You can also manage Tarantool users and roles from |tcm| using the Lua API
as described in :ref:`access_control`. To do this, connect to instance consoles
from the **Terminal** tab of the instance page.

..  _tcm_cluster_users_users:

Managing cluster users
----------------------

To create a user on a cluster:

#.  Go to **Stateboard**.
#.  Find a replica set leader in the instances list and click it to open the instance page.
#.  Go to the **Users** tab and click **Add user**.
#.  Enter a username and a password and click **Add**.
#.  Click the lock icon against the username in the table to open user privileges dialog.
#.  Add required privileges to the user.
#.  Repeat all previous steps on all read-write instances in the cluster.

To edit or delete a user, or alter their privileges, click the corresponding button in the users table.


..  _tcm_cluster_users_roles:

Managing cluster roles
----------------------

To create a role on a cluster:

#.  Go to **Stateboard**.
#.  Find a replica set leader in the instances list and click it to open the instance page.
#.  Go to the **Users** tab and click **Add role**.
#.  Enter a role name and a password and click **Add**.
#.  Click the lock icon against the role name in the table to open role privileges dialog.
#.  Add required privileges to the role.
#.  Repeat all previous steps on all read-write instances in the cluster.

To edit or delete a role, click the corresponding button in the roles table.


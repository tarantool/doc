..  _tcm_access_control:

Access control
==============

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| features a role-based access control system. It enables flexible
management of access to |tcm| functions, connected clusters, and stored data.
The |tcm| access system uses three main entities: permissions, roles,
and users (or user accounts). They work as follows:

-   Permissions correspond to specific functions or objects in
    |tcm| (*administrative permissions*) or operations on clusters (*cluster permissions*).
-   Roles are predefined sets of *administrative* permissions to
    assign to users.
-   Users have roles that define their access rights to |tcm| functions and objects, and
    *cluster* permissions that are assigned for each cluster separately.

..  note::

    |tcm| users, roles, and permissions are not to be confused with similar subjects
    of the :ref:`Tarantool access control system <authentication>`. To access Tarantool
    instances directly, Tarantool users with corresponding roles are required.

.. _tcm_access_control_permissions:

Permissions
-----------

Permissions define access to specific actions that users can do in |tcm|. For example,
there are permissions to view connected clusters or to manage users.

There are two types of permissions in |tcm|: *administrative* and *cluster* permissions.

*   *Administrative permissions* provide access to |tcm| functions. They define which
    pages and controls are available to users in the web UI. Typically, *read* permissions
    define pages shown in the left menu. *Write* permissions define the availability
    of controls for managing objects on the pages.
    For example, users with read permission to clusters can view the **Clusters** page
    but they don't see **Add**, **Edit**, or **Remove** buttons unless they have the
    write permission.

    Administrative permissions are assigned to users through :ref:`roles <tcm_access_control_roles>`.

*   *Cluster permissions* enable actions with connected Tarantool clusters.
    These permissions are granted to users on a per-cluster level: each user has a separate
    set of permissions for each cluster.

    Cluster permissions define which pages of the **Cluster** menu section users
    see and what actions they can take on these pages.
    For example, users with the read configuration permission to a cluster configuration
    see the **Configuration** page when this cluster is selected.

    Cluster permissions are assigned to users individually when creating or editing them.

Permissions are predefined in |tcm|, there is no way to change, add, or delete them.
The complete lists of administrative and cluster permissions in |tcm| are provided
in the :ref:`Permissions reference <tcm_access_control_permissions_ref>`.

.. _tcm_access_control_roles:

Roles
-----

Roles are groups of :ref:`administrative permissions <tcm_access_control_permissions>`
that are assigned to users together.

The assigned roles define pages that users see in |tcm| and actions available
on these pages.

.. note::

    Roles don't include cluster permissions. Access to connected clusters
    is configured for each user individually.

Default roles
~~~~~~~~~~~~~

|tcm| comes with default roles that cover three common usage scenarios:

-   **Super Admin Role** is a default role with all available
    :ref:`administrative permissions <tcm_access_control_permissions_admin>`.
    Additionally, the users with this role automatically gain all
    :ref:`cluster permissions <tcm_access_control_permissions_cluster>`
    to all clusters.
-   **Cluster Admin Role** is a default role for cluster administration. It includes
    administrative permissions for cluster management.
-   **Default User Role** is a default role for working with clusters. It includes
    basic administrative *read* permissions that are required to log in to |tcm|
    and navigate to a cluster.

Managing roles
~~~~~~~~~~~~~~

Administrators can create new roles, edit, and delete existing ones.

Roles are listed on the **Roles** page.

To create a new role, click **Add**, enter the role name, and select the permissions
to include in the role.

To edit an existing role, click **Edit** in the **Actions** menu of the corresponding
table row.

To delete a role, click **Delete** in the **Actions** menu of the corresponding
table row.

..  note::

    You can delete a role only if there are no users with this role.

Users
-----

|tcm| users gain access to objects and actions through assigned :ref:`roles <tcm_access_control_roles>`
and :ref:`cluster permissions <tcm_access_control_permissions>`.

A user can have any number of roles or none of them. Users without roles
have access only to clusters that are assigned to them.

|tcm| uses password authentication for users. For information on password management,
see the :ref:`Passwords <tcm_access_control_password>` section below.

Default admin
~~~~~~~~~~~~~

There is one default user **Default Admin**. It has all the available permissions,
both administrative and cluster ones. When new clusters are added in |tcm|,
**Default Admin** automatically receives all cluster permissions for them as well.

.. _tcm_access_control_users_manage:

Managing users
~~~~~~~~~~~~~~

Administrators can create new users, edit, and delete existing ones.

The tools for managing users are located on the **Users** page.

To create a user:

1.  Click **Add**.
2.  Fill in the user information: username, full name, and description.
3.  Generate or type in a password.
4.  Select roles to assign to the user.
5.  Add clusters to give the user access to, and select cluster permissions for
    each of them.

To edit a  user, click **Edit** in the **Actions** menu of the corresponding table row.

To delete a user, click **Delete**  in the **Actions** menu of the corresponding table row.

.. _tcm_access_control_password:

Passwords
---------

|tcm| uses the general term *secret* for user authentication keys. A secret is any
pair of a public and a private key that can be used for authentication. In |tcm| |tcm_version|,
*password* is the only supported secret type. In this case, the public key is a username,
and the private key is a password.

Users receive their first passwords during their :ref:`account creation <tcm_access_control_users_manage>`.

All passwords are governed by the :ref:`password policy <tcm_access_control_password_policy>`.
It can be flexibly configured to follow the security requirements of your organization.

Changing your password
~~~~~~~~~~~~~~~~~~~~~~

To change your own password, click your name in the top-right corner and go to
**Settings** > **Change password**.

Changing users' passwords
~~~~~~~~~~~~~~~~~~~~~~~~~

Administrators can manage a user's password on this user's **Secrets** page.
To open it, click **Secrets** in the **Actions** menu of the corresponding **Users** table row.

To change a user's password, click **Edit** in the **Actions** menu of the corresponding
**Secrets** table row and enter the new password in the **New secret key** field.

.. _tcm_access_control_password_expiry:

Password expiry
~~~~~~~~~~~~~~~

Passwords expire automatically after the expiration period defined in the :ref:`password policy <tcm_access_control_password_policy>`.
When a user logs in to |tcm| with an expired password, the only action available to
them is a password change. All other |tcm| functions and objects are unavailable until
the new password is set.

Administrators can also set users' passwords to expired manually.
To set a user's password to expired, click **Expire** in the **Actions**
menu of the corresponding **Secrets** table row.

.. important::

    Password expiration can't be reverted.

Blocking passwords
~~~~~~~~~~~~~~~~~~

To forbid users' access to |tcm|, administrators can temporarily block their
passwords. A blocked password can't be used to log into |tcm| until it's
unblocked manually or the blocking period expires.

To block a user's password, click **Block** in the **Actions** menu of the corresponding
**Secrets** table row. Then provide a blocking reason and enter the blocking period.

To unblock a blocked password, click **Unblock** in the **Actions** menu of the corresponding
**Secrets** table row.

.. _tcm_access_control_password_policy:

Password policy
~~~~~~~~~~~~~~~

Password policy helps improve security and comply with security requirements that
can apply to your organization.

You can edit the |tcm| password policy on the **Password policy** page.
There are the following password policy settings:

-   **Minimal password length**.
-   **Do not use last N passwords**.
-   **Password expiration in days**. Users' passwords :ref:`expire <tcm_access_control_password_expiry>`
    after this number of days since they were set. Users with expired passwords
    lose access to any objects and functions except password change until they set
    a new password.
-   **Password expiration warning in days**. After this number of days, the user
    sees a warning that their password expires soon.
-   **Block after N login attempts**. Temporarily block users if they enter their
    username or password incorrectly this number of times consecutively.
-   **User lockout time in seconds**. The time interval for which users can't log
    in after spending all failed login attempts.
-   **Password must include**. Characters and symbols that must be present in passwords:

    -   **Lowercase characters (a-z)**
    -   **Uppercase characters (A-Z)**
    -   **Digits (0-9)**
    -   **Symbols (such as !@#$%^&\*()_+№"':,.;=][{}`?>/.)**

.. _tcm_access_control_acl:

Access control list
-------------------

|tcm|'s *access control list* (*ACL*) determines user access to particular data
and functions stored in clusters. You can use it to allow or deny access to specific
stored objects one by one.

Each ACL entry specifies privileges that a |tcm| user's privileges has on a particular
space or a function. There are three access privileges that can be granted in the ACL:
read, write, and execute (for stored functions only). The privileges work as follows:

-   Spaces:

    - ``Read``: the user sees the space and its tuples on the **Tuples** and **Explorer** pages
    - ``Write``: the user can add new and edit existing tuples of the space

-   Functions:

    - ``Read``: the user sees the function on the **Functions** tab of the instance details page.
    - ``Write``: the user can edit or delete the function
    - ``Execute``: the user can call the function


.. important::

    Users' access to space data and stored functions is primarily defined by the
    :ref:`cluster permissions <tcm_access_control_permissions_cluster>` ``cluster.space.data.*`` and ``cluster.func.*``.
    ACL only increases the access control granularity to particular objects.
    Make sure that users have these permissions before enabling ACL for them.

To granularly manage a user's access to particular objects in a cluster, enable
the use of ACL in this user's account settings:

#.  Go to users and click **Edit** in the **Actions** menu of the corresponding table row.

#.  In the user's **Clusters** list, add a cluster on which you want to use ACL
    or click the pencil icon if the cluster is already on the list.

#.  Select the **Use Access Control List (ACL)** checkbox and save changes.

#.  Repeat two previous steps for each cluster on which you want to use ACL for this user.

#.  Click **Update** to save the user account.

If the user doesn't exist yet, you can do the same when creating it.

.. important::

    When ACL use is enabled for a user, this user loses access to all spaces and
    functions of the selected cluster except the ones explicitly specified in the ACL.

The tools for managing ACL are located on the **ACL** page.

To add an ACL entry:

#.  Click **Add**.
#.  Select a user to which you want to grant access.
#.  Select a cluster that stores the target object: a space or a function.
#.  Select the target object type and enter its name.
#.  Select the privileges you want to grant.

To delete an ACL entry, click **Delete** in the **Actions** menu of the corresponding table row.


.. _tcm_access_control_sessions:

Sessions
--------

Administrators can view and revoke user sessions in |tcm|. All active sessions
are listed on the **Sessions** page. To revoke a session, click **Revoke** in the
**Actions** menu of the corresponding table row.

To revoke all sessions of a user, go to **Users** and click **Revoke all sessions**
in the **Actions** menu of the corresponding table row.

.. _tcm_access_control_permissions_ref:

Permissions reference
---------------------

.. _tcm_access_control_permissions_admin:

Administrative permissions
~~~~~~~~~~~~~~~~~~~~~~~~~~

The following administrative permissions are available in |tcm|:

..  list-table::
    :widths: auto
    :header-rows: 1

    *   -   Permission
        -   Description

    *   -   ``admin.clusters.read``
        -   View connected clusters' details

    *   -   ``admin.clusters.write``
        -   Edit cluster details and add new clusters

    *   -   ``admin.users.read``
        -   View users' details

    *   -   ``admin.users.write``
        -   Edit user details and add new users

    *   -   ``admin.roles.read``
        -   View roles' details

    *   -   ``admin.roles.write``
        -   Edit roles and add new roles

    *   -   ``admin.addons.read``
        -   View add-ons

    *   -   ``admin.addons.write``
        -   Edit add-on flags

    *   -   ``admin.addons.upload``
        -   Upload new add-ons

    *   -   ``admin.auditlog.read``
        -   View audit log configuration and read audit log in |tcm|

    *   -   ``admin.auditlog.write``
        -   Edit audit log configuration

    *   -   ``admin.sessions.read``
        -   View users' sessions

    *   -   ``admin.sessions.write``
        -   Revoke users' sessions

    *   -   ``admin.ldap.read``
        -   View LDAP configurations

    *   -   ``admin.ldap.write``
        -   Manage LDAP configurations

    *   -   ``admin.passwordpolicy.read``
        -   View password policy

    *   -   ``admin.passwordpolicy.write``
        -   Manage password policy

    *   -   ``admin.secrets.read``
        -   View information about users' secrets

    *   -   ``admin.secrets.write``
        -   Manage users' secrets: add, edit, expire, block, delete

    *   -   ``user.password.change``
        -   User's permission to change their own password

    *   -   ``user.api-token.read``
        -   User's permission to read their own API tokens information

    *   -   ``user.api-token.write``
        -   User's permission to modify their own API tokens

    *   -   ``admin.metrics``
        -   Read |tcm| metrics

    *   -   ``admin.acl.read``
        -   View the access control list (ACL)

    *   -   ``admin.acl.write``
        -   Add and delete ACL entries

.. _tcm_access_control_permissions_cluster:

Cluster permissions
~~~~~~~~~~~~~~~~~~~

The following cluster permissions are available in |tcm|:

..  list-table::
    :widths: auto
    :header-rows: 1

    *   -   Permission
        -   Description

    *   -   ``cluster.config.read``
        -   View cluster configuration

    *   -   ``cluster.config.write``
        -   Manage cluster configuration

    *   -   ``cluster.stateboard.read``
        -   View cluster stateboard

    *   -   ``cluster.func.read``
        -   View cluster's stored functions

    *   -   ``cluster.func.write``
        -   Edit cluster's stored functions

    *   -   ``cluster.func.call``
        -   Execute stored functions on cluster instances

    *   -   ``cluster.space.read``
        -   Read cluster data schema

    *   -   ``cluster.space.write``
        -   Modify cluster data schema

    *   -   ``cluster.space.data.read``
        -   Read stored data from cluster

    *   -   ``cluster.space.data.write``
        -   Edit stored data on cluster

    *   -   ``cluster.failover.read``
        -   Read cluster failover information

    *   -   ``cluster.failover.write``
        -   Write cluster failover commands

    *   -   ``cluster.terminal``
        -   Connect to cluster instances with ``tt`` terminal from |TCM|

    *   -   ``cluster.sql``
        -   Execute SQL queries

    *   -   ``cluster.metrics``
        -   View cluster metrics

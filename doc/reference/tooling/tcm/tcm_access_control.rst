..  _tcm_access_control:

Access control
==============

..  admonition:: Enterprise Edition
    :class: fact

    |tcm_full_name| is a part of the `Enterprise Edition <https://www.tarantool.io/compare/>`_.

|tcm_full_name| features a role-based access control system. It enables flexible
management of access to |tcm| functions, connected clusters, and stored data.
There are three main entities in the |tcm| access system: permissions, roles,
and users (or user accounts). They work as follows:

-   Permissions correspond to specific functions or objects in
    |tcm| (*administrative permissions*) or operations on clusters (*cluster permissions*).
-   Roles are predefined sets of *administrative* permissions to
    assign to users.
-   Users have roles that define their access rights to |tcm| function and objects, and
    *cluster* permissions that are assigned for each cluster separately.

..  note::

    |tcm| users, roles, and permissions are not to be confused with similar subjects
    of :ref:`Tarantool access control system <authentication>`. To access Tarantool
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
    These permission are granted to users on a per-cluster level: each user has a separate
    set of permissions for each cluster.

    Technically, cluster permissions define pages shown in the **Cluster** section
    of the left menu and controls available on these pages. For example, users
    with the read configuration permission to a cluster configuration see the **Configuration**
    page when this cluster is selected.

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
Each user can have any number of roles, including zero. Users without roles
have access only to clusters that are assigned to them.

|tcm| uses password authentication for users. For information on password management,
see the :ref:`Passwords <tcm_access_control_password>` section below.

Default admin
~~~~~~~~~~~~~

There is one default user **Default Admin**. It has all the available permissions,
both administrative and cluster ones. When new clusters are added in |tcm|,
**Default Admin** automatically receives all cluster permissions for them as well.

Managing users
~~~~~~~~~~~~~~

Administrators can create new users, edit, and delete existing ones.

The tools for managing users are located on the **Users** page.

To create a user:

1.  Click **Add**.
2.  Fill in the user information: username, full name, and description.
3.  Generate or enter a password.
4.  Select roles to assign to user.
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

Users receive their first passwords during the account creation. It can be entered
manually or generated automatically.

All passwords are governed by the :ref:`password policy <tcm_access_control_password_policy>`.
It can be flexibly configured to follow security requirements of your organization.

Changing your password
~~~~~~~~~~~~~~~~~~~~~~

To change your own password, click your name in the top-right corner and go to
**Settings** > **Change password**.

Changing users' passwords
~~~~~~~~~~~~~~~~~~~~~~~~~

Administrators can manage a user's passwords on this user's **Secrets** page.
To open it, click **Secrets** in the **Actions** menu of the corresponding **Users** table row.

To change a user's password, click **Edit** in the **Actions** menu of the corresponding
**Secrets** table row and enter the new password in the **New secret key** field.

Password expiry
~~~~~~~~~~~~~~~

Passwords expire automatically after the expiration period defined in the :ref:`password policy <tcm_access_control_password_policy>`.
When a user logs in to |tcm| with an expired password, the only action available to
them is password change. All other |tcm| functions and objects are unavailable until
the new password is set.

Administrators can also set users' password to expired manually.
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
-   **Password expiration in days**. After this number of days, the user loses access
    to any objects and functions except password change. After they change the password,
    all the access rights are returned.
-   **Password expiration warning in days**. After this number of days, the user
    sees a warning that they must change their password.
-   **Block after N login attempts**.
-   **User lockout time in seconds**.
-   **Password must include**. Characters and symbols that must be present in passwords:

    -   **Lowercase characters (a-z)**
    -   **Uppercase characters (A-Z)**
    -   **Digits (0-9)**
    -   **Symbols (such as !@#$%^&\*()_+№"':,.;=][{}`?>/.)**

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
    :widths: 30 70
    :header-rows: 1

    *   -   Permission
        -   Description

    *   -   ``admin.clusters.read``
        -   View connected clusters

    *   -   ``admin.clusters.write``
        -   Edit cluster details and add new clusters

    *   -   ``admin.users.read``
        -   View users

    *   -   ``admin.users.write``
        -   Edit user details and add new users

    *   -   ``admin.roles.read``
        -   View roles

    *   -   ``admin.roles.write``
        -   Edit roles and add new roles

    *   -   ``admin.lowlevel.state.read``
        -   Read low-level information from |tcm| storage

    *   -   ``admin.lowlevel.state.write``
        -   Write low-level information from |tcm| storage

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

    *   -  ``admin.devmode.toggle``
        -   Toggle development mode

    *   -   ``user.password.change``
        -   Change own password

    *   -   ``admin.secrets.read``
        -   View users' secrets.

    *   -   ``admin.secrets.write``
        -   Manage users' secrets: add, edit, expire, block, delete.

.. _tcm_access_control_permissions_cluster:

Cluster permissions
~~~~~~~~~~~~~~~~~~~

The following cluster permissions are available in |tcm|:

..  list-table::
    :widths: 35 65
    :header-rows: 1

    *   -   Permission
        -   Description

    *   -   ``cluster.lowlevel.state.read``
        -   Read low-level information from |tcm| storage

    *   -   ``cluster.lowlevel.state.write``
        -   Description

    *   -   ``cluster.lowlevel.metrics.read``
        -   Description

    *   -   ``cluster.config.read``
        -   View cluster configuration

    *   -   ``cluster.config.write``
        -   Manage cluster configuration

    *   -   ``cluster.stateboard.read``
        -   View cluster stateboard

    *   -   ``cluster.explorer.read``
        -   Read data from the cluster instances

    *   -   ``cluster.explorer.write``
        -   Write data to the cluster instances

    *   -   ``cluster.explorer.call``
        -   Execute stored functions on the cluster instances

    *   -   ``cluster.explorer.eval``
        -   Execute code on the cluster instances

    *   -   ``cluster.space.read``
        -   Read cluster data schema

    *   -   ``cluster.space.write``
        -   Modify cluster data schema
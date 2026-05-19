.. _tcm_releases_1_8:

Tarantool Cluster Manager 1.8
=============================

Release date: March 13, 2026

Latest release in series: 1.8.1

|tcm| 1.8.0 improves LDAP reliability, expands the CLI with full user and role administration capabilities,
and adds safer behavior when creating clusters.
This release also includes fixes that improve authentication stability after failed login attempts and correct data rendering in the tuples tab.

.. _tcm_releases_1_8_ldap:

LDAP improvements
-----------------

|tcm| 1.8.0 introduces support for cascading LDAP connections in environments where multiple LDAP domains share the same domain name.
Instead of failing on the first unreachable domain, TCM now tries each configured domain sequentially until a successful connection is established.

.. _tcm_releases_1_8_new_cli_commands:

New CLI commands for user and role management
---------------------------------------------

This release adds dedicated CLI commands to manage users and roles without relying on the UI.
You can now create and delete users using `tcm user add` and `tcm user delete`, and create, update, or delete roles using `tcm role add`, `tcm role update`, and `tcm role delete`.

When creating users, the CLI supports assigning multiple roles and granting access to multiple clusters (including per-cluster permissions and ACL on/off).
Passwords are validated against the configured password policy, and operations provide detailed logging to support auditing and traceability.

Example of user creation:

.. code-block:: console

    .. tcm user add

    --fullname 'John Doe'
    --description 'System administrator'
    --role admin-role-id
    --role operator-role-id
    --clusters cluster-id-1:cluster.config.read,cluster.config.write:true
    --clusters cluster-id-2:cluster.config.read:false
    --secret-type password
    --public-key john-public-key
    --secret-key john-secret-key

    .. tcm role add

    --name 'Cluster Administrator'
    --description 'Full access to cluster configuration and management'
    --permission admin.clusters.read
    --permission admin.clusters.write
    --permission admin.users.read
    --permission admin.users.write

.. _tcm_releases_1_8_cluster:

Safer cluster creation
----------------------

To prevent configuration mistakes, |tcm| now shows a warning when attempting to create a new cluster using an ID that already exists.
This helps catch ID conflicts early and reduces the chance of accidental misconfiguration.

.. _tcm_releases_1_8_fixes:

Fixes
-----

-   Fixed an issue where, after several failed login attempts followed by a successful login, an error could occur during logout.
-   Fixed an issue in the **Tuples** tab where scrolling could trigger a “data could not be found” error when connected to a cluster with multiple storages.
-   Improved the error returned when hitting the WebSession limit: previously it could be uninformative.

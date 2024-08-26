..  _tcm_access_control:

Access control
==============

..  include:: ../index.rst
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
    *cluster* permissions that are assigned for each cluster individually.

..  note::

    |tcm| users, roles, and permissions are not to be confused with similar subjects
    of the :ref:`Tarantool access control system <access_control>`. To access Tarantool
    instances directly, Tarantool users with corresponding roles are required.

..  toctree::
    :maxdepth: 1

    tcm_access_control_rbac
    tcm_access_control_list
    tcm_api_tokens
    tcm_ldap_auth
    tcm_sessions
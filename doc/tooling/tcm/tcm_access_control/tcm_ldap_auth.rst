..  _tcm_ldap_auth:

LDAP authentication
===================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

In addition to its internal :ref:`role-based access control model <tcm_access_control_rbac>`,
|tcm_full_name| can use an external LDAP (Lightweight Directory Access Protocol)
directory server for user authentication and authorization.

When LDAP authentication is enabled, |tcm| attempts to authenticate users who submit
the login form on a connected LDAP directory server. |tcm| constructs requests to
the servers according to configuration parameters described on this page. Permissions
of LDAP users in |tcm| are defined by LDAP group mapping.

Both LDAP and secure LDAPS (LDAP over TLS) protocols are supported.

..  _tcm_ldap_auth_enable:

Enabling LDAP authentication
----------------------------

To allow LDAP user authentication in |tcm|, enable the ``ldap`` authentication method
in the :ref:`security.auth <tcm_configuration_reference_security_auth>` configuration option before startup:

-   In the YAML |tcm| configuration:

    .. code-block:: yaml

        security:
          auth:
            - ldap

-   In the command line:

    .. code-block:: console

        $ tcm --security.auth="ldap"

.. note::

    If both authentication methods -- LDAP and local -- are enabled, |tcm| tries them
    for each login attempt in the order they are specified in the configuration.

..  _tcm_ldap_auth_config:

LDAP configuration
------------------

To enable LDAP user access to |tcm|, create an *LDAP configuration* that connects
|tcm| to the LDAP server that stores the users. An LDAP configuration
defines how |tcm| connects to the server and queries user data. To create a LDAP
configuration, go to the **LDAP** page and click **Add**.

To edit a LDAP configuration, click **Edit** in the **Actions** menu of the corresponding row.

To delete a LDAP configuration, click **Delete** in the **Actions** menu of the corresponding row.

..  _tcm_ldap_auth_config_general:

General settings
~~~~~~~~~~~~~~~~

Define the general configuration settings:

*   **Enabled**. Defines if the configuration is used. Turn the toggle off to
    stop using the configuration.

    .. note::

        If there are several enabled LDAP configurations, |tcm| attempts to use them
        for user authentication in the order they are created.

*   **Automatically add non-existent users**. By default, |tcm| automatically saves
    LDAP user information to its :ref:`backend store <tcm_backend_store>`
    upon their first login. Turn the toggle off if you don't want to save users from this LDAP server.

..  _tcm_ldap_auth_config_connect:

LDAP server connection
~~~~~~~~~~~~~~~~~~~~~~

Enter the LDAP server connection parameters:

*   **Endpoints**. URLs of the LDAP server.
*   **Request timeout**. The timeout for |tcm| requests to the LDAP server, in seconds.
*   **Enabled TLS**. If the server uses LDAPS, turn this toggle on and specify
    TLS connection parameters, such as a certificate and a key file.

..  _tcm_ldap_auth_config_query:

LDAP queries
~~~~~~~~~~~~

To define how |tcm| queries the LDAP server for user authentication and authorization,
fill in the fields of the **Queries** step:

-   **Query user** and **Query password**. Credentials of the LDAP user on behalf
    of which all LDAP queries are executed: a distinguished name (DN) and a password.
    Example DN: ``cn=admin,cn=users,dc=tarantool,dc=io``.
-   **Base DN**. The DN of a directory that serves as a root for making all LDAP requests.
    Example: ``dc=tarantool,dc=io``.
-   **Username regex**. A regular expression that defines a username template for
    this LDAP configuration. When a user enters their username on the login page,
    |tcm| matches it against username regular expressions of all enabled LDAP
    configurations and selects the one to use for this user authentication.
    Example: ``^([\w\-\.]+)@tarantool.io$`` -- a regex to match employee
    email addresses within the specified domain.
-   **Template DN**. A template for building a DN to send in an authentication bind request.
    Use the numbers in curly braces as placeholders to replace with username regex parts:
    ``{0}``, ``{1}`` and so on.
    Example: ``cn={0},cn=users,dc=tarantool,dc=io``. When used with the **Username regex**
    shown above, it substitutes ``{0}`` with the username part of the email address (before ``@``)
    entered into the login form. For example, the username ``user1@tarantool.io``
    forms the following DN for bind request: ``cn=user1,cn=users,dc=tarantool,dc=io``.
-   **Template query**. A template for querying the LDAP server for the DN. This
    way is used if **Template DN** is not provided.
-   **Group query template**. A template for querying groups to which a user belongs
    for authorization purposes. Learn more in :ref:`tcm_ldap_auth_config_permissions`.
    Example: ``(&(objectCategory=person)(objectClass=user)(cn={0}))``


..  _tcm_ldap_auth_config_permissions:

LDAP user permissions
~~~~~~~~~~~~~~~~~~~~~

Permissions of LDAP users in |tcm| are defined by groups to which they belong.
You can map |tcm| administrative and cluster :ref:`permissions <tcm_access_control_permissions>`
to LDAP groups on the **Groups** step of the configuration creation.

To assign permissions to an LDAP group, click **Add group**. In the dialog that opens,
enter the group name, for example, ``CN=Admins,CN=Builtin,DC=tarantool,DC=io``.
Then, select administrative permission to grant to this group in the **Permissions** list.

To grant cluster permissions, click **Add cluster**. Select a cluster and the cluster
permissions to grant to the group. Save the group.

Each user has permissions of all LDAP groups to which they belong.


..  _tcm_ldap_auth_config_disable:

Disabling LDAP configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To stop using an LDAP configuration, open its **Edit** page and turn off the **Enabled** toggle.
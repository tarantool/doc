..  _tcm_ldap_auth:

LDAP authentication
===================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

In addition to its internal :ref:`role-based access model <tcm_access_control_rbac>`,
|tcm_full_name| can be configured to use an external LDAP (Lightweight Directory Access Protocol)
server for user authentication. Both LDAP and secure LDAPS (LDAP over TLS)
protocols are supported.

|tcm| intergrates wit LDAP servers via *LDAP configurations*. A LDAP configuration
defines a
To manage access permissions of LDAP users, you can define a set of |tcm|
:ref:`administrative and cluster permissions <tcm_access_control_permissions>`
for each LDAP group. When authenticating an external user,
|tcm| checks this user's groups and displays the corresponding pages and controls.

- can use ldap
- your own server
- over TLS
- distinct access
- local auth vs ldap?

- prereq
- conflicts

..  _tcm_ldap_auth_enable:

Enabling LDAP authentication
----------------------------

To allow LDAP user authentication in |tcm|, enable the ``ldap`` authentication method
in the :ref:`security.auth <tcm_configuration_reference_security_auth>` configuration option before startup:

- In the YAML |tcm| configuration:

    .. code-block:: yaml

        security:
          auth:
            - ldap

- In the command line:

    .. code-block:: console

        $ tcm --security.auth="ldap"

.. note::

    If both authentication methods -- LDAP and local -- are enabled, |tcm| tries them
    for each login attempt in the order they are specified in the configuration.

..  _tcm_ldap_auth_config:

LDAP configuration
------------------

To connect |tcm| to your LDAP server, create a *LDAP configuration*. A LDAP configuration
defines how |tcm| connects to the server and queries user data.

To create a LDAP configuration, go to the **LDAP** page and click **Add**.

.. note::

    If there are several enabled LDAP configurations, |tcm| attempts to use them for
    user authentication in the order they are created.


..  _tcm_ldap_auth_config_connect:

LDAP server connection
~~~~~~~~~~~~~~~~~~~~~~

The LDAP server connection parameters are defines on the **General** step of the
configuration creation. Enter the LDAP server endpoints and request timeout
in seconds. If the server uses LDAPS, toggle **Enabled TLS** and specify
TLS connection parameters, such as a certificate or a key file.

Toggle **Automatically add non-existent users** to automatically save LDAP
users to the |tcm| :ref:`backend store <tcm_backend_store>` upon their first login.


..  _tcm_ldap_auth_config_query:

LDAP queries
~~~~~~~~~~~~

To define how |tcm|

#.  On the **Queries** page, specify the parameters of |tcm| queries to the LDAP server:

    -   **Query user** and **Query password**. Credentials of the user on behalf of
        which all LDAP queries are executed: distinguished name (DN) and password.
    -   **Base DN**. The base DN for making all LDAP requests.
    -   **Username regex**. A regular expression that defines a username template for
        this LDAP configuration. This regex is used for selecting a correct LDAP server
        by a username.
    -   **Template DN**. A template for building a DN

To edit a LDAP configuration, click **Edit** in the **Actions** menu of the corresponding table row.

To delete a LDAP configuration, click **Delete** in the **Actions** menu of the corresponding table row.

..  _tcm_ldap_auth_config_permissions:

LDAP user permissions
~~~~~~~~~~~~~~~~~~~~~

LDAP users' permissions in |tcm| are defined by groups to which they belong.
You can map |tcm| administrative and cluster :ref:`permissions <tcm_access_control_permissions>`
to LDAP groups on the **Groups** step of the configuration creation.

To assign permissions to an LDAP group, click **Add group**. In the dialog that opens,
enter the group name, for example, ``CN=Admins,CN=Builtin,DC=example,DC=com``.
Then, select administrative permission to grant in the **Permissions** list.

To grant cluster permissions, click **Add cluster**. Select a cluster and the cluster
permissions to grant to the group. Save the group.

Each user has permissions of all LDAP groups to which they belong.

..  _tcm_ldap_auth_config_disable:

Disabling LDAP configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To stop using a LDAP configuration, open its **Edit** page and turn off the **Enabled** toggle.





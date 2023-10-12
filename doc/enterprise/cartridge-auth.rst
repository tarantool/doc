..  _enterprise-cartridge-auth:

LDAP authorization
==================

This chapter describes how to manage the access roles for LDAP users authorizing in your Cartridge application.

Setting up this feature is twofold:

*   :ref:`enabling the feature <enterprise-cartridge-auth-config>` for your application
*   :ref:`specifying configuration parameters <enterprise-cartridge-auth-config>`.

..  note::

    For information on setting up the authorization of external users in your application, refer to :ref:`ldap_auth`.

..  _enterprise-cartridge-auth-enable:

Enabling LDAP authorization
---------------------------

First, you should enable LDAP authorization function in your :ref:`application development project <cartridge-project>`:

*   set up dependency to the ``cartridge-auth-extension`` module that is available in the :ref:`Enterprise Edition's package <enterprise-package-contents>`.
*   update the configuration in the application initialization file.

..  note::

    If you don't have a development project yet, refer to :doc:`dev` on how to create it.

1.  In your development project, find a ``.rockspec`` file and specify the following dependency:

    ..  code-block:: bash

        dependencies = {
            'cartridge-auth-extension'
        }

2.  In an initialization Lua file of your project, specify the ``cartridge-auth-extension`` :ref:`cluster role <cartridge-roles>` in the :ref:`Cartridge configuration <cartridge.cfg>`.
    The role enables storing authorized users and validating the :ref:`LDAP configuration <enterprise-cartridge-auth-config>`.

    ..  code-block:: lua

        cartridge.cfg({
            roles = {
               'cartridge-auth-extension',
            },
            auth_backend_name = 'cartridge-auth-extension',
        })

3.  Deploy and start your application. For details, refer to :doc:`dev`.

..  _enterprise-cartridge-auth-config:

Configuring LDAP authorization
------------------------------

After starting your application, you need to configure LDAP authorization. It can be done via the GUI administrative console.

1.  In a web browser, open the GUI administrative console of your application.

2.  If you have the application instances already configured, proceed to the next step. Otherwise, refer to :ref:`cartridge-deployment` on how to configure the cluster.

3.  In the GUI administrative console, navigate to the **Code** tab. Create the following YAML configuration files and specify the necessary parameters.
    Below is the example of configuration and the :ref:`description of parameters <enterprise-cartridge-auth-config-params>`.

..  note::

    If you set the authorization mode as ``local`` in the ``auth_extension.yml`` file, you don't need to define LDAP configuration parameters in the ``ldap.yml`` file.


*   ``auth_extension.yml``

    ..  code-block:: yaml

        method: local+ldap

*   ``ldap.yml``

    ..  code-block:: yaml

        - domain: 'test.glauth.com'
          organizational_units: ['all_staff']
          hosts:
            - localhost:3893
          use_tls: false
          use_active_directory: false
          search_timeout: 2
          roles:
            - role: 'admin'
              domain_groups:
                - 'cn=superusers,ou=groups,dc=glauth,dc=com'
                - 'cn=users,ou=groups,dc=glauth,dc=com'
          options:
            LDAP_OPT_DEBUG_LEVEL: 10

*   ``auth.yml``

    ..  code-block:: yaml

        enabled: true

..  _enterprise-cartridge-auth-config-params:

**Configuration parameters:**

*   ``method`` -- authorization mode. Possible values:

    *   ``local`` -- only local users can be authorized in the application. "Local" refers to users created in the application.
    *   ``ldap`` -- only LDAP users can be authorized.
    *   ``local+ldap`` -- both local and LDAP users can be authorized.

*   ``domain`` -- domain name that is used in the domain login ID (``user_name@domain``).

*   ``organizational_units`` -- names of the organizational units or user groups.

*   ``hosts`` -- LDAP server addresses.

*   ``use_tls`` -- boolean flag that defines TLS usage. Defaults to ``false``.

*   ``use_active_directory`` -- boolean flag that defines usage of the Active Directory. Defaults to ``false``.
    If set to ``true``, use the login ID in the email format (``user_name@domain``).
    The ID should be equal to the ``userPrincipalName`` Active Directory attribute value because the latter is used in the Active Directory filter.

*   ``search_timeout`` -- LDAP server response timeout. Defaults to 2 seconds.

*   ``roles`` -- user roles assigned to a user depending on the LDAP groups the user belongs to:

    *   ``role`` -- user role;
    *   ``domain_groups`` -- LDAP groups where ``cn`` -- common name; ``ou`` -- organization unit name; ``dc`` -- domain component.

*   ``options`` -- the OpenLDAP library options. Supported options:

    *   LDAP_OPT_X_TLS_REQUIRE_CERT
    *   LDAP_OPT_PROTOCOL_VERSION
    *   LDAP_OPT_DEBUG_LEVEL
    *   LDAP_OPT_X_TLS_CACERTFILE
    *   LDAP_OPT_X_TLS_CACERTDIR.

    For description of the options, refer to the `OpenLDAP documentation <https://www.openldap.org/doc/>`__.

*   ``enabled`` -- boolean flag. If set to ``true``, enables mandatory authentication mode in the application web interface.


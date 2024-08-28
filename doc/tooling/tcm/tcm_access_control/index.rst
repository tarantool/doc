..  _tcm_access_control:

Access control
==============

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides means for managing user and client applications access
to its own functions and connected clusters:

-   :ref:`Local role-based access model <tcm_access_control_rbac>` allow flexible
    access management with user accounts created inside |tcm|.
-   :ref:`LDAP authentication <tcm_ldap_auth>` enable authentication with an external
    directory server.
-   :ref:`Access control list <tcm_access_control_list>` enables fine-grained access
    to entities stored on connected clusters.
-   :ref:`API tokens <tcm_access_control_api_tokens>` enable integration with third-party applications.
-   :ref:`Sessions management <tcm_access_control_sessions>` allow administrators to view and
    revoke user sessions.


..  toctree::
    :maxdepth: 1

    tcm_access_control_rbac
    tcm_ldap_auth
    tcm_access_control_list
    tcm_api_tokens
    tcm_sessions
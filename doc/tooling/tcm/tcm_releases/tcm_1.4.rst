.. _tcm_releases_1_4:

Tarantool Cluster Manager 1.4
=============================

Release date: June 9, 2025

Latest release in series: 1.4.0

|tcm_full_name| 1.4.0 improves LDAP support and includes several enhancements and fixes aimed at improving authentication flexibility and system stability.

.. _tcm_releases_1_4_0_ldap:

LDAP support improvements
------------------------

|tcm| 1.4.0 significantly enhances the experience of working with LDAP authentication.
The web interface now includes a visual confirmation pop-up when a connection to an LDAP server is successfully established.
This helps administrators quickly verify the correctness of LDAP settings without checking logs or reloading the page.

The authentication settings now support switching between local and LDAP methods directly in the interface, making it easier to configure hybrid or alternative access scenarios.

The LDAP configuration form has been simplified:

* ``groupQueryTemplate`` field is now optional, allowing LDAP authentication without querying for user groups.
* ``queryUser`` and ``queryPassword`` fields are also optional, which enables anonymous binding to the LDAP server.
* You now only need to provide either ``templateDN`` or ``templateQuery``, instead of both -- reducing configuration complexity.

More about :ref:`tcm_ldap_auth`.


.. _tcm_releases_1_4_0_infra_fixes:

LDAP support improvements
------------------------

In version 1.4.0, |tcm| improves the behavior of the etcd client.
Previously, if one of the etcd nodes became unresponsive while keeping its port open, the client could hang indefinitely.
This issue has been fixed to ensure better resilience of etcd-based components.

Additionally, the audit log mechanism now correctly creates log files in the directory of the running application binary.
To learn more, see :ref:`tcm_audit_log_config`.

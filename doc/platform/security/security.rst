.. _enterprise-security:

Security hardening guide
========================

This guide explains how to enhance security in your Tarantool Enterprise Edition's
cluster using built-in features and provides general recommendations on security
hardening.
If you need to perform a security audit of a Tarantool Enterprise cluster,
refer to the :doc:`security checklist <audit>`.

Tarantool Enterprise Edition does not provide a dedicated API for security control. All
the necessary configurations can be done via an administrative console or
initialization code.

Tarantool Enterprise Edition has the following built-in security features:

*  :ref:`authentication <configuration_authentication>`
*  :ref:`access control <enterprise-access-control>`
*  :ref:`audit log <enterprise-logging>`
*  :ref:`traffic encryption <enterprise-iproto-encryption>`


.. _enterprise-authentication:

Authentication
--------------

Tarantool Enterprise Edition supports password-based authentication and allows for two
types of connections:

* Via an :doc:`administrative console </reference/reference_lua/console>`.
* Over a binary port for read and write operations and procedure invocation.

For more information on authentication and connection types, see the
:ref:`admin-security` section in :ref:`Administration <admin>`.

In addition, Tarantool provides the following functionality:

* :ref:`Sessions <authentication-sessions>`
  -- states which associate connections with users and make Tarantool API available
  to them after authentication.
* Authentication :ref:`triggers <triggers-box_triggers>`,
  which execute actions on authentication events.
* Third-party (external) authentication protocols and services such as LDAP or
  Active Directory -- supported in the web interface, but unavailable
  on the binary-protocol level.

.. _enterprise-access-control:

Access control
--------------

Tarantool Enterprise Edition provides the means for administrators to prevent
unauthorized access to the database and to certain functions.

Tarantool recognizes:

* different users (guests and administrators)
* privileges associated with users
* roles (containers for privileges) granted to users

The following system spaces are used to store users and privileges:

* The ``_user`` space to store usernames and hashed passwords for authentication.
* The ``_priv`` space to store privileges for access control.

For more information, see the
:ref:`Access control <authentication-users>` section.

Users who create **objects** (spaces, indexes, users, roles, sequences, and
functions) in the database become their **owners** and automatically acquire
privileges for what they create. For more information, see the
:ref:`Owners and privileges <authentication-owners_privileges>` section.



.. _enterprise-logging:

Audit log
---------

Tarantool Enterprise Edition has a built-in audit log that records events such as:

* authentication successes and failures
* connection closures
* creation, removal, enabling, and disabling of users
* changes of passwords, privileges, and roles
* denials of access to database objects

The audit log contains:

* timestamps
* usernames of users who performed actions
* event types (for example, ``user_create``, ``user_enable``, ``disconnect``)
* descriptions

You can configure the following audit log options:

*   :ref:`audit_log.to <configuration_reference_audit_to>` -- enable audit logging and define the log location (file, pipe, or syslog).
    The option is similar to the :ref:`log <cfg_logging-log>`.

*   :ref:`audit_log.nonblock <configuration_reference_audit_nonblock>` -- specify the logging behavior if the system is not ready to write.
    The option is similar to the :ref:`log_nonblock <cfg_logging-log_nonblock>`.

For more information on logging, see the following:

*   the :ref:`admin-logs` section
*   the :ref:`log <configuration_reference_log>` section in the configuration reference
*   the :ref:`Tarantool audit module <enterprise_audit_module>` topic

Access permissions to audit log files can be set up as to any other Unix file
system object -- via ``chmod``.



.. _enterprise-security-hardening:

Recommendations on security hardening
-------------------------------------

This section lists recommendations that can help you harden the cluster's security.

.. _enterprise-traffic-encryption:

Encrypting traffic
~~~~~~~~~~~~~~~~~~

Since version 2.10.0, Tarantool Enterprise Edition has built-in support for using SSL to encrypt the client-server communications over binary connections,
that is, between Tarantool instances in a cluster. For details on enabling SSL encryption, see the :ref:`enterprise-iproto-encryption` section of this guide.

In case the built-in encryption is not set for particular connections, consider the following security recommendations:

* setting up connection tunneling, or
* encrypting the actual data stored in the database.

For more information on data encryption, see the
:doc:`crypto module reference </reference/reference_lua/crypto>`.

The `HTTP server module <https://github.com/tarantool/http>`_ provided by rocks
does not support the HTTPS protocol. To set up a secure connection for a client
(e.g., REST service), consider hiding the Tarantool instance (router if it is
a cluster of instances) behind an Nginx server and setting up an SSL certificate
for it.

To make sure that no information can be intercepted 'from the wild', run nginx
on the same physical server as the instance and set up their communication over
a Unix socket. For more information, see the
:doc:`socket module reference </reference/reference_lua/socket>`.

.. _enterprise-firewall-config:

Firewall configuration
~~~~~~~~~~~~~~~~~~~~~~

To protect the cluster from any unwanted network activity 'from the wild',
configure the firewall on each server to allow traffic on ports listed in
:ref:`Network requirements <enterprise-prereqs-network>`.

If you are using static IP addresses, whitelist them, again, on each server as
the cluster has a full mesh network topology. Consider blacklisting all the other
addresses on all servers except the router (running behind the Nginx server).

Tarantool Enterprise does not provide defense against DoS or DDoS attacks.
Consider using third-party software instead.

.. _enterprise-integrity:

Data integrity
~~~~~~~~~~~~~~

Tarantool Enterprise Edition does not keep checksums or provide the means to control
data integrity. However, it ensures data persistence using a write-ahead log,
regularly snapshots the entire data set to disk, and checks the data format
whenever it reads the data back from the disk. For more information, see the
:ref:`Data persistence <index-box_persistence>` section.

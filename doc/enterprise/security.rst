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

*  :ref:`authentication <enterprise-authentication>`
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
:doc:`Security </book/admin/security>` section of the Tarantool manual.

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


.. _enterprise-auth-restrictions:

Authentication restrictions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tarantool Enterprise Edition provides the ability to apply additional restrictions for user authentication.
For example, you can specify the minimum time between authentication attempts
or disable access for guest users.

The following :doc:`configuration options </reference/configuration/index>` are available:

* :ref:`auth_delay <cfg_auth_delay>`
* :ref:`disable_guest <cfg_disable_guest>`


.. _cfg_auth_delay:

.. confval:: auth_delay

    Specifies a period of time (in seconds) that a specific user should wait
    for the next attempt after failed authentication.

    With the configuration below, Tarantool refuses the authentication attempt if the previous
    attempt was less than 5 seconds ago.

    .. code-block:: lua

        box.cfg{ auth_delay = 5 }


    | Since version: 2.11
    | Type: number
    | Default: 0
    | Environment variable: TT_AUTH_DELAY
    | Dynamic: **yes**


.. _cfg_disable_guest:

.. confval:: disable_guest

    If **true**, disables access over remote connections
    from unauthenticated or :ref:`guest access <authentication-passwords>` users.
    This option affects both
    :doc:`net.box </reference/reference_lua/net_box>` and
    :ref:`replication <replication-master_replica_bootstrap>` connections.

    | Since version: 2.11
    | Type: boolean
    | Default: false
    | Environment variable: TT_DISABLE_GUEST
    | Dynamic: **yes**



.. _enterprise-password-policy:

Password policy
~~~~~~~~~~~~~~~

A password policy allows you to improve database security by enforcing the use
of strong passwords, setting up a maximum password age, and so on.
When you create a new user with
:doc:`box.schema.user.create </reference/reference_lua/box_schema/user_create>`
or update the password of an existing user with
:doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`,
the password is checked against the configured password policy settings.

The following :doc:`configuration options </reference/configuration/index>` are available:

* :ref:`password_min_length <cfg_password_min_length>`
* :ref:`password_enforce_uppercase <cfg_password_enforce_uppercase>`
* :ref:`password_enforce_lowercase <cfg_password_enforce_lowercase>`
* :ref:`password_enforce_digits <cfg_password_enforce_digits>`
* :ref:`password_enforce_specialchars <cfg_password_enforce_specialchars>`
* :ref:`password_lifetime_days <cfg_password_lifetime_days>`
* :ref:`password_history_length <cfg_password_history_length>`

.. _cfg_password_min_length:

.. confval:: password_min_length

    Specifies the minimum number of characters for a password.

    The following example shows how to set the minimum password length to 10.

    .. code-block:: lua

        box.cfg{ password_min_length = 10 }

    | Since version: 2.11
    | Type: integer
    | Default: 0
    | Environment variable: TT_PASSWORD_MIN_LENGTH
    | Dynamic: **yes**


.. _cfg_password_enforce_uppercase:

.. confval:: password_enforce_uppercase

    If **true**, a password should contain uppercase letters (A-Z).

    | Since version: 2.11
    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_UPPERCASE
    | Dynamic: **yes**


.. _cfg_password_enforce_lowercase:

.. confval:: password_enforce_lowercase

    If **true**, a password should contain lowercase letters (a-z).

    | Since version: 2.11
    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_LOWERCASE
    | Dynamic: **yes**


.. _cfg_password_enforce_digits:

.. confval:: password_enforce_digits

    If **true**, a password should contain digits (0-9).

    | Since version: 2.11
    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_DIGITS
    | Dynamic: **yes**


.. _cfg_password_enforce_specialchars:

.. confval:: password_enforce_specialchars

    If **true**, a password should contain at least one special character (such as ``&|?!@$``).

    | Since version: 2.11
    | Type: boolean
    | Default: false
    | Environment variable: TT_PASSWORD_ENFORCE_SPECIALCHARS
    | Dynamic: **yes**


.. _cfg_password_lifetime_days:

.. confval:: password_lifetime_days

    Specifies the maximum period of time (in days) a user can use the same password.
    When this period ends, a user gets the "Password expired" error on a login attempt.
    To restore access for such users, use :doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`.

    .. note::

        The default 0 value means that a password never expires.

    The example below shows how to set a maximum password age to 365 days.

    .. code-block:: lua

        box.cfg{ password_lifetime_days = 365 }

    | Since version: 2.11
    | Type: integer
    | Default: 0
    | Environment variable: TT_PASSWORD_LIFETIME_DAYS
    | Dynamic: **yes**


.. _cfg_password_history_length:

.. confval:: password_history_length

    Specifies the number of unique new user passwords before an old password can be reused.

    In the example below, a new password should differ from the last three passwords.

    .. code-block:: lua

        box.cfg{ password_history_length = 3 }

    | Since version: 2.11
    | Type: integer
    | Default: 0
    | Environment variable: TT_PASSWORD_HISTORY_LENGTH
    | Dynamic: **yes**

    .. note::
        Tarantool uses the ``auth_history`` field in the
        :doc:`box.space._user </reference/reference_lua/box_space/_user>`
        system space to store user passwords.




.. _enterprise-authentication-protocol:

Authentication protocol
~~~~~~~~~~~~~~~~~~~~~~~

By default, Tarantool uses the
`CHAP <https://en.wikipedia.org/wiki/Challenge-Handshake_Authentication_Protocol>`_
protocol to authenticate users and applies ``SHA-1`` hashing to
:ref:`passwords <authentication-passwords>`.
Note that CHAP stores password hashes in the ``_user`` space unsalted.
If an attacker gains access to the database, they may crack a password, for example, using a `rainbow table <https://en.wikipedia.org/wiki/Rainbow_table>`_.

In the Enterprise Edition, you can enable
`PAP <https://en.wikipedia.org/wiki/Password_Authentication_Protocol>`_ authentication
with the ``SHA256`` hashing algorithm.
For PAP, a password is salted with a user-unique salt before saving it in the database,
which keeps the database protected from cracking using a rainbow table.

To enable PAP, specify the ``box.cfg.auth_type`` option as follows:

.. code-block:: lua

    box.cfg{ auth_type = 'pap-sha256' }

| Since version: 2.11
| Type: string
| Default value: 'chap-sha1'
| Possible values: 'chap-sha1', 'pap-sha256'
| Environment variable: TT_AUTH_TYPE
| Dynamic: **yes**

For new users, the :doc:`box.schema.user.create </reference/reference_lua/box_schema/user_create>` method
will generate authentication data using ``PAP-SHA256``.
For existing users, you need to reset a password using
:doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`
to use the new authentication protocol.

.. warning::

    Given that ``PAP`` transmits a password as plain text,
    Tarantool requires configuring :ref:`SSL/TLS <enterprise-iproto-encryption-config>`
    for a connection.

The examples below show how to specify the authentication protocol on the client side:

*   For :doc:`net.box </reference/reference_lua/net_box>`, you can
    specify the authentication protocol using the ``auth_type`` URI parameter or
    the corresponding connection option:

    .. code-block:: lua

        -- URI parameters
        conn = require('net.box').connect(
            'username:password@localhost:3301?auth_type=pap-sha256')

        -- URI parameters table
        conn = require('net.box').connect({
            uri = 'username:password@localhost:3301',
            params = {auth_type = 'pap-sha256'},
        })

        -- Connection options
        conn = require('net.box').connect('localhost:3301', {
            user = 'username',
            password = 'password',
            auth_type = 'pap-sha256',
        })

*   For :ref:`replication configuration <replication-master_replica_bootstrap>`,
    the authentication protocol can be specified in URI parameters:

    .. code-block:: lua

        -- URI parameters
        box.cfg{
            replication = {
                'replicator:password@localhost:3301?auth_type=pap-sha256',
            },
        }

        -- URI parameters table
        box.cfg{
            replication = {
                {
                    uri = 'replicator:password@localhost:3301',
                    params = {auth_type = 'pap-sha256'},
                },
            },
        }

If the authentication protocol isn't specified explicitly on the client side,
the client uses the protocol configured on the server via ``box.cfg.auth_type``.




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
* event types (e.g. ``user_create``, ``user_enable``, ``disconnect``, etc)
* descriptions

You can configure the following audit log parameters:

*   ``audit_log = <PATH_TO_FILE>`` which is similar to the
    :ref:`log <cfg_logging-log>`
    parameter. This parameter tells Tarantool to record audit events to a specific file.
*   ``audit_nonblock`` which is similar to the
    :ref:`log_nonblock <cfg_logging-log_nonblock>`
    parameter.

For more information on logging, see the following:

*   the :doc:`Logs </book/admin/logs>` section
*   the :ref:`Logging <cfg_logging-log>` section in the configuration reference
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

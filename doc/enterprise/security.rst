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

.. _enterprise-iproto-encryption:

Traffic encryption
------------------

Since version 2.10.0, Tarantool Enterprise Edition has the built-in support for using SSL to encrypt the client-server communications over :ref:`binary connections <box_protocol-iproto_protocol>`,
that is, between Tarantool instances in a cluster or connecting to an instance via connectors using :doc:`net.box </reference/reference_lua/net_box>`.

Tarantool uses the OpenSSL library that is included in the delivery package.
Please note that SSL connections use only TLSv1.2.

.. _enterprise-iproto-encryption-config:

Configuration
~~~~~~~~~~~~~

To configure traffic encryption, you need to set the special :ref:`URI parameters <index-uri-several-params>` for a particular connection.
The parameters can be set for the following ``box.cfg`` options and ``nex.box`` method:

*   :ref:`box.cfg.listen <cfg_basic-listen>` -- on the server side.
*   :ref:`box.cfg.replication <cfg_replication-replication>`--on the client side.
*   :ref:`net_box_object.connect() <net_box-connect>`--on the client side.

Below is the list of the parameters.
In the :ref:`next section <enterprise-iproto-encryption-config-sc>`, you can find details and examples on what should be configured on both the server side and the client side.

*   ``transport`` -- enables SSL encryption for a connection if set to ``ssl``.
    The default value is ``plain``, which means the encryption is off. If the parameter is not set, the encryption is off too.
    Other encryption-related parameters can be used only if the ``transport = 'ssl'`` is set.

    Example:

    ..  code-block:: lua

        c = require('net.box').connect({
            uri = 'localhost:3301',
            params = {transport = 'ssl'}
        })

*   ``ssl_key_file`` -- a path to a private SSL key file.
    Mandatory for a server.
    For a client, it's mandatory if the ``ssl_ca_file`` parameter is set for a server; otherwise, optional.
    If the private key is encrypted, provide a password for it in the ``ssl_password`` or ``ssl_password_file`` parameter.

*   ``ssl_cert_file`` -- a path to an SSL certificate file.
    Mandatory for a server.
    For a client, it's mandatory if the ``ssl_ca_file`` parameter is set for a server; otherwise, optional.

*   ``ssl_ca_file`` -- a path to a trusted certificate authorities (CA) file. Optional. If not set, the peer won't be checked for authenticity.

    Both a server and a client can use the ``ssl_ca_file`` parameter:

    *   If it's on the server side, the server verifies the client.
    *   If it's on the client side, the client verifies the server.
    *   If both sides have the CA files, the sever and the client verify each other.

*   ``ssl_ciphers`` -- a colon-separated (``:``) list of SSL cipher suites the connection can use. See the :ref:`enterprise-iproto-encryption-ciphers` section for details. Optional.
    Note that the list is not validated: if a cipher suite is unknown, Tarantool just ignores it, doesn't establish the connection and writes to the log that no shared cipher found.

*   ``ssl_password`` -- a password for an encrypted private SSL key. Optional. Alternatively, the password
    can be provided in ``ssl_password_file``.

*   ``ssl_password_file`` -- a text file with one or more passwords for encrypted private SSL keys
    (each on a separate line). Optional. Alternatively, the password can be provided in ``ssl_password``.

    Tarantool applies the ``ssl_password`` and ``ssl_password_file`` parameters in the following order:

    1.  If ``ssl_password`` is provided, Tarantool tries to decrypt the private key with it.
    2.  If ``ssl_password`` is incorrect or isn't provided, Tarantool tries all passwords from ``ssl_password_file``
        one by one in the order they are written.
    3.  If ``ssl_password`` and all passwords from ``ssl_password_file`` are incorrect,
        or none of them is provided, Tarantool treats the private key as unencrypted.

Configuration example:

..  code-block:: lua

    box.cfg{ listen = {
        uri = 'localhost:3301',
        params = {
            transport = 'ssl',
            ssl_key_file = '/path_to_key_file',
            ssl_cert_file = '/path_to_cert_file',
            ssl_ciphers = 'HIGH:!aNULL',
            ssl_password = 'topsecret'
        }
    }}

.. _enterprise-iproto-encryption-ciphers:

Supported ciphers
*****************

Tarantool Enterprise supports the following cipher suites:

*   ECDHE-ECDSA-AES256-GCM-SHA384
*   ECDHE-RSA-AES256-GCM-SHA384
*   DHE-RSA-AES256-GCM-SHA384
*   ECDHE-ECDSA-CHACHA20-POLY1305
*   ECDHE-RSA-CHACHA20-POLY1305
*   DHE-RSA-CHACHA20-POLY1305
*   ECDHE-ECDSA-AES128-GCM-SHA256
*   ECDHE-RSA-AES128-GCM-SHA256
*   DHE-RSA-AES128-GCM-SHA256
*   ECDHE-ECDSA-AES256-SHA384
*   ECDHE-RSA-AES256-SHA384
*   DHE-RSA-AES256-SHA256
*   ECDHE-ECDSA-AES128-SHA256
*   ECDHE-RSA-AES128-SHA256
*   DHE-RSA-AES128-SHA256
*   ECDHE-ECDSA-AES256-SHA
*   ECDHE-RSA-AES256-SHA
*   DHE-RSA-AES256-SHA
*   ECDHE-ECDSA-AES128-SHA
*   ECDHE-RSA-AES128-SHA
*   DHE-RSA-AES128-SHA
*   AES256-GCM-SHA384
*   AES128-GCM-SHA256
*   AES256-SHA256
*   AES128-SHA256
*   AES256-SHA
*   AES128-SHA
*   GOST2012-GOST8912-GOST8912
*   GOST2001-GOST89-GOST89

Tarantool Enterprise static build has the embeded engine to support the GOST cryptographic algorithms.
If you use these algorithms for traffic encryption, specify the corresponding cipher suite in the ``ssl_ciphers`` parameter, for example:

..  code-block:: lua

    box.cfg{ listen = {
        uri = 'localhost:3301',
        params = {
            transport = 'ssl',
            ssl_key_file = '/path_to_key_file',
            ssl_cert_file = '/path_to_cert_file',
            ssl_ciphers = 'GOST2012-GOST8912-GOST8912'
        }
    }}

For detailed information on SSL ciphers and their syntax, refer to `OpenSSL documentation <https://www.openssl.org/docs/man1.1.1/man1/ciphers.html>`__.

Using environment variables
***************************

The URI parameters for traffic encryption can also be set via environment variables. For example:

..  code-block:: bash

    export TT_LISTEN="localhost:3301?transport=ssl&ssl_cert_file=/path_to_cert_file&ssl_key_file=/path_to_key_file"

For details, refer to the Tarantool :ref:`configuration reference <box-cfg-params-env>`.

.. _enterprise-iproto-encryption-config-sc:

Server-client configuration details
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When configuring the traffic encryption, you need to specify the necessary parameters on both the server side and the client side.
Below you can find the summary on the options and parameters to be used and :ref:`examples of configuration <enterprise-iproto-encryption-config-example>`.

**Server side**

*   Is configured via the ``box.cfg.listen`` option.
*   Mandatory URI parameters: ``transport``, ``ssl_key_file`` and ``ssl_cert_file``.
*   Optional URI parameters: ``ssl_ca_file``, ``ssl_ciphers``, ``ssl_password``, and ``ssl_password_file``.


**Client side**

*   Is configured via the ``box.cfg.replication`` option (see :ref:`details <enterprise-iproto-encryption-config-example>`) or ``net_box_object.connect()``.

Parameters:

*   If the server side has only the ``transport``, ``ssl_key_file`` and ``ssl_cert_file`` parameters set,
    on the client side, you need to specify only ``transport = ssl`` as the mandatory parameter.
    All other URI parameters are optional.

*   If the server side also has the ``ssl_ca_file`` parameter set,
    on the client side, you need to specify ``transport``, ``ssl_key_file`` and ``ssl_cert_file`` as the mandatory parameters.
    Other parameters -- ``ssl_ca_file``, ``ssl_ciphers``, ``ssl_password``, and ``ssl_password_file`` -- are optional.

.. _enterprise-iproto-encryption-config-example:

Configuration examples
**********************

Suppose, there is a :ref:`master-replica <replication-master_replica_bootstrap>` set with two Tarantool instances:

*   127.0.0.1:3301 -- master (server)
*   127.0.0.1:3302 -- replica (client).

Examples below show the configuration related to connection encryption for two cases:
when the trusted certificate authorities (CA) file is not set on the server side and when it does.
Only mandatory URI parameters are mentioned in these examples.

1. **Without CA**

*   127.0.0.1:3301 -- master (server)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3301',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file'
                }
            }
        }

*   127.0.0.1:3302 -- replica (client)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3302',
                params = {transport = 'ssl'}
            },
            replication = {
                uri = 'username:password@127.0.0.1:3301',
                params = {transport = 'ssl'}
            },
            read_only = true
        }

2. **With CA**

*   127.0.0.1:3301 -- master (server)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3301',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file',
                    ssl_ca_file = '/path_to_ca_file'
                }
            }
        }

*   127.0.0.1:3302 -- replica (client)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3302',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file'
                }
            },
            replication = {
                uri = 'username:password@127.0.0.1:3301',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file'
                }
            },
            read_only = true
        }

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

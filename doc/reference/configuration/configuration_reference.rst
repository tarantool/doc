..  _configuration_reference:

Configuration reference
=======================

..  TODO
    https://github.com/tarantool/doc/issues/3664

This topic describes all :ref:`configuration parameters <configuration>` provided by Tarantool.

Most of the configuration options described in this reference can be applied to a specific instance, replica set, group, or to all instances globally.
To do so, you need to define the required option at the :ref:`specified level <configuration_scopes>`.

..  _configuration_reference_audit:

audit_log
---------

..  admonition:: Enterprise Edition
    :class: fact

    Configuring ``audit_log`` parameters is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


The ``audit_log`` section defines configuration parameters related to :ref:`audit logging <enterprise_audit_module>`.

..  NOTE::

    ``audit_log`` can be defined in any :ref:`scope <configuration_scopes>`.


* :ref:`audit_log.extract_key <configuration_reference_audit_extract_key>`
* :ref:`audit_log.file <configuration_reference_audit_file>`
* :ref:`audit_log.filter <configuration_reference_audit_filter>`
* :ref:`audit_log.format <configuration_reference_audit_format>`
* :ref:`audit_log.nonblock <configuration_reference_audit_nonblock>`
* :ref:`audit_log.pipe <configuration_reference_audit_pipe>`
* :ref:`audit_log.spaces <configuration_reference_audit_spaces>`
* :ref:`audit_log.syslog_facility <configuration_reference_audit_syslog-facility>`
* :ref:`audit_log.syslog_identity <configuration_reference_audit_syslog-identity>`
* :ref:`audit_log.syslog_server <configuration_reference_audit_syslog-server>`
* :ref:`audit_log.to <configuration_reference_audit_to>`

..  _configuration_reference_audit_extract_key:

..  confval:: audit_log.extract_key

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    If set to ``true``, the audit subsystem extracts and prints only the primary key instead of full
    tuples in DML events (``space_insert``, ``space_replace``, ``space_delete``).
    Otherwise, full tuples are logged.
    The option may be useful in case tuples are big.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_AUDIT_LOG_EXTRACT_KEY

..  _configuration_reference_audit_file:

..  confval:: audit_log.file

    Specify a file for the audit log destination.
    You can set the ``file`` type using the :ref:`audit_log.to <configuration_reference_audit_to>` option.
    If you write logs to a file, Tarantool reopens the audit log at `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.

    |
    | Type: string
    | Default: 'var/log/{{ instance_name }}/audit.log'
    | Environment variable: TT_AUDIT_LOG_FILE

..  _configuration_reference_audit_filter:

..  confval:: audit_log.filter

    Enable logging for a specified subset of audit events.
    This option accepts the following values:

    *   Event names (for example, ``password_change``). For details, see :ref:`Audit log events <audit-log-events>`.
    *   Event groups (for example, ``audit``).  For details, see :ref:`Event groups <audit-log-event-groups>`.

    The option contains either one value from above or a combination of them.

    To enable :ref:`user-defined audit log events <audit-log-custom>`, specify the ``custom`` value in this option.

    |
    | Type: array
    | Possible values: 'all', 'audit', 'auth', 'priv', 'ddl', 'dml', 'data_operations', 'compatibility',
      'audit_enable', 'auth_ok', 'auth_fail', 'disconnect', 'user_create', 'user_drop', 'role_create', 'role_drop',
      'user_disable', 'user_enable', 'user_grant_rights', 'role_grant_rights', 'role_revoke_rights', 'password_change',
      'access_denied', 'eval', 'call', 'space_select', 'space_create', 'space_alter', 'space_drop', 'space_insert',
      'space_replace', 'space_delete', 'custom'
    | Default: 'nil'
    | Environment variable: TT_AUDIT_LOG_FILTER

..  _configuration_reference_audit_format:

..  confval:: audit_log.format

    Specify a format that is used for the audit log.

    **Example**

    If you set the option to ``plain``,

    ..  code-block:: yaml

        audit_log:
            to: file
            format: plain

    the output in the file might look as follows:

    ..  code-block:: text

        2024-01-17T00:12:27.155+0300
        4b5a2624-28e5-4b08-83c7-035a0c5a1db9
        INFO remote:unix/:(socket)
        session_type:console
        module:tarantool
        user:admin
        type:space_create
        tag:
        description:Create space Bands

    |
    | Type: string
    | Possible values: 'json', 'csv', 'plain'
    | Default: 'json'
    | Environment variable: TT_AUDIT_LOG_FORMAT

..  _configuration_reference_audit_nonblock:

..  confval:: audit_log.nonblock

    Specify the logging behavior if the system is not ready to write.
    If set to ``true``, Tarantool does not block during logging if the system is non-writable and writes a message instead.
    Using this value may improve logging performance at the cost of losing some log messages.

    ..  note::

        The option only has an effect if the :ref:`audit_log.to <configuration_reference_audit_to>` is set to ``syslog``
        or ``pipe``.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_AUDIT_LOG_NONBLOCK

..  _configuration_reference_audit_pipe:

..  confval:: audit_log.pipe

    Specify a pipe for the audit log destination.
    You can set the ``pipe`` type using the :ref:`audit_log.to <configuration_reference_audit_to>` option.
    If log is a program, its pid is stored in the ``audit_log.logger_pid`` variable.
    You need to send it a signal to rotate logs.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log_pipe/config.yaml
        :language: yaml
        :start-at: audit_log:
        :end-at: '| cronolog audit_tarantool.log'
        :dedent:

    This starts the `cronolog <https://linux.die.net/man/1/cronolog>`_ program when the server starts
    and sends all ``audit_log`` messages to cronolog standard input (``stdin``).
    If the ``audit_log`` string starts with '|',
    the string is interpreted as a Unix `pipeline <https://en.wikipedia.org/wiki/Pipeline_%28Unix%29>`_.

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_AUDIT_LOG_PIPE

..  _configuration_reference_audit_spaces:

..  confval:: audit_log.spaces

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    The array of space names for which data operation events (``space_select``, ``space_insert``, ``space_replace``,
    ``space_delete``) should be logged. The array accepts string values.
    If set to :ref:`box.NULL <box-null>`, the data operation events are logged for all spaces.

    **Example**

    In the example, only the events of ``bands`` and ``singers`` spaces are logged:

    ..  code-block:: yaml

        audit_log:
          spaces: [bands, singers]

    |
    | Type: array
    | Default: box.NULL
    | Environment variable: TT_AUDIT_LOG_SPACES

..  _configuration_reference_audit_syslog-facility:

..  confval:: audit_log.syslog_facility

    Specify a system logger keyword that tells `syslogd <https://datatracker.ietf.org/doc/html/rfc5424>`__ where to send the message.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

    See also: :ref:`syslog configuration example <configuration_reference_audit_syslog-example>`.

    |
    | Type: string
    | Possible values: 'auth', 'authpriv', 'cron', 'daemon', 'ftp', 'kern', 'lpr', 'mail', 'news', 'security', 'syslog', 'user', 'uucp', 'local0', 'local1', 'local2', 'local3', 'local4', 'local5', 'local6', 'local7'
    | Default: 'local7'
    | Environment variable: TT_AUDIT_LOG_SYSLOG_FACILITY

..  _configuration_reference_audit_syslog-identity:

..  confval:: audit_log.syslog_identity

    Specify an arbitrary string that will be placed at the beginning of all messages.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

    See also: :ref:`syslog configuration example <configuration_reference_audit_syslog-example>`.

    |
    | Type: string
    | Default: 'tarantool'
    | Environment variable: TT_AUDIT_LOG_SYSLOG_IDENTITY

..  _configuration_reference_audit_syslog-server:

..  confval:: audit_log.syslog_server

    Set a location for the syslog server.
    It can be a Unix socket path starting with 'unix:' or an ipv4 port number.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

..  _configuration_reference_audit_syslog-example:

    **Example**

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log_syslog/config.yaml
        :language: yaml
        :start-at: audit_log:
        :end-at: 'tarantool'
        :dedent:

    -   :ref:`audit_log.syslog_server <configuration_reference_audit_syslog-server>` -- a syslog server location.

    -   :ref:`audit_log.syslog_facility <configuration_reference_audit_syslog-facility>` -- a system logger keyword that tells syslogd where to send the message.
        The default value is ``local7``.

    -   :ref:`audit_log.syslog_identity <configuration_reference_audit_syslog-identity>` -- a string placed at the beginning of every message.
        The default value is ``tarantool``.

    These options are interpreted as a message for the `syslogd <https://datatracker.ietf.org/doc/html/rfc5424>`_ program,
    which runs in the background of any Unix-like platform.

    An example of a Tarantool audit log entry in the syslog:

    ..  code-block:: json

        {
          "__CURSOR" : "s=81564632436a4de590e80b89b0151148;i=11519;b=def80c1464fe49d1aac8a64895d6614d;m=8c825ebfc;t=5edb27a75f282;x=7eba320f7cc9ae4d",
          "__REALTIME_TIMESTAMP" : "1668725698065026",
          "__MONOTONIC_TIMESTAMP" : "37717666812",
          "_BOOT_ID" : "def80c1464fe49d1aac8a64895d6614d",
          "_UID" : "1003",
          "_GID" : "1004",
          "_COMM" : "tarantool",
          "_EXE" : "/app/tarantool/dist/tdg-2.6.4.0.x86_64/tarantool",
          "_CMDLINE" : "tarantool init.lua <running>: core-03",
          "_CAP_EFFECTIVE" : "0",
          "_AUDIT_SESSION" : "1",
          "_AUDIT_LOGINUID" : "1003",
          "_SYSTEMD_CGROUP" : "/user.slice/user-1003.slice/user@1003.service/app.slice/app@core-03.service",
          "_SYSTEMD_OWNER_UID" : "1003",
          "_SYSTEMD_UNIT" : "user@1003.service",
          "_SYSTEMD_USER_UNIT" : "app@core-03.service",
          "_SYSTEMD_SLICE" : "user-1003.slice",
          "_SYSTEMD_USER_SLICE" : "app.slice",
          "_SYSTEMD_INVOCATION_ID" : "be368b4243d842ea8c06b010e0df62c2",
          "_MACHINE_ID" : "2e2339725deb4bc198c54ff4a2e8d626",
          "_HOSTNAME" : "vm-0.test.env",
          "_TRANSPORT" : "syslog",
          "PRIORITY" : "6",
          "SYSLOG_FACILITY" : "23",
          "SYSLOG_IDENTIFIER" : "tarantool",
          "SYSLOG_PID" : "101562",
          "_PID" : "101562",
          "MESSAGE" : "remote: session_type:background module:common.admin.auth user: type:custom_tdg_audit tag:tdg_severity_INFO description:[119eae0e-a691-42cc-9b4c-f14c499e6726] subj: \"anonymous\", msg: \"Access granted to anonymous user\"",
          "_SOURCE_REALTIME_TIMESTAMP" : "1668725698064202"
        }

    ..  warning::

        Above is an example of writing audit logs to a directory shared with the system logs.
        Tarantool allows this option, but it is not recommended to do this to avoid difficulties
        when working with audit logs. System and audit logs should be written separately.
        To do this, create separate paths and specify them.

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_AUDIT_LOG_SYSLOG_SERVER

..  _configuration_reference_audit_to:

..  confval:: audit_log.to

    Enable audit logging and define the log location.
    This option accepts the following values:

    -   ``devnull``: disable audit logging.
    -   ``file``: write audit logs to a file (see :ref:`audit_log.file <configuration_reference_audit_file>`).
    -   ``pipe``: write audit logs to a pipe (see :ref:`audit_log.pipe <configuration_reference_audit_pipe>`).
    -   ``syslog``: write audit logs to a system logger (see :ref:`audit_log.syslog <configuration_reference_audit_pipe>`).

    By default, audit logging is disabled.

    **Example**

    The basic audit log configuration might look as follows:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
        :language: yaml
        :start-at: audit_log
        :end-at: extract_key: true
        :dedent:

    |
    | Type: string
    | Possible values: 'devnull', 'file', 'pipe', 'syslog'
    | Default: 'devnull'
    | Environment variable: TT_AUDIT_LOG_TO

..  _configuration_reference_config:

config
------

The ``config`` section defines various parameters related to centralized configuration.

..  NOTE::

    ``config`` can be defined in the global :ref:`scope <configuration_scopes>` only.

* :ref:`config.reload <configuration_reference_config_reload>`
* :ref:`config.etcd.* <configuration_reference_config_etcd>`

.. _configuration_reference_config_reload:

.. confval:: config.reload

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Specify how the configuration is reloaded.
    This option accepts the following values:

    - ``auto``: configuration is reloaded automatically when it is changed.
    - ``manual``: configuration should be reloaded manually. In this case, you can reload the configuration in the application code using :ref:`config:reload() <config-module>`.

    See also: :ref:`Reloading configuration <etcd_reloading_configuration>`.

    |
    | Type: string
    | Possible values: 'auto', 'manual'
    | Default: 'auto'
    | Environment variable: TT_CONFIG_RELOAD



.. _configuration_reference_config_etcd:

config.etcd.*
~~~~~~~~~~~~~

..  include:: /concepts/configuration/configuration_etcd.rst
    :start-after: ee_note_etcd_start
    :end-before: ee_note_etcd_end

This section describes options related to :ref:`storing configuration in etcd <configuration_etcd>`.

* :ref:`config.etcd.endpoints <config_etcd_endpoints>`
* :ref:`config.etcd.prefix <config_etcd_prefix>`
* :ref:`config.etcd.username <config_etcd_username>`
* :ref:`config.etcd.password <config_etcd_password>`
* :ref:`config.etcd.ssl.ca_file <config_etcd_ssl_ca_file>`
* :ref:`config.etcd.ssl.ca_path <config_etcd_ssl_ca_path>`
* :ref:`config.etcd.ssl.ssl_key <config_etcd_ssl_ssl_key>`
* :ref:`config.etcd.ssl.verify_host <config_etcd_ssl_verify_host>`
* :ref:`config.etcd.ssl.verify_peer <config_etcd_ssl_verify_peer>`
* :ref:`config.etcd.http.request.timeout <config_etcd_http_request_timeout>`
* :ref:`config.etcd.http.request.unix_socket <config_etcd_http_request_unix_socket>`



.. _config_etcd_endpoints:

.. confval:: config.etcd.endpoints

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    The list of endpoints used to access an etcd server.

    See also: :ref:`Local etcd configuration <etcd_local_configuration>`.

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_ENDPOINTS


.. _config_etcd_prefix:

.. confval:: config.etcd.prefix

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A key prefix used to search a configuration on an etcd server.
    Tarantool searches keys by the following path: ``<prefix>/config/*``.
    Note that ``<prefix>`` should start with a slash (``/``).

    See also: :ref:`Local etcd configuration <etcd_local_configuration>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PREFIX

.. _config_etcd_username:

.. confval:: config.etcd.username

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A username used for authentication.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_USERNAME

.. _config_etcd_password:

.. confval:: config.etcd.password

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A password used for authentication.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PASSWORD


.. _config_etcd_ssl_ca_file:

.. confval:: config.etcd.ssl.ca_file

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a trusted certificate authorities (CA) file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_FILE


.. _config_etcd_ssl_ca_path:

.. confval:: config.etcd.ssl.ca_path

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a directory holding certificates to verify the peer with.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_PATH


.. _config_etcd_ssl_ssl_key:

.. confval:: config.etcd.ssl.ssl_key

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A path to a private SSL key file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_SSL_KEY


.. _config_etcd_ssl_verify_host:

.. confval:: config.etcd.ssl.verify_host

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Enable verification of the certificate's name (CN) against the specified host.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_HOST


.. _config_etcd_ssl_verify_peer:

.. confval:: config.etcd.ssl.verify_peer

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Enable verification of the peer's SSL certificate.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_PEER


.. _config_etcd_http_request_timeout:

.. confval:: config.etcd.http.request.timeout

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A time period required to process an HTTP request to an etcd server: from sending a request to receiving a response.

    |
    | Type: number
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_TIMEOUT

.. _config_etcd_http_request_unix_socket:

.. confval:: config.etcd.http.request.unix_socket

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    A Unix domain socket used to connect to an etcd server.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_UNIX_SOCKET




..  _configuration_reference_credentials:

credentials
-----------

..  TODO: https://github.com/tarantool/doc/issues/3666

.. NOTE::

    ``credentials`` can be defined in any :ref:`scope <configuration_scopes>`.


-   :ref:`credentials.roles.* <configuration_reference_credentials_roles>`
-   :ref:`credentials.users.* <configuration_reference_credentials_users>`
-   :ref:`<user_or_role_name>.privileges.* <configuration_reference_credentials_privileges>`


.. _configuration_reference_credentials_roles:

.. confval:: credentials.roles

    | Type: map
    | Default: nil
    | Environment variable: TT_CREDENTIALS_ROLES


.. _configuration_reference_credentials_users:

.. confval:: credentials.users

    | Type: map
    | Default: nil
    | Environment variable: TT_CREDENTIALS_USERS



..  _configuration_reference_credentials_role:

credentials.roles.*
~~~~~~~~~~~~~~~~~~~

.. _configuration_reference_credentials_roles_name_roles:

.. confval:: credentials.roles.<role_name>.roles


.. _configuration_reference_credentials_roles_name_privileges:

.. confval:: credentials.roles.<role_name>.privileges

    See :ref:`privileges <configuration_reference_credentials_privileges>`.


..  _configuration_reference_credentials_user:

credentials.users.*
~~~~~~~~~~~~~~~~~~~


.. _configuration_reference_credentials_users_name_password:

.. confval:: credentials.users.<username>.password


.. _configuration_reference_credentials_users_name_roles:

.. confval:: credentials.users.<username>.roles


.. _configuration_reference_credentials_users_name_privileges:

.. confval:: credentials.users.<username>.privileges

    See :ref:`privileges <configuration_reference_credentials_privileges>`.


..  _configuration_reference_credentials_privileges:

<user_or_role_name>.privileges.*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _configuration_reference_credentials_users_name_privileges_permissions:

.. confval:: <user_or_role_name>.privileges.permissions


.. _configuration_reference_credentials_users_name_privileges_spaces:

.. confval:: <user_or_role_name>.privileges.spaces


.. _configuration_reference_credentials_users_name_privileges_functions:

.. confval:: <user_or_role_name>.privileges.functions


.. _configuration_reference_credentials_users_name_privileges_sequences:

.. confval:: <user_or_role_name>.privileges.sequences


.. _configuration_reference_credentials_users_name_privileges_lua_eval:

.. confval:: <user_or_role_name>.privileges.lua_eval


.. _configuration_reference_credentials_users_name_privileges_lua_call:

.. confval:: <user_or_role_name>.privileges.lua_call


.. _configuration_reference_credentials_users_name_privileges_sql:

.. confval:: <user_or_role_name>.privileges.sql




..  _configuration_reference_database:

database
--------

The ``database`` section defines database-specific configuration parameters, such as an instance's read-write mode or transaction isolation level.

.. NOTE::

    ``database`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`database.hot_standby <configuration_reference_database_hot_standby>`
-   :ref:`database.instance_uuid <configuration_reference_database_instance_uuid>`
-   :ref:`database.mode <configuration_reference_database_mode>`
-   :ref:`database.replicaset_uuid <configuration_reference_database_replicaset_uuid>`
-   :ref:`database.txn_isolation <configuration_reference_database_txn_isolation>`
-   :ref:`database.txn_timeout <configuration_reference_database_txn_timeout>`
-   :ref:`database.use_mvcc_engine <configuration_reference_database_use_mvcc_engine>`

.. _configuration_reference_database_hot_standby:

.. confval:: database.hot_standby

    | Type: boolean
    | Default: false
    | Environment variable: TT_DATABASE_HOT_STANDBY


.. _configuration_reference_database_instance_uuid:

.. confval:: database.instance_uuid

    An :ref:`instance UUID <replication_uuid>`.

    By default, instance UUIDs are generated automatically.
    ``database.instance_uuid`` can be used to specify an instance identifier manually.

    UUIDs should follow these rules:

    *   The values must be true unique identifiers, not shared by other instances
        or replica sets within the common infrastructure.

    *   The values must be used consistently, not changed after the initial setup.
        The initial values are stored in :ref:`snapshot files <index-box_persistence>`
        and are checked whenever the system is restarted.

        .. TODO: https://github.com/tarantool/doc/issues/3661 mention that UUIDs can be dropped during migration.

    *   The values must comply with `RFC 4122 <https://tools.ietf.org/html/rfc4122>`_.
        The `nil UUID <https://tools.ietf.org/html/rfc4122#section-4.1.7>`_ is not allowed.

    See also: :ref:`database.replicaset_uuid <configuration_reference_database_replicaset_uuid>`

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_DATABASE_INSTANCE_UUID


.. _configuration_reference_database_mode:

.. confval:: database.mode

    An instance's operating mode.
    This option is in effect if :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``off``.

    The following modes are available:

    -   ``rw``: an instance is in read-write mode.
    -   ``ro``: an instance is in read-only mode.

    If not specified explicitly, the default value depends on the number of instances in a replica set. For a single instance, the ``rw`` mode is used, while for multiple instances, the ``ro`` mode is used.

    **Example**

    You can set the ``database.mode`` option to ``rw`` on all instances in a replica set to make a :ref:`master-master <replication-roles>` configuration.
    In this case, ``replication.failover`` should be set to ``off``.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/master_master/config.yaml
        :language: yaml
        :dedent:

    | Type: string
    | Default: :ref:`box.NULL <box-null>` (the actual default value depends on the number of instances in a replica set)
    | Environment variable: TT_DATABASE_MODE


.. _configuration_reference_database_replicaset_uuid:

.. confval:: database.replicaset_uuid

    A :ref:`replica set UUID <replication_uuid>`.

    By default, replica set UUIDs are generated automatically.
    ``database.replicaset_uuid`` can be used to specify a replica set identifier manually.

    See also: :ref:`database.instance_uuid <configuration_reference_database_instance_uuid>`

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_DATABASE_REPLICASET_UUID


.. _configuration_reference_database_txn_isolation:

.. confval:: database.txn_isolation

    A transaction :ref:`isolation level <transaction_model_levels>`.

    |
    | Type: string
    | Default: ``best-effort``
    | Possible values: ``best-effort``, ``read-committed``, ``read-confirmed``
    | Environment variable: TT_DATABASE_TXN_ISOLATION


.. _configuration_reference_database_txn_timeout:

.. confval:: database.txn_timeout

    A timeout (in seconds) after which the transaction is rolled back.

    See also: :ref:`box.begin() <box-begin>`

    |
    | Type: number
    | Default: 3153600000 (~100 years)
    | Environment variable: TT_DATABASE_TXN_TIMEOUT


.. _configuration_reference_database_use_mvcc_engine:

.. confval:: database.use_mvcc_engine

    Whether the :ref:`transactional manager <txn_mode_transaction-manager>` is enabled.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_DATABASE_USE_MVCC_ENGINE

..  _configuration_reference_flightrec:

flightrec
---------

..  admonition:: Enterprise Edition
    :class: fact

    Configuring ``flightrec`` parameters is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

The ``flightrec`` section describes options related to the :ref:`flight recorder <enterprise-flight-recorder>` configuration.

..  NOTE::

    ``flightrec`` can be defined in any :ref:`scope <configuration_scopes>`.

* :ref:`flightrec.enabled <configuration_reference_flightrec_enabled>`
* :ref:`flightrec.logs_size <configuration_reference_flightrec_logs_size>`
* :ref:`flightrec.logs_max_msg_size <configuration_reference_flightrec_logs_max_msg_size>`
* :ref:`flightrec.logs_log_level <configuration_reference_flightrec_logs_log_level>`
* :ref:`flightrec.metrics_period <configuration_reference_flightrec_metrics_period>`
* :ref:`flightrec.metrics_interval <configuration_reference_flightrec_metrics_interval>`
* :ref:`flightrec.requests_size <configuration_reference_flightrec_requests_size>`
* :ref:`flightrec.requests_max_req_size <configuration_reference_flightrec_requests_max_req_size>`
* :ref:`flightrec.requests_max_res_size <configuration_reference_flightrec_requests_max_res_size>`

..  _configuration_reference_flightrec_enabled:

..  confval:: flightrec.enabled

    Enable the :ref:`flight recorder <enterprise-flight-recorder>`.

    | Type: boolean
    | Default: false
    | Environment variable: TT_FLIGHTREC_ENABLED


..  TODO not implemented yet
    .. _config-directory:

    ..  _configuration_reference_flightrec_dir:

    ..  confval:: flightrec.dir

        Specify the directory used to store flight recordings (``*.ttfr`` files).

        | Type: string
        | Default: snapshot.dir
        | Environment variable: TT_FLIGHTREC_DIR


..  _configuration_reference_flightrec_logs_size:

..  confval:: flightrec.logs_size

    Specify the size (in bytes) of the log storage.
    You can set this option to ``0`` to disable the log storage.

    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_LOGS_SIZE

..  _configuration_reference_flightrec_logs_max_msg_size:

..  confval:: flightrec.logs_max_msg_size

    Specify the maximum size (in bytes) of the log message.
    The log message is truncated if its size exceeds this limit.

    | Type: integer
    | Default: 4096
    | Maximum: 16384
    | Environment variable: TT_FLIGHTREC_LOGS_MAX_MSG_SIZE


..  _configuration_reference_flightrec_logs_log_level:

..  confval:: flightrec.logs_log_level

    Specify the level of detail the log has.
    The default value is 6 (``VERBOSE``).
    You can learn more about log levels from the :ref:`log_level <cfg_logging-log_level>`
    option description.
    Note that the ``flightrec.logs_log_level`` value might differ from ``log_level``.

    | Type: integer
    | Default: 6
    | Environment variable: TT_FLIGHTREC_LOGS_LOG_LEVEL

..  _configuration_reference_flightrec_metrics_period:

..  confval:: flightrec.metrics_period

    Specify the time period (in seconds) that defines how long metrics are stored from the moment of dump.
    So, this value defines how much historical metrics data is collected up to the moment of crash.
    The frequency of metric dumps is defined by :ref:`flightrec.metrics_interval <configuration_reference_flightrec_metrics_interval>`.

    | Type: integer
    | Default: 180
    | Environment variable: TT_FLIGHTREC_METRICS_PERIOD


..  _configuration_reference_flightrec_metrics_interval:

..  confval:: flightrec.metrics_interval

    Specify the time interval (in seconds) that defines the frequency of dumping metrics.
    This value shouldn't exceed :ref:`flightrec.metrics_period <configuration_reference_flightrec_metrics_period>`.

    | Type: number
    | Default: 1.0
    | Minimum: 0.001
    | Environment variable: TT_FLIGHTREC_METRICS_INTERVAL

    ..  NOTE::

        Given that the average size of a metrics entry is 2 kB,
        you can estimate the size of the metrics storage as follows:

        ..  code-block:: console

            (flightrec_metrics_period / flightrec_metrics_interval) * 2 kB


..  _configuration_reference_flightrec_requests_size:

..  confval:: flightrec.requests_size

    Specify the size (in bytes) of storage for the request and response data.
    You can set this parameter to ``0`` to disable a storage of requests and responses.

    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_REQUESTS_SIZE


..  _configuration_reference_flightrec_requests_max_req_size:

..  confval:: flightrec.requests_max_req_size

    Specify the maximum size (in bytes) of a request entry.
    A request entry is truncated if this size is exceeded.

    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_REQ_SIZE


..  _configuration_reference_flightrec_requests_max_res_size:

..  confval:: flightrec.requests_max_res_size

    Specify the maximum size (in bytes) of a response entry.
    A response entry is truncated if this size is exceeded.

    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_RES_SIZE


..  _configuration_reference_iproto:

iproto
------

The ``iproto`` section is used to configure parameters related to :ref:`communicating to and between cluster instances <configuration_connections>`.

.. NOTE::

    ``iproto`` can be defined in any :ref:`scope <configuration_scopes>`.


-   :ref:`iproto.advertise.* <configuration_reference_iproto_advertise>`

    -   :ref:`iproto.advertise.client <configuration_reference_iproto_advertise_client>`
    -   :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>`
    -   :ref:`iproto.advertise.sharding <configuration_reference_iproto_advertise_sharding>`
    -   :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`

-   :ref:`iproto.* <configuration_reference_iproto_misc>`

    -   :ref:`iproto.listen <configuration_reference_iproto_listen>`
    -   :ref:`iproto.net_msg_max <configuration_reference_iproto_net_msg_max>`
    -   :ref:`iproto.readahead <configuration_reference_iproto_readahead>`
    -   :ref:`iproto.threads <configuration_reference_iproto_threads>`

-   :ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`



.. _configuration_reference_iproto_advertise:

iproto.advertise.*
~~~~~~~~~~~~~~~~~~


.. _configuration_reference_iproto_advertise_client:

.. confval:: iproto.advertise.client

    A URI used to advertise the current instance to clients.

    The ``iproto.advertise.client`` option accepts a URI in the following formats:

    -   An address: ``host:port``.

    -   A Unix domain socket: ``unix/:``.

    Note that this option doesn't allow to set a username and password.
    If a remote client needs this information, it should be delivered outside of the cluster configuration.

    .. host_port_limitations_start

    .. NOTE::

        The host value cannot be ``0.0.0.0``/``[::]`` and the port value cannot be ``0``.

    .. host_port_limitations_end

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_IPROTO_ADVERTISE_CLIENT

.. _configuration_reference_iproto_advertise_peer:

.. confval:: iproto.advertise.peer

    Settings used to advertise the current instance to other cluster members.
    The format of these settings is described in :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` user with the ``replication`` role is created.
    -   ``iproto.advertise.peer`` specifies that other instances should connect to an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` using the ``replicator`` user.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: 127.0.0.1:3303
        :dedent:

    | Type: map
    | Environment variable: see :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`

.. _configuration_reference_iproto_advertise_sharding:

.. confval:: iproto.advertise.sharding

    Settings used to advertise the current instance to a router and rebalancer.
    The format of these settings is described in :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`.

    .. NOTE::

        If ``iproto.advertise.sharding`` is not specified, advertise settings from :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` are used.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` and ``storage`` users are created.
    -   ``iproto.advertise.peer`` specifies that other instances should connect to an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` with the ``replicator`` user.
    -   ``iproto.advertise.sharding`` specifies that a router should connect to storages using an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` with the ``storage`` user.

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: login: storage
        :dedent:

    | Type: map
    | Environment variable: see :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`


.. _configuration_reference_iproto_advertise.peer_sharding:

iproto.advertise.<peer_or_sharding>.*
*************************************

.. _configuration_reference_iproto_advertise.peer_sharding.uri:

.. confval:: iproto.advertise.<peer_or_sharding>.uri

    (Optional) A URI used to advertise the current instance.
    By default, the URI defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` is used to advertise the current instance.

    ..  include:: /reference/configuration/configuration_reference.rst
        :start-after: host_port_limitations_start
        :end-before: host_port_limitations_end

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_URI, TT_IPROTO_ADVERTISE_SHARDING_URI

.. _configuration_reference_iproto_advertise.peer_sharding.login:

.. confval:: iproto.advertise.<peer_or_sharding>.login

    (Optional) A username used to connect to the current instance.
    If a username is not set, the ``guest`` user is used.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_LOGIN, TT_IPROTO_ADVERTISE_SHARDING_LOGIN

.. _configuration_reference_iproto_advertise.peer_sharding.password:

.. confval:: iproto.advertise.<peer_or_sharding>.password

    (Optional) A password for the specified user.
    If a ``login`` is specified but a password is missing, it is taken from the user's :ref:`credentials <configuration_reference_credentials>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PASSWORD, TT_IPROTO_ADVERTISE_SHARDING_PASSWORD

.. _configuration_reference_iproto_advertise.peer_sharding.params:

.. confval:: iproto.advertise.<peer_or_sharding>.params

    (Optional) URI parameters (:ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`) required for connecting to the current instance.


.. _configuration_reference_iproto_misc:

iproto.*
~~~~~~~~

.. _configuration_reference_iproto_listen:

.. confval:: iproto.listen

    An array of URIs used to listen for incoming requests.
    If required, you can enable SSL for specific URIs by providing additional parameters (:ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`).

    Note that a URI value can't contain parameters, a login, or a password.

    **Example**

    In the example below, ``iproto.listen`` is set explicitly for each instance in a cluster:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/auto_leader/config.yaml
        :language: yaml
        :start-at: groups:
        :end-before: Load sample data
        :dedent:

    See also: :ref:`Connections <configuration_connections>`.

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_IPROTO_LISTEN


.. _configuration_reference_iproto_net_msg_max:

.. confval:: iproto.net_msg_max

    To handle messages, Tarantool allocates :ref:`fibers <app-fibers>`.
    To prevent fiber overhead from affecting the whole system,
    Tarantool restricts how many messages the fibers handle,
    so that some pending requests are blocked.

    -   On powerful systems, increase ``net_msg_max``, and the scheduler
        starts processing pending requests immediately.

    -   On weaker systems, decrease ``net_msg_max``, and the overhead
        may decrease. However, this may take some time because the
        scheduler must wait until already-running requests finish.

    When ``net_msg_max`` is reached,
    Tarantool suspends processing of incoming packages until it
    has processed earlier messages. This is not a direct restriction of
    the number of fibers that handle network messages, rather it
    is a system-wide restriction of channel bandwidth.
    This in turn restricts the number of incoming
    network messages that the
    :ref:`transaction processor thread <thread_model>`
    handles, and therefore indirectly affects the fibers that handle
    network messages.

    .. NOTE::

        The number of fibers is smaller than the number of messages because
        messages can be released as soon as they are delivered, while
        incoming requests might not be processed until some time after delivery.

    | Type: integer
    | Default: 768
    | Environment variable: TT_IPROTO_NET_MSG_MAX


.. _configuration_reference_iproto_readahead:

.. confval:: iproto.readahead

    The size of the read-ahead buffer associated with a client connection.
    The larger the buffer, the more memory an active connection consumes, and the
    more requests can be read from the operating system buffer in a single
    system call.

    The recommendation is to make sure that the buffer can contain at least a few dozen requests.
    Therefore, if a typical tuple in a request is large, e.g. a few kilobytes or even megabytes, the read-ahead buffer size should be increased.
    If batched request processing is not used, it’s prudent to leave this setting at its default.

    |
    | Type: integer
    | Default: 16320
    | Environment variable: TT_IPROTO_READAHEAD


.. _configuration_reference_iproto_threads:

.. confval:: iproto.threads

    The number of :ref:`network threads <thread_model>`.
    There can be unusual workloads where the network thread
    is 100% loaded and the transaction processor thread is not, so the network
    thread is a bottleneck.
    In that case, set ``iproto_threads`` to 2 or more.
    The operating system kernel determines which connection goes to
    which thread.

    |
    | Type: integer
    | Default: 1
    | Environment variable: TT_IPROTO_THREADS


.. _configuration_reference_iproto_uri_params:

<uri>.params.*
~~~~~~~~~~~~~~

..  admonition:: Enterprise Edition
    :class: fact

    TLS traffic encryption is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

URI parameters that can be used in the following options:

-   :ref:`iproto.advertise.\<peer_or_sharding\>.params <configuration_reference_iproto_advertise.peer_sharding.params>`
-   :ref:`iproto.listen.\<uri\>.params <configuration_reference_iproto_listen>`

..  NOTE::

    Note that ``<uri>.params.*`` options don't have corresponding :ref:`environment variables <configuration_environment_variable>` for URIs specified in ``iproto.listen``.

.. _configuration_reference_iproto_uri_params_transport:

.. confval:: <uri>.params.transport

    Allows you to enable :ref:`traffic encryption <configuration_connections_ssl>` for client-server communications over binary connections.
    In a Tarantool cluster, one instance might act as the server that accepts connections from other instances and the client that connects to other instances.

    ``<uri>.params.transport`` accepts one of the following values:

    -   ``plain`` (default): turn off traffic encryption.
    -   ``ssl``: encrypt traffic by using the TLS 1.2 protocol (`Enterprise Edition <https://www.tarantool.io/compare/>`_ only).

    **Example**

    The example below demonstrates how to enable traffic encryption by using a self-signed server certificate.
    The following parameters are specified for each instance:

    -   ``ssl_cert_file``: a path to an SSL certificate file.
    -   ``ssl_key_file``: a path to a private SSL key file.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/ssl_without_ca/config.yaml
        :language: yaml
        :start-at: replicaset001:
        :dedent:

    You can find the full example here: `ssl_without_ca <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/ssl_without_ca>`_.

    |
    | Type: string
    | Default: 'plain'
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_TRANSPORT, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_TRANSPORT

.. _configuration_reference_iproto_uri_params_ssl_ca_file:

.. confval:: <uri>.params.ssl_ca_file

    (Optional) A path to a trusted certificate authorities (CA) file.
    If not set, the peer won't be checked for authenticity.

    Both a server and a client can use the ``ssl_ca_file`` parameter:

    -   If it's on the server side, the server verifies the client.
    -   If it's on the client side, the client verifies the server.
    -   If both sides have the CA files, the server and the client verify each other.

    **See also:** :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CA_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CA_FILE

.. _configuration_reference_iproto_uri_params_ssl_cert_file:

.. confval:: <uri>.params.ssl_cert_file

    A path to an SSL certificate file:

    -   For a server, it's mandatory.
    -   For a client, it's mandatory if the :ref:`ssl_ca_file <configuration_reference_iproto_uri_params_ssl_ca_file>` parameter is set for a server; otherwise, optional.

    **See also:** :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CERT_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CERT_FILE

.. _configuration_reference_iproto_uri_params_ssl_ciphers:

.. confval:: <uri>.params.ssl_ciphers

    (Optional) A colon-separated (``:``) list of SSL cipher suites the connection can use.
    Note that the list is not validated: if a cipher suite is unknown, Tarantool ignores it, doesn't establish the connection, and writes to the log that no shared cipher was found.

    The supported cipher suites are:

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

    For detailed information on SSL ciphers and their syntax, refer to `OpenSSL documentation <https://www.openssl.org/docs/man1.1.1/man1/ciphers.html>`__.

    **See also:** :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CIPHERS, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CIPHERS

.. _configuration_reference_iproto_uri_params_ssl_key_file:

.. confval:: <uri>.params.ssl_key_file

    A path to a private SSL key file:

    -   For a server, it's mandatory.
    -   For a client, it's mandatory if the :ref:`ssl_ca_file <configuration_reference_iproto_uri_params_ssl_ca_file>` parameter is set for a server; otherwise, optional.

    If the private key is encrypted, provide a password for it in the ``ssl_password`` or ``ssl_password_file`` parameter.

    **See also:** :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_KEY_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_KEY_FILE

.. _configuration_reference_iproto_uri_params_ssl_password:

.. confval:: <uri>.params.ssl_password

    (Optional) A password for an encrypted private SSL key provided using ``ssl_key_file``.
    Alternatively, the password can be provided in ``ssl_password_file``.

    Tarantool applies the ``ssl_password`` and ``ssl_password_file`` parameters in the following order:

    1.  If ``ssl_password`` is provided, Tarantool tries to decrypt the private key with it.
    2.  If ``ssl_password`` is incorrect or isn't provided, Tarantool tries all passwords from ``ssl_password_file``
        one by one in the order they are written.
    3.  If ``ssl_password`` and all passwords from ``ssl_password_file`` are incorrect,
        or none of them is provided, Tarantool treats the private key as unencrypted.

    **See also:** :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_PASSWORD, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_PASSWORD

.. _configuration_reference_iproto_uri_params_ssl_password_file:

.. confval:: <uri>.params.ssl_password_file

    (Optional) A text file with one or more passwords for encrypted private SSL keys provided using ``ssl_key_file`` (each on a separate line).
    Alternatively, the password can be provided in ``ssl_password``.

    **See also:** :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_PASSWORD_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_PASSWORD_FILE





..  _configuration_reference_groups:

groups
------

The ``groups`` section provides the ability to define the :ref:`full topology of a Tarantool cluster <configuration_overview>`.

.. NOTE::

    ``groups`` can be defined in the global :ref:`scope <configuration_scopes>` only.

-   :ref:`groups.\<group_name\> <configuration_reference_groups_name>`
-   :ref:`groups.\<group_name\>.replicasets <configuration_reference_groups_name_replicasets>`
-   :ref:`groups.\<group_name\>.\<config_parameter\> <configuration_reference_groups_name_config_parameter>`

.. _configuration_reference_groups_name:

.. confval:: groups.<group_name>

    A group name.


.. _configuration_reference_groups_name_replicasets:

.. confval:: groups.<group_name>.replicasets

    Replica sets that belong to this group. See :ref:`replicasets <configuration_reference_replicasets>`.


.. _configuration_reference_groups_name_config_parameter:

.. confval:: groups.<group_name>.<config_parameter>

    Any configuration parameter that can be defined in the group :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the group level are applied to all instances in this group.



..  _configuration_reference_replicasets:

replicasets
~~~~~~~~~~~

.. NOTE::

    ``replicasets`` can be defined in the group :ref:`scope <configuration_scopes>` only.

-   :ref:`replicasets.\<replicaset_name\> <configuration_reference_replicasets_name>`
-   :ref:`replicasets.\<replicaset_name\>.leader <configuration_reference_replicasets_name_leader>`
-   :ref:`replicasets.\<replicaset_name\>.bootstrap_leader <configuration_reference_replicasets_name_bootstrap_leader>`
-   :ref:`replicasets.\<replicaset_name\>.instances <configuration_reference_replicasets_name_instances>`
-   :ref:`replicasets.\<replicaset_name\>.\<config_parameter\> <configuration_reference_replicasets_name_config_parameter>`

.. _configuration_reference_replicasets_name:

.. confval:: replicasets.<replicaset_name>

    A replica set name.


.. _configuration_reference_replicasets_name_leader:

.. confval:: replicasets.<replicaset_name>.leader

    A replica set leader.
    This option can be used to set a replica set leader when ``manual`` :ref:`replication.failover <configuration_reference_replication_failover>` is used.

    To perform :ref:`controlled failover <replication-controlled_failover>`, ``<replicaset_name>.leader`` can be temporarily removed or set to ``null``.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
        :language: yaml
        :start-at: replication:
        :end-at: 127.0.0.1:3303
        :dedent:


.. _configuration_reference_replicasets_name_bootstrap_leader:

.. confval:: replicasets.<replicaset_name>.bootstrap_leader

    A bootstrap leader for a replica set.
    To specify a bootstrap leader manually, you need to set :ref:`replication.bootstrap_strategy <configuration_reference_replication_bootstrap_strategy>` to ``config``.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/bootstrap_strategy/config.yaml
        :language: yaml
        :start-at: groups:
        :end-at: 127.0.0.1:3303
        :dedent:


.. _configuration_reference_replicasets_name_instances:

.. confval:: replicasets.<replicaset_name>.instances

    Instances that belong to this replica set. See :ref:`instances <configuration_reference_instances>`.


.. _configuration_reference_replicasets_name_config_parameter:

.. confval:: replicasets.<replicaset_name>.<config_parameter>

    Any configuration parameter that can be defined in the replica set :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the replica set level are applied to all instances in this replica set.



..  _configuration_reference_instances:

instances
*********

.. NOTE::

    ``instances`` can be defined in the replica set :ref:`scope <configuration_scopes>` only.

-   :ref:`instances.\<instance_name\> <configuration_reference_instances_name>`
-   :ref:`instances.\<instance_name\>.\<config_parameter\> <configuration_reference_instances_name_config_parameter>`

.. _configuration_reference_instances_name:

.. confval:: instances.<instance_name>

    An instance name.


.. _configuration_reference_instances_name_config_parameter:

.. confval:: instances.<instance_name>.<config_parameter>

    Any configuration parameter that can be defined in the instance :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the instance level are applied to this instance only.














..  _configuration_reference_replication:

replication
-----------

The ``replication`` section defines configuration parameters related to :ref:`replication <replication>`.

-   :ref:`replication.anon <configuration_reference_replication_anon>`
-   :ref:`replication.bootstrap_strategy <configuration_reference_replication_bootstrap_strategy>`
-   :ref:`replication.connect_timeout <configuration_reference_replication_connect_timeout>`
-   :ref:`replication.election_mode <configuration_reference_replication_election_mode>`
-   :ref:`replication.election_timeout <configuration_reference_replication_election_timeout>`
-   :ref:`replication.election_fencing_mode <configuration_reference_replication_election_fencing_mode>`
-   :ref:`replication.failover <configuration_reference_replication_failover>`
-   :ref:`replication.peers <configuration_reference_replication_peers>`
-   :ref:`replication.skip_conflict <configuration_reference_replication_skip_conflict>`
-   :ref:`replication.sync_lag <configuration_reference_replication_sync_lag>`
-   :ref:`replication.sync_timeout <configuration_reference_replication_sync_timeout>`
-   :ref:`replication.synchro_quorum <configuration_reference_replication_synchro_quorum>`
-   :ref:`replication.synchro_timeout <configuration_reference_replication_synchro_timeout>`
-   :ref:`replication.threads <configuration_reference_replication_threads>`
-   :ref:`replication.timeout <configuration_reference_replication_timeout>`


.. _configuration_reference_replication_anon:

.. confval:: replication.anon

    | Type: boolean
    | Default: ``false``
    | Environment variable: TT_REPLICATION_ANON


.. _configuration_reference_replication_bootstrap_strategy:

.. confval:: replication.bootstrap_strategy

    Specifies a strategy used to bootstrap a :ref:`replica set <replication-bootstrap>`.
    The following strategies are available:

    *   ``auto``: a node doesn't boot if half or more of the other nodes in a replica set are not connected.
        For example, if a replica set contains 2 or 3 nodes, a node requires 2 connected instances.
        In the case of 4 or 5 nodes, at least 3 connected instances are required.
        Moreover, a bootstrap leader fails to boot unless every connected node has chosen it as a bootstrap leader.

    *   ``config``: use the specified node to bootstrap a replica set.
        To specify the bootstrap leader, use the :ref:`<replicaset_name>.bootstrap_leader <configuration_reference_replicasets_name_bootstrap_leader>` option.

    *   ``supervised``: a bootstrap leader isn't chosen automatically but should be appointed using :ref:`box.ctl.make_bootstrap_leader() <box_ctl-make_bootstrap_leader>` on the desired node.

    *   ``legacy`` (deprecated since :doc:`2.11.0 </release/2.11.0>`): a node requires the :ref:`replication_connect_quorum <cfg_replication-replication_connect_quorum>` number of other nodes to be connected.
        This option is added to keep the compatibility with the current versions of Cartridge and might be removed in the future.

    | Type: string
    | Default: ``auto``
    | Environment variable: TT_REPLICATION_BOOTSTRAP_STRATEGY


.. _configuration_reference_replication_connect_timeout:

.. confval:: replication.connect_timeout

    A timeout (in seconds) a replica waits when trying to connect to a master in a cluster.
    See :ref:`orphan status <replication-orphan_status>` for details.

    This parameter is different from
    :ref:`replication.timeout <configuration_reference_replication_timeout>`,
    which a master uses to disconnect a replica when the master
    receives no acknowledgments of heartbeat messages.

    |
    | Type: number
    | Default: 30
    | Environment variable: TT_REPLICATION_CONNECT_TIMEOUT


.. _configuration_reference_replication_election_mode:

.. confval:: replication.election_mode

    A role of a replica set node in the :ref:`leader election process <repl_leader_elect>`.

    The possible values are:

    *   ``off``: a node doesn't participate in the election activities.

    *   ``voter``: a node can participate in the election process but can't be a leader.

    *   ``candidate``: a node should be able to become a leader.

    *   ``manual``: allow to control which instance is the leader explicitly instead of relying on automated leader election.
        By default, the instance acts like a voter -- it is read-only and may vote for other candidate instances.
        Once :ref:`box.ctl.promote() <box_ctl-promote>` is called, the instance becomes a candidate and starts a new election round.
        If the instance wins the elections, it becomes a leader but won't participate in any new elections.

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>` (the actual default value depends on :ref:`replication.failover <configuration_reference_replication_failover>`)
    | Environment variable: TT_REPLICATION_ELECTION_MODE


.. _configuration_reference_replication_election_timeout:

.. confval:: replication.election_timeout

    Specifies the timeout (in seconds) between election rounds in the
    :ref:`leader election process <repl_leader_elect>` if the previous round
    ended up with a split vote.

    It is quite big, and for most of the cases, it can be lowered to
    300-400 ms.

    To avoid the split vote repeat, the timeout is randomized on each node
    during every new election, from 100% to 110% of the original timeout value.
    For example, if the timeout is 300 ms and there are 3 nodes started
    the election simultaneously in the same term,
    they can set their election timeouts to 300, 310, and 320 respectively,
    or to 305, 302, and 324, and so on. In that way, the votes will never be split
    because the election on different nodes won't be restarted simultaneously.

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_REPLICATION_ELECTION_TIMEOUT


.. _configuration_reference_replication_election_fencing_mode:

.. confval:: replication.election_fencing_mode

    Specifies the :ref:`leader fencing mode <repl_leader_elect_fencing>` that
    affects the leader election process. When the parameter is set to ``soft``
    or ``strict``, the leader resigns its leadership if it has less than
    :ref:`replication.synchro_quorum <configuration_reference_replication_synchro_quorum>`
    of alive connections to the cluster nodes.
    The resigning leader receives the status of a follower in the current election term and becomes
    read-only.

    *   In ``soft`` mode, a connection is considered dead if there are no responses for
        :ref:`4 * replication.timeout <configuration_reference_replication_timeout>` seconds both on the current leader and the followers.

    *   In ``strict`` mode, a connection is considered dead if there are no responses
        for :ref:`2 * replication.timeout <configuration_reference_replication_timeout>` seconds on the
        current leader and
        :ref:`4 * replication.timeout <configuration_reference_replication_timeout>` seconds on the
        followers. This improves the chances that there is only one leader at any time.

    Fencing applies to the instances that have the
    :ref:`replication.election_mode <configuration_reference_replication_election_mode>` set to ``candidate`` or ``manual``.
    To turn off leader fencing, set ``election_fencing_mode`` to ``off``.

    |
    | Type: string
    | Default: ``soft``
    | Possible values: ``off``, ``soft``, ``strict``
    | Environment variable: TT_REPLICATION_ELECTION_FENCING_MODE


.. _configuration_reference_replication_failover:

.. confval:: replication.failover

    A failover mode used to take over a master role when the current master instance fails.
    The following modes are available:

    -   ``off``

        Leadership in a replica set is controlled using the :ref:`database.mode <configuration_reference_database_mode>` option.
        In this case, you can set the ``database.mode`` option to ``rw`` on all instances in a replica set to make a :ref:`master-master <replication-roles>` configuration.

        The default ``database.mode`` is determined as follows: ``rw`` if there is one instance in a replica set; ``ro`` if there are several instances.

    -   ``manual``

        Leadership in a replica set is controlled using the :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` option.
        In this case, a :ref:`master-master <replication-roles>` configuration is forbidden.

        In the ``manual`` mode, the :ref:`database.mode <configuration_reference_database_mode>` option cannot be set explicitly.
        The leader is configured in the read-write mode, all the other instances are read-only.

    -   ``election``

        :ref:`Automated leader election <repl_leader_elect>` is used to control leadership in a replica set.

        In the ``election`` mode, :ref:`database.mode <configuration_reference_database_mode>` and :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` shouldn't be set explicitly.

    -   ``supervised`` (`Enterprise Edition <https://www.tarantool.io/compare/>`_ only)

        Leadership in a replica set is controlled using an external failover agent.

        In the ``supervised`` mode, :ref:`database.mode <configuration_reference_database_mode>` and :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` shouldn't be set explicitly.

        ..  TODO: https://github.com/tarantool/enterprise_doc/issues/253


    See also: :ref:`Replication tutorials <how-to-replication>`.

    .. NOTE::

        ``replication.failover`` can be defined in the global, group, and replica set :ref:`scope <configuration_scopes>`.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` user with the ``replication`` role is created.
    -   :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` specifies that other instances should connect to an address defined in :ref:`iproto.listen <configuration_reference_iproto_listen>` using the ``replicator`` user.
    -   ``replication.failover`` specifies that a master instance should be set manually.
    -   :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` sets ``instance001`` as a replica set leader.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
        :language: yaml
        :end-before: Load sample data
        :dedent:

    | Type: string
    | Default: ``off``
    | Environment variable: TT_REPLICATION_FAILOVER


.. _configuration_reference_replication_peers:

.. confval:: replication.peers

    URIs of instances that constitute a replica set.
    These URIs are used by an instance to connect to another instance as a replica.

    Alternatively, you can use :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>` to specify a URI used to advertise the current instance to other cluster members.

    **Example**

    In the example below, the following configuration options are specified:

    -   In the :ref:`credentials <configuration_reference_credentials>` section, the ``replicator`` user with the ``replication`` role is created.
    -   ``replication.peers`` specifies URIs of replica set instances.

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/peers/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: - replicator:topsecret@127.0.0.1:3303
        :dedent:

    | Type: array
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_REPLICATION_PEERS


.. _configuration_reference_replication_skip_conflict:

.. confval:: replication.skip_conflict

    By default, if a replica adds a unique key that another replica has
    added, replication :ref:`stops <replication-replication_stops>`
    with the ``ER_TUPLE_FOUND`` :ref:`error <error_codes>`.
    If ``replication.skip_conflict`` is set to ``true``, such errors are ignored.

    .. NOTE::

        Instead of saving the broken transaction to the write-ahead log, it is written as ``NOP`` (No operation).

    | Type: boolean
    | Default: false
    | Environment variable: TT_REPLICATION_SKIP_CONFLICT


.. _configuration_reference_replication_sync_lag:

.. confval:: replication.sync_lag

    The maximum delay (in seconds) between the time when data is written to the master and the time when it is written to a replica.
    If ``replication.sync_lag`` is set to ``nil`` or 365 * 100 * 86400 (``TIMEOUT_INFINITY``),
    a replica is always considered to be "synced".

    .. NOTE::

        This parameter is ignored during bootstrap.
        See :ref:`orphan status <replication-orphan_status>` for details.

    | Type: number
    | Default: 10
    | Environment variable: TT_REPLICATION_SYNC_LAG


.. _configuration_reference_replication_sync_timeout:

.. confval:: replication.sync_timeout

    The timeout (in seconds) that a node waits when trying to sync with
    other nodes in a replica set after connecting or during a :ref:`configuration update <replication-configuration_update>`.
    This could fail indefinitely if :ref:`replication.sync_lag <configuration_reference_replication_sync_lag>` is smaller than network latency, or if the replica cannot keep pace with master updates.
    If ``replication.sync_timeout`` expires, the replica enters :ref:`orphan status <replication-orphan_status>`.

    |
    | Type: number
    | Default: 0
    | Environment variable: TT_REPLICATION_SYNC_TIMEOUT


.. _configuration_reference_replication_synchro_quorum:

.. confval:: replication.synchro_quorum

    A number of replicas that should confirm the receipt of a :ref:`synchronous <repl_sync>` transaction before it can finish its commit.

    This option supports dynamic evaluation of the quorum number.
    For example, the default value is ``N / 2 + 1`` where ``N`` is the current number of replicas registered in a cluster.
    Once any replicas are added or removed, the expression is re-evaluated automatically.

    Note that the default value (``at least 50% of the cluster size + 1``) guarantees data reliability.
    Using a value less than the canonical one might lead to unexpected results,
    including a :ref:`split-brain <repl_leader_elect_splitbrain>`.

    ``replication.synchro_quorum`` is not used on replicas. If the master fails, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is elected.

    .. NOTE::

        ``replication.synchro_quorum`` does not account for anonymous replicas.

    | Type: string, number
    | Default: ``N / 2 + 1``
    | Environment variable: TT_REPLICATION_SYNCHRO_QUORUM


.. _configuration_reference_replication_synchro_timeout:

.. confval:: replication.synchro_timeout

    For :ref:`synchronous replication <repl_sync>` only.
    Specify how many seconds to wait for a synchronous transaction quorum
    replication until it is declared failed and is rolled back.

    It is not used on replicas, so if the master fails, the pending synchronous
    transactions will be kept waiting on the replicas until a new master is
    elected.

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_REPLICATION_SYNCHRO_TIMEOUT


.. _configuration_reference_replication_threads:

.. confval:: replication.threads

    The number of threads spawned to decode the incoming replication data.

    In most cases, one thread is enough for all incoming data.
    Possible values range from 1 to 1000.
    If there are multiple replication threads, connections to serve are distributed evenly between the threads.

    |
    | Type: integer
    | Default: 1
    | Environment variable: TT_REPLICATION_THREADS


.. _configuration_reference_replication_timeout:

.. confval:: replication.timeout

    A time interval (in seconds) used by a master to send heartbeat requests to a replica when there are no updates to send to this replica.
    For each request, a replica should return a heartbeat acknowledgment.

    If a master or replica gets no heartbeat message for ``4 * replication.timeout`` seconds, a connection is dropped and a replica tries to reconnect to the master.

    See also: :ref:`Monitoring a replica set <replication-monitoring>`.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_REPLICATION_TIMEOUT



..  _configuration_reference_security:

security
--------

..  admonition:: Enterprise Edition
    :class: fact

    Configuring security parameters is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

The ``security`` section defines configuration parameters related to various security settings.

.. NOTE::

    ``security`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`security.auth_delay <configuration_reference_security_auth_delay>`
-   :ref:`security.auth_retries <configuration_reference_security_auth_retries>`
-   :ref:`security.auth_type <configuration_reference_security_auth_type>`
-   :ref:`security.disable_guest <configuration_reference_security_disable_guest>`
-   :ref:`security.password_enforce_digits <configuration_reference_security_password_enforce_digits>`
-   :ref:`security.password_enforce_lowercase <configuration_reference_security_password_enforce_lowercase>`
-   :ref:`security.password_enforce_specialchars <configuration_reference_security_password_enforce_specialchars>`
-   :ref:`security.password_enforce_uppercase <configuration_reference_security_password_enforce_uppercase>`
-   :ref:`security.password_history_length <configuration_reference_security_password_history_length>`
-   :ref:`security.password_lifetime_days <configuration_reference_security_password_lifetime_days>`
-   :ref:`security.password_min_length <configuration_reference_security_password_min_length>`
-   :ref:`security.secure_erasing <configuration_reference_security_secure_erasing>`


..  _configuration_reference_security_auth_delay:

..  confval:: security.auth_delay

    Specify a period of time (in seconds) that a specific user should wait for the next attempt after failed authentication.

    The :ref:`security.auth_retries <configuration_reference_security_auth_retries>` option lets a client try to authenticate the specified number of times before ``security.auth_delay`` is enforced.

    In the configuration below, Tarantool lets a client try to authenticate with the same username three times.
    At the fourth attempt, the authentication delay configured with ``security.auth_delay`` is enforced.
    This means that a client should wait 10 seconds after the first failed attempt.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/security_auth_restrictions/config.yaml
        :language: yaml
        :start-at: security:
        :end-at: auth_retries: 2
        :dedent:


    |
    | Type: number
    | Default: 0
    | Environment variable: TT_SECURITY_AUTH_DELAY


..  _configuration_reference_security_auth_retries:

..  confval:: security.auth_retries

    Specify the maximum number of authentication retries allowed before :ref:`security.auth_delay <configuration_reference_security_auth_delay>` is enforced.
    The default value is 0, which means ``security.auth_delay`` is enforced after the first failed authentication attempt.

    The retry counter is reset after ``security.auth_delay`` seconds since the first failed attempt.
    For example, if a client tries to authenticate fewer than ``security.auth_retries`` times within ``security.auth_delay`` seconds, no authentication delay is enforced.
    The retry counter is also reset after any successful authentication attempt.

    |
    | Type: integer
    | Default: 0
    | Environment variable: TT_SECURITY_AUTH_RETRIES


..  _configuration_reference_security_auth_type:

..  confval:: security.auth_type

    Specify a protocol used to authenticate users.
    The possible values are:

    -   ``chap-sha1``: use the `CHAP <https://en.wikipedia.org/wiki/Challenge-Handshake_Authentication_Protocol>`_ protocol with ``SHA-1`` hashing applied to :ref:`passwords <authentication-passwords>`.
    -   ``pap-sha256``: use `PAP <https://en.wikipedia.org/wiki/Password_Authentication_Protocol>`_ authentication with the ``SHA256`` hashing algorithm.

    Note that CHAP stores password hashes in the ``_user`` space unsalted.
    If an attacker gains access to the database, they may crack a password, for example, using a `rainbow table <https://en.wikipedia.org/wiki/Rainbow_table>`_.
    For PAP, a password is salted with a user-unique salt before saving it in the database,
    which keeps the database protected from cracking using a rainbow table.

    To enable PAP, specify the ``security.auth_type`` option as follows:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/security_auth_protocol/config.yaml
        :language: yaml
        :start-at: security:
        :end-at: 'pap-sha256'
        :dedent:

    |
    | Type: string
    | Default: 'chap-sha1'
    | Environment variable: TT_SECURITY_AUTH_TYPE


..  _configuration_reference_security_disable_guest:

..  confval:: security.disable_guest

    If **true**, turn off access over remote connections from unauthenticated or :ref:`guest <authentication-passwords>` users.
    This option affects connections between cluster members and :doc:`net.box </reference/reference_lua/net_box>` connections.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_SECURITY_DISABLE_GUEST


..  _configuration_reference_security_password_enforce_digits:

..  confval:: security.password_enforce_digits

    If **true**, a password should contain digits (0-9).

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_SECURITY_PASSWORD_ENFORCE_DIGITS


..  _configuration_reference_security_password_enforce_lowercase:

..  confval:: security.password_enforce_lowercase

    If **true**, a password should contain lowercase letters (a-z).

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_SECURITY_PASSWORD_ENFORCE_LOWERCASE


..  _configuration_reference_security_password_enforce_specialchars:

..  confval:: security.password_enforce_specialchars

    If **true**, a password should contain at least one special character (such as ``&|?!@$``).

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_SECURITY_PASSWORD_ENFORCE_SPECIALCHARS


..  _configuration_reference_security_password_enforce_uppercase:

..  confval:: security.password_enforce_uppercase

    If **true**, a password should contain uppercase letters (A-Z).

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_SECURITY_PASSWORD_ENFORCE_UPPERCASE


..  _configuration_reference_security_password_history_length:

..  confval:: security.password_history_length

    Specify the number of unique new user passwords before an old password can be reused.

    .. NOTE::

        Tarantool uses the ``auth_history`` field in the
        :doc:`box.space._user </reference/reference_lua/box_space/_user>`
        system space to store user passwords.

    |
    | Type: integer
    | Default: 0
    | Environment variable: TT_SECURITY_PASSWORD_HISTORY_LENGTH


..  _configuration_reference_security_password_lifetime_days:

..  confval:: security.password_lifetime_days

    Specify the maximum period of time (in days) a user can use the same password.
    When this period ends, a user gets the "Password expired" error on a login attempt.
    To restore access for such users, use :doc:`box.schema.user.passwd </reference/reference_lua/box_schema/user_passwd>`.

    .. note::

        The default 0 value means that a password never expires.

    |
    | Type: integer
    | Default: 0
    | Environment variable: TT_SECURITY_PASSWORD_LIFETIME_DAYS


..  _configuration_reference_security_password_min_length:

..  confval:: security.password_min_length

    Specify the minimum number of characters for a password.

    |
    | Type: integer
    | Default: 0
    | Environment variable: TT_SECURITY_PASSWORD_MIN_LENGTH


..  _configuration_reference_security_secure_erasing:

..  confval:: security.secure_erasing

    If **true**, forces Tarantool to overwrite a data file a few times before deletion to render recovery of a deleted file impossible.
    The option applies to both ``.xlog`` and ``.snap`` files as well as Vinyl data files.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_SECURITY_SECURE_ERASING

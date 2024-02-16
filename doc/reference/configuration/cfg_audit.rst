..  _cfg_audit:

..  admonition:: Enterprise Edition
    :class: fact

    The audit log is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


The ``audit_log`` section defines configuration parameters related to :ref:`audit logging <enterprise_audit_module>`.

..  NOTE::

    ``audit_log`` can be defined in any :ref:`scope <configuration_scopes>`.

*   :ref:`audit_log.extract_key <configuration_reference_audit_extract_key>`
*   :ref:`audit_log.file <configuration_reference_audit_file>`
*   :ref:`audit_log.filter <configuration_reference_audit_filter>`
*   :ref:`audit_log.format <configuration_reference_audit_format>`
*   :ref:`audit_log.nonblock <configuration_reference_audit_nonblock>`
*   :ref:`audit_log.pipe <configuration_reference_audit_pipe>`
*   :ref:`audit_log.spaces <configuration_reference_audit_spaces>`
*   :ref:`audit_log.to <configuration_reference_audit_to>`
*   :ref:`audit_log.syslog.* <configuration_reference_audit_syslog>`

    -   :ref:`audit_log.syslog.facility <configuration_reference_audit_syslog-facility>`
    -   :ref:`audit_log.syslog.identity <configuration_reference_audit_syslog-identity>`
    -   :ref:`audit_log.syslog.server <configuration_reference_audit_syslog-server>`

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

    The option contains either one value from ``Possible values`` section (see below) or a combination of them.

    To enable :ref:`custom audit log events <audit-log-custom>`, specify the ``custom`` value in this option.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
        :language: lua
        :start-at: filter:
        :end-at: custom ]
        :dedent:

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
    If log is a program, its pid is stored in the ``audit.pid`` field.
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

..  _configuration_reference_audit_to:

..  confval:: audit_log.to

    Enable audit logging and define the log location.
    This option accepts the following values:

    -   ``devnull``: disable audit logging.
    -   ``file``: write audit logs to a file (see :ref:`audit_log.file <configuration_reference_audit_file>`).
    -   ``pipe``: start a program and write audit logs to it (see :ref:`audit_log.pipe <configuration_reference_audit_pipe>`).
    -   ``syslog``: write audit logs to a system logger (see :ref:`audit_log.syslog.* <configuration_reference_audit_syslog>`).

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

..  _configuration_reference_audit_syslog:

audit_log.syslog.*
~~~~~~~~~~~~~~~~~~

..  _configuration_reference_audit_syslog-facility:

..  confval:: audit_log.syslog.facility

    Specify a system logger keyword that tells `syslogd <https://datatracker.ietf.org/doc/html/rfc5424>`__ where to send the message.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

    See also: :ref:`syslog configuration example <configuration_reference_audit_syslog-example>`.

    |
    | Type: string
    | Possible values: 'auth', 'authpriv', 'cron', 'daemon', 'ftp', 'kern', 'lpr', 'mail', 'news', 'security', 'syslog', 'user', 'uucp', 'local0', 'local1', 'local2', 'local3', 'local4', 'local5', 'local6', 'local7'
    | Default: 'local7'
    | Environment variable: TT_AUDIT_LOG_SYSLOG_FACILITY

..  _configuration_reference_audit_syslog-identity:

..  confval:: audit_log.syslog.identity

    Specify an application name to show in logs.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

    See also: :ref:`syslog configuration example <configuration_reference_audit_syslog-example>`.

    |
    | Type: string
    | Default: 'tarantool'
    | Environment variable: TT_AUDIT_LOG_SYSLOG_IDENTITY

..  _configuration_reference_audit_syslog-server:

..  confval:: audit_log.syslog.server

    Set a location for the syslog server.
    It can be a Unix socket path starting with 'unix:' or an ipv4 port number.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

..  _configuration_reference_audit_syslog-example:

    **Example**

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log_syslog/config.yaml
        :language: yaml
        :start-at: audit_log:
        :end-at: 'tarantool_audit'
        :dedent:

    -   :ref:`audit_log.syslog.server <configuration_reference_audit_syslog-server>` -- a syslog server location.

    -   :ref:`audit_log.syslog.facility <configuration_reference_audit_syslog-facility>` -- a system logger keyword that tells syslogd where to send the message.
        The default value is ``local7``.

    -   :ref:`audit_log.syslog.identity <configuration_reference_audit_syslog-identity>` -- an application name to show in logs.
        The default value is ``tarantool``.

    These options are interpreted as a message for the `syslogd <https://datatracker.ietf.org/doc/html/rfc5424>`_ program,
    which runs in the background of any Unix-like platform.

    An example of a Tarantool audit log entry in the syslog:

    ..  code-block:: text

        09:32:52 tarantool_audit: {"time": "2024-02-08T09:32:52.190+0300", "uuid": "94454e46-9a0e-493a-bb9f-d59e44a43581", "severity": "INFO", "remote": "unix/:(socket)", "session_type": "console", "module": "tarantool", "user": "admin", "type": "space_create", "tag": "", "description": "Create space bands"}

    ..  warning::

        Above is an example of writing audit logs to a directory shared with the system logs.
        Tarantool allows this option, but it is not recommended to do this to avoid difficulties
        when working with audit logs. System and audit logs should be written separately.
        To do this, create separate paths and specify them.

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_AUDIT_LOG_SYSLOG_SERVER

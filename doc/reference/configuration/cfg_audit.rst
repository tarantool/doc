..  _cfg_audit:

..  admonition:: Enterprise Edition
    :class: fact

    Audit log features are available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

The ``audit_*`` parameters define configuration related to :ref:`audit logging <enterprise_audit_module>`.

*   :ref:`audit_extract_key <cfg_audit_extract_key>`
*   :ref:`audit_filter <cfg_audit_filter>`
*   :ref:`audit_format <cfg_audit_format>`
*   :ref:`audit_log <cfg_audit_log>`
*   :ref:`audit_nonblock <cfg_audit_nonblock>`
*   :ref:`audit_spaces <cfg_audit_spaces>`

..  _cfg_audit_extract_key:

..  confval:: audit_extract_key

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    If set to ``true``, the audit subsystem extracts and prints only the primary key instead of full
    tuples in DML events (``space_insert``, ``space_replace``, ``space_delete``).
    Otherwise, full tuples are logged.
    The option may be useful in case tuples are big.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_AUDIT_EXTRACT_KEY

..  _cfg_audit_filter:

..  confval:: audit_filter

    Enable logging for a specified subset of audit events.
    This option accepts the following values:

    *   Event names (for example, ``password_change``). For details, see :ref:`Audit log events <audit-log-events>`.
    *   Event groups (for example, ``audit``).  For details, see :ref:`Event groups <audit-log-event-groups>`.

    The option contains either one value from ``Possible values`` section (see below) or a combination of them.

    To enable :ref:`custom audit log events <audit-log-custom>`, specify the ``custom`` value in this option.

    The default value is ``compatibility``, which enables logging of all events available before 2.10.0.

    **Example**

    ..  code-block:: lua

        box.cfg{
            audit_log = 'audit.log',
            audit_filter = 'audit,auth,priv,password_change,access_denied'
           }

    |
    | Type: array
    | Possible values: 'all', 'audit', 'auth', 'priv', 'ddl', 'dml', 'data_operations', 'compatibility',
      'audit_enable', 'auth_ok', 'auth_fail', 'disconnect', 'user_create', 'user_drop', 'role_create', 'role_drop',
      'user_disable', 'user_enable', 'user_grant_rights', 'role_grant_rights', 'role_revoke_rights', 'password_change',
      'access_denied', 'eval', 'call', 'space_select', 'space_create', 'space_alter', 'space_drop', 'space_insert',
      'space_replace', 'space_delete', 'custom'
    | Default: 'compatibility'
    | Environment variable: TT_AUDIT_FILTER

..  _cfg_audit_format:

..  confval:: audit_format

    Specify the format that is used for the audit log events -- plain text, CSV or JSON format.

    Plain text is used by default. This human-readable format can be efficiently compressed.

    ..  code-block:: lua

        box.cfg{audit_log = 'audit.log', audit_format = 'plain'}

    **Example**

    ..  code-block:: text

        remote: session_type:background module:common.admin.auth user: type:custom_tdg_audit tag:tdg_severity_INFO description:[5e35b406-4274-4903-857b-c80115275940] subj: "anonymous", msg: "Access granted to anonymous user"

    The JSON format is more convenient to receive log events, analyze them and integrate them with other systems if needed.

    ..  code-block:: lua

        box.cfg{audit_log = 'audit.log', audit_format = 'json'}

    **Example**

    ..  code-block:: json

        {"time": "2022-11-17T21:55:49.880+0300", "remote": "", "session_type": "background", "module": "common.admin.auth", "user": "", "type": "custom_tdg_audit", "tag": "tdg_severity_INFO", "description": "[c26cd11a-3342-4ce6-8f0b-a4b222268b9d] subj: \"anonymous\", msg: \"Access granted to anonymous user\""}

    Using the CSV format allows you to view audit log events in tabular form.

    ..  code-block:: lua

        box.cfg{audit_log = 'audit.log', audit_format = 'csv'}

    **Example**

    ..  code-block:: text

        2022-11-17T21:58:03.131+0300,,background,common.admin.auth,,,custom_tdg_audit,tdg_severity_INFO,"[b3dfe2a3-ec29-4e61-b747-eb2332c83b2e] subj: ""anonymous"", msg: ""Access granted to anonymous user"""

    |
    | Type: string
    | Possible values: 'json', 'csv', 'plain'
    | Default: 'json'
    | Environment variable: TT_AUDIT_FORMAT

..  _cfg_audit_log:

..  confval:: audit_log

    Enable audit logging and define the log location.

    This option accepts a string value that allows you to define the log location.
    The following locations are supported:

    - File: to write audit logs to a file, specify a path to a file (with an optional `file` prefix)
    - Pipeline: to start a program and write audit logs to it, specify a program name (with `|` or `pipe` prefix)
    - System log: to write audit logs to a system log, specify a message for `syslogd` (with `syslog` prefix)

    See the examples below.

    By default, audit logging is disabled.

    **Example: Writing to a file**

    ..  code-block:: lua

        box.cfg{audit_log = 'audit_tarantool.log'}
        -- or
        box.cfg{audit_log = 'file:audit_tarantool.log'}

    This opens the ``audit_tarantool.log`` file for output in the server’s default directory.
    If the ``audit_log`` string has no prefix or the prefix ``file:``, the string is interpreted as a file path.

    If you log to a file, Tarantool will reopen the audit log at `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.

    **Example: Sending to a pipeline**

    ..  code-block:: lua

        box.cfg{audit_log = '| cronolog audit_tarantool.log'}
        -- or
        box.cfg{audit_log = 'pipe: cronolog audit_tarantool.log'}'

    This starts the `cronolog <https://linux.die.net/man/1/cronolog>`_ program when the server starts
    and sends all ``audit_log`` messages to cronolog's standard input (``stdin``).
    If the ``audit_log`` string starts with '|' or contains the prefix ``pipe:``,
    the string is interpreted as a Unix `pipeline <https://en.wikipedia.org/wiki/Pipeline_%28Unix%29>`_.

    If log is a program, check out its pid and send it a signal to rotate logs.

    **Example: Writing to a system log**

    ..  warning::

        Below is an example of writing audit logs to a directory shared with the system logs.
        Tarantool allows this option, but it is **not recommended** to do this to avoid difficulties
        when working with audit logs. System and audit logs should be written separately.
        To do this, create separate paths and specify them.

    This sample configuration sends the audit log to syslog:

    ..  code-block:: lua

        box.cfg{audit_log = 'syslog:identity=tarantool'}
        -- or
        box.cfg{audit_log = 'syslog:facility=user'}
        -- or
        box.cfg{audit_log = 'syslog:identity=tarantool,facility=user'}
        -- or
        box.cfg{audit_log = 'syslog:server=unix:/dev/log'}

    If the ``audit_log`` string starts with "syslog:",
    it is interpreted as a message for the `syslogd <https://datatracker.ietf.org/doc/html/rfc5424>`_ program,
    which normally runs in the background of any Unix-like platform.
    The setting can be 'syslog:', 'syslog:facility=...', 'syslog:identity=...', 'syslog:server=...' or a combination.

    The ``syslog:identity`` setting is an arbitrary string that is placed at the beginning of all messages.
    The default value is ``tarantool``.

    The ``syslog:facility`` setting is currently ignored, but will be used in the future.
    The value must be one of the `syslog <https://en.wikipedia.org/wiki/Syslog>`_ keywords
    that tell ``syslogd`` where to send the message.
    The possible values are ``auth``, ``authpriv``, ``cron``, ``daemon``, ``ftp``,
    ``kern``, ``lpr``, ``mail``, ``news``, ``security``, ``syslog``, ``user``, ``uucp``,
    ``local0``, ``local1``, ``local2``, ``local3``, ``local4``, ``local5``, ``local6``, ``local7``.
    The default value is ``local7``.

    The ``syslog:server`` setting is the locator for the syslog server.
    It can be a Unix socket path starting with "unix:" or an ipv4 port number.
    The default socket value is ``/dev/log`` (on Linux) or ``/var/run/syslog`` (on Mac OS).
    The default port value is 514, which is the UDP port.

    An example of a Tarantool audit log entry in the syslog:

    ..  code-block:: json

        09:32:52 tarantool_audit: {"time": "2024-02-08T09:32:52.190+0300", "uuid": "94454e46-9a0e-493a-bb9f-d59e44a43581", "severity": "INFO", "remote": "unix/:(socket)", "session_type": "console", "module": "tarantool", "user": "admin", "type": "space_create", "tag": "", "description": "Create space bands"}

    |
    | Type: string
    | Possible values: see the string format above
    | Default: 'nill'
    | Environment variable: TT_AUDIT_LOG

..  _cfg_audit_nonblock:

..  confval:: audit_nonblock

    Specify the logging behavior if the system is not ready to write.
    If set to ``true``, Tarantool does not block during logging if the system is non-writable and writes a message instead.
    Using this value may improve logging performance at the cost of losing some log messages.

    ..  note::

        The option only has an effect if the :ref:`audit_log <cfg_audit_log>` is set to ``syslog``
        or ``pipe``.

        Setting ``audit_nonblock`` to ``true`` is not allowed if the output is to a file.
        In this case, set ``audit_nonblock`` to ``false``.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_AUDIT_NONBLOCK

..  _cfg_audit_spaces:

..  confval:: audit_spaces

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    The array of space names for which data operation events (``space_select``, ``space_insert``, ``space_replace``,
    ``space_delete``) should be logged. The array accepts string values.
    If set to :ref:`box.NULL <box-null>`, the data operation events are logged for all spaces.

    **Example**

    In the example, only the events of ``bands`` and ``singers`` spaces are logged:

    ..  code-block:: lua

        box.cfg{
            audit_spaces = 'bands,singers'
           }

    |
    | Type: array
    | Default: box.NULL
    | Environment variable: TT_AUDIT_SPACES

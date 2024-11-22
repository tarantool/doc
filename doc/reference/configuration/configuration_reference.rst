..  _configuration_reference:

Configuration reference
=======================

This topic describes all :ref:`configuration parameters <configuration>` provided by Tarantool.

Most of the configuration options described in this reference can be applied to a specific instance, replica set, group, or to all instances globally.
To do so, you need to define the required option at the :ref:`specified level <configuration_scopes>`.

..  _configuration_reference_app:

app
---

Using Tarantool as an application server, you can run your own Lua applications.
In the ``app`` section, you can load the application and provide an application configuration in the ``app.cfg`` section.

.. NOTE::

    ``app`` can be defined in any :ref:`scope <configuration_scopes>`.

..  NOTE::

    Note that an application specified using ``app`` is loaded after application roles specified using the :ref:`roles <configuration_reference_roles>` option.

-   :ref:`app.cfg <configuration_reference_app_cfg>`
-   :ref:`app.file <configuration_reference_app_file>`
-   :ref:`app.module <configuration_reference_app_module>`


.. _configuration_reference_app_cfg:

.. confval:: app.cfg

    A configuration of the application loaded using ``app.file`` or ``app.module``.

    **Example**

    In the example below, the application is loaded from the ``myapp.lua`` file placed next to the YAML configuration file:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application/config.yaml
        :language: yaml
        :end-at: greeting
        :dedent:

    Example on GitHub: `application <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/application>`_

    .. tip::

        The :ref:`experimental.config.utils.schema <config_utils_schema_module>`
        built-in module provides an API for managing user-defined configurations
        of applications (``app.cfg``) and roles (``roles_cfg``).

    |
    | Type: map
    | Default: nil
    | Environment variable: TT_APP_CFG


.. _configuration_reference_app_file:

.. confval:: app.file

    A path to a Lua file to load an application from.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_APP_FILE


.. _configuration_reference_app_module:

.. confval:: app.module

    A Lua module to load an application from.

    **Example**

    The ``app`` section can be placed in any :ref:`configuration scope <configuration_scopes>`.
    As an example use case, you can provide different applications for storages and routers in a sharded cluster:

    ..  code-block:: yaml

        groups:
          storages:
            app:
              module: storage
              # ...
          routers:
            app:
              module: router
              # ...

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_APP_MODULE

..  _configuration_reference_audit:

audit_log
---------

..  admonition:: Enterprise Edition
    :class: fact

    Configuring ``audit_log`` parameters is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

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

..  _configuration_reference_audit_extract_key:

..  confval:: audit_log.extract_key

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

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
        :language: yaml
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

    This starts the `cronolog <https://linux.die.net/man/1/cronolog>`_ program when the server starts
    and sends all ``audit_log`` messages to cronolog standard input (``stdin``).

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log_pipe/config.yaml
        :language: yaml
        :start-at: audit_log:
        :end-at: 'cronolog audit_tarantool.log'
        :dedent:

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_AUDIT_LOG_PIPE

..  _configuration_reference_audit_spaces:

..  confval:: audit_log.spaces

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

*   :ref:`audit_log.syslog.facility <configuration_reference_audit_syslog-facility>`
*   :ref:`audit_log.syslog.identity <configuration_reference_audit_syslog-identity>`
*   :ref:`audit_log.syslog.server <configuration_reference_audit_syslog-server>`

..  _configuration_reference_audit_syslog-facility:

..  confval:: audit_log.syslog.facility

    Specify a system logger keyword that tells `syslogd <https://datatracker.ietf.org/doc/html/rfc5424>`__ where to send the message.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

    See also: :ref:`syslog configuration example <configuration_reference_audit_syslog-example>`

    |
    | Type: string
    | Possible values: 'auth', 'authpriv', 'cron', 'daemon', 'ftp', 'kern', 'lpr', 'mail', 'news', 'security', 'syslog', 'user', 'uucp', 'local0', 'local1', 'local2', 'local3', 'local4', 'local5', 'local6', 'local7'
    | Default: 'local7'
    | Environment variable: TT_AUDIT_LOG_SYSLOG_FACILITY

..  _configuration_reference_audit_syslog-identity:

..  confval:: audit_log.syslog.identity

    Specify an application name to show in logs.
    You can enable logging to a system logger using the :ref:`audit_log.to <configuration_reference_audit_to>` option.

    See also: :ref:`syslog configuration example <configuration_reference_audit_syslog-example>`

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

..  _configuration_reference_compat:

compat
------

The ``compat`` section defines values of the :ref:`compat <compat-module>` module options.

..  NOTE::

    ``compat`` can be defined in any :ref:`scope <configuration_scopes>`.

* :ref:`compat.binary_data_decoding <configuration_reference_compat_binary_decoding>`
* :ref:`compat.box_cfg_replication_sync_timeout <configuration_reference_compat_replication_timeout>`
* :ref:`compat.box_error_serialize_verbose <configuration_reference_compat_error_serialize>`
* :ref:`compat.box_error_unpack_type_and_code <configuration_reference_compat_error_unpack>`
* :ref:`compat.box_info_cluster_meaning <configuration_reference_compat_cluster_meaning>`
* :ref:`compat.box_session_push_deprecation <configuration_reference_compat_session_push>`
* :ref:`compat.box_space_execute_priv <configuration_reference_compat_space_execute>`
* :ref:`compat.box_space_max <configuration_reference_compat_space_max>`
* :ref:`compat.box_tuple_extension <configuration_reference_compat_tuple_extension>`
* :ref:`compat.box_tuple_new_vararg <configuration_reference_compat_tuple_new>`
* :ref:`compat.c_func_iproto_multireturn <configuration_reference_compat_iproto_multireturn>`
* :ref:`compat.fiber_channel_close_mode <configuration_reference_compat_fiber_channel>`
* :ref:`compat.fiber_slice_default <configuration_reference_compat_fiber_slice>`
* :ref:`compat.json_escape_forward_slash <configuration_reference_compat_json_escape>`
* :ref:`compat.sql_priv <configuration_reference_compat_sql_priv>`
* :ref:`compat.sql_seq_scan_default <configuration_reference_compat_sql_scan>`
* :ref:`compat.yaml_pretty_multiline <configuration_reference_compat_yaml_pretty>`


.. _configuration_reference_compat_binary_decoding:

.. confval:: compat.binary_data_decoding

    Define how to store binary data fields in Lua after decoding:

    -   ``new``: as varbinary objects
    -   ``old``: as plain strings

    See also: :ref:`compat-option-binary-decoding`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BINARY_DATA_DECODING

.. _configuration_reference_compat_replication_timeout:

.. confval:: compat.box_cfg_replication_sync_timeout

    Set a default replication sync timeout:

    -   ``new``: 0
    -   ``old``: 300 seconds

    .. important::

        This value is set during the initial ``box.cfg{}`` call and cannot be changed later.

    See also: :ref:`compat-option-replication-timeout`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BOX_CFG_REPLICATION_SYNC_TIMEOUT

.. _configuration_reference_compat_error_serialize:

.. confval:: compat.box_error_serialize_verbose

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    Set the verbosity of :ref:`error objects <box_error-error_object>` serialization:

    -   ``new``: serialize the error message together with other potentially useful fields
    -   ``old``: serialize only the error message

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'old'
    | Environment variable: TT_COMPAT_BOX_ERROR_SERIALIZE_VERBOSE

.. _configuration_reference_compat_error_unpack:

.. confval:: compat.box_error_unpack_type_and_code

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    Whether to show error fields in ``box.error.unpack()``:

    -   ``new``: do not show ``base_type`` and ``custom_type`` fields; do not show
        the ``code`` field if it is 0. Note that ``base_type`` is still accessible for an error object.
    -   ``old``: show all fields

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'old'
    | Environment variable: TT_COMPAT_BOX_ERROR_UNPACK_TYPE_AND_CODE

.. _configuration_reference_compat_cluster_meaning:

.. confval:: compat.box_info_cluster_meaning

    Define the behavior of ``box.info.cluster``:

    -   ``new``: show the entire cluster
    -   ``old:``: show the current replica set

    See also: :ref:`compat-option-box-info-cluster`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BOX_INFO_CLUSTER_MEANING


.. _configuration_reference_compat_session_push:

.. confval:: compat.box_session_push_deprecation

    Whether to raise errors on attempts to call the deprecated function ``box.session.push``:

    -   ``new``: raise an error
    -   ``old``: do not raise an error


    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'old'
    | Environment variable: TT_COMPAT_BOX_SESSION_PUSH_DEPRECATION

.. _configuration_reference_compat_space_execute:

.. confval:: compat.box_space_execute_priv

    Whether the ``execute`` privilege can be granted on spaces:

    -   ``new``: an error is raised
    -   ``old``: the privilege can be granted with no actual effect

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BOX_SPACE_EXECUTE_PRIV

.. _configuration_reference_compat_space_max:

.. confval:: compat.box_space_max

    Set the maximum space identifier (``box.schema.SPACE_MAX``):

    -   ``new``: 2147483646
    -   ``old``: 2147483647

    The limit was decremented because the old max value is used as an error indicator in the ``box`` C API.

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BOX_SPACE_MAX

.. _configuration_reference_compat_tuple_extension:

.. confval:: compat.box_tuple_extension

    Controls ``IPROTO_FEATURE_CALL_RET_TUPLE_EXTENSION`` and
    ``IPROTO_FEATURE_CALL_ARG_TUPLE_EXTENSION`` feature bits that
    define tuple encoding in iproto ``call`` and ``eval`` requests.

    -   ``new``: tuples with formats are encoded as ``MP_TUPLE``
    -   ``old``: tuples with formats are encoded as ``MP_ARRAY``

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BOX_TUPLE_EXTENSION

.. _configuration_reference_compat_tuple_new:

.. confval:: compat.box_tuple_new_vararg

    Controls how ``box.tuple.new`` interprets an argument list:

    -   ``new``: as a value with a tuple format
    -   ``old``: as an array of tuple fields

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_BOX_TUPLE_NEW_VARARG


.. _configuration_reference_compat_iproto_multireturn:

.. confval:: compat.c_func_iproto_multireturn

    Controls wrapping of multiple results of a stored C function when returning them via iproto:

    -   ``new``: return without wrapping (consistently with a local call via ``box.func``)
    -   ``old``: wrap results into a MessagePack array

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_C_FUNC_IPROTO_MULTIRETURN

.. _configuration_reference_compat_fiber_channel:

.. confval:: compat.fiber_channel_close_mode

    Define the behavior of fiber channels after closing:

    -   ``new``: mark the channel read-only
    -   ``old``: destroy the channel object

    See also: :ref:`compat-option-fiber-channel`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_FIBER_CHANNEL_CLOSE_MODE

.. _configuration_reference_compat_fiber_slice:

.. confval:: compat.fiber_slice_default

    Define the maximum fiber execution time without a yield:

    -   ``new``: ``{warn = 0.5, err = 1.0}``
    -   ``old``: infinity (no warnings or errors raised).

    See also: :ref:`compat-option-fiber-slice`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_FIBER_SLICE_DEFAULT

.. _configuration_reference_compat_json_escape:

.. confval:: compat.json_escape_forward_slash

    Whether to escape the forward slash symbol '/' using a backslash in a ``json.encode()`` result:

    -   ``new``: do not escape the forward slash
    -   ``old``: escape the forward slash

    See also: :ref:`compat-option-json-slash`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_JSON_ESCAPE_FORWARD_SLASH

.. _configuration_reference_compat_sql_priv:

.. confval:: compat.sql_priv

    Whether to enable access checks for SQL requests over iproto:

    -   ``new``: check the user's access permissions
    -   ``old``: allow any user to execute SQL over iproto

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_SQL_PRIV

.. _configuration_reference_compat_sql_scan:

.. confval:: compat.sql_seq_scan_default

    Controls the default value of the ``sql_seq_scan`` session setting:

    -   ``new``: false
    -   ``old``: true

    See also: :ref:`compat-option-sql-scan`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_SQL_SEQ_SCAN_DEFAULT

.. _configuration_reference_compat_yaml_pretty:

.. confval:: compat.yaml_pretty_multiline

    Whether to encode in block scalar style all multiline strings or ones containing the ``\n\n`` substring:

    -   ``new``: all multiline strings
    -   ``old``: only strings containing the ``\n\n`` substring

    See also: :ref:`compat-option-lyaml`

    |
    | Type: string
    | Possible values: 'new', 'old'
    | Default: 'new'
    | Environment variable: TT_COMPAT_YAML_PRETTY_MULTILINE


..  _configuration_reference_conditional:

conditional
-----------

The ``conditional`` section defines the configuration parts that apply to instances
that meet certain conditions.

..  NOTE::

    ``conditional`` can be defined in the global :ref:`scope <configuration_scopes>` only.

* :ref:`conditional.if <configuration_reference_conditional_if>`

.. _configuration_reference_conditional_if:

.. confval:: conditional.if

    Specify a conditional section of the configuration. The configuration options
    defined inside a ``conditional.if`` section apply only to instances on which
    the specified condition is true.

    Conditions can include one variable -- ``tarantool_version``: a three-number
    Tarantool version running on the instance, for example,  3.1.0. It compares to
    *version literal* values that include three numbers separated by periods (``x.y.z``).

    The following operators are available in conditions:

    -   comparison: ``>``, ``<``, ``>=``, ``<=``, ``==``, ``!=``
    -   logical operators ``||`` (OR) and ``&&`` (AND)
    -   parentheses ``()``

    **Example**:

    In this example, different configuration parts apply to instances running
    Tarantool versions above and below 3.1.0:

    -   On versions less than 3.1.0, the ``upgraded`` label is set to ``false``.
    -   On versions 3.1.0 or newer, the ``upgraded`` label is set to ``true``.
        Additionally, new ``compat`` options are defined. These options were introduced
        in version 3.1.0, so on older versions they would cause an error.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/conditional/config.yaml
        :language: yaml
        :start-at: conditional:
        :end-before: groups:
        :dedent:

    See also: :ref:`configuration_conditional`

..  _configuration_reference_config:

config
------

The ``config`` section defines various parameters related to centralized configuration.

..  NOTE::

    ``config`` can be defined in the global :ref:`scope <configuration_scopes>` only.

* :ref:`config.reload <configuration_reference_config_reload>`
* :ref:`config.context.* <configuration_reference_config_context_options>`
* :ref:`config.etcd.* <configuration_reference_config_etcd>`
* :ref:`config.storage.* <configuration_reference_config_storage>`

.. _configuration_reference_config_reload:

.. confval:: config.reload

    Specify how the configuration is reloaded.
    This option accepts the following values:

    - ``auto``: configuration is reloaded automatically when it is changed.
    - ``manual``: configuration should be reloaded manually. In this case, you can reload the configuration in the application code using :ref:`config:reload() <config-module>`.

    See also: :ref:`Reloading configuration <etcd_reloading_configuration>`

    |
    | Type: string
    | Possible values: 'auto', 'manual'
    | Default: 'auto'
    | Environment variable: TT_CONFIG_RELOAD


.. _configuration_reference_config_context_options:

config.context.*
~~~~~~~~~~~~~~~~

This section describes options related to loading configuration settings from external storage such as external files or environment variables.

*   :ref:`config.context <configuration_reference_config_context>`

    * :ref:`config.context.\<name\> <configuration_reference_config_context_name>`

        * :ref:`config.context.\<name\>.env <configuration_reference_config_context_name_env>`
        * :ref:`config.context.\<name\>.from <configuration_reference_config_context_name_from>`
        * :ref:`config.context.\<name\>.file <configuration_reference_config_context_name_file>`
        * :ref:`config.context.\<name\>.env <configuration_reference_config_context_name_rstrip>`

..  _configuration_reference_config_context:

..  confval:: config.context

    Specify how to load settings from external storage.
    For example, this option can be used to load passwords from safe storage.
    You can find examples in the :ref:`configuration_credentials_loading_secrets` section.

    |
    | Type: map
    | Default: nil
    | Environment variable: TT_CONFIG_CONTEXT


..  _configuration_reference_config_context_name:

..  confval:: config.context.<name>

    The name of an entity that identifies a configuration value to load.

..  _configuration_reference_config_context_name_env:

..  confval:: config.context.<name>.env

    The name of an environment variable to load a configuration value from.
    To load a configuration value from an environment variable, set :ref:`config.context.\<name\>.from <configuration_reference_config_context_name_from>` to ``env``.

    **Example**

    In this example, passwords are loaded from the ``DBADMIN_PASSWORD`` and ``SAMPLEUSER_PASSWORD`` environment variables:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials_context_env/config.yaml
        :language: yaml
        :start-at: config:
        :end-before: credentials:
        :dedent:

    See also: :ref:`configuration_credentials_loading_secrets`


..  _configuration_reference_config_context_name_from:

..  confval:: config.context.<name>.from

    The type of storage to load a configuration value from.
    There are the following storage types:

    *   ``file``: load a configuration value from a file.
        In this case, you need to specify the path to the file using :ref:`config.context.\<name\>.file <configuration_reference_config_context_name_file>`.
    *   ``env``: load a configuration value from an environment variable.
        In this case, specify the environment variable name using :ref:`config.context.\<name\>.env <configuration_reference_config_context_name_env>`.


..  _configuration_reference_config_context_name_file:

..  confval:: config.context.<name>.file

    The path to a file to load a configuration value from.
    To load a configuration value from a file, set :ref:`config.context.\<name\>.from <configuration_reference_config_context_name_from>` to ``file``.

    **Example**

    In this example, passwords are loaded from the ``dbadmin_password.txt`` and ``sampleuser_password.txt`` files:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials_context_file/config.yaml
        :language: yaml
        :start-at: config:
        :end-before: credentials:
        :dedent:

    See also: :ref:`configuration_credentials_loading_secrets`


..  _configuration_reference_config_context_name_rstrip:

..  confval:: config.context.<name>.rstrip

    (Optional) Whether to strip whitespace characters and newlines from the end of data.

.. _configuration_reference_config_etcd:

config.etcd.*
~~~~~~~~~~~~~

..  include:: /platform/configuration/configuration_etcd.rst
    :start-after: ee_note_centralized_config_start
    :end-before: ee_note_centralized_config_end

This section describes options related to providing connection settings to a :ref:`centralized etcd-based storage <configuration_etcd>`.
If :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``supervised``, Tarantool also uses etcd to maintain the state of failover coordinators.

..  NOTE::

    Note that a :ref:`centralized cluster configuration <centralized_configuration_storage_publish_config>` cannot contain the ``config.etcd`` section.

* :ref:`config.etcd.endpoints <config_etcd_endpoints>`
* :ref:`config.etcd.prefix <config_etcd_prefix>`
* :ref:`config.etcd.username <config_etcd_username>`
* :ref:`config.etcd.password <config_etcd_password>`
* :ref:`config.etcd.ssl.ca_file <config_etcd_ssl_ca_file>`
* :ref:`config.etcd.ssl.ca_path <config_etcd_ssl_ca_path>`
* :ref:`config.etcd.ssl.ssl_cert <config_etcd_ssl_ssl_cert>`
* :ref:`config.etcd.ssl.ssl_key <config_etcd_ssl_ssl_key>`
* :ref:`config.etcd.ssl.verify_host <config_etcd_ssl_verify_host>`
* :ref:`config.etcd.ssl.verify_peer <config_etcd_ssl_verify_peer>`
* :ref:`config.etcd.http.request.timeout <config_etcd_http_request_timeout>`
* :ref:`config.etcd.http.request.unix_socket <config_etcd_http_request_unix_socket>`
* :ref:`config.etcd.watchers.reconnect_max_attempts <config_etcd_watchers_reconnect_max_attempts>`
* :ref:`config.etcd.watchers.reconnect_timeout <config_etcd_watchers_reconnect_timeout>`

.. _config_etcd_endpoints:

.. confval:: config.etcd.endpoints

    The list of endpoints used to access an etcd server.

    See also: :ref:`etcd_local_configuration`

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_ENDPOINTS

.. _config_etcd_prefix:

.. confval:: config.etcd.prefix

    A key prefix used to search a configuration on an etcd server.
    Tarantool searches keys by the following path: ``<prefix>/config/*``.
    Note that ``<prefix>`` should start with a slash (``/``).

    See also: :ref:`etcd_local_configuration`

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PREFIX

.. _config_etcd_username:

.. confval:: config.etcd.username

    A username used for authentication.

    See also: :ref:`etcd_local_configuration`

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_USERNAME

.. _config_etcd_password:

.. confval:: config.etcd.password

    A password used for authentication.

    See also: :ref:`etcd_local_configuration`

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_PASSWORD

.. _config_etcd_ssl_ca_file:

.. confval:: config.etcd.ssl.ca_file

    A path to a trusted certificate authorities (CA) file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_FILE

.. _config_etcd_ssl_ca_path:

.. confval:: config.etcd.ssl.ca_path

    A path to a directory holding certificates to verify the peer with.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_CA_PATH

.. _config_etcd_ssl_ssl_cert:

.. confval:: config.etcd.ssl.ssl_cert

    **Since:** :doc:`3.2.0 </release/3.2.0>`

    A path to an SSL certificate file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_SSL_CERT

.. _config_etcd_ssl_ssl_key:

.. confval:: config.etcd.ssl.ssl_key

    A path to a private SSL key file.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_SSL_KEY

.. _config_etcd_ssl_verify_host:

.. confval:: config.etcd.ssl.verify_host

    Enable verification of the certificate's name (CN) against the specified host.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_HOST


.. _config_etcd_ssl_verify_peer:

.. confval:: config.etcd.ssl.verify_peer

    Enable verification of the peer's SSL certificate.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_SSL_VERIFY_PEER


.. _config_etcd_http_request_timeout:

.. confval:: config.etcd.http.request.timeout

    A time period required to process an HTTP request to an etcd server: from sending a request to receiving a response.

    See also: :ref:`etcd_local_configuration`

    |
    | Type: number
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_TIMEOUT

.. _config_etcd_http_request_unix_socket:

.. confval:: config.etcd.http.request.unix_socket

    A Unix domain socket used to connect to an etcd server.

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_HTTP_REQUEST_UNIX_SOCKET

.. _config_etcd_watchers_reconnect_max_attempts:

.. confval:: config.etcd.watchers.reconnect_max_attempts

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    The maximum number of attempts to reconnect to an etcd server in case of connection failure.

    |
    | Type: integer
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_WATCHERS_RECONNECT_MAX_ATTEMPTS

.. _config_etcd_watchers_reconnect_timeout:

.. confval:: config.etcd.watchers.reconnect_timeout

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    The timeout (in seconds) between attempts to reconnect to an etcd server in case of connection failure.

    |
    | Type: number
    | Default: nil
    | Environment variable: TT_CONFIG_ETCD_WATCHERS_RECONNECT_TIMEOUT


.. _configuration_reference_config_storage:

config.storage.*
~~~~~~~~~~~~~~~~

..  include:: /platform/configuration/configuration_etcd.rst
    :start-after: ee_note_centralized_config_start
    :end-before: ee_note_centralized_config_end

This section describes options related to providing connection settings to a :ref:`centralized Tarantool-based storage <configuration_etcd>`.

..  NOTE::

    Note that a :ref:`centralized cluster configuration <centralized_configuration_storage_publish_config>` cannot contain the ``config.storage`` section.

* :ref:`config.storage.endpoints <config_storage_endpoints>`
* :ref:`config.storage.prefix <config_storage_prefix>`
* :ref:`config.storage.reconnect_after <config_storage_reconnect_after>`
* :ref:`config.storage.timeout <config_storage_timeout>`

.. _config_storage_endpoints:

.. confval:: config.storage.endpoints

    An array of endpoints used to access a configuration storage.
    Each endpoint can include the following fields:

    *    ``uri``: a URI of the configuration storage's instance.
    *    ``login``: a username used to connect to the instance.
    *    ``password``: a password used for authentication.
    *    ``params``: SSL parameters required for :ref:`encrypted connections <configuration_connections_ssl>` (:ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`).

    See also: :ref:`centralized_configuration_storage_connect_tarantool`

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_CONFIG_STORAGE_ENDPOINTS


.. _config_storage_prefix:

.. confval:: config.storage.prefix

    A key prefix used to search a configuration in a centralized configuration storage.
    Tarantool searches keys by the following path: ``<prefix>/config/*``.
    Note that ``<prefix>`` should start with a slash (``/``).

    See also: :ref:`centralized_configuration_storage_connect_tarantool`

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_CONFIG_STORAGE_PREFIX


.. _config_storage_reconnect_after:

.. confval:: config.storage.reconnect_after

    A number of seconds to wait before reconnecting to a configuration storage.

    |
    | Type: number
    | Default: 3
    | Environment variable: TT_CONFIG_STORAGE_RECONNECT_AFTER


.. _config_storage_timeout:

.. confval:: config.storage.timeout

    The interval (in seconds) to perform the status check of a configuration storage.

    See also: :ref:`centralized_configuration_storage_connect_tarantool`

    |
    | Type: number
    | Default: 3
    | Environment variable: TT_CONFIG_STORAGE_TIMEOUT

..  _configuration_reference_console:

console
-------

Configure the administrative console. A client to the console is ``tt connect``.

..  NOTE::

    ``console`` can be defined in any :ref:`scope <configuration_scopes>`.

* :ref:`console.enabled <configuration_reference_console_enabled>`
* :ref:`console.socket <configuration_reference_console_socket>`

.. _configuration_reference_console_enabled:

.. confval:: console.enabled

    Whether to listen on the Unix socket provided in the
    :ref:`console.socket <configuration_reference_console_socket>` option.

    If the option is set to ``false``, the administrative console is disabled.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_CONSOLE_ENABLED

.. _configuration_reference_console_socket:

.. confval:: console.socket

    The Unix socket for the administrative console.

    Mind the following nuances:

    * Only a Unix domain socket is allowed. A TCP socket can't be configured this way.
    * ``console.socket`` is a file path, without any ``unix:`` or ``unix/:`` prefixes.
    * If the file path is a relative path, it is interpreted relative to
      :ref:`process.work_dir <configuration_reference_process_work_dir>`.

    |
    | Type: string
    | Default: 'var/run/{{ instance_name }}/tarantool.control'
    | Environment variable: TT_CONSOLE_SOCKET

..  _configuration_reference_credentials:

credentials
-----------

The ``credentials`` section allows you to create users and grant them the specified privileges.
Learn more in :ref:`configuration_credentials`.

.. NOTE::

    ``credentials`` can be defined in any :ref:`scope <configuration_scopes>`.

*   :ref:`credentials.roles.* <configuration_reference_credentials_roles_options>`
*   :ref:`credentials.users.* <configuration_reference_credentials_users_options>`
*   :ref:`<user_or_role_name>.privileges.* <configuration_reference_credentials_privileges_options>`

..  _configuration_reference_credentials_roles_options:

credentials.roles.*
~~~~~~~~~~~~~~~~~~~

*   :ref:`credentials.roles <configuration_reference_credentials_roles>`

    *   :ref:`credentials.roles.\<role_name\>.roles <configuration_reference_credentials_roles_name_roles>`
    *   :ref:`credentials.roles.\<role_name\>.privileges <configuration_reference_credentials_roles_name_privileges>`

.. _configuration_reference_credentials_roles:

.. confval:: credentials.roles

    An array of :ref:`roles <access_control_concepts_roles>` that can be granted to users or other roles.

    **Example**

    In the example below, the ``writers_space_reader`` role gets privileges to select data in the ``writers`` space:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
        :language: yaml
        :start-after: spaces: [ books ]
        :end-at: spaces: [ writers ]
        :dedent:

    See also: :ref:`configuration_credentials_managing_users_roles`

    |
    | Type: map
    | Default: nil
    | Environment variable: TT_CREDENTIALS_ROLES

.. _configuration_reference_credentials_roles_name_roles:

.. confval:: credentials.roles.<role_name>.roles

    An array of :ref:`roles <access_control_concepts_roles>` granted to this role.

.. _configuration_reference_credentials_roles_name_privileges:

.. confval:: credentials.roles.<role_name>.privileges

    An array of :ref:`privileges <authentication-owners_privileges>` granted to this role.

    See :ref:`\<user_or_role_name\>.privileges.* <configuration_reference_credentials_privileges_options>`.

..  _configuration_reference_credentials_users_options:

credentials.users.*
~~~~~~~~~~~~~~~~~~~

*   :ref:`credentials.users <configuration_reference_credentials_users>`

    *   :ref:`credentials.users.\<username\>.password <configuration_reference_credentials_users_name_password>`
    *   :ref:`credentials.users.\<username\>.roles <configuration_reference_credentials_users_name_roles>`
    *   :ref:`credentials.users.\<username\>.privileges <configuration_reference_credentials_users_name_privileges>`

.. _configuration_reference_credentials_users:

.. confval:: credentials.users

    An array of :ref:`users <access_control_concepts_users>`.

    **Example**

    In this example, ``sampleuser`` gets the following privileges:

    *   Privileges granted to the ``writers_space_reader`` role.
    *   Privileges to select and modify data in the ``books`` space.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
        :language: yaml
        :start-at: sampleuser:
        :end-at: [ books ]
        :dedent:

    See also: :ref:`configuration_credentials_managing_users_roles`

    |
    | Type: map
    | Default: nil
    | Environment variable: TT_CREDENTIALS_USERS


.. _configuration_reference_credentials_users_name_password:

.. confval:: credentials.users.<username>.password

    A user's password.

    **Example**

    In the example below, a password for the ``dbadmin`` user is set:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-at: T0p_Secret
        :dedent:

    See also: :ref:`configuration_credentials_loading_secrets`

.. _configuration_reference_credentials_users_name_roles:

.. confval:: credentials.users.<username>.roles

    An array of :ref:`roles <access_control_concepts_roles>` granted to this user.

.. _configuration_reference_credentials_users_name_privileges:

.. confval:: credentials.users.<username>.privileges

    An array of :ref:`privileges <authentication-owners_privileges>` granted to this user.

    See :ref:`\<user_or_role_name\>.privileges.* <configuration_reference_credentials_privileges_options>`.

..  _configuration_reference_credentials_privileges_options:

<user_or_role_name>.privileges.*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*   :ref:`\<user_or_role_name\>.privileges <configuration_reference_credentials_privileges>`

    *   :ref:`\<user_or_role_name\>.privileges.permissions <configuration_reference_credentials_privileges_permissions>`
    *   :ref:`\<user_or_role_name\>.privileges.spaces <configuration_reference_credentials_privileges_spaces>`
    *   :ref:`\<user_or_role_name\>.privileges.functions <configuration_reference_credentials_privileges_functions>`
    *   :ref:`\<user_or_role_name\>.privileges.sequences <configuration_reference_credentials_privileges_sequences>`
    *   :ref:`\<user_or_role_name\>.privileges.lua_eval <configuration_reference_credentials_privileges_lua_eval>`
    *   :ref:`\<user_or_role_name\>.privileges.lua_call <configuration_reference_credentials_privileges_lua_call>`
    *   :ref:`\<user_or_role_name\>.privileges.sql <configuration_reference_credentials_privileges_sql>`

..  _configuration_reference_credentials_privileges:

.. confval:: <user_or_role_name>.privileges

    Privileges that can be granted to a user or role using the following options:

    *   :ref:`credentials.users.\<username\>.privileges <configuration_reference_credentials_users_name_privileges>`
    *   :ref:`credentials.roles.\<role_name\>.privileges <configuration_reference_credentials_roles_name_privileges>`

..  _configuration_reference_credentials_privileges_permissions:

.. confval:: <user_or_role_name>.privileges.permissions

    :ref:`Permissions <access_control_list_privileges>` assigned to this user or a user with this role.

    **Example**

    In this example, ``sampleuser`` gets privileges to select and modify data in the ``books`` space:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
        :language: yaml
        :start-at: sampleuser:
        :end-at: [ books ]
        :dedent:

    See also: :ref:`configuration_credentials_managing_users_roles`

..  _configuration_reference_credentials_privileges_spaces:

.. confval:: <user_or_role_name>.privileges.spaces

    Spaces to which this user or a user with this role gets the specified permissions.

    **Example**

    In this example, ``sampleuser`` gets privileges to select and modify data in the ``books`` space:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/credentials/config.yaml
        :language: yaml
        :start-at: sampleuser:
        :end-at: [ books ]
        :dedent:

    See also: :ref:`configuration_credentials_managing_users_roles`

..  _configuration_reference_credentials_privileges_functions:

.. confval:: <user_or_role_name>.privileges.functions

    Functions to which this user or a user with this role gets the specified permissions.

..  _configuration_reference_credentials_privileges_sequences:

.. confval:: <user_or_role_name>.privileges.sequences

    Sequences to which this user or a user with this role gets the specified permissions.

..  _configuration_reference_credentials_privileges_lua_eval:

.. confval:: <user_or_role_name>.privileges.lua_eval

    Whether this user or a user with this role can execute arbitrary Lua code.

..  _configuration_reference_credentials_privileges_lua_call:

.. confval:: <user_or_role_name>.privileges.lua_call

    A list of global user-defined Lua functions that this user or a user with this role can call.
    To allow calling all such functions, specify the ``all`` value.

    This option should be configured together with the ``execute``
    :ref:`permission <configuration_reference_credentials_privileges_permissions>`.

..  _configuration_reference_credentials_privileges_sql:

.. confval:: <user_or_role_name>.privileges.sql

    Whether this user or a user with this role can execute an arbitrary SQL expression.

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

    Whether to start the server in the hot standby mode.
    This mode can be used to provide failover without :ref:`replication <replication>`.

    Suppose there are two cluster applications.
    Each cluster has one instance with the same configuration:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/hot_standby_1/config.yaml
        :language: yaml
        :dedent:

    In particular, both instances use the same directory for storing write-ahead logs and snapshots.

    When you start both cluster applications on the same machine, the instance from the first one will be the primary instance and the second will be the standby instance.
    In the :ref:`logs <configuration_reference_log>` of the second cluster instance, you should see a notification:

    ..  code-block:: text

        main/104/interactive I> Entering hot standby mode

    This means that the standby instance is ready to take over if the primary instance goes down.
    The standby instance initializes and tries to take a lock on a directory for storing write-ahead logs
    but fails because the primary instance has made a lock on this directory.

    If the primary instance goes down for any reason, the lock is released.
    In this case, the standby instance succeeds in taking the lock and becomes the primary instance.

    ``database.hot_standby`` has no effect:

    * If :ref:`wal.mode <configuration_reference_wal_mode>` is set to ``none``.
    * If :ref:`wal.dir_rescan_delay <configuration_reference_wal_dir_rescan_delay>` is set to a large value on macOS or FreeBSD. On these platforms, the hot standby mode is designed so that the loop repeats every ``wal.dir_rescan_delay`` seconds.
    * For spaces created with :ref:`engine <space_opts_engine>` set to ``vinyl``.

    Examples on GitHub: `hot_standby_1 <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/hot_standby_1>`_, `hot_standby_2 <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/hot_standby_2>`_

    |
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

    |
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

..  _configuration_reference_failover:

failover
--------

The ``failover`` section defines parameters related to a :ref:`supervised failover <repl_supervised_failover>`.

.. NOTE::

    ``failover`` can be defined in the global :ref:`scope <configuration_scopes>` only.

-   :ref:`failover.call_timeout <configuration_reference_failover_call_timeout>`
-   :ref:`failover.connect_timeout <configuration_reference_failover_connect_timeout>`
-   :ref:`failover.lease_interval <configuration_reference_failover_lease_interval>`
-   :ref:`failover.probe_interval <configuration_reference_failover_probe_interval>`
-   :ref:`failover.renew_interval <configuration_reference_failover_renew_interval>`
-   :ref:`failover.stateboard.* <configuration_reference_failover_stateboard>`

..  _configuration_reference_failover_call_timeout:

..  confval:: failover.call_timeout

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A call timeout (in seconds) for monitoring and failover requests to an instance.

    | Type: number
    | Default: 1
    | Environment variable: TT_FAILOVER_CALL_TIMEOUT

..  _configuration_reference_failover_connect_timeout:

..  confval:: failover.connect_timeout

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A connection timeout (in seconds) for monitoring and failover requests to an instance.

    | Type: number
    | Default: 1
    | Environment variable: TT_FAILOVER_CONNECT_TIMEOUT

..  _configuration_reference_failover_lease_interval:

..  confval:: failover.lease_interval

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A time interval (in seconds) that specifies how long an instance should be a leader without renew requests from a coordinator.
    When this interval expires, the leader switches to read-only mode.
    This action is performed by the instance itself and works even if there is no connectivity between the instance and the coordinator.

    | Type: number
    | Default: 30
    | Environment variable: TT_FAILOVER_LEASE_INTERVAL

..  _configuration_reference_failover_probe_interval:

..  confval:: failover.probe_interval

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A time interval (in seconds) that specifies how often a monitoring service of the failover coordinator polls an instance for its status.

    | Type: number
    | Default: 10
    | Environment variable: TT_FAILOVER_PROBE_INTERVAL

..  _configuration_reference_failover_renew_interval:

..  confval:: failover.renew_interval

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A time interval (in seconds) that specifies how often a failover coordinator sends read-write deadline renewals.

    | Type: number
    | Default: 10
    | Environment variable: TT_FAILOVER_RENEW_INTERVAL


..  _configuration_reference_failover_stateboard:

failover.stateboard.*
~~~~~~~~~~~~~~~~~~~~~

``failover.stateboard.*`` options define configuration parameters related to maintaining the state of failover coordinators in a remote etcd-based storage.

*   :ref:`failover.stateboard.keepalive_interval <configuration_reference_failover_stateboard_keepalive_interval>`
*   :ref:`failover.stateboard.renew_interval <configuration_reference_failover_stateboard_renew_interval>`

See also: :ref:`supervised_failover_overview_fault_tolerance`

..  _configuration_reference_failover_stateboard_keepalive_interval:

..  confval:: failover.stateboard.keepalive_interval

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A time interval (in seconds) that specifies how long a transient state information is stored and how quickly a lock expires.

    ..  NOTE::

        ``failover.stateboard.keepalive_interval`` should be smaller than :ref:`failover.lease_interval <configuration_reference_failover_lease_interval>`.
        Otherwise, switching of a coordinator causes a replica set leader to go to read-only mode for some time.

    | Type: number
    | Default: 10
    | Environment variable: TT_FAILOVER_STATEBOARD_KEEPALIVE_INTERVAL

..  _configuration_reference_failover_stateboard_renew_interval:

..  confval:: failover.stateboard.renew_interval

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    A time interval (in seconds) that specifies how often a failover coordinator writes its state information to etcd.
    This option also determines the frequency at which an active coordinator reads new commands from etcd.

    | Type: number
    | Default: 2
    | Environment variable: TT_FAILOVER_STATEBOARD_RENEW_INTERVAL

..  _configuration_reference_feedback:

feedback
--------

The ``feedback`` section describes configuration parameters for sending information about a running Tarantool instance to the specified feedback server.

..  NOTE::

    ``feedback`` can be defined in any :ref:`scope <configuration_scopes>`.

* :ref:`feedback.crashinfo <configuration_reference_feedback_crashinfo>`
* :ref:`feedback.enabled <configuration_reference_feedback_enabled>`
* :ref:`feedback.host <configuration_reference_feedback_host>`
* :ref:`feedback.interval <configuration_reference_feedback_interval>`
* :ref:`feedback.metrics_collect_interval <configuration_reference_feedback_metrics_collect_interval>`
* :ref:`feedback.metrics_limit <configuration_reference_feedback_metrics_limit>`
* :ref:`feedback.send_metrics <configuration_reference_feedback_send_metrics>`

..  _configuration_reference_feedback_crashinfo:

..  confval:: feedback.crashinfo

    Whether to send crash information in the case of an instance failure.
    This information includes:

    -   General information from the ``uname`` output.
    -   Build information.
    -   The crash reason.
    -   The stack trace.

    To turn off sending crash information, set this option to ``false``.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_FEEDBACK_CRASHINFO

..  _configuration_reference_feedback_enabled:

..  confval:: feedback.enabled

    Whether to send information about a running instance to the feedback server.
    To turn off sending feedback, set this option to ``false``.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_FEEDBACK_ENABLED

..  _configuration_reference_feedback_host:

..  confval:: feedback.host

    The address to which information is sent.

    |
    | Type: string
    | Default: https://feedback.tarantool.io
    | Environment variable: TT_FEEDBACK_HOST

..  _configuration_reference_feedback_interval:

..  confval:: feedback.interval

    The interval (in seconds) of sending information.

    |
    | Type: number
    | Default: 3600
    | Environment variable: TT_FEEDBACK_INTERVAL

..  _configuration_reference_feedback_metrics_collect_interval:

..  confval:: feedback.metrics_collect_interval

    The interval (in seconds) for collecting metrics.

    |
    | Type: number
    | Default: 60
    | Environment variable: TT_FEEDBACK_METRICS_COLLECT_INTERVAL

..  _configuration_reference_feedback_metrics_limit:

..  confval:: feedback.metrics_limit

    The maximum size of memory (in bytes) used to store metrics before sending them to the feedback server.
    If the size of collected metrics exceeds this value, earlier metrics are dropped.

    |
    | Type: integer
    | Default: 1024 * 1024 (1048576)
    | Environment variable: TT_FEEDBACK_METRICS_LIMIT

..  _configuration_reference_feedback_send_metrics:

..  confval:: feedback.send_metrics

    Whether to send :ref:`metrics <monitoring>` to the feedback server.
    Note that all collected metrics are dropped after sending them to the feedback server.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_FEEDBACK_SEND_METRICS


..  _configuration_reference_fiber:

fiber
-----

The ``fiber`` section describes options related to configuring :ref:`fibers, yields, and cooperative multitasking <concepts-coop_multitasking>`.

..  NOTE::

    ``fiber`` can be defined in any :ref:`scope <configuration_scopes>`.

* :ref:`fiber.io_collect_interval <configuration_reference_fiber_io_collect_interval>`
* :ref:`fiber.too_long_threshold <configuration_reference_fiber_too_long_threshold>`
* :ref:`fiber.worker_pool_threads <configuration_reference_fiber_worker_pool_threads>`
* :ref:`fiber.slice.* <configuration_reference_fiber_slice_options>`
* :ref:`fiber.top.* <configuration_reference_fiber_top_options>`

..  _configuration_reference_fiber_io_collect_interval:

..  confval:: fiber.io_collect_interval

    The time period (in seconds) a :ref:`fiber <app-fibers>` sleeps between
    iterations of the event loop.

    ``fiber.io_collect_interval`` can be used to reduce CPU load in deployments
    where the number of client connections is large, but requests are not so frequent
    (for example, each connection issues just a handful of requests per second).

    |
    | Type: number
    | Default: box.NULL
    | Environment variable: TT_FIBER_IO_COLLECT_INTERVAL

..  _configuration_reference_fiber_too_long_threshold:

..  confval:: fiber.too_long_threshold

    If processing a request takes longer than the given period (in seconds),
    the fiber warns about it in the log.

    ``fiber.too_long_threshold`` has effect only if
    :ref:`log.level <configuration_reference_log_level>` is greater than
    or equal to 4 (``warn``).

    |
    | Type: number
    | Default: 0.5
    | Environment variable: TT_FIBER_TOO_LONG_THRESHOLD

..  _configuration_reference_fiber_worker_pool_threads:

..  confval:: fiber.worker_pool_threads

    The maximum number of threads to use during execution
    of certain internal processes (for example,
    :ref:`socket.getaddrinfo() <socket-getaddrinfo>` and
    :ref:`coio_call() <c_api-coio-coio_call>`).

    |
    | Type: number
    | Default: 4
    | Environment variable: TT_FIBER_WORKER_POOL_THREADS

.. _configuration_reference_fiber_slice_options:

fiber.slice.*
~~~~~~~~~~~~~

This section describes options related to configuring time periods for
:ref:`fiber slices <fibers_limit_execution_time>`.
See :ref:`fiber.set_max_slice <fiber-set_max_slice>` for details and examples.

* :ref:`fiber.slice.warn <configuration_reference_fiber_slice_warn>`
* :ref:`fiber.slice.err <configuration_reference_fiber_slice_err>`

..  _configuration_reference_fiber_slice_warn:

..  confval:: fiber.slice.warn

    Set a time period (in seconds) that specifies the warning slice.

    |
    | Type: number
    | Default: 0.5
    | Environment variable: TT_FIBER_SLICE_WARN

..  _configuration_reference_fiber_slice_err:

..  confval:: fiber.slice.err

    Set a time period (in seconds) that specifies the error slice.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_FIBER_SLICE_ERR

..  _configuration_reference_fiber_top_options:

fiber.top.*
~~~~~~~~~~~

This section describes options related to configuring the
:ref:`fiber.top() <fiber-top>` function, normally used for debug purposes.
``fiber.top()`` shows all alive fibers and their CPU consumption.

* :ref:`fiber.top.enabled <configuration_reference_fiber_top_enabled>`

..  _configuration_reference_fiber_top_enabled:

..  confval:: fiber.top.enabled

    Enable or disable the ``fiber.top()`` function.

    Enabling ``fiber.top()`` slows down fiber switching by about 15%,
    so it is disabled by default.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_FIBER_TOP_ENABLED

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

    |
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

    |
    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_LOGS_SIZE

..  _configuration_reference_flightrec_logs_max_msg_size:

..  confval:: flightrec.logs_max_msg_size

    Specify the maximum size (in bytes) of the log message.
    The log message is truncated if its size exceeds this limit.

    |
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

    |
    | Type: integer
    | Default: 6
    | Environment variable: TT_FLIGHTREC_LOGS_LOG_LEVEL

..  _configuration_reference_flightrec_metrics_period:

..  confval:: flightrec.metrics_period

    Specify the time period (in seconds) that defines how long metrics are stored from the moment of dump.
    So, this value defines how much historical metrics data is collected up to the moment of crash.
    The frequency of metric dumps is defined by :ref:`flightrec.metrics_interval <configuration_reference_flightrec_metrics_interval>`.

    |
    | Type: integer
    | Default: 180
    | Environment variable: TT_FLIGHTREC_METRICS_PERIOD


..  _configuration_reference_flightrec_metrics_interval:

..  confval:: flightrec.metrics_interval

    Specify the time interval (in seconds) that defines the frequency of dumping metrics.
    This value shouldn't exceed :ref:`flightrec.metrics_period <configuration_reference_flightrec_metrics_period>`.

    |
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

    |
    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_REQUESTS_SIZE

..  _configuration_reference_flightrec_requests_max_req_size:

..  confval:: flightrec.requests_max_req_size

    Specify the maximum size (in bytes) of a request entry.
    A request entry is truncated if this size is exceeded.

    |
    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_REQ_SIZE

..  _configuration_reference_flightrec_requests_max_res_size:

..  confval:: flightrec.requests_max_res_size

    Specify the maximum size (in bytes) of a response entry.
    A response entry is truncated if this size is exceeded.

    |
    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_RES_SIZE

..  _configuration_reference_iproto:

iproto
------

The ``iproto`` section is used to configure parameters related to :ref:`communicating to and between cluster instances <configuration_connections>`.

.. NOTE::

    ``iproto`` can be defined in any :ref:`scope <configuration_scopes>`.

*   :ref:`iproto.listen <configuration_reference_iproto_listen>`
*   :ref:`iproto.net_msg_max <configuration_reference_iproto_net_msg_max>`
*   :ref:`iproto.readahead <configuration_reference_iproto_readahead>`
*   :ref:`iproto.threads <configuration_reference_iproto_threads>`
*   :ref:`iproto.advertise.* <configuration_reference_iproto_advertise>`
*   :ref:`<uri>.params.* <configuration_reference_iproto_uri_params>`


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

    See also: :ref:`Connections <configuration_connections>`

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

    |
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


.. _configuration_reference_iproto_advertise:

iproto.advertise.*
~~~~~~~~~~~~~~~~~~

*   :ref:`iproto.advertise.client <configuration_reference_iproto_advertise_client>`
*   :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>`
*   :ref:`iproto.advertise.sharding <configuration_reference_iproto_advertise_sharding>`
*   :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`

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

    |
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

    |
    | Type: map
    | Environment variable: see :ref:`iproto.advertise.\<peer_or_sharding\>.* <configuration_reference_iproto_advertise.peer_sharding>`

.. _configuration_reference_iproto_advertise.peer_sharding:

iproto.advertise.<peer_or_sharding>.*
*************************************

*   :ref:`iproto.advertise.\<peer_or_sharding\>.uri <configuration_reference_iproto_advertise.peer_sharding.uri>`
*   :ref:`iproto.advertise.\<peer_or_sharding\>.login <configuration_reference_iproto_advertise.peer_sharding.login>`
*   :ref:`iproto.advertise.\<peer_or_sharding\>.password <configuration_reference_iproto_advertise.peer_sharding.password>`
*   :ref:`iproto.advertise.\<peer_or_sharding\>.params <configuration_reference_iproto_advertise.peer_sharding.params>`

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




.. _configuration_reference_iproto_uri_params:

<uri>.params.*
~~~~~~~~~~~~~~

..  admonition:: Enterprise Edition
    :class: fact

    TLS traffic encryption is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

URI parameters that can be used in the :ref:`iproto.listen.\<uri\>.params <configuration_reference_iproto_listen>` and :ref:`iproto.advertise.\<peer_or_sharding\>.params <configuration_reference_iproto_advertise.peer_sharding.params>` options.

*   :ref:`\<uri\>.params.transport <configuration_reference_iproto_uri_params_transport>`
*   :ref:`\<uri\>.params.ssl_ca_file <configuration_reference_iproto_uri_params_ssl_ca_file>`
*   :ref:`\<uri\>.params.ssl_cert_file <configuration_reference_iproto_uri_params_ssl_cert_file>`
*   :ref:`\<uri\>.params.ssl_ciphers <configuration_reference_iproto_uri_params_ssl_ciphers>`
*   :ref:`\<uri\>.params.ssl_key_file <configuration_reference_iproto_uri_params_ssl_key_file>`
*   :ref:`\<uri\>.params.ssl_password <configuration_reference_iproto_uri_params_ssl_password>`
*   :ref:`\<uri\>.params.ssl_password_file <configuration_reference_iproto_uri_params_ssl_password_file>`

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

    Example on Github: `ssl_without_ca <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/ssl_without_ca>`_

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

    See also: :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_CA_FILE, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_CA_FILE

.. _configuration_reference_iproto_uri_params_ssl_cert_file:

.. confval:: <uri>.params.ssl_cert_file

    A path to an SSL certificate file:

    -   For a server, it's mandatory.
    -   For a client, it's mandatory if the :ref:`ssl_ca_file <configuration_reference_iproto_uri_params_ssl_ca_file>` parameter is set for a server; otherwise, optional.

    See also: :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`

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

    See also: :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`

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

    See also: :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`

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

    See also: :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`

    |
    | Type: string
    | Default: nil
    | Environment variable: TT_IPROTO_ADVERTISE_PEER_PARAMS_SSL_PASSWORD, TT_IPROTO_ADVERTISE_SHARDING_PARAMS_SSL_PASSWORD

.. _configuration_reference_iproto_uri_params_ssl_password_file:

.. confval:: <uri>.params.ssl_password_file

    (Optional) A text file with one or more passwords for encrypted private SSL keys provided using ``ssl_key_file`` (each on a separate line).
    Alternatively, the password can be provided in ``ssl_password``.

    See also: :ref:`<uri>.params.transport <configuration_reference_iproto_uri_params_transport>`

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

    The following rules are applied to group names:

    -   The maximum number of symbols is 63.
    -   Should start with a letter.
    -   Can contain lowercase letters (a-z).
    -   Can contain digits (0-9).
    -   Can contain the following characters: ``-``, ``_``.

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

    Note that the rules applied to a replica set name are the same as for groups.
    Learn more in :ref:`groups.\<group_name\> <configuration_reference_groups_name>`.

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

    Note that the rules applied to an instance name are the same as for groups.
    Learn more in :ref:`groups.\<group_name\> <configuration_reference_groups_name>`.

.. _configuration_reference_instances_name_config_parameter:

.. confval:: instances.<instance_name>.<config_parameter>

    Any configuration parameter that can be defined in the instance :ref:`scope <configuration_scopes>`.
    For example, :ref:`iproto <configuration_reference_iproto>` and :ref:`database <configuration_reference_database>` configuration parameters defined at the instance level are applied to this instance only.

..  _configuration_reference_labels:

labels
------

The ``labels`` section allows adding custom attributes to the configuration.
Attributes must be ``key: value`` pairs with string keys and values.


..  NOTE::

    ``labels`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`labels.\<label_name\> <configuration_reference_labels_name>`

..  _configuration_reference_labels_name:

.. confval:: labels.<label_name>

    A value of the label with the specified name.

    **Example**

    The example below shows how to define labels on the replica set and instance levels:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/labels/config.yaml
        :language: yaml
        :dedent:

    See also: :ref:`configuration_labels`

..  _configuration_reference_log:

log
---

The ``log`` section defines configuration parameters related to logging.
To handle logging in your application, use the :ref:`log module <log-module>`.

..  NOTE::

    ``log`` can be defined in any :ref:`scope <configuration_scopes>`.

*   :ref:`log.to <configuration_reference_log_to>`
*   :ref:`log.file <configuration_reference_log_file>`
*   :ref:`log.format <configuration_reference_log_format>`
*   :ref:`log.level <configuration_reference_log_level>`
*   :ref:`log.modules <configuration_reference_log_modules>`
*   :ref:`log.nonblock <configuration_reference_log_nonblock>`
*   :ref:`log.pipe <configuration_reference_log_pipe>`
*   :ref:`log.syslog.* <configuration_reference_log_syslog>`

..  _configuration_reference_log_to:

..  confval:: log.to

    Define a location Tarantool sends logs to.
    This option accepts the following values:

    *   ``stderr``: write logs to the standard error stream.
    *   ``file``: write logs to a file (see :ref:`log.file <configuration_reference_log_file>`).
    *   ``pipe``: start a program and write logs to its standard input (see :ref:`log.pipe <configuration_reference_log_pipe>`).
    *   ``syslog``: write logs to a system logger (see :ref:`log.syslog.* <configuration_reference_log_syslog>`).

    |
    | Type: string
    | Default: 'stderr'
    | Environment variable: TT_LOG_TO

..  _configuration_reference_log_file:

..  confval:: log.file

    Specify a file for logs destination.
    To write logs to a file, you need to set :ref:`log.to <configuration_reference_log_to>` to ``file``.
    Otherwise, ``log.file`` is ignored.

    **Example**

    The example below shows how to write logs to a file placed in the specified directory:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_file/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: instance.log
        :dedent:

    Example on GitHub: `log_file <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_file>`_

    |
    | Type: string
    | Default: 'var/log/{{ instance_name }}/tarantool.log'
    | Environment variable: TT_LOG_FILE

..  _configuration_reference_log_format:

..  confval:: log.format

    Specify a format that is used for a log entry.
    The following formats are supported:

    *   ``plain``: a log entry is formatted as plain text. Example:

        ..  code-block:: text

            2024-04-09 11:00:10.369 [12089] main/104/interactive I> log level 5 (INFO)

    *   ``json``: a log entry is formatted as JSON and includes additional fields. Example:

        ..  code-block:: text

            {
              "time": "2024-04-09T11:00:57.174+0300",
              "level": "INFO",
              "message": "log level 5 (INFO)",
              "pid": 12160,
              "cord_name": "main",
              "fiber_id": 104,
              "fiber_name": "interactive",
              "file": "src/main.cc",
              "line": 498
            }

    |
    | Type: string
    | Default: 'plain'
    | Environment variable: TT_LOG_FORMAT


..  _configuration_reference_log_level:

..  confval:: log.level

    Specify the level of detail logs have.
    There are the following levels:

    * 0 -- ``fatal``
    * 1 -- ``syserror``
    * 2 -- ``error``
    * 3 -- ``crit``
    * 4 -- ``warn``
    * 5 -- ``info``
    * 6 -- ``verbose``
    * 7 -- ``debug``

    By setting ``log.level``, you can enable logging of all events with severities above or equal to the given level.

    **Example**

    The example below shows how to log all events with severities above or equal to the ``VERBOSE`` level.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_level/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: verbose
        :dedent:

    Example on GitHub: `log_level <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_level>`_

    |
    | Type: number, string
    | Default: 5
    | Environment variable: TT_LOG_LEVEL

..  _configuration_reference_log_modules:

..  confval:: log.modules

    Configure the specified log levels (:ref:`log.level <configuration_reference_log_level>`) for different modules.

    You can specify a logging level for the following module types:

    *   Modules (files) that use the default logger.
        Example: :ref:`Set log levels for files that use the default logger <configuration_reference_log_modules_example_existing_modules>`.

    *   Modules that use custom loggers created using the :ref:`log.new() <log-new>` function.
        Example: :ref:`Set log levels for modules that use custom loggers <configuration_reference_log_modules_example_new_modules>`.

    *   The ``tarantool`` module that enables you to configure the logging level for Tarantool core messages.
        Specifically, it configures the logging level for messages logged from non-Lua code, including C modules.
        Example: :ref:`Set a log level for C modules <configuration_reference_log_modules_example_tarantool_module>`.

    .. _configuration_reference_log_modules_example_existing_modules:

    **Example 1: Set log levels for files that use the default logger**

    Suppose you have two identical modules placed by the following paths: ``test/module1.lua`` and ``test/module2.lua``.
    These modules use the default logger and look as follows:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_existing_modules/test/module1.lua
        :language: lua
        :dedent:

    To configure logging levels, you need to provide module names corresponding to paths to these modules:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_existing_modules/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: app.lua
        :dedent:

    To load these modules in your application (``app.lua``), you need to add the corresponding ``require`` directives:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_existing_modules/app.lua
        :language: lua
        :start-at: module1 = require
        :end-at: module2 = require
        :dedent:

    Given that ``module1`` has the ``verbose`` logging level and ``module2`` has the ``error`` level, calling ``module1.say_hello()`` shows a message but ``module2.say_hello()`` is swallowed:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_existing_modules/app.lua
        :language: lua
        :start-after: module2 = require
        :dedent:

    Example on GitHub: `log_existing_modules <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_existing_modules>`_

    .. _configuration_reference_log_modules_example_new_modules:

    **Example 2: Set log levels for modules that use custom loggers**

    This example shows how to set the ``verbose`` level for ``module1`` and the ``error`` level for ``module2``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_new_modules/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: app.lua
        :dedent:

    To create custom loggers in your application (``app.lua``), call the :ref:`log.new() <log-new>` function:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_new_modules/app.lua
        :language: lua
        :start-at: Creates new loggers
        :end-at: module2_log = require
        :dedent:

    Given that ``module1`` has the ``verbose`` logging level and ``module2`` has the ``error`` level, calling ``module1_log.info()`` shows a message but ``module2_log.info()`` is swallowed:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_new_modules/app.lua
        :language: lua
        :start-after: module2_log = require
        :dedent:

    Example on GitHub: `log_new_modules <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_new_modules>`_

    .. _configuration_reference_log_modules_example_tarantool_module:

    **Example 3: Set a log level for C modules**

    This example shows how to set the ``info`` level for the ``tarantool`` module:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_existing_c_modules/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: app.lua
        :dedent:

    The specified level affects messages logged from C modules:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_existing_c_modules/app.lua
        :language: lua
        :dedent:

    The example above uses the `LuaJIT ffi library <http://luajit.org/ext_ffi.html>`_ to call C functions provided by the ``say`` module.

    Example on GitHub: `log_existing_c_modules <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_existing_c_modules>`_

    |
    | Type: map
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_LOG_MODULES

..  _configuration_reference_log_nonblock:

..  confval:: log.nonblock

    Specify the logging behavior if the system is not ready to write.
    If set to ``true``, Tarantool does not block during logging if the system is non-writable and writes a message instead.
    Using this value may improve logging performance at the cost of losing some log messages.

    ..  note::

        The option only has an effect if the :ref:`log.to <configuration_reference_log_to>` is set to ``syslog``
        or ``pipe``.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_LOG_NONBLOCK

..  _configuration_reference_log_pipe:

..  confval:: log.pipe

    Start a program and write logs to its standard input (``stdin``).
    To send logs to a program's standard input, you need to set :ref:`log.to <configuration_reference_log_to>` to ``pipe``.

    **Example**

    In the example below, Tarantool writes logs to the standard input of ``cronolog``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_pipe/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: tarantool.log
        :dedent:

    Example on GitHub: `log_pipe <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_pipe>`_

    |
    | Type: string
    | Default: :ref:`box.NULL <box-null>`
    | Environment variable: TT_LOG_PIPE


..  _configuration_reference_log_syslog:

log.syslog.*
~~~~~~~~~~~~

*   :ref:`log.syslog.facility <configuration_reference_log_syslog-facility>`
*   :ref:`log.syslog.identity <configuration_reference_log_syslog-identity>`
*   :ref:`log.syslog.server <configuration_reference_log_syslog-server>`

..  _configuration_reference_log_syslog-facility:

..  confval:: log.syslog.facility

    Specify the syslog facility to be used when syslog is enabled.
    To write logs to syslog, you need to set :ref:`log.to <configuration_reference_log_to>` to ``syslog``.

    |
    | Type: string
    | Possible values: 'auth', 'authpriv', 'cron', 'daemon', 'ftp', 'kern', 'lpr', 'mail', 'news', 'security', 'syslog', 'user', 'uucp', 'local0', 'local1', 'local2', 'local3', 'local4', 'local5', 'local6', 'local7'
    | Default: 'local7'
    | Environment variable: TT_LOG_SYSLOG_FACILITY

..  _configuration_reference_log_syslog-identity:

..  confval:: log.syslog.identity

    Specify an application name used to identify Tarantool messages in syslog logs.
    To write logs to syslog, you need to set :ref:`log.to <configuration_reference_log_to>` to ``syslog``.

    |
    | Type: string
    | Default: 'tarantool'
    | Environment variable: TT_LOG_SYSLOG_IDENTITY

..  _configuration_reference_log_syslog-server:

..  confval:: log.syslog.server

    Set a location of a syslog server.
    This option accepts one of the following values:

    *   An IPv4 address. Example: ``127.0.0.1:514``.
    *   A Unix socket path starting with ``unix:``. Examples: ``unix:/dev/log`` on Linux or ``unix:/var/run/syslog`` on macOS.

    To write logs to syslog, you need to set :ref:`log.to <configuration_reference_log_to>` to ``syslog``.

    **Example**

    In the example below, Tarantool writes logs to a syslog server that listens for logging messages on the ``127.0.0.1:514`` address:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/log_syslog/config.yaml
        :language: yaml
        :start-at: log:
        :end-at: 127.0.0.1:514
        :dedent:

    Example on GitHub: `log_syslog <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/log_syslog>`_

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_LOG_SYSLOG_SERVER

..  _configuration_reference_memtx:

memtx
-----

The ``memtx`` section is used to configure parameters related to the :ref:`memtx engine <configuration_memtx>`.

.. NOTE::

    ``memtx`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`memtx.allocator <configuration_reference_memtx_allocator>`
-   :ref:`memtx.max_tuple_size <configuration_reference_memtx_max_size>`
-   :ref:`memtx.memory <configuration_reference_memtx_memory>`
-   :ref:`memtx.min_tuple_size <configuration_reference_memtx_min_size>`
-   :ref:`memtx.slab_alloc_factor <configuration_reference_memtx_slab_alloc_factor>`
-   :ref:`memtx.slab_alloc_granularity <configuration_reference_memtx_slab_alloc_granularity>`
-   :ref:`memtx.sort_threads <configuration_reference_memtx_sort_threads>`

..  _configuration_reference_memtx_allocator:

..  confval:: memtx.allocator

    Specify the allocator that manages memory for ``memtx`` tuples.
    Possible values:

    *   ``system`` --  the memory is allocated as needed, checking that the quota is not exceeded.
        THe allocator is based on the ``malloc`` function.

    *   ``small`` -- a `slab allocator <https://github.com/tarantool/small>`_.
        The allocator repeatedly uses a memory block to allocate objects of the same type.
        Note that this allocator is prone to unresolvable fragmentation on specific workloads,
        so you can switch to ``system`` in such cases.

    |
    | Type: string
    | Default: 'small'
    | Environment variable: TT_MEMTX_ALLOCATOR

..  _configuration_reference_memtx_max_size:

..  confval:: memtx.max_tuple_size

    Size of the largest allocation unit for the memtx storage engine in bytes.
    It can be increased if it is necessary to store large tuples.

    |
    | Type: integer
    | Default: 1048576
    | Environment variable: TT_MEMTX_MAX_TUPLE_SIZE

..  _configuration_reference_memtx_memory:

..  confval:: memtx.memory

    The amount of memory in bytes that Tarantool allocates to store tuples.
    When the limit is reached, :ref:`INSERT <box_space-insert>` and
    :ref:`UPDATE <box_space-insert>` requests fail with the  :errcode:`ER_MEMORY_ISSUE` error.
    The server does not go beyond the ``memtx.memory`` limit to allocate tuples, but there is additional memory
    used to store indexes and connection information.

    **Example**

    In the example below, the memory size is set to 1 GB (1073741824 bytes).

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/memtx/config.yaml
        :language: yaml
        :start-at: memtx:
        :end-at: 1073741824
        :dedent:

    |
    | Type: integer
    | Default: 268435456
    | Environment variable: TT_MEMTX_MEMORY

..  _configuration_reference_memtx_min_size:

..  confval:: memtx.min_tuple_size

    Size of the smallest allocation unit in bytes.
    It can be decreased if most of the tuples are very small.

    |
    | Type: integer
    | Default: 16
    | Possible values: between 8 and 1048280 inclusive
    | Environment variable: TT_MEMTX_MIN_TUPLE_SIZE

..  _configuration_reference_memtx_slab_alloc_factor:

..  confval:: memtx.slab_alloc_factor

    The multiplier for computing the sizes of memory
    chunks that tuples are stored in.
    A lower value may result in less wasted
    memory depending on the total amount of memory available and the
    distribution of item sizes.

    See also: :ref:`memtx.slab_alloc_granularity <configuration_reference_memtx_slab_alloc_granularity>`

    |
    | Type: number
    | Default: 1.05
    | Possible values: between 1 and 2 inclusive
    | Environment variable: TT_MEMTX_SLAB_ALLOC_FACTOR

..  _configuration_reference_memtx_slab_alloc_granularity:

..  confval:: memtx.slab_alloc_granularity

    Specify the granularity in bytes of memory allocation in the :ref:`small allocator <cfg_storage-memtx_allocator>`.
    The ``memtx.slab_alloc_granularity`` value should meet the following conditions:

    *   The value is a power of two.
    *   The value is greater than or equal to 4.

    Below are few recommendations on how to adjust the ``memtx.slab_alloc_granularity`` option:

    *   If the tuples in space are small and have about the same size, set the option to 4 bytes to save memory.
    *   If the tuples are different-sized, increase the option value to allocate tuples from the same ``mempool`` (memory pool).

    See also: :ref:`memtx.slab_alloc_factor <configuration_reference_memtx_slab_alloc_factor>`

    |
    | Type: integer
    | Default: 8
    | Environment variable: TT_MEMTX_SLAB_ALLOC_GRANULARITY

..  _configuration_reference_memtx_sort_threads:

..  confval:: memtx.sort_threads

    The number of threads from the :ref:`thread pool <supplementary_threads>` used to sort keys of secondary indexes on loading a ``memtx`` database.
    The minimum value is 1, the maximum value is 256.
    The default is to use all available cores.

    ..  include:: /platform/atomic/thread_model.rst
        :start-after: note_drop_openmp_start
        :end-before: note_drop_openmp_end

    |
    | Type: integer
    | Default: box.NULL
    | Environment variable: TT_MEMTX_SORT_THREADS




..  _configuration_reference_metrics:

metrics
-------

The ``metrics`` section defines configuration parameters for :ref:`metrics <monitoring>`.

..  NOTE::

    ``metrics`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`metrics.exclude <configuration_reference_metrics_exclude>`
-   :ref:`metrics.include <configuration_reference_metrics_include>`
-   :ref:`metrics.labels <configuration_reference_metrics_labels>`


.. _configuration_reference_metrics_exclude:

..  confval:: metrics.exclude

    An array containing the metrics to turn off.
    The array can contain the same values as the ``exclude`` configuration parameter passed to :ref:`metrics.cfg() <metrics_cfg>`.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics/config.yaml
        :start-at: metrics:
        :end-at: instance_name
        :language: yaml
        :dedent:

    |
    | Type: array
    | Default: ``[]``
    | Environment variable: TT_METRICS_EXCLUDE


.. _configuration_reference_metrics_include:

..  confval:: metrics.include

    An array containing the metrics to turn on.
    The array can contain the same values as the ``include`` configuration parameter passed to :ref:`metrics.cfg() <metrics_cfg>`.

    |
    | Type: array
    | Default: ``[ all ]``
    | Environment variable: TT_METRICS_INCLUDE


.. _configuration_reference_metrics_labels:

..  confval:: metrics.labels

    Global :ref:`labels <metrics-api_reference-labels>` to be added to every observation.

    |
    | Type: map
    | Default: ``{ alias = names.instance_name }``
    | Environment variable: TT_METRICS_LABELS




..  _configuration_reference_process:

process
-------

The ``process`` section defines configuration parameters of the Tarantool process in the system.

..  NOTE::

    ``process`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`process.background <configuration_reference_process_background>`
-   :ref:`process.coredump <configuration_reference_process_coredump>`
-   :ref:`process.title <configuration_reference_process_title>`
-   :ref:`process.pid_file <configuration_reference_process_pid_file>`
-   :ref:`process.strip_core <configuration_reference_process_strip_core>`
-   :ref:`process.username <configuration_reference_process_username>`
-   :ref:`process.work_dir <configuration_reference_process_work_dir>`

.. _configuration_reference_process_background:

.. confval:: process.background

    Run the server as a daemon process.

    If this option is set to ``true``, Tarantool log location defined by the
    :ref:`log.to <configuration_reference_log_to>` option should be set to
    ``file``, ``pipe``, or ``syslog`` -- anything other than ``stderr``,
    the default, because a daemon process is detached from a terminal
    and it can't write to the terminal's stderr.

    .. important::

        Do not enable the background mode for applications intended to run by the
        ``tt`` utility. For more information, see the :ref:`tt start <tt-start>` reference.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_PROCESS_BACKGROUND

.. _configuration_reference_process_coredump:

.. confval:: process.coredump

    Create coredump files.

    Usually, an administrator needs to call ``ulimit -c unlimited``
    (or set corresponding options in systemd's unit file)
    before running a Tarantool process to get core dumps.
    If ``process.coredump`` is enabled, Tarantool sets the corresponding
    resource limit by itself
    and the administrator doesn't need to call ``ulimit -c unlimited``
    (see `man 3 setrlimit <https://man7.org/linux/man-pages/man3/setrlimit.3p.html>`_).

    This option also sets the state of the ``dumpable`` attribute,
    which is enabled by default,
    but may be dropped in some circumstances (according to
    `man 2 prctl <https://man7.org/linux/man-pages/man2/prctl.2.html>`_, see PR_SET_DUMPABLE).

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_PROCESS_COREDUMP

.. _configuration_reference_process_title:

.. confval:: process.title

    Add the given string to the server's process title
    (it is shown in the COMMAND column for the Linux commands
    ``ps -ef`` and ``top -c``).

    For example, if you set the option to ``myservice - {{ instance_name }}``:

    .. code-block:: yaml

		process:
		  title: myservice - {{ instance_name }}

    :samp:`ps -ef` might show the Tarantool server process like this:

    .. code-block:: console

        $ ps -ef | grep tarantool
        503      68100 68098  0 10:33 pts/2    00:00.10 tarantool <running>: myservice instance1

    |
    | Type: string
    | Default: 'tarantool - {{ instance_name }}'
    | Environment variable: TT_PROCESS_TITLE

.. _configuration_reference_process_pid_file:

.. confval:: process.pid_file

    Store the process id in this file.

    This option may contain a relative file path.
    In this case, it is interpreted as relative to
    :ref:`process.work_dir <configuration_reference_process_work_dir>`.

    |
    | Type: string
    | Default: 'var/run/{{ instance_name }}/tarantool.pid'
    | Environment variable: TT_PROCESS_PID_FILE

.. _configuration_reference_process_strip_core:

.. confval:: process.strip_core

    Whether coredump files should not include memory allocated for tuples --
    this memory can be large if Tarantool runs under heavy load.
    Setting to ``true`` means "do not include".

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_PROCESS_STRIP_CORE

.. _configuration_reference_process_username:

.. confval:: process.username

    The name of the system user to switch to after start.

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_PROCESS_USERNAME

.. _configuration_reference_process_work_dir:

.. confval:: process.work_dir

    A directory where Tarantool working files will be stored
    (database files, logs, a PID file, a console Unix socket, and other files
    if an application generates them in the current directory).
    The server instance switches to ``process.work_dir`` with
    :manpage:`chdir(2)` after start.

    If set as a relative file path, it is relative to the current
    working directory, from where Tarantool is started.
    If not specified, defaults to the current working directory.

    Other directory and file parameters, if set as relative paths,
    are interpreted as relative to ``process.work_dir``, for example, directories for storing
    :ref:`snapshots and write-ahead logs <configuration_persistence>`.

    |
    | Type: string
    | Default: box.NULL
    | Environment variable: TT_PROCESS_WORK_DIR

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

    Whether to make the current instance act as an anonymous replica.
    Anonymous replicas are read-only and can be used, for example, for backups.

    To make the specified instance act as an anonymous replica, set ``replication.anon`` to ``true``:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/anonymous_replica/config.yaml
        :language: yaml
        :start-at: instance003
        :end-at: anon: true
        :dedent:

    You can find the full example on GitHub: `anonymous_replica <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/replication/instances.enabled/anonymous_replica>`_.

    Anonymous replicas are not displayed in the :ref:`box.info.replication <box_info_replication>` section.
    You can check their status using :ref:`box.info.replication_anon() <box_info_replication-anon>`.

    While anonymous replicas are read-only, you can write data to replication-local and temporary spaces (:ref:`created <box_schema-space_create>` with ``is_local = true`` and ``temporary = true``, respectively).
    Given that changes to replication-local spaces are allowed, an anonymous replica might increase the ``0`` component of the :ref:`vclock <box_introspection-box_info>` value.

    Here are the limitations of having anonymous replicas in a replica set:

    *   A replica set must contain at least one non-anonymous instance.
    *   An anonymous replica can't be configured as a writable instance by setting :ref:`database.mode <configuration_reference_database_mode>` to ``rw`` or making it a leader using :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>`.
    *   If :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``election``, an anonymous replica can have :ref:`replication.election_mode <configuration_reference_replication_election_mode>` set to ``off`` only.
    *   If :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``supervised``, an external failover coordinator doesn't consider anonymous replicas when selecting a bootstrap or replica set leader.

    ..  NOTE::

        Anonymous replicas are not registered in the :ref:`_cluster <box_space-cluster>` space.
        This means that there is no :ref:`limitation <limitations_replicas>` on the number of anonymous replicas in a replica set.

    |
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

    |
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

    ..  NOTE::

        You can set ``replication.election_mode`` to a value other than ``off`` if the :ref:`replication.failover <configuration_reference_replication_failover>` mode is ``election``.

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

        Leadership in a replica set is controlled using an :ref:`external failover coordinator <repl_supervised_failover>`.

        In the ``supervised`` mode, :ref:`database.mode <configuration_reference_database_mode>` and :ref:`<replicaset_name>.leader <configuration_reference_replicasets_name_leader>` shouldn't be set explicitly.

    See also: :ref:`Replication tutorials <how-to-replication>`

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

    |
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

    |
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

    |
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

    |
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

    |
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

    See also: :ref:`Monitoring a replica set <replication-monitoring>`

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_REPLICATION_TIMEOUT

..  _configuration_reference_roles_options:

roles
-----

This section describes configuration parameters related to :ref:`application roles <application_roles>`.

.. NOTE::

    Configuration parameters related to roles can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`roles <configuration_reference_roles>`
-   :ref:`roles_cfg <configuration_reference_roles_cfg>`

.. _configuration_reference_roles:

.. confval:: roles

    Specify the roles of an instance.
    To specify a role's configuration, use the :ref:`roles_cfg <configuration_reference_roles_cfg>` option.

    See also: :ref:`configuration_application_roles`

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_ROLES

.. _configuration_reference_roles_cfg:

.. confval:: roles_cfg

    Specify a role's configuration.
    This option accepts a role name as the key and a role's configuration as the value.
    To specify the roles of an instance, use the :ref:`roles <configuration_reference_roles>` option.

    See also: :ref:`configuration_application_roles`

    .. tip::

        The :ref:`experimental.config.utils.schema <config_utils_schema_module>`
        built-in module provides an API for managing user-defined configurations
        of applications (``app.cfg``) and roles (``roles_cfg``).

    |
    | Type: map
    | Default: nil
    | Environment variable: TT_ROLES_CFG

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

..  _configuration_reference_sharding:

sharding
--------

The ``sharding`` section defines configuration parameters related to :ref:`sharding <vshard-admin>`.

..  NOTE::

    Sharding support requires installing the :ref:`vshard <vshard>` module.
    The minimum required version of ``vshard`` is 0.1.25.

-   :ref:`sharding.bucket_count <configuration_reference_sharding_bucket_count>`
-   :ref:`sharding.discovery_mode <configuration_reference_sharding_discovery_mode>`
-   :ref:`sharding.failover_ping_timeout <configuration_reference_sharding_failover_ping_timeout>`
-   :ref:`sharding.lock <configuration_reference_sharding_lock>`
-   :ref:`sharding.rebalancer_disbalance_threshold <configuration_reference_sharding_rebalancer_disbalance_threshold>`
-   :ref:`sharding.rebalancer_max_receiving <configuration_reference_sharding_rebalancer_max_receiving>`
-   :ref:`sharding.rebalancer_max_sending <configuration_reference_sharding_rebalancer_max_sending>`
-   :ref:`sharding.rebalancer_mode <configuration_reference_sharding_rebalancer_mode>`
-   :ref:`sharding.roles <configuration_reference_sharding_roles>`
-   :ref:`sharding.sched_move_quota <configuration_reference_sharding_sched_move_quota>`
-   :ref:`sharding.sched_ref_quota <configuration_reference_sharding_sched_ref_quota>`
-   :ref:`sharding.shard_index <configuration_reference_sharding_shard_index>`
-   :ref:`sharding.sync_timeout <configuration_reference_sharding_sync_timeout>`
-   :ref:`sharding.weight <configuration_reference_sharding_weight>`
-   :ref:`sharding.zone <configuration_reference_sharding_zone>`

..  _configuration_reference_sharding_bucket_count:

..  confval:: sharding.bucket_count

    The total number of buckets in a cluster.
    Learn more in :ref:`vshard_config_bucket_count`.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    **Example**

    ..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
        :language: yaml
        :start-after: login: storage
        :end-at: bucket_count
        :dedent:

    |
    | Type: integer
    | Default: 3000
    | Environment variable: TT_SHARDING_BUCKET_COUNT

..  _configuration_reference_sharding_discovery_mode:

..  confval:: sharding.discovery_mode

    A mode of the background discovery fiber used by the router to find buckets.
    Learn more in :ref:`vshard.router.discovery_set() <router_api-discovery_set>`.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: string
    | Default: 'on'
    | Possible values: 'on', 'off', 'once'
    | Environment variable: TT_SHARDING_DISCOVERY_MODE

..  _configuration_reference_sharding_failover_ping_timeout:

..  confval:: sharding.failover_ping_timeout

    The timeout (in seconds) after which a node is considered unavailable if there are no responses during this period.
    The :ref:`failover fiber <vshard-failover>` is used to detect if a node is down.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: number
    | Default: 5
    | Environment variable: TT_SHARDING_FAILOVER_PING_TIMEOUT

..  _configuration_reference_sharding_lock:

..  confval:: sharding.lock

    Whether a replica set is :ref:`locked <vshard-lock-pin>`.
    A locked replica set cannot receive new buckets nor migrate its own buckets.

    ..  NOTE::

        ``sharding.lock`` can be specified at the :ref:`replica set level <configuration_scopes>` or higher.

    |
    | Type: boolean
    | Default: nil
    | Environment variable: TT_SHARDING_LOCK

..  _configuration_reference_sharding_rebalancer_disbalance_threshold:

..  confval:: sharding.rebalancer_disbalance_threshold

    The maximum bucket :ref:`disbalance <vshard-rebalancing>` threshold (in percent).
    The disbalance is calculated for each replica set using the following formula:

    .. code-block:: none

        |etalon_bucket_count - real_bucket_count| / etalon_bucket_count * 100

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_SHARDING_REBALANCER_DISBALANCE_THRESHOLD

..  _configuration_reference_sharding_rebalancer_max_receiving:

..  confval:: sharding.rebalancer_max_receiving

    The maximum number of buckets that can be :ref:`received in parallel <vshard-parallel-rebalancing>` by a single replica set.
    This number must be limited because the rebalancer sends a large number of buckets from the existing replica sets to the newly added one.
    This produces a heavy load on the new replica set.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    **Example**

    Suppose, ``rebalancer_max_receiving`` is equal to 100 and ``bucket_count`` is equal to 1000.
    There are 3 replica sets with 333, 333, and 334 buckets on each respectively.
    When a new replica set is added, each replica set’s ``etalon_bucket_count`` becomes
    equal to 250. Rather than receiving all 250 buckets at once, the new replica set
    receives 100, 100, and 50 buckets sequentially.

    |
    | Type: integer
    | Default: 100
    | Environment variable: TT_SHARDING_REBALANCER_MAX_RECEIVING

..  _configuration_reference_sharding_rebalancer_max_sending:

..  confval:: sharding.rebalancer_max_sending

    The degree of parallelism for :ref:`parallel rebalancing <vshard-parallel-rebalancing>`.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: integer
    | Default: 1
    | Maximum: 15
    | Environment variable: TT_SHARDING_REBALANCER_MAX_SENDING

..  _configuration_reference_sharding_rebalancer_mode:

..  confval:: sharding.rebalancer_mode

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    Configure how a rebalancer is selected:

    *   ``auto`` (default): if there are no replica sets with the ``rebalancer`` sharding role (:ref:`sharding.roles <configuration_reference_sharding_roles>`), a replica set with the rebalancer is selected automatically among all replica sets.
    *   ``manual``: one of the replica sets should have the ``rebalancer`` sharding role. The rebalancer is in this replica set.
    *   ``off``: rebalancing is turned off regardless of whether a replica set with the ``rebalancer`` sharding role  exists or not.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: string
    | Default: 'auto'
    | Environment variable: TT_SHARDING_REBALANCER_MODE

..  _configuration_reference_sharding_roles:

..  confval:: sharding.roles

    Roles of a replica set in regard to sharding.
    A replica set can have the following roles:

    *   ``router``: a replica set acts as a :ref:`router <vshard-architecture-router>`.
    *   ``storage``: a replica set acts as a :ref:`storage <vshard-architecture-storage>`.
    *   ``rebalancer``: a replica set acts as a :ref:`rebalancer <vshard-rebalancer>`.

    The ``rebalancer`` role is optional.
    If it is not specified, a rebalancer is selected automatically from the master instances of replica sets.

    There can be at most one replica set with the ``rebalancer`` role.
    Additionally, this replica set should have a ``storage`` role.

    **Example**

    .. code-block:: yaml

        replicasets:
          storage-a:
            sharding:
              roles: [storage, rebalancer]

    See also: :ref:`vshard_config_sharding_roles`

    ..  NOTE::

        ``sharding.roles`` can be specified at the :ref:`replica set level <configuration_scopes>` or higher.

    |
    | Type: array
    | Default: nil
    | Environment variable: TT_SHARDING_ROLES

..  _configuration_reference_sharding_sched_move_quota:

..  confval:: sharding.sched_move_quota

    A scheduler's bucket move quota used by the :ref:`rebalancer <vshard-rebalancing>`.

    ``sched_move_quota`` defines how many bucket moves can be done in a row if there are pending storage refs.
    Then, bucket moves are blocked and a router continues making map-reduce requests.

    See also: :ref:`sharding.sched_ref_quota <configuration_reference_sharding_sched_ref_quota>`

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_SHARDING_SCHED_MOVE_QUOTA

..  _configuration_reference_sharding_sched_ref_quota:

..  confval:: sharding.sched_ref_quota

    A scheduler's storage ref quota used by a :ref:`router <vshard-architecture-router>`'s map-reduce API.
    For example, the :ref:`vshard.router.map_callrw() <router_api-map_callrw>` function implements consistent map-reduce over the entire cluster.

    ``sched_ref_quota`` defines how many storage refs, therefore map-reduce requests, can be executed on the storage in a row if there are pending bucket moves.
    Then, storage refs are blocked and the rebalancer continues bucket moves.

    See also: :ref:`sharding.sched_move_quota <configuration_reference_sharding_sched_move_quota>`

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: number
    | Default: 300
    | Environment variable: TT_SHARDING_SCHED_REF_QUOTA

..  _configuration_reference_sharding_shard_index:

..  confval:: sharding.shard_index

    The name or ID of a TREE index over the :ref:`bucket id <vshard-vbuckets>`.
    Spaces without this index do not participate in a sharded Tarantool
    cluster and can be used as regular spaces if needed. It is necessary to
    specify the first part of the index, other parts are optional.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    See also: :ref:`vshard-define-spaces`

    |
    | Type: string
    | Default: 'bucket_id'
    | Environment variable: TT_SHARDING_SHARD_INDEX

..  _configuration_reference_sharding_sync_timeout:

..  confval:: sharding.sync_timeout

    The timeout to wait for synchronization of the old master with replicas before demotion.
    Used when switching a master or when manually calling the :ref:`sync() <storage_api-sync>` function.

    ..  NOTE::

        This option should be defined at the :ref:`global level <configuration_scopes>`.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_SHARDING_SYNC_TIMEOUT

..  _configuration_reference_sharding_weight:

..  confval:: sharding.weight

    **Since:** :doc:`3.1.0 </release/3.1.0>`

    The relative amount of data that a replica set can store.
    Learn more at :ref:`vshard-replica-set-weights`.

    ..  NOTE::

        ``sharding.weight`` can be specified at the :ref:`replica set level <configuration_scopes>`.

    |
    | Type: number
    | Default: 1
    | Environment variable: TT_SHARDING_WEIGHT

..  _configuration_reference_sharding_zone:

..  confval:: sharding.zone

    A zone that can be set for routers and replicas.
    This allows sending read-only requests not only to a master instance but to any available replica that is the nearest to the router.

    ..  NOTE::

        ``sharding.zone`` can be specified at any :ref:`level <configuration_scopes>`.

    |
    | Type: integer
    | Default: nil
    | Environment variable: TT_SHARDING_ZONE

..  _configuration_reference_snapshot:

snapshot
--------

The ``snapshot`` section defines configuration parameters related to the :ref:`snapshot files <internals-snapshot>`.
To learn more about the snapshots' configuration, check the :ref:`Persistence <configuration_persistence_snapshot>` page.

..  NOTE::

    ``snapshot`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`snapshot.dir <configuration_reference_snapshot_dir>`
-   :ref:`snapshot.snap_io_rate_limit <configuration_reference_snapshot_snap_io_rate_limit>`
-   :ref:`snapshot.count <configuration_reference_snapshot_count>`
-   :ref:`snapshot.by.* <configuration_reference_snapshot_by>`

..  _configuration_reference_snapshot_dir:

..  confval:: snapshot.dir

    A directory where memtx stores snapshot (.snap) files.
    A relative path in this option is interpreted as relative to ``process.work_dir``.

    By default, snapshots and WAL files are stored in the same directory.
    However, you can set different values for the ``snapshot.dir`` and :ref:`wal.dir <configuration_reference_wal_dir>` options
    to store them on different physical disks for performance matters.

    |
    | Type: string
    | Default: 'var/lib/{{ instance_name }}'
    | Environment variable: TT_SNAPSHOT_DIR

..  _configuration_reference_snapshot_snap_io_rate_limit:

..  confval:: snapshot.snap_io_rate_limit

    Reduce the throttling effect of :doc:`box.snapshot() </reference/reference_lua/box_snapshot>` on
    INSERT/UPDATE/DELETE performance by setting a limit on how many
    megabytes per second it can write to disk. The same can be
    achieved by splitting :ref:`wal.dir <configuration_reference_wal_dir>` and
    :ref:`snapshot.dir <configuration_reference_snapshot_dir>`
    locations and moving snapshots to a separate disk.
    The limit also affects what
    :ref:`box.stat.vinyl().regulator <box_introspection-box_stat_vinyl_regulator>`
    may show for the write rate of dumps to ``.run`` and ``.index`` files.

    |
    | Type: number
    | Default: box.NULL
    | Environment variable: TT_SNAPSHOT_SNAP_IO_RATE_LIMIT

..  _configuration_reference_snapshot_count:

..  confval:: snapshot.count

    The maximum number of snapshots that are stored in the
    :ref:`snapshot.dir <configuration_reference_snapshot_dir>` directory.
    If the number of snapshots after creating a new one exceeds this value,
    the :ref:`Tarantool garbage collector <configuration_persistence_garbage_collector>` deletes old snapshots.
    If ``snapshot.count`` is set to zero, the garbage collector
    does not delete old snapshots.

    **Example**

    In the example, the checkpoint daemon creates a snapshot every two hours until
    it has created three snapshots. After creating a new snapshot (the fourth one), the oldest snapshot
    and any associated write-ahead-log files are deleted.

    ..  code-block:: yaml

        snapshot:
          by:
            interval: 7200
          count: 3

    ..  NOTE::

        Snapshots will not be deleted if replication is ongoing and the file has not been relayed to a replica.
        Therefore, ``snapshot.count`` has no effect unless all replicas are alive.

    |
    | Type: integer
    | Default: 2
    | Environment variable: TT_SNAPSHOT_COUNT

..  _configuration_reference_snapshot_by:

snapshot.by.*
~~~~~~~~~~~~~

*   :ref:`snapshot.by.interval <configuration_reference_snapshot_by_interval>`
*   :ref:`snapshot.by.wal_size <configuration_reference_snapshot_by_wal_size>`

..  _configuration_reference_snapshot_by_interval:

..  confval:: snapshot.by.interval

    The interval in seconds between actions by the :ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>`.
    If the option is set to a value greater than zero, and there is
    activity that causes change to a database, then the checkpoint daemon calls
    :doc:`box.snapshot() </reference/reference_lua/box_snapshot>` every ``snapshot.by.interval``
    seconds, creating a new snapshot file each time.
    If the option is set to zero, the checkpoint daemon is disabled.

    **Example**

    In the example, the checkpoint daemon creates a new database snapshot every two hours, if there is activity.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_snapshot/config.yaml
        :language: yaml
        :start-at: by:
        :end-at: interval: 7200
        :dedent:

    |
    | Type: number
    | Default: 3600
    | Environment variable: TT_SNAPSHOT_BY_INTERVAL

..  _configuration_reference_snapshot_by_wal_size:

..  confval:: snapshot.by.wal_size

    The threshold for the total size in bytes for all WAL files created since the last snapshot taken.
    Once the configured threshold is exceeded, the WAL thread notifies the
    :ref:`checkpoint daemon <configuration_persistence_checkpoint_daemon>` that it must make a new snapshot and delete old WAL files.

    |
    | Type: integer
    | Default: 10^18
    | Environment variable: TT_SNAPSHOT_BY_WAL_SIZE



..  _configuration_reference_sql:

sql
---

The ``sql`` section defines configuration parameters related to :ref:`SQL <reference_sql>`.

..  NOTE::

    ``sql`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`sql.cache_size <configuration_reference_sql_cache_size>`

..  _configuration_reference_sql_cache_size:

..  confval:: sql.cache_size

    The maximum cache size (in bytes) for all :ref:`SQL prepared statements <box-sql_box_prepare>`.
    To see the actual cache size, use :ref:`box.info.sql().cache.size <box_introspection-box_info>`.

    |
    | Type: integer
    | Default: 5242880
    | Environment variable: TT_SQL_CACHE_SIZE



..  _configuration_reference_vinyl:

vinyl
-----

The ``vinyl`` section defines configuration parameters related to the
:ref:`vinyl storage engine <engines-vinyl>`.

..  NOTE::

    ``vinyl`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`vinyl.bloom_fpr <configuration_reference_vinyl_bloom_fpr>`
-   :ref:`vinyl.cache <configuration_reference_vinyl_cache>`
-   :ref:`vinyl.defer_deletes <configuration_reference_vinyl_defer_deletes>`
-   :ref:`vinyl.dir <configuration_reference_vinyl_dir>`
-   :ref:`vinyl.max_tuple_size <configuration_reference_vinyl_max_tuple_size>`
-   :ref:`vinyl.memory <configuration_reference_vinyl_memory>`
-   :ref:`vinyl.page_size <configuration_reference_vinyl_page_size>`
-   :ref:`vinyl.range_size <configuration_reference_vinyl_range_size>`
-   :ref:`vinyl.read_threads <configuration_reference_vinyl_read_threads>`
-   :ref:`vinyl.run_count_per_level <configuration_reference_vinyl_run_count_per_level>`
-   :ref:`vinyl.run_size_ratio <configuration_reference_vinyl_run_size_ratio>`
-   :ref:`vinyl.timeout <configuration_reference_vinyl_timeout>`
-   :ref:`vinyl.write_threads <configuration_reference_vinyl_write_threads>`

..  _configuration_reference_vinyl_bloom_fpr:

..  confval:: vinyl.bloom_fpr

    A bloom filter's false positive rate -- the suitable probability of the
    `bloom filter <https://en.wikipedia.org/wiki/Bloom_filter>`_
    to give a wrong result.
    The ``vinyl.bloom_fpr`` setting is a default value for the
    :ref:`bloom_fpr <index_opts_bloom_fpr>`
    option passed to ``space_object:create_index()``.

    |
    | Type: number
    | Default: 0.05
    | Environment variable: TT_VINYL_BLOOM_FPR

..  _configuration_reference_vinyl_cache:

..  confval:: vinyl.cache

    The cache size for the vinyl storage engine. The cache can
    be resized dynamically.

    |
    | Type: integer
    | Default: 128 * 1024 * 1024
    | Environment variable: TT_VINYL_CACHE

..  _configuration_reference_vinyl_defer_deletes:

..  confval:: vinyl.defer_deletes

    Enable the deferred DELETE optimization in vinyl. It was disabled by default
    since Tarantool version 2.10 to avoid possible performance degradation
    of secondary index reads.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_VINYL_DEFER_DELETES

..  _configuration_reference_vinyl_dir:

..  confval:: vinyl.dir

    A directory where vinyl files or subdirectories will be stored.

    This option may contain a relative file path.
    In this case, it is interpreted as relative to
    :ref:`process.work_dir <configuration_reference_process_work_dir>`.

    |
    | Type: string
    | Default: 'var/lib/{{ instance_name }}'
    | Environment variable: TT_VINYL_DIR

..  _configuration_reference_vinyl_max_tuple_size:

..  confval:: vinyl.max_tuple_size

    The size of the largest allocation unit, for the vinyl storage engine.
    It can be increased if it is necessary to store large tuples.

    |
    | Type: integer
    | Default: 1024 * 1024
    | Environment variable: TT_VINYL_MAX_TUPLE_SIZE

..  _configuration_reference_vinyl_memory:

..  confval:: vinyl.memory

    The maximum number of in-memory bytes that vinyl uses.

    |
    | Type: integer
    | Default: 128 * 1024 * 1024
    | Environment variable: TT_VINYL_MEMORY

..  _configuration_reference_vinyl_page_size:

..  confval:: vinyl.page_size

    The page size. A page is a read/write unit for vinyl disk operations.
    The ``vinyl.page_size`` setting is a default value
    for the :ref:`page_size <index_opts_page_size>`
    option passed to ``space_object:create_index()``.

    |
    | Type: integer
    | Default: 8 * 1024
    | Environment variable: TT_VINYL_PAGE_SIZE

..  _configuration_reference_vinyl_range_size:

..  confval:: vinyl.range_size

    The default maximum range size for a vinyl index, in bytes.
    The maximum range size affects the decision of whether to
    :ref:`split <engines-vinyl_split>` a range.

    If ``vinyl.range_size`` is specified (but the value is not ``null`` or 0), then
    it is used as the default value for the
    :ref:`range_size <index_opts_range_size>`
    option passed to ``space_object:create_index()``.

    If ``vinyl.range_size`` is not specified (or is explicitly set to ``null`` or 0),
    and ``range_size`` is not specified when the index is created,
    then Tarantool sets a value later depending on performance considerations.
    To see the actual value, use
    :doc:`index_object:stat().range_size </reference/reference_lua/box_index/stat>`.

    |
    | Type: integer
    | Default: box.NULL (means that an effective default is determined in runtime)
    | Environment variable: TT_VINYL_RANGE_SIZE

..  _configuration_reference_vinyl_read_threads:

..  confval:: vinyl.read_threads

    The maximum number of read threads that vinyl can use for
    concurrent operations, such as I/O and compression.

    |
    | Type: integer
    | Default: 1
    | Environment variable: TT_VINYL_READ_THREADS

..  _configuration_reference_vinyl_run_count_per_level:

..  confval:: vinyl.run_count_per_level

    The maximum number of runs per level in the vinyl LSM tree.
    If this number is exceeded, a new level is created.
    The ``vinyl.run_count_per_level`` setting is a default value for the
    :ref:`run_count_per_level <index_opts_run_count_per_level>`
    option passed to ``space_object:create_index()``.

    |
    | Type: integer
    | Default: 2
    | Environment variable: TT_VINYL_RUN_COUNT_PER_LEVEL

..  _configuration_reference_vinyl_run_size_ratio:

..  confval:: vinyl.run_size_ratio

    The ratio between the sizes of different levels in the LSM tree.
    The ``vinyl.run_size_ratio`` setting is a default value for the
    :ref:`run_size_ratio <index_opts_run_size_ratio>`
    option passed to ``space_object:create_index()``.

    |
    | Type: number
    | Default: 3.5
    | Environment variable: TT_VINYL_RUN_SIZE_RATIO

..  _configuration_reference_vinyl_timeout:

..  confval:: vinyl.timeout

    The vinyl storage engine has a scheduler that performs compaction.
    When vinyl is low on available memory, the compaction scheduler
    may be unable to keep up with incoming update requests.
    In that situation, queries may time out after ``vinyl.timeout`` seconds.
    This should rarely occur, since normally vinyl
    throttles inserts when it is running low on compaction bandwidth.
    Compaction can also be initiated manually with
    :doc:`/reference/reference_lua/box_index/compact`.

    |
    | Type: integer
    | Default: 60
    | Environment variable: TT_VINYL_TIMEOUT

..  _configuration_reference_vinyl_write_threads:

..  confval:: vinyl.write_threads

    The maximum number of write threads that vinyl can use for some
    concurrent operations, such as I/O and compression.

    |
    | Type: integer
    | Default: 4
    | Environment variable: TT_VINYL_WRITE_THREADS

..  _configuration_reference_wal:

wal
---

The ``wal`` section defines configuration parameters related to :ref:`write-ahead log <internals-wal>`.
To learn more about the WAL configuration, check the :ref:`Persistence <configuration_persistence_wal>` page.

..  NOTE::

    ``wal`` can be defined in any :ref:`scope <configuration_scopes>`.

-   :ref:`wal.cleanup_delay <configuration_reference_wal_cleanup_delay>`
-   :ref:`wal.dir <configuration_reference_wal_dir>`
-   :ref:`wal.dir_rescan_delay <configuration_reference_wal_dir_rescan_delay>`
-   :ref:`wal.max_size <configuration_reference_wal_max_size>`
-   :ref:`wal.mode <configuration_reference_wal_mode>`
-   :ref:`wal.queue_max_size <configuration_reference_wal_queue_max_size>`
-   :ref:`wal.retention_period <configuration_reference_wal_retention_period>`
-   :ref:`wal.ext.* <configuration_reference_wal_ext>`

..  _configuration_reference_wal_cleanup_delay:

..  confval:: wal.cleanup_delay

    The delay in seconds used to prevent the :ref:`Tarantool garbage collector <configuration_persistence_checkpoint_daemon>`
    from immediately removing :ref:`write-ahead log <internals-wal>` files after a node restart.
    This delay eliminates possible erroneous situations when the master deletes WALs
    needed by :ref:`replicas <replication-roles>` after restart.
    As a consequence, replicas sync with the master faster after its restart and
    don't need to download all the data again.
    Once all the nodes in the replica set are up and running, a scheduled garbage collection is started again
    even if ``wal.cleanup_delay`` has not expired.

    ..  NOTE::

        The option has no effect on nodes running as
        :ref:`anonymous replicas <configuration_reference_replication_anon>`.

    See also: :ref:`wal.retention_period <configuration_reference_wal_retention_period>`

    |
    | Type: number
    | Default: 14400
    | Environment variable: TT_WAL_CLEANUP_DELAY

..  _configuration_reference_wal_dir:

..  confval:: wal.dir

    A directory where write-ahead log (``.xlog``) files are stored.
    A relative path in this option is interpreted as relative to ``process.work_dir``.

    By default, WAL files and snapshots are stored in the same directory.
    However, you can set different values for the ``wal.dir`` and :ref:`snapshot.dir <configuration_reference_snapshot_dir>` options
    to store them on different physical disks for performance matters.

    |
    | Type: string
    | Default: 'var/lib/{{ instance_name }}'
    | Environment variable: TT_WAL_DIR

..  _configuration_reference_wal_dir_rescan_delay:

..  confval:: wal.dir_rescan_delay

    The time interval in seconds between periodic scans of the write-ahead-log
    file directory, when checking for changes to write-ahead-log
    files for the sake of :ref:`replication <replication>` or :ref:`hot standby <configuration_reference_database_hot_standby>`.

    |
    | Type: number
    | Default: 2
    | Environment variable: TT_WAL_DIR_RESCAN_DELAY

..  _configuration_reference_wal_max_size:

..  confval:: wal.max_size

    The maximum number of bytes in a single write-ahead log file.
    When a request would cause an ``.xlog`` file to become larger than
    ``wal.max_size``, Tarantool creates a new WAL file.

    |
    | Type: integer
    | Default: 268435456
    | Environment variable: TT_WAL_MAX_SIZE

..  _configuration_reference_wal_mode:

..  confval:: wal.mode

    Specify fiber-WAL-disk synchronization mode as:

    *   ``none``: write-ahead log is not maintained.
        A node with ``wal.mode`` set to ``none`` can't be a replication master.

    *   ``write``: :ref:`fibers <fiber-fibers>` wait for their data to be written to
        the write-ahead log (no ``fsync(2)``).

    *   ``fsync``: fibers wait for their data, :manpage:`fsync(2)`
        follows each :manpage:`write(2)`.

    |
    | Type: string
    | Default: 'write'
    | Environment variable: TT_WAL_MODE

..  _configuration_reference_wal_queue_max_size:

..  confval:: wal.queue_max_size

    The size of the queue in bytes used by a :ref:`replica <replication-roles>` to submit
    new transactions to a :ref:`write-ahead log <internals-wal>` (WAL).
    This option helps limit the rate at which a replica submits transactions to the WAL.

    Limiting the queue size might be useful when a replica is trying to sync with a master and
    reads new transactions faster than writing them to the WAL.

    ..  NOTE::

        You might consider increasing the ``wal.queue_max_size`` value in case of
        large tuples (approximately one megabyte or larger).

    |
    | Type: integer
    | Default: 16777216
    | Environment variable: TT_WAL_QUEUE_MAX_SIZE

..  _configuration_reference_wal_retention_period:

..  confval:: wal.retention_period

    **Since:** :doc:`3.1.0 </release/3.1.0>` (`Enterprise Edition <https://www.tarantool.io/compare/>`_ only)

    The delay in seconds used to prevent the :ref:`Tarantool garbage collector <configuration_persistence_checkpoint_daemon>` from removing a :ref:`write-ahead log <internals-wal>` file after it has been closed.
    If a node is restarted, ``wal.retention_period`` counts down from the last modification time of the write-ahead log file.

    The garbage collector doesn't track write-ahead logs that are to be :ref:`relayed <memtx-replication>` to anonymous replicas, such as:

    *   Anonymous replicas added as a part of a cluster configuration (see :ref:`replication.anon <configuration_reference_replication_anon>`).
    *   CDC (Change Data Capture) that retrieves data using anonymous replication.

    In case of a replica or CDC downtime, the required write-ahead logs can be removed.
    As a result, such a replica needs to be rebootstrapped.
    You can use ``wal.retention_period`` to prevent such issues.

    Note that :ref:`wal.cleanup_delay <configuration_reference_wal_cleanup_delay>` option also sets the delay used to prevent the Tarantool garbage collector from removing write-ahead logs.
    The difference is that the garbage collector doesn't take into account ``wal.cleanup_delay`` if all the nodes in the replica set are up and running, which may lead to the removal of the required write-ahead logs.

    ..  NOTE::

        :ref:`box.info.gc().wal_retention_vclock <box_info_gc>` can be used to get a vclock value of the oldest write-ahead log protected by ``wal.retention_period``.

    |
    | Type: number
    | Default: 0
    | Environment variable: TT_WAL_RETENTION_PERIOD

..  _configuration_reference_wal_ext:

wal.ext.*
~~~~~~~~~

..  admonition:: Enterprise Edition
    :class: fact

    Configuring ``wal.ext.*`` parameters is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

This section describes options related to :ref:`WAL extensions <wal_extensions>`.

*   :ref:`wal.ext.new <configuration_reference_wal_ext_new>`
*   :ref:`wal.ext.old <configuration_reference_wal_ext_old>`
*   :ref:`wal.ext.spaces <configuration_reference_wal_ext_spaces>`

..  _configuration_reference_wal_ext_new:

..  confval:: wal.ext.new

    Enable storing a new tuple for each :ref:`CRUD <box_space_examples>` operation performed.
    The option is in effect for all spaces.
    To adjust the option for specific spaces, use the :ref:`wal.ext.spaces <configuration_reference_wal_ext_spaces>`
    option.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_WAL_EXT_NEW

..  _configuration_reference_wal_ext_old:

..  confval:: wal.ext.old

    Enable storing an old tuple for each :ref:`CRUD <box_space_examples>` operation performed.
    The option is in effect for all spaces.
    To adjust the option for specific spaces, use the :ref:`wal.ext.spaces <configuration_reference_wal_ext_spaces>`
    option.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_WAL_EXT_OLD

..  _configuration_reference_wal_ext_spaces:

..  confval:: wal.ext.spaces

    Enable or disable storing an old and new tuple in the :ref:`WAL <internals-wal>` record
    for a given space explicitly.
    The configuration for specific spaces has priority over the configuration in the
    :ref:`wal.ext.new <configuration_reference_wal_ext_new>` and :ref:`wal.ext.old <configuration_reference_wal_ext_old>`
    options.

    The option is a key-value pair:

    *   The key is a space name (string).

    *   The value is a table that includes two optional boolean options: ``old`` and ``new``.
        The format and the default value of these options are described in ``wal.ext.old`` and ``wal.ext.new``.

    **Example**

    In the example, only new tuples are added to the log for the ``bands`` space.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/persistence_wal/config.yaml
        :language: yaml
        :start-at: ext:
        :end-at: old: false
        :dedent:

    |
    | Type: map
    | Default: nil
    | Environment variable: TT_WAL_EXT_SPACES

..  _enterprise_audit_module:

Audit module
============

..  admonition:: Enterprise Edition
    :class: fact

    The audit module is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

**Example on GitHub**: `audit_log <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/audit_log>`_

The audit module available in Tarantool Enterprise Edition allows you to record various events occurred in Tarantool.
Each :ref:`event <audit-log-events-types>` is an action related to authorization and authentication, data manipulation,
administrator activity, or system events.

The module provides detailed reports of these activities and helps you find and
fix breaches to protect your business. For example, you can see who created a new user
and when.

It is up to each company to decide exactly what activities to audit and what actions to take.
System administrators, security engineers, and people in charge of the company may want to
audit different events for different reasons. Tarantool provides such an option for each of them.

..  _audit-log-configure:

Configure audit log
-------------------

The section describes how to enable and configure audit logging and write logs to a selected destination -- a file, a pipe,
or a system logger.

Read more: :ref:`Audit log configuration reference <configuration_reference_audit>`.

..  _audit-log-enable:

Enable audit logging
~~~~~~~~~~~~~~~~~~~~

To enable audit logging, define the log location using the
:ref:`audit_log.to <configuration_reference_audit_to>` option in the configuration file.
Possible log locations:

*   a :ref:`file <configuration_reference_audit_file>`
*   a :ref:`pipe <configuration_reference_audit_pipe>`
*   a :ref:`system logger <configuration_reference_audit_syslog-server>`

In the configuration below, the :ref:`audit_log.to <configuration_reference_audit_to>` option is set to ``file``.
It means that the logs are written to a file.
By default, audit logs are saved in the ``var/log/{{ instance_name }}/audit.log`` file.
To specify the path to an audit log file explicitly, use the :ref:`audit_log.file <configuration_reference_audit_file>` option.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: audit_log:
    :end-at: 'audit_tarantool.log'
    :dedent:

If you log to a file, Tarantool reopens the audit log at `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.

To disable audit logging, set the ``audit_log.to`` option to ``devnull``.

..  _audit-log-filters:

Filter the events
~~~~~~~~~~~~~~~~~

Tarantool's extensive filtering options help you write only the events you need to the audit log.
To select the recorded events, use the :ref:`audit_log.filter <configuration_reference_audit_filter>` option.
Its value can be a list of events and event groups.
You can customize the filters and use different combinations of them for your purposes.
Possible filtering options:

-   Filter by event. You can set a list of :ref:`events <audit-log-events>` to be recorded. For example, select
    ``password_change`` to monitor the users who have changed their passwords:

    ..  code-block:: yaml

        audit_log:
          filter: [ password_change ]

-   Filter by group. You can specify a list of :ref:`event groups <audit-log-event-groups>` to be recorded. For example,
    select ``auth`` and ``priv`` to see the events related to authorization and granted privileges:

    ..  code-block:: yaml

        audit_log:
          filter: [ auth,priv ]

-   Filter by group and event. You can specify a group and a certain event depending on the purpose.
    In the configuration below, ``user_create``, ``data_operations``, ``ddl``, and ``custom`` are selected to see the events related to:

    *   user creation
    *   space creation, altering, and dropping
    *   data modification or selection from spaces
    *   :ref:`custom events <audit-log-custom>` (any events added manually using the audit module API)

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
        :language: yaml
        :start-at: filter:
        :end-at: custom ]
        :dedent:

..  _audit-log-format:

Set the format of audit log events
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the :ref:`audit_log.format <configuration_reference_audit_format>` option to choose the format of audit log events
-- plain text, CSV, or JSON.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: format:
    :end-at: json
    :dedent:

JSON is used by default. It is more convenient to receive log events, analyze them, and integrate them with other systems if needed.
The plain format can be efficiently compressed.
The CSV format allows you to view audit log events in tabular form.

..  _audit-log-spaces:

Specify the spaces to be logged
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`audit_log.spaces <configuration_reference_audit_spaces>` option is used to specify
a list of space names for which data operation events should be logged.

In the configuration below, only the events from the ``bands`` space are logged:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: spaces:
    :end-at: bands ]
    :dedent:

..  _audit-log-extract:

Specify the logging mode in DML events
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If set to ``true``, the :ref:`audit_log.extract_key <configuration_reference_audit_extract_key>` option
forces the audit subsystem to log the primary key instead of a full tuple in DML operations.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: extract_key:
    :end-at: true
    :dedent:

..  _audit-log-run-example:

Examples of audit log entries
-----------------------------

In this example, the following audit log configuration is used:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: audit_log
    :end-at: extract_key: true
    :dedent:

Create a space ``bands`` and check the logs in the file after the creation:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
    :language: lua
    :start-after: function create_space()
    :end-before: box.space.bands:format({
    :dedent:

The audit log entry for the ``space_create`` event might look as follows:

..  code-block:: json

    {
      "time": "2024-01-24T11:43:21.566+0300",
      "uuid": "26af0a7d-1052-490a-9946-e19eacc822c9",
      "severity": "INFO",
      "remote": "unix/:(socket)",
      "session_type": "console",
      "module": "tarantool",
      "user": "admin",
      "type": "space_create",
      "tag": "",
      "description": "Create space Bands"
    }

Then insert one tuple to space:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
    :language: lua
    :start-after: load_data()
    :end-before: box.space.bands:insert { 2
    :dedent:

If the ``extract_key`` option is set to ``true``, the audit system prints the primary key instead of the full tuple:

..  code-block:: json

    {
      "time": "2024-01-24T11:45:42.358+0300",
      "uuid": "b437934d-62a7-419a-8d59-e3b33c688d7a",
      "severity": "VERBOSE",
      "remote": "unix/:(socket)",
      "session_type": "console",
      "module": "tarantool",
      "user": "admin",
      "type": "space_insert",
      "tag": "",
      "description": "Insert key [2] into space bands"
    }

If the ``extract_key`` option is set to ``false``, the audit system prints the full tuple like this:

..  code-block:: json

    {
      "time": "2024-01-24T11:45:42.358+0300",
      "uuid": "b437934d-62a7-419a-8d59-e3b33c688d7a",
      "severity": "VERBOSE",
      "remote": "unix/:(socket)",
      "session_type": "console",
      "module": "tarantool",
      "user": "admin",
      "type": "space_insert",
      "tag": "",
      "description": "Insert tuple [1, \"Roxette\", 1986] into space bands"
    }

..  _audit-log-events:

Audit log events
----------------

..  _audit-log-events-types:

Events types
~~~~~~~~~~~~

The Tarantool audit log module can record various events that you can monitor and
decide whether you need to take actions:

*   Administrator activity -- events related to actions performed by the administrator.
    For example, such logs record the creation of a user.

*   Access events -- events related to authorization and authentication of users.
    For example, such logs record failed attempts to access secure data.

*   Data access and modification -- events of data manipulation in the storage.

*   System events -- events related to modification or configuration of resources.
    For example, such logs record the replacement of a space.

*   :ref:`Custom events <audit-log-custom>` -- any events added manually using
    the audit module API.

The full list of available audit log events is provided in the table below:

..  container:: table

    ..  list-table::
        :widths: 20 25 20 35
        :header-rows: 1

        *   -   Event
            -   Event type
            -   Severity level
            -   Example
        *   -   Audit log enabled for events
            -   ``audit_enable``
            -   ``VERBOSE``
            -
        *   -   :ref:`Custom events <audit-log-custom>`
            -   ``custom``
            -   ``INFO`` (default)
            -
        *   -   User authorized successfully
            -   ``auth_ok``
            -   ``VERBOSE``
            -   ``Authenticate user <USER>``
        *   -   User authorization failed
            -   ``auth_fail``
            -   ``ALARM``
            -   ``Failed to authenticate user <USER>``
        *   -   User logged out or quit the session
            -   ``disconnect``
            -   ``VERBOSE``
            -   ``Close connection``
        *   -   User created
            -   ``user_create``
            -   ``INFO``
            -   ``Create user <USER>``
        *   -   User dropped
            -   ``user_drop``
            -   ``INFO``
            -   ``Drop user <USER>``
        *   -   Role created
            -   ``role_create``
            -   ``INFO``
            -   ``Create role <ROLE>``
        *   -   Role dropped
            -   ``role_drop``
            -   ``INFO``
            -   ``Drop role <ROLE>``
        *   -   User disabled
            -   ``user_disable``
            -   ``INFO``
            -   ``Disable user <USER>``
        *   -   User enabled
            -   ``user_enable``
            -   ``INFO``
            -   ``Enable user <USER>``
        *   -   User granted rights
            -   ``user_grant_rights``
            -   ``INFO``
            -   ``Grant <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> to user <USER>``
        *   -   User revoked rights
            -   ``user_revoke_rights``
            -   ``INFO``
            -   ``Revoke <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> from user <USER>``
        *   -   Role granted rights
            -   ``role_grant_rights``
            -   ``INFO``
            -   ``Grant <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> to role <ROLE>``
        *   -   Role revoked rights
            -   ``role_revoke_rights``
            -   ``INFO``
            -   ``Revoke <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> from role <ROLE>``
        *   -   User password changed
            -   ``password_change``
            -   ``INFO``
            -   ``Change password for user <USER>``
        *   -   Failed attempt to access secure data (for example, personal records, details, geolocation)
            -   ``access_denied``
            -   ``ALARM``
            -   ``<ACCESS_TYPE> denied to <OBJECT_TYPE> <OBJECT_NAME>``
        *   -   Expressions with arguments evaluated in a string
            -   ``eval``
            -   ``INFO``
            -   ``Evaluate expression <EXPR>``
        *   -   Function called with arguments
            -   ``call``
            -   ``VERBOSE``
            -   ``Call function <FUNCTION> with arguments <ARGS>``
        *   -   Iterator key selected from ``space.index``
            -   ``space_select``
            -   ``VERBOSE``
            -   ``Select <ITER_TYPE> <KEY> from <SPACE>.<INDEX>``
        *   -   Space created
            -   ``space_create``
            -   ``INFO``
            -   ``Create space <SPACE>``
        *   -   Space altered
            -   ``space_alter``
            -   ``INFO``
            -   ``Alter space <SPACE>``
        *   -   Space dropped
            -   ``space_drop``
            -   ``INFO``
            -   ``Drop space <SPACE>``
        *   -   Tuple inserted into space
            -   ``space_insert``
            -   ``VERBOSE``
            -   ``Insert tuple <TUPLE> into space <SPACE>``
        *   -   Tuple replaced in space
            -   ``space_replace``
            -   ``VERBOSE``
            -   ``Replace tuple <TUPLE> with <NEW_TUPLE> in space <SPACE>``
        *   -   Tuple deleted from space
            -   ``space_delete``
            -   ``VERBOSE``
            -   ``Delete tuple <TUPLE> from space <SPACE>``


    ..  note::

        The ``eval`` event displays data from the ``console`` module
        and the ``eval`` function of the ``net.box`` module.
        For more on how they work, see :ref:`Module console <console-module>`
        and :ref:`Module net.box -- eval <net_box-eval>`.
        To separate the data, specify ``console`` or ``binary`` in the session field.

..  _audit-log-structure:

Structure of audit log event
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each audit log event contains a number of fields that can be used to filter and aggregate the resulting logs.
An example of a Tarantool audit log entry in JSON:

..  code-block:: json

    {
        "time": "2024-01-15T13:39:36.046+0300",
        "uuid": "cb44fb2b-5c1f-4c4b-8f93-1dd02a76cec0",
        "severity": "VERBOSE",
        "remote": "unix/:(socket)",
        "session_type": "console",
        "module": "tarantool",
        "user": "admin",
        "type": "auth_ok",
        "tag": "",
        "description": "Authenticate user Admin"
    }

Each event consists of the following fields:

..  container:: table

    ..  list-table::
        :widths: 30 35 35
        :header-rows: 1

        *   -   Field
            -   Description
            -   Example
        *   -   ``time``
            -   Time of the event
            -   ``2024-01-15T16:33:12.368+0300``
        *   -   ``uuid``
            -    Since :doc:`3.0.0 </release/3.0.0>`. A unique identifier of audit log event
            -   ``cb44fb2b-5c1f-4c4b-8f93-1dd02a76cec0``
        *   -   ``severity``
            -   Since :doc:`3.0.0 </release/3.0.0>`. A severity level. Each system audit event has a severity level determined by its importance.
                :ref:`Custom events <audit-log-custom>` have the ``INFO`` severity level by default.

            -   ``VERBOSE``
        *   -   ``remote``
            -   Remote host that triggered the event
            -   ``unix/:(socket)``
        *   -   ``session_type``
            -   Session type
            -   ``console``
        *   -   ``module``
            -   Audit log module. Set to ``tarantool`` for system events;
                can be overwritten for custom events
            -   ``tarantool``
        *   -   ``user``
            -   User who triggered the event
            -   ``admin``
        *   -   ``type``
            -   Audit event type
            -   ``auth_ok``
        *   -   ``tag``
            -   A text field that can be overwritten by the user
            -
        *   -   ``description``
            -   Human-readable event description
            -   ``Authenticate user Admin``


..  _audit-log-event-groups:

Event groups
~~~~~~~~~~~~

Built-in event groups are used to filter the event types that you want to audit.
For example, you can set to record only authorization events or only events related to a space.

Tarantool provides the following event groups:

*   ``all`` -- all :ref:`events <audit-log-events>`.

    ..  note::

        Events ``call`` and ``eval`` are included only in the ``all`` group.

*   ``audit`` -- ``audit_enable`` event.

*   ``auth`` -- authorization events: ``auth_ok``, ``auth_fail``.

*   ``priv`` -- events related to authentication, authorization, users, and roles:
    ``user_create``, ``user_drop``, ``role_create``, ``role_drop``, ``user_enable``, ``user_disable``,
    ``user_grant_rights``, ``user_revoke_rights``, ``role_grant_rights``, ``role_revoke_rights``.

*   ``ddl`` -- events of space creation, altering, and dropping:
    ``space_create``, ``space_alter``, ``space_drop``.

*   ``dml`` -- events of data modification in spaces:
    ``space_insert``, ``space_replace``, ``space_delete``.

*   ``data_operations`` -- events of data modification or selection from spaces:
    ``space_select``, ``space_insert``, ``space_replace``, ``space_delete``.

*   ``compatibility`` -- events available in Tarantool before the version 2.10.0.
    ``auth_ok``, ``auth_fail``, ``disconnect``, ``user_create``, ``user_drop``,
    ``role_create``, ``role_drop``, ``user_enable``, ``user_disable``,
    ``user_grant_rights``, ``user_revoke_rights``, ``role_grant_rights``.
    ``role_revoke_rights``, ``password_change``, ``access_denied``.
    This group enables the compatibility with earlier Tarantool versions.

..  warning::

    Be careful when recording ``all`` and ``data_operations`` event groups.
    The more events you record, the slower the requests are processed over time.
    It is recommended that you select only those groups
    whose events your company needs to monitor and analyze.

..  _audit-log-custom:

Custom events
-------------

Tarantool provides an API for writing custom audit log events.
To enable these events, specify the ``custom`` value in the :ref:`audit_log.filter <configuration_reference_audit_filter>` option:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: filter:
    :end-at: custom ]
    :dedent:

..  _audit-log-custom-log:

Log a custom event
~~~~~~~~~~~~~~~~~~

To log an event, use the ``audit.log()`` function that takes one of the following values:

*   Message string. Printed to the audit log with type ``message``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
        :language: lua
        :start-after: Log message string
        :end-before: Log format string and arguments
        :dedent:

*   Format string and arguments. Passed to string format and then output to the audit log with type ``message``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
        :language: lua
        :start-after: Log format string and arguments
        :end-before: Log table with audit log field values
        :dedent:

*   Table with audit log field values. The table must contain at least one field -- ``description``.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
        :language: lua
        :start-after: Log table with audit log field values
        :end-at: description = 'Farewell, Eve!' })
        :dedent:

Alternatively, you can use ``audit.new()`` to create a new log module.
This allows you to avoid passing all custom audit log fields each time ``audit.log()`` is called.
The ``audit.new()`` function takes a table of audit log field values (same as ``audit.log()``).
The ``type`` of the log module for writing custom events must either be ``message`` or have the ``custom_`` prefix.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
    :language: lua
    :start-after: Create a new log module
    :end-before: Log 'Hello!' message with the VERBOSE severity level
    :dedent:

..  _audit-log-custom-field-overwrite:

Overwrite custom event fields
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is possible to overwrite most of the custom audit log :ref:`fields <audit-log-structure>` using ``audit.new()`` or ``audit.log()``.
The only audit log field that cannot be overwritten is ``time``.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
    :language: lua
    :start-after: Overwrite session_type and remote fields
    :end-at: remote = 'my_remote' })
    :dedent:

If omitted, the ``session_type`` is set to the current session type, ``remote`` is set to the remote peer address.

..  note::

    To avoid confusion with system events, the value of the type field must either be ``message`` (default)
    or begin with the ``custom_`` prefix. Otherwise, you receive the error message.
    Custom events are filtered out by default.

..  _audit-log-custom-severity:

Severity level
~~~~~~~~~~~~~~

By default, custom events have the ``INFO`` :ref:`severity level <audit-log-structure>`.
To override the level, you can:

*   specify the ``severity`` field
*   use a shortcut function

The following shortcuts are available:

..  container:: table

    ..  list-table::
        :widths: 40 60
        :header-rows: 1

        *   -   Shortcut
            -   Equivalent
        *   -   ``audit.verbose(...)``
            -   ``audit.log({severity = 'VERBOSE', ...})``
        *   -   ``audit.info(...)``
            -   ``audit.log({severity = 'INFO', ...})``
        *   -   ``audit.warning(...)``
            -   ``audit.log({severity = 'WARNING', ...})``
        *   -   ``audit.alarm(...)``
            -   ``audit.log({severity = 'ALARM', ...})``

**Example**

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/myapp.lua
    :language: lua
    :start-at: audit.log({ severity
    :end-at: description = 'Hello!' })
    :dedent:

..  _audit-log-tips:

Tips
----

How many events can be recorded?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you write to a file, the size of the Tarantool audit log is limited by the disk space.
If you write to a system logger, the size of the Tarantool audit log is limited by the system logger.
If you write to a pipe, the size of the Tarantool audit message is limited by the system buffer.
If the ``audit_log.nonblock = false``, if ``audit_log.nonblock`` = ``true``, there is no limit.

How often should audit logs be reviewed?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider setting up a schedule in your company. It is recommended to review audit logs at least every 3 months.

How long should audit logs be stored?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is recommended to store audit logs for at least one year.

What is the best way to process audit logs?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is recommended to use SIEM systems for this issue.

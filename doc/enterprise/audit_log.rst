.. _enterprise_audit_module:

Audit module
============

The audit module available in Tarantool Enterprise Edition writes messages that record Tarantool events in plain text,
CSV, or JSON format.

It provides detailed reports of security-related activities and helps you find and
fix breaches to protect your business. For example, you can see who created a new user
and when.

It is up to each company to decide exactly what activities to audit and what actions to take.
System administrators, security engineers, and people in charge of the company may want to
audit different events for different reasons. Tarantool provides such an option for each of them.

.. _audit-log-events:

Audit log events
----------------

The Tarantool audit log module can record various events that you can monitor and
decide whether you need to take actions:

*   Administrator activity -- events related to actions performed by the administrator.
    For example, such logs record the creation of a user.

*   Access events -- events related to authorization and authentication of users.
    For example, such logs record failed attempts to access secure data.

*   Data access and modification -- events of data manipulation in the storage.

*   System events -- events related to modification or configuration of resources.
    For example, such logs record the replacement of a space.

*   :ref:`User-defined events <audit-log-custom>`-- any events added manually using
    the audit module API.

The full list of available audit log events is provided in the table below:

..  container:: table

    ..  list-table::
        :widths: 20 25 20 35
        :header-rows: 1

        *   -   Event
            -   Type of event written to the audit log
            -   Severity level
            -   Example of an event description
        *   -   Audit log enabled for events   
            -   ``audit_enable``
            -   ``VERBOSE``
            -
        *   -   :ref:`User-defined events <audit-log-custom>`
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
----------------------------

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
            -   Example of a log field display
        *   -   ``time``
            -   Time of the event
            -   ``2024-01-15T16:33:12.368+0300``
        *   -   ``uuid``. Since :doc:`3.0.0 </release/3.0.0>`
            -   A unique identifier of audit log event
            -   ``cb44fb2b-5c1f-4c4b-8f93-1dd02a76cec0``
        *   -   ``severity``. Since :doc:`3.0.0 </release/3.0.0>`
            -   A severity level
            -   ``VERBOSE``
        *   -   ``remote``
            -   Remote host that triggered the event
            -   ``unix/:(socket)``
        *   -   ``session_type``
            -   Session type
            -   ``console``
        *   -   ``module``
            -   Audit log module. Set to ``tarantool`` for system events;
                can be overwritten for user-defined events
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

    ..  warning::

        You can set all these parameters only once.

..  _audit-log-event-groups:

Event groups
------------

Built-in event groups are used to filter the event types that you want to audit.
For example, you can set to record only authorization events,
or only events related to a space.

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

.. _audit-log-custom:

Create user-defined events
--------------------------

Tarantool provides an API for writing user-defined audit log events.
To enable custom events, specify the ``custom`` value in the :ref:`audit_log.filter <configuration_reference_audit_filter>` option.

To add a new event, use the ``audit.log()`` function that takes one of the following values:

*   Message string. Printed to the audit log with type ``message``.
    Example: ``audit.log('Hello, World!')``.

*   Format string and arguments. Passed to string format and then output to the audit log with type ``message``.
    Example: ``audit.log('Hello, %s!', 'World')``.

*   Table with audit log field values. The table must contain at least one field -- ``description``.
    Example: ``audit.log({type = 'custom_hello', description = 'Hello, World!'})``.

Using the option ``audit.new()``, you can create a new log module that allows you
to avoid passing all custom audit log fields each time ``audit.log()`` is called.
It takes a table of audit log field values (same as ``audit.log()``). The ``type``
of the log module for writing user-defined events must either be ``message`` or
have the ``custom_`` prefix.

Example
~~~~~~~

..  code-block:: lua

    audit.log({type = 'custom_hello', module = 'my_module', description = 'Hello, Alice!' })
    audit.log({type = 'custom_hello', module = 'my_module', tag = 'admin', description = 'Hello, Bob!'})


Some user-defined audit log fields (``time``, ``remote``, ``session_type``)
are set in the same way as for a system event.
If a field is not overwritten, it is set to the same value as for a system event.

Some audit log fields you can overwrite with ``audit.new()`` and ``audit.log()``:

*   ``type``
*   ``user``
*   ``module``
*   ``tag``
*   ``description``

..  note::

    To avoid confusion with system events, the value of the type field must either be ``message`` (default)
    or begin with the ``custom_`` prefix. Otherwise, you receive the error message.
    User-defined events are filtered out by default..


..  _audit-log-example:

Example: using Tarantool audit log
----------------------------------

The example shows how to enable and configure audit logging and write logs to a selected destination (a file, a pipe,
or a system logger).

Before starting this example:

#.  Install the :ref:`tt <tt-cli>` utility.

#.  Create a tt environment in the current directory by executing the :ref:`tt init <tt-init>` command.

#.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``audit_log`` directory.

#.  Inside ``instances.enabled/audit_log``, create the ``instances.yml`` and ``config.yaml`` files:

    -   ``instances.yml`` specifies instances to run in the current environment and should look like this:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/instances.yml
            :language: yaml
            :end-at: instance001:
            :dedent:

    -   The ``config.yaml`` file stores an audit log configuration (the ``audit_log`` section). The configuration is described in detail in the next section.

..  _audit-log-enable:

Enable audit logging
~~~~~~~~~~~~~~~~~~~~

To enable audit logging, define the log location using the
:ref:`audit_log.to <configuration_reference_audit_to>` option in the ``audit_log`` section of the configuration file.
Possible logs locations:

*   a :ref:`file <audit-log-file>`
*   a :ref:`pipe <audit-log-pipe>`
*   a :ref:`system logger <audit-log-syslog>`

To disable audit logging, set the ``audit_log`` option to ``devnull``.

In this tutorial, the logs are written to a file. To do this, set the
:ref:`audit_log.to <configuration_reference_audit_to>` option to ``file``.
After that, you can define a file path (for example, ``audit_tarantool.log``) using
the :ref:`audit_log.file <configuration_reference_audit_file>` option.
If the option is omitted, the default path is used: ``var/log/instance001/audit.log``.

The configuration might look as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: audit_log:
    :end-at: audit_tarantool.log
    :dedent:

If you log to a file, Tarantool reopens the audit log at `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.

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
    select ``auth`` and ``priv`` to see only events related to authorization and granted privileges.

    ..  code-block:: yaml

        audit_log:
          filter: [ auth,priv ]

-   Filter by group and event. You can specify a group and a certain event depending on the purpose.
    For example, you can select ``user_create``, ``data_operations``, and ``ddl`` to see the events related to

    *   user creation
    *   space creation, altering, and dropping
    *   data modification or selection from spaces

    Let's add this filter to our configuration file:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
        :language: yaml
        :start-at: audit_log:
        :end-at: audit_tarantool.log
        :dedent:


..  _audit-log-format:

Set the format of audit log events
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the :ref:`audit_log.format <configuration_reference_audit_format>` option to choose the format of audit log events
-- plain text, CSV, or JSON.

JSON is used by default. It is more convenient to receive log events, analyze them, and integrate them with other systems if needed.
The plain format can be efficiently compressed.
The CSV format allows you to view audit log events in tabular form.

In this tutorial, set the format to JSON:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :start-at: audit_log:
    :end-at: format: json
    :dedent:

..  _audit-log-spaces:

Specify the spaces to be logged
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since: :doc:`3.0.0 </release/3.0.0>`, it is possible to :ref:`specify a list of space names <configuration_reference_audit_spaces>`
for which data operation events should be logged.

To log the events from the ``bands`` space only, specify the option in the configuration file:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :liines: 15
    :dedent:

..  _audit-log-extract:

Specify the logging mode in DML events
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since: :doc:`3.0.0 </release/3.0.0>`, it is possible to
force the audit subsystem to log the primary key instead of a full tuple in DML operations.

To do so, set the :ref:`audit_log.extract_key <configuration_reference_audit_extract_key>` option to ``true``.

The resulting configuration in ``config.yaml`` now looks as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/audit_log/config.yaml
    :language: yaml
    :dedent:

..  _audit-log-run-example:

Check the example
~~~~~~~~~~~~~~~~~

After the configuration is done, execute the :ref:`tt start <tt-start>` command from the :ref:`tt environment directory <replication-tt-env>`:

    .. code-block:: console

        $ tt start audit_log
           • Starting an instance [audit_log:instance001]...

After that, connect to the instance with :ref:`tt connect <tt-connect>`:

..  code-block:: console

    $ tt connect audit_log:instance001

In the interactive console. run the following commands:


.. _audit-log-read:

Use read commands
-----------------

To easily read the audit log events in the needed form, use the different commands:

*  ``cat`` -- prints one or more files

*  ``grep`` -- prints a specific text

*  ``head`` -- prints the first N lines of the file

*  ``tail`` -- prints the last N lines of the file

    ..  note:: 
        
        These are the basic commands to help you read the logs. If necessary, you can use other commands.

.. _audit-log-tips:

Tips
----

How many events can be recorded?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you write to a file, the size of the Tarantool audit module is limited by the disk space.
If you write to a system logger, the size of the Tarantool audit module is limited by the system logger.
If you write to a pipe, the size of the Tarantool audit module is limited by the system buffer.
If the ``audit_nonblock = false``, if ``audit_nonblock`` = ``true``, there is no limit.
However, it is not recommended to use the entire memory, as this may cause performance degradation
and even loss of some logs.

How often should audit logs be reviewed?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Consider setting up a schedule in your company. It is recommended to review audit logs at least every 3 months.

How long should audit logs be stored?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is recommended to store audit logs for at least one year.

What is the best way to process audit logs?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is recommended to use SIEM systems for this issue.

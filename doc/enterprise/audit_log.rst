.. _enterprise_audit_module:

Audit module
============

The Tarantool audit module available in Tarantool Enterprise writes messages that record Tarantool events in plain text, CSV, or JSON format.

It provides detailed reports of security-related activities and helps you find and
fix breaches to protect your business. For example, you can see who created a new user
and when:

..  code-block:: json

    {
        "time": "2022-04-07T13:39:36.046+0300",
        "remote": "",
        "session_type": "background",
        "module": "tarantool",
        "user": "admin",
        "type": "user_create",
        "tag": "",
        "description": "Create user alice"
    }

It is up to each company to decide exactly what activities to audit and what actions to take.
System administrators, security engineers, and people in charge of the company may want to
audit different events for different reasons. Tarantool provides such an option for each of them.

.. _audit-log-events:

Audit log events
----------------

The Tarantool audit log module can record various events that you can monitor and
decide whether you need to take actions:

*   Admin activity -- events related to actions performed by the administrator.
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
        :widths: 30 35 35
        :header-rows: 1

        *   -   Event
            -   Type of event written to the audit log
            -   Example of an event description
        *   -   Audit log enabled for events   
            -   ``audit_enable``   
            -
        *   -   :ref:`User-defined events <audit-log-custom>`
            -   ``custom``
            -
        *   -   User authorized successfully    
            -   ``auth_ok``   
            -   ``Authenticate user <USER>``
        *   -   User authorization failed    
            -   ``auth_fail``   
            -   ``Failed to authenticate user <USER>``
        *   -   User logged out or quit the session    
            -   ``disconnect``   
            -   ``Close connection``
        *   -   User created
            -   ``user_create``
            -   ``Create user <USER>``
        *   -   User dropped
            -   ``user_drop``
            -   ``Drop user <USER>``
        *   -   Role created
            -   ``role_create``
            -   ``Create role <ROLE>``
        *   -   Role dropped
            -   ``role_drop``
            -   ``Drop role <ROLE>``
        *   -   User disabled    
            -   ``user_disable``   
            -   ``Disable user <USER>``
        *   -   User enabled   
            -   ``user_enable``   
            -   ``Enable user <USER>``
        *   -   User granted rights
            -   ``user_grant_rights``
            -   ``Grant <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> to user <USER>``
        *   -   User revoked rights
            -   ``user_revoke_rights``
            -   ``Revoke <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> from user <USER>``
        *   -   Role granted rights
            -   ``role_grant_rights``
            -   ``Grant <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> to role <ROLE>``
        *   -   Role revoked rights
            -   ``role_revoke_rights``
            -   ``Revoke <PRIVILEGE> rights for <OBJECT_TYPE> <OBJECT_NAME> from role <ROLE>``
        *   -   User password changed
            -   ``password_change``   
            -   ``Change password for user <USER>``
        *   -   Failed attempt to access secure data (personal records, details, geolocation, etc.)
            -   ``access_denied``
            -   ``<ACCESS_TYPE> denied to <OBJECT_TYPE> <OBJECT_NAME>``
        *   -   Expressions with arguments evaluated in a string
            -   ``eval``
            -   ``Evaluate expression <EXPR>``
        *   -   Function called with arguments
            -   ``call``
            -   ``Call function <FUNCTION> with arguments <ARGS>``
        *   -   Iterator key selected from ``space.index``
            -   ``space_select``
            -   ``Select <ITER_TYPE> <KEY> from <SPACE>.<INDEX>``
        *   -   Space created
            -   ``space_create``  
            -   ``Create space <SPACE>``
        *   -   Space altered 
            -   ``space_alter``   
            -   ``Alter space <SPACE>``
        *   -   Space dropped   
            -   ``space_drop``   
            -   ``Drop space <SPACE>``
        *   -   Tuple inserted into space     
            -   ``space_insert``  
            -   ``Insert tuple <TUPLE> into space <SPACE>``
        *   -   Tuple replaced in space   
            -   ``space_replace``   
            -   ``Replace tuple <TUPLE> with <NEW_TUPLE> in space <SPACE>``
        *   -   Tuple deleted from space   
            -   ``space_delete``   
            -   ``Delete tuple <TUPLE> from space <SPACE>``


    ..  note::
    
        The ``eval`` event displays data from the ``console`` module
        and the ``eval`` function of the ``net.box`` module.
        For more on how they work, see :ref:`Module console <console-module>`
        and :ref:`Module net.box -- eval <net_box-eval>`. 
        To separate the data, specify ``console`` or ``binary`` in the session field.

.. _audit-log-event-groups:

Event groups
------------

You can simplify working with audit log events by using built-in event groups.
For example, you can set to record only events related to the enabling of the audit log,
or only events related to a space.

Tarantool provides the following event groups:

*   ``all`` -- all :ref:`events <audit-log-events>`.

    ..  note::

        Events ``call`` and ``eval`` are included only into the ``all`` group.

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
    The more events you record, the slower the requests will be processed over time.
    It is recommended that you select only those groups
    whose events your company really needs to monitor and analyze.

.. _audit-log-structure:

Structure of audit log events
-----------------------------

Each audit log event contains several fields to make it easy to filter and aggregate the resulting logs.
They are described in the following table.

..  container:: table

    ..  list-table::
        :widths: 30 35 35
        :header-rows: 1
        
        *   -   Field
            -   Description
            -   Example of a log field display
        *   -   ``time``   
            -   Time of the event   
            -   2022-04-07T13:20:05.327+0300             
        *   -   ``remote``   
            -   Remote host that triggered the event   
            -   100.96.163.226:48722             
        *   -   ``session_type``   
            -   Session type   
            -   console             
        *   -   ``module``   
            -   Audit log module. Set to ``tarantool`` for system events;
                can be overwritten for user-defined events   
            -   tarantool             
        *   -   ``user``   
            -   User who triggered the event   
            -   admin             
        *   -   ``type`` 
            -   Audit event type   
            -   access_denied            
        *   -   ``tag``   
            -   A text field that can be overwritten by the user   
            -                      
        *   -   ``description``   
            -   Human-readable event description   
            -   Authenticate user Alice                

    ..  warning:: 
    
        You can set all these parameters only once. Unlike many other parameters in ``box.cfg``,
        they cannot be changed.

.. _audit-log-start:

Enable the Tarantool audit log
------------------------------

By default, audit logging is disabled. To enable audit logging,
define the logs location by setting the ``box.cfg.audit_log`` option.
Tarantool can write audit logs to a file, to a pipe, or to the system logger.

To disable audit logging, set the ``audit_log`` option to ``nil``.

Write to a file
~~~~~~~~~~~~~~~

..  code-block:: lua

    box.cfg{audit_log = 'audit_tarantool.log'}
    -- or
    box.cfg{audit_log = 'file:audit_tarantool.log'}

This opens the ``audit_tarantool.log`` file for output in the server’s default directory.
If the ``audit_log`` string has no prefix or the prefix ``file:``, the string is interpreted as a file path.

Send to a pipe
~~~~~~~~~~~~~~

..  code-block:: lua   

    box.cfg{audit_log = '| cronolog audit_tarantool.log'}
    -- or
    box.cfg{audit_log = 'pipe: cronolog audit_tarantool.log'}'
    
This starts the `cronolog <https://linux.die.net/man/1/cronolog>`_ program when the server starts
and sends all ``audit_log`` messages to cronolog's standard input (``stdin``).
If the ``audit_log`` string starts with '|' or contains the prefix ``pipe:``,
the string is interpreted as a Unix `pipeline <https://en.wikipedia.org/wiki/Pipeline_%28Unix%29>`_.

Send to syslog
~~~~~~~~~~~~~~

..  warning::

    Below is an example of writing audit logs to a directory shared with the system logs.
    Tarantool allows this option, but it is not recommended to do this to avoid difficulties
    when working with audit logs. System and audit logs should be written separately.
    To do this, create separate paths and specify them.

This example setting sends the audit log to syslog:

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

If you log to a file, Tarantool will reopen the audit log at `SIGHUP <https://en.wikipedia.org/wiki/SIGHUP>`_.
If log is a program, its pid is stored in the ``audit_log.logger_pid`` variable.
You need to send it a signal to rotate logs.

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

.. _audit-log-filters:

Select events to write to audit log
-----------------------------------

Tarantool's extensive filtering options help you write only the events you need to the audit log.

To select events to write to audit log, use the ``box.cfg.audit_filter`` option.
Its value can be a list of events and event groups.
The default value for the ``box.cfg.audit_filter`` option is ``compatibility``,
which enables logging of all events available before 2.10.0.

..  code-block:: lua

    box.cfg{
            audit_log = 'audit.log',
            audit_filter = 'audit,auth,priv,password_change,access_denied'
           }

.. _audit-log-combinations:

Customize your filters
~~~~~~~~~~~~~~~~~~~~~~

You can customize the filters and use different combinations of filters for your purposes.

Filter based on a specific event
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can set only certain events that you need to record.

For example, select ``password_change`` to monitor the users who have changed their passwords.

..  code-block:: lua

    box.cfg{
            audit_log = 'audit.log',
            audit_filter = 'password_change'
           }

Filter based on a specific group
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can set one of the groups of events that you need to record.

For example, select ``compatibility`` to monitor only events of user authorization,
granted privileges, disconnection, user password change, and denied access.

..  code-block:: lua

    box.cfg{
            audit_log = 'audit.log',
            audit_filter = 'compatibility'
           }

Filter based on multiple groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can specify multiple groups depending on the purpose.

For example, select ``auth`` and ``priv`` to see only events related to authorization and granted privileges.

..  code-block:: lua

    box.cfg{
            audit_log = 'audit.log',
            audit_filter = 'auth,priv'
           }

Filter based on a group and a specific event
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can specify a group and a certain event depending on the purpose.

For example, you can select ``priv`` and ``disconnect`` to see only events related to
granted privileges and disconnect events.

..  code-block:: lua

    box.cfg{
            audit_log = 'audit.log',
            audit_filter = 'priv,disconnect'
           }

Example
~~~~~~~

Run the command to filter:

..  code-block:: lua

    local audit = require('audit')

    box.cfg{audit_log = 'audit.log', audit_filter = 'custom,user_create', audit_format = 'csv'}
    -- The Tarantool audit module writes the event because a filter is set for it
    box.schema.user.create('alice')
    -- The Tarantool audit module will not write the event because no filter is set for it
    box.schema.user.drop('alice')

.. _audit-log-nonblock:

Configure a blocking mode
-------------------------

By default, the ``audit_nonblock`` option is set to ``true``
and Tarantool will not block during logging if the system is not ready to write, dropping the message instead.
Using this value may improve logging performance at the cost of losing some log messages.
This option only has an effect if the output goes to ``syslog:`` or ``pipe:``.
Setting ``audit_nonblock`` to ``true`` is not allowed if the output is to a file.
In this case, set ``audit_nonblock`` to ``false``.   

.. _audit-log-format:

Configure the format of audit log events
----------------------------------------

You can choose the format of audit log events -- plain text, CSV or JSON format. 

Plain text is used by default. This human-readable format can be efficiently compressed.
The JSON format is more convenient to receive log events, analyze them and integrate them with other systems if needed.
Using the CSV format allows you to view audit log events in tabular form.

Use these commands to configure the format of audit log events in Tarantool.

Plain text
~~~~~~~~~~

..  code-block:: lua

    box.cfg{audit_log = 'audit.log', audit_format = 'plain'}

Example:

..  code-block:: text

    remote:
    session_type:background
    module:common.admin.auth
    user: type:custom_tdg_audit
    tag:tdg_severity_INFO
    description:[5e35b406-4274-4903-857b-c80115275940]
    subj: "anonymous",
    msg: "Access granted to anonymous user"

JSON format
~~~~~~~~~~~

..  code-block:: lua

    box.cfg{audit_log = 'audit.log', audit_format = 'json'}

Example:

..  code-block:: json

    {
        "time": "2022-11-17T21:55:49.880+0300",
        "remote": "",
        "session_type": "background",
        "module": "common.admin.auth",
        "user": "",
        "type": "custom_tdg_audit",
        "tag": "tdg_severity_INFO",
        "description": "[c26cd11a-3342-4ce6-8f0b-a4b222268b9d] subj: \"anonymous\", msg: \"Access granted to anonymous user\""
    }

CSV format
~~~~~~~~~~

..  code-block:: lua

    box.cfg{audit_log = 'audit.log', audit_format = 'csv'}

Example:

..  code-block:: text

    2022-11-17T21:58:03.131+0300,,background,common.admin.auth,,,custom_tdg_audit,tdg_severity_INFO,"[b3dfe2a3-ec29-4e61-b747-eb2332c83b2e] subj: ""anonymous"", msg: ""Access granted to anonymous user"""

.. _audit-log-custom:

Create user-defined events
--------------------------

Tarantool provides an API for writing user-defined audit log events.

To add a new event, use the ``audit.log()`` function that takes one of the following values:

*   Message string. Printed to the audit log with type ``message``. Example: ``audit.log('Hello, World!')``.

*   Format string and arguments. Passed to string format and then output to the audit log with type message.
    Example: ``audit.log('Hello, %s!', 'World')``.

*   Table with audit log field values. The table must contain at least one field -- description.
    Example: ``audit.log({type = 'custom_hello', description = 'Hello, World!'})``.

Using the field ``audit.new()``, you can create a new log module that allows you
to avoid passing all custom audit log fields each time ``audit.log()`` is called.
It takes a table of audit log field values (same as ``audit.log()``). The ``type``
of the log module for writing user-defined events must either be ``message`` or
have the ``custom_`` prefix.

Example
~~~~~~~

..  code-block:: lua

    local my_audit = audit.new({type = 'custom_hello', module = 'my_module'})
    my_audit:log('Hello, Alice!')
    my_audit:log({tag = 'admin', description = 'Hello, Bob!'})

    -- is equivalent to
    audit.log({type = 'custom_hello', module = 'my_module',
               description = 'Hello, Alice!' })
    audit.log({type = 'custom_hello', module = 'my_module',
               tag = 'admin', description = 'Hello, Bob!'})


Some user-defined audit log fields (``time``, ``remote``, ``session_type``)
are set in the same way as for a system event.
If a field is not overwritten, it is set to the same value as for a system event.  

Some audit log fields you can overwrite with ``audit.new()`` and ``audit.log()``: 

*   type
*   user
*   module
*   tag
*   description

    ..  note::
        
        To avoid confusion with system events, the value of the type field must either be ``message`` (default)
        or begin with ``custom_``. Otherwise you will get the error message.
        User-defined events are filtered out by default.
        To enable user-defined audit log events, you must add ``custom`` to ``box.cfg.audit_filter``.                                                            

Example
~~~~~~~

..  code-block:: lua

    local audit = require('audit')

    box.cfg{audit_log = 'audit.log', audit_filter = 'custom', audit_format = 'csv'}
    audit.log('Hello, Alice!')
    audit.log('Hello, %s!', 'Bob')
    audit.log({type = 'custom_hello', description = 'Hello, Eve!'})
    audit.log({type = 'custom_farewell', user = 'eve', module = 'custom', description = 'Farewell, Eve!'})

    local my_audit = audit.new({module = 'my_module', tag = 'default'})
    my_audit:log({description = 'Message 1'})
    my_audit:log({description = 'Message 2', tag = 'my_tag'})
    my_audit:log({description = 'Message 3', module = 'other_module'})

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
If you write to a pipe, the size of the Tarantool audit module is limited by the system buffer
if the ``audit_nonblock`` = ``false``; if ``audit_nonblock`` = ``true``, there is no limit.
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

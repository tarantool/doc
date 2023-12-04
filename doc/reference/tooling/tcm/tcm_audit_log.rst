..  _tcm_audit_log:

Audit log
=========

..  admonition:: Enterprise Edition
    :class: fact

    |tcm_full_name| is a part of the `Enterprise Edition <https://www.tarantool.io/compare/>`_.

|tcm_full_name| provides the audit logging functionality for tracking user activity
and security-related events, such as:

*   Successful and failed login attempts.
*   Access to clusters, their configurations, data model, and stored data.
*   Changes in the access control system: users, roles, passwords, LDAP configurations.

The complete list of |tcm| audit events is provided in :ref:`Event types <tcm_audit_log_event_types>`.

.. note::

    |tcm| audit log records only events that happen in |tcm| itself.
    For information about Tarantool audit logging, see :ref:`Audit module <enterprise_audit_module>`.

Audit logging is disabled in |tcm| by default. To start recording events, you need
to :ref:`enable <tcm_audit_log_enable>` and :ref:`configure <tcm_audit_log_config>` it.

The audit log stores event details in the JSON format. Each log entry contains the
event type, description, time, impacted objects, and other information that
may be used for incident investigation. The complete list of fields is provided in
:ref:`Structure of audit log events <tcm_audit_log_structure>`.

In addition to writing audit logs, |tcm| has a built-in interface for reading and
searching them. For details, see :ref:`Viewing audit logs <tcm_audit_log_view>`.

..  _tcm_audit_log_enable:

Enabling audit logging
----------------------

To enable audit logging in |tcm|, go to **Audit settings** and click **Enable**.

To additionally send audit log events to the standard output, click **Send to stdout**.

..  _tcm_audit_log_config:

Audit log configuration
-----------------------

|tcm| audit events can be logged to a local file or sent to a
`syslog <https://datatracker.ietf.org/doc/rfc5424/>`__ server.
To configure audit logging, go to **Audit settings**.

Writing to a file
~~~~~~~~~~~~~~~~~

To write |tcm| audit logs to a file:

1.  Go to **Audit settings** and select the **file** protocol.
2.  Specify the name of the audit log file. The file appears in the |tcm| working directory.
3.  Configure the log files rotation: the maximum file size and age, and the number
    of files to store simultaneously.
4.  (Optional) Enable compression of audit log files.

.. TODO: move to UI reference

Configuration parameters:

-   **Output file name**. The name of the audit log file. Default: ``audit.log``
-   **Max size (in MB)**. The maximum size of the log file before it gets rotated, in megabytes. Default: 100.
-   **Max backups**. The maximum number of stored audit log files. Default: 10.
-   **Max age (in days)**. The maximum age of audit log files in days. Default: 30.
-   **Compress**. Compress audit log files into ``gzip`` archives when rotating.

Sending to syslog
~~~~~~~~~~~~~~~~~

If you use a centralized log management system based on `syslog <https://datatracker.ietf.org/doc/rfc5424/>`__,
you can configure |tcm| to send its audit log to your syslog server:

1.  Go to **Audit settings** and select the **syslog** protocol.
2.  Enter the syslog server URI and select the network protocol. Typically,
    ``syslogd`` listens on port 514 and uses the UDP protocol.
3.  Specify the syslog logging parameters: timeout, priority, and facility.

.. TODO: move to UI reference

Configuration parameters:

-   **Protocol**. The network protocol used for connecting to the syslog server. Default: ``udp``.
-   **Output**. The syslog server URI. Default: 127.0.0.1:514 (localhost).
-   **Timeout**. The syslog write timeout in the `ISO 8601 duration format <https://en.wikipedia.org/wiki/ISO_8601#Durations>`__.
    Default: ``PT2S`` (two seconds).
-   **Priority**. The syslog severity level. Default: ``info``.
-   **Facility**. The syslog facility. Default: ``local0``.

Selecting audit events to record
--------------------------------

When the audit log is enabled, |tcm| records all audit events listed in :ref:`Event types <tcm_audit_log_event_types>`.
To decrease load and make the audit log comply with specific security
requirements, you can record only selected events. For example, these can be events
of user account management or events of cluster data access.

To select events to record into the audit log, go to **Audit settings** and
enter their :ref:`types <tcm_audit_log_event_types>` into the **Filters** field
one-by-one, pressing the **Enter** key after each type.

To remove an event type from a filters list, click the cross icon beside it.

..  _tcm_audit_log_view:

Viewing audit log
-----------------

If the audit log is written to a file, you can view it in |tcm| in the **Audit log** page.
On this page, you can view or search for events.

To view the details of a logged audit event, click the corresponding line in the
table.

To search for an event, use the search bar at the top of the page. Note that the
search is case-sensitive. For example, to find events with the ``ALARM`` severity,
enter ``ALARM``, not ``alarm``.

..  _tcm_audit_log_structure:

Structure of audit log events
-----------------------------

All entries of the |tcm| audit log include the mandatory fields listed in the table below.

..  container:: table

    ..  list-table::
        :widths: 20 40 40
        :header-rows: 1

        *   -   Field
            -   Description
            -   Example
        *   -   ``time``
            -   Time of the event
            -   2023-11-23T12:05:27.099+07:00
        *   -   ``severity``
            -   Event severity: ``VERBOSE``, ``INFO``, ``WARNING``, or ``ALARM``
            -   INFO
        *   -   ``type``
            -   Audit :ref:`event type <tcm_audit_log_event_types>`
            -   user.update
        *   -   ``description``
            -   Human-readable event description
            -   Update user
        *   -   ``uuid``
            -   Event UUID
            -   f8744f51-5760-40c3-ae2d-0b4d6b44836f
        *   -   ``user``
            -   UUID of the user who triggered the event
            -   942a4f54-cf7f-4f46-80ce-3511dbbb57b7
        *   -   ``remote``
            -   Remote host that triggered the event
            -   100.96.163.226:48722
        *   -   ``host``
            -   The |tcm| host on which the event happened
            -   100.96.163.226:8080
        *   -   ``userAgent``
            -   Information about the client application and platform that was used to trigger the event
            -   Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36
        *   -   ``permission``
            -   The permission that was used to trigger the event
            -   ["admin.users.write"]
        *   -   ``result``
            -   Event result: ``ok`` or ``nok``
            -   ok
        *   -   ``err``
            -   Human-readable error description for events with ``nok`` result
            -   failed to login
        *   -   ``fields``
            -   Additional fields for specific event types in the key-value format
            -   Key examples:

                - ``clusterId`` in cluster-related events.
                - ``username`` in ``current.*`` or ``auth.*`` events
                - ``payload`` in events that include sending data to the server

This is an example of an audit log entry on a successful login attempt:

.. code-block:: json

    {
        "time": "2023-11-23T12:01:27.247+07:00",
        "severity": "INFO",
        "description": "Login user",
        "type": "current.login",
        "uuid": "4b9c2dd1-d9a1-4b40-a448-6bef4a0e5c79",
        "user": "",
        "remote": "127.0.0.1:63370",
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
        "host": "127.0.0.1:8080",
        "permissions": [],
        "result": "ok",
        "fields": [
            {
                "Key": "username",
                "Value": "admin"
            },
            {
                "Key": "method",
                "Value": "null"
            },
            {
                "Key": "output",
                "Value": "true"
            }
        ]
    }

..  _tcm_audit_log_event_types:

Event types
-----------

The following table lists all possible values of the ``type`` field of |tcm|
audit log events.

..  container:: table

    ..  list-table::
        :widths: auto
        :header-rows: 1

        *   -   Event type
            -   Description

        *   -   ``auth.fail``
            -   Authentication failed
        *   -   ``auth.ok``
            -   Authentication successful
        *   -   ``access.denied``
            -   An attempt to access an object without the required permission
        *   -   ``user.add``
            -   User added
        *   -   ``user.update``
            -   User updated
        *   -   ``user.delete``
            -   User deleted
        *   -   ``secret.add``
            -   User secret added
        *   -   ``secret.update``
            -   User secret updated
        *   -   ``secret.block``
            -   User secret blocked
        *   -   ``secret.unblock``
            -   User secret unblocked
        *   -   ``secret.delete``
            -   User secret deleted
        *   -   ``secret.expire``
            -   User secret expired
        *   -   ``session.revoke``
            -   Session revoked
        *   -   ``session.revokeuser``
            -   All user's sessions revoked
        *   -   ``explorer.insert``
            -   Data inserted in a cluster
        *   -   ``explorer.delete``
            -   Data deleted from a cluster
        *   -   ``explorer.replace``
            -   Data replaced in a cluster
        *   -   ``explorer.call``
            -   Stored function called on a cluster
        *   -   ``explorer.evaluate``
            -   Code executed on a cluster
        *   -   ``explorer.switchover``
            -   Master switched manually
        *   -   ``test.devmode``
            -   Switched to development mode
        *   -   ``auditlog.config``
            -   Audit log configuration changed
        *   -   ``passwordpolicy.save``
            -   Password policy changed
        *   -   ``passwordpolicy.resetpasswords``
            -   All passwords expired by an administrator
        *   -   ``ddl.save``
            -   Cluster data model saved
        *   -   ``ddl.apply``
            -   Cluster data model applied
        *   -   ``cluster.config.save``
            -   Cluster configuration saved
        *   -   ``cluster.config.reset``
            -   Saved cluster configuration reset
        *   -   ``cluster.config.apply``
            -   Cluster configuration applied
        *   -   ``current.logout``
            -   User logged out their own session
        *   -   ``current.revoke``
            -   User revoked their own session
        *   -   ``current.revokeall``
            -   User revoked all their active sessions
        *   -   ``current.changepassword``
            -   User changed their password
        *   -   ``role.add``
            -   Role added
        *   -   ``role.update``
            -   Role updated
        *   -   ``role.delete``
            -   Role deleted
        *   -   ``cluster.add``
            -   Cluster added
        *   -   ``cluster.update``
            -   Cluster updated
        *   -   ``cluster.delete``
            -   Cluster removed
        *   -   ``ldap.testlogin``
            -   Login test executed for a LDAP configuration
        *   -   ``ldap.testconnection``
            -   Connection test executed for a LDAP configuration
        *   -   ``ldap.add``
            -   LDAP configuration added
        *   -   ``ldap.update``
            -   LDAP configuration updated
        *   -   ``ldap.delete``
            -   LDAP configuration deleted
        *   -   ``addon.enable``
            -   Add-on enabled
        *   -   ``addon.disable``
            -   Add-on disabled
        *   -   ``addon.delete``
            -   Add-on removed
        *   -   ``tcmstate.save``
            -   Low-level information saved in the TCM storage (for debug purposes)
        *   -   ``tcmstate.delete``
            -   Low-level information deleted from the TCM storage (for debug purposes)

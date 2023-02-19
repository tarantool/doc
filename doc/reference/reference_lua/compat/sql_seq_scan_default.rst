.. _compat-option-sql-scan:

Default value for sql_seq_scan session setting
==============================================

The default value for the sql_seq_scan session setting will be set to false starting with Tarantool 3.0.
To be able to return the behavior to the old default, a new compat option is introduced.

Old and new behavior
--------------------

Old behavior - SELECT scan queries are always allowed.

New behavior - SELECT scan queries are only allowed if the SEQSCAN keyword is used correctly.

Note that sql_seq_scan_default compat option only affects sessions during initialization. This means that you should set sql_seq_scan_default before running box.cfg{} or creating a new session. Also, a new session created before executing box.cfg{} will not be affected by the value of the compat option.

Examples of setting the option before execution of box.cfg{}:

..  code-block:: lua

    tarantool> require('compat').sql_seq_scan_default = 'new'
    ---
    ...

    tarantool> box.cfg{log_level = 1}
    ---
    ...

    tarantool> box.space._session_settings:get{'sql_seq_scan'}
    ---
    - ['sql_seq_scan', false]
    ...

..  code-block:: lua

    tarantool> require('compat').sql_seq_scan_default = 'old'
    ---
    ...

    tarantool> box.cfg{log_level = 1}
    ---
    ...

    tarantool> box.space._session_settings:get{'sql_seq_scan'}
    ---
    - ['sql_seq_scan', true]
    ...

Examples of setting the option before creation of a new session after execution of box.cfg{}:

..  code-block:: lua

    tarantool> box.cfg{log_level = 1, listen = 3301}
    ---
    ...

    tarantool> require('compat').sql_seq_scan_default = 'new'
    ---
    ...

    tarantool> cn = require('net.box').connect(box.cfg.listen)
    ---
    ...

    tarantool> cn.space._session_settings:get{'sql_seq_scan'}
    ---
    - ['sql_seq_scan', false]
    ...

    tarantool> require('tarantool').compat.sql_seq_scan_default = 'old'
    ---
    ...

    tarantool> cn = require('net.box').connect(box.cfg.listen)
    ---
    ...

    tarantool> cn.space._session_settings:get{'sql_seq_scan'}
    ---
    - ['sql_seq_scan', true]
    ...


Known compatibility issues
--------------------------

At this point we do not know any incompatible modules.

Detecting issues in you codebase
--------------------------------

We expect most SELECTs that do not use indexes to fail after the sql_seq_scan session setting is set to false. The best way to avoid this is to refactor the query to use indexes. To understand if SELECT uses indexes, you can use EXPLAIN QUERY PLAN. If SEARCH TABLE is specified, the index is used. If it says SCAN TABLE, the index is not used.

You can use the SEQSCAN keyword to manually allow scanning queries. Or you can set the sql_seq_scan session setting to true to allow all scanning queries.

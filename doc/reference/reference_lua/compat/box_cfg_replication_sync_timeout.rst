.. _compat-option-replication-timeout:

Default value for replication_sync_timeout
==========================================

Having a non-zero replication_sync_timeout gives the user a false assumption that box.cfg{replication = ...} call returns only when the configured node is synced with all the others. This is mostly true for big replication_sync_timeout values, but it is not 100% guaranteed. In other words, the user still has to check if the node is synced or the sync just timed out. Besides, while replication_sync_timeout is ticking, you cannot reconfigure box with another box.cfg call, which hardens reconfiguration.

We decided to set replication_sync_timeout to zero by default.

Old and new behavior
--------------------

compat lets you chose between old behavior - box.cfg.replication_sync_timeout is 300 seconds by default - and new behavior - box.cfg.replication_sync_timeout is 0 by default.

It is important to set the desired behavior before the initial box.cfg{} call in order for it to take effect.

..  code-block:: lua

    tarantool> compat.box_cfg_replication_sync_timeout = 'new'
    ---
    ...
    tarantool> box.cfg{}
    ---
    ...
    tarantool> box.cfg.replication_sync_timeout
    ---
    - 0
    ...
    tarantool> compat.box_cfg_replication_sync_timeout = 'old'
    ---
    - error: 'builtin/box/load_cfg.lua:253: The compat  option ''box_cfg_replication_sync_timeout''
        takes effect only before the initial box.cfg() call'
...

A fresh tarantool run:

..  code-block:: lua

    tarantool> compat.box_cfg_replication_sync_timeout = 'old'
    ---
    ...
    tarantool> box.cfg{}
    ---
    ...
    tarantool> box.cfg.replication_sync_timeout
    ---
    - 300
    ...

Known compatibility issues
--------------------------

At this point we do not know any incompatible modules.

Detecting issues in you codebase
--------------------------------

We expect issues with user assuming that the node is not in orphan state (box.info.status ~= "orphan") after box.cfg{replication=...} call returns. This is not true with new behaviour. To simulate old behavior, one may add a box.ctl.wait_rw() call after the box.cfg{} call. box.ctl.wait_rw() returns only when the node becomes writable, and hence is not an orphan.





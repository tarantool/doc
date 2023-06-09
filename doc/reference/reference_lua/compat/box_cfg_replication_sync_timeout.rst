.. _compat-option-replication-timeout:

Default value for replication_sync_timeout
==========================================

Having a non-zero :ref:`replication_sync_timeout <cfg_replication-replication_sync_timeout>` gives a user the false assumption that the ``box.cfg{replication = ...}`` call returns only when the configured node is synced with all the other nodes.
This is mostly true for the big ``replication_sync_timeout`` values, but it is not 100% guaranteed.
In other words, a user still has to check if the node is synced, or the sync just timed out.
Besides, while ``replication_sync_timeout`` is ticking, you cannot reconfigure ``box`` with another ``box.cfg`` call, which hardens reconfiguration.

It is decided to set the ``replication_sync_timeout`` to zero by default.

Old and new behavior
--------------------

The ``compat`` module allows you to choose between

*   the old behavior: ``box.cfg.replication_sync_timeout`` is 300 seconds by default

*   and the new behavior:``box.cfg.replication_sync_timeout`` is 0 by default.

It is important to set the desired behavior before the initial ``box.cfg{}`` call to take effect for it.

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

A fresh Tarantool run:

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

At this point, no incompatible modules are known.

Detecting issues in your codebase
---------------------------------

We expect issues with a user assuming that the node is not in the orphan state (``box.info.status ~= "orphan"``) after the ``box.cfg{replication=...}`` call returns.
This is not true with the new behaviour. To simulate the old behavior, one may add a ``box.ctl.wait_rw()`` call after the ``box.cfg{}`` call.
``box.ctl.wait_rw()`` returns only when the node becomes writable, and hence is not an orphan.

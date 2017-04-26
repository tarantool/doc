.. _admin-os_notes:

================================================================================
Notes for operating systems
================================================================================

.. _admin-os_notes-mac:

--------------------------------------------------------------------------------
Mac OS
--------------------------------------------------------------------------------

On Mac OS, you can administer Tarantool instances only with ``tarantoolctl``.
No native system tools are supported.

.. _admin-os_notes-freebsd:

--------------------------------------------------------------------------------
FreeBSD
--------------------------------------------------------------------------------

To make ``tarantoolctl`` work along with ``init.d`` utilities on FreeBSD, use
paths other than those suggested in
:ref:`Instance configuration <admin-instance_config>`. Instead of 
``/usr/share/tarantool/`` directory, use ``/usr/local/etc/tarantool/`` and
create the following subdirectories:

* ``default`` for ``tarantoolctl`` defaults (see example below),
* ``instances.available`` for all available instance files, and
* ``instances.enabled`` for instance files to be auto-started by sysvinit.

Here is an example of ``tarantoolctl`` defaults on FreeBSD:

.. code-block:: lua

   default_cfg = {
       pid_file   = "/var/run/tarantool", -- /var/run/tarantool/${INSTANCE}.pid
       wal_dir    = "/var/db/tarantool", -- /var/db/tarantool/${INSTANCE}/
       snap_dir   = "/var/db/tarantool", -- /var/db/tarantool/${INSTANCE}
       logger     = "/var/log/tarantool", -- /var/log/tarantool/${INSTANCE}.log
       username   = "tarantool",
   }
   
   -- instances.available - all available instances
   -- instances.enabled - instances to autostart by sysvinit
   instance_dir = "/usr/local/etc/tarantool/instances.available"

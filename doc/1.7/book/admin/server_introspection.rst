.. _admin-server_introspection:

================================================================================
Server introspection
================================================================================

.. _admin-using_tarantool_as_a_client:

--------------------------------------------------------------------------------
Using Tarantool as a client
--------------------------------------------------------------------------------

Tarantool enters the interactive mode if:

* you start Tarantool without an
  :ref:`instance file <admin-instance_file>`, or

* the instance file contains :ref:`console.start() <console-start>`.

Tarantool displays a prompt (e.g. "tarantool>") and you can enter requests.
When used this way, Tarantool can be a client for a remote server.
See basic examples in :ref:`Getting started <getting_started>`.

The interactive mode is used by ``tarantoolctl`` to implement "enter" and
"connect" commands.

.. _admin-executing_code_on_an_instance:

--------------------------------------------------------------------------------
Executing code on an instance
--------------------------------------------------------------------------------

You can attach to an instance's :ref:`admin console <admin-security>` and execute some Lua code using
``tarantoolctl``:

.. code-block:: bash

   $ # for local instances:
   $ tarantoolctl enter my_app
   /bin/tarantoolctl: Found my_app.lua in /etc/tarantool/instances.available
   /bin/tarantoolctl: Connecting to /var/run/tarantool/my_app.control
   /bin/tarantoolctl: connected to unix/:/var/run/tarantool/my_app.control
   unix/:/var/run/tarantool/my_app.control> 1 + 1
   ---
   - 2
   ...
   unix/:/var/run/tarantool/my_app.control>
   
   $ # for local and remote instances:
   $ tarantoolctl connect username:password@127.0.0.1:3306

You can also use ``tarantoolctl`` to execute Lua code on an instance without
attaching to its admin console. For example:

.. code-block:: bash

   # executing commands directly from the command line
   $ <command> | tarantoolctl eval my_app
   <...>
   $ # - OR -
   # executing commands from a script file
   $ tarantoolctl eval my_app script.lua
   <...>

.. NOTE::

   Alternatively, you can use the :ref:`console <console-module>` module or the
   :ref:`net.box <net_box-module>` module from a Tarantool server. Also, you can
   write your client programs with any of the
   :ref:`connectors <index-box_connectors>`. However, most of the examples in
   this manual illustrate usage with either ``tarantoolctl connect`` or
   :ref:`using the Tarantool server as a client <admin-using_tarantool_as_a_client>`.

.. _admin-health_checks:

--------------------------------------------------------------------------------
Health checks
--------------------------------------------------------------------------------

To check the instance status, say:

.. code-block:: bash

   $ tarantoolctl status my_app
   my_app is running (pid: /var/run/tarantool/my_app.pid)
   $ # - OR -
   $ systemctl status tarantool@my_app
   tarantool@my_app.service - Tarantool Database Server
   Loaded: loaded (/etc/systemd/system/tarantool@.service; disabled; vendor preset: disabled)
   Active: active (running)
   Docs: man:tarantool(1)
   Process: 5346 ExecStart=/usr/bin/tarantoolctl start %I (code=exited, status=0/SUCCESS)
   Main PID: 5350 (tarantool)
   Tasks: 11 (limit: 512)
   CGroup: /system.slice/system-tarantool.slice/tarantool@my_app.service
   + 5350 tarantool my_app.lua <running>

To check the boot log, on systems with ``systemd``, say:

.. code-block:: bash

   $ journalctl -u tarantool@my_app -n 5
   -- Logs begin at Fri 2016-01-08 12:21:53 MSK, end at Thu 2016-01-21 21:17:47 MSK. --
   Jan 21 21:17:47 localhost.localdomain systemd[1]: Stopped Tarantool Database Server.
   Jan 21 21:17:47 localhost.localdomain systemd[1]: Starting Tarantool Database Server...
   Jan 21 21:17:47 localhost.localdomain tarantoolctl[5969]: /usr/bin/tarantoolctl: Found my_app.lua in /etc/tarantool/instances.available
   Jan 21 21:17:47 localhost.localdomain tarantoolctl[5969]: /usr/bin/tarantoolctl: Starting instance...
   Jan 21 21:17:47 localhost.localdomain systemd[1]: Started Tarantool Database Server

For more details, use the reports provided by functions in the following submodules:

* :ref:`box.cfg <box_introspection-box_cfg>` submodule (check and specify all
  configuration parameters for the Tarantool server)

* :ref:`box.slab <box_introspection-box_slab>` submodule (monitor the total use
  and fragmentation of memory allocated for storing data in Tarantool)

* :ref:`box.info <box_introspection-box_info>` submodule (introspect Tarantool
  server variables, primarily those related to replication)
  
* :ref:`box.stat <box_introspection-box_stat>` submodule (introspect Tarantool
  request and network statistics)

You can also try `tarantool/prometheus <https://github.com/tarantool/prometheus>`_,
a Lua module that makes it easy to collect metrics (e.g. memory usage or number
of requests) from Tarantool applications and databases and expose them via the
Prometheus protocol.

**Example**

A very popular administrator request is :ref:`box.slab.info() <box_slab_info>`,
which displays detailed memory usage statistics for a Tarantool instance.

.. code-block:: tarantoolsession

   tarantool> box.slab.info()
   ---
   - items_size: 228128
     items_used_ratio: 1.8%
     quota_size: 1073741824
     quota_used_ratio: 0.8%
     arena_used_ratio: 43.2%
     items_used: 4208
     quota_used: 8388608
     arena_size: 2325176
     arena_used: 1003632
   ...

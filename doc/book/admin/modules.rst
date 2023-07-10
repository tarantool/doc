..  _admin-managing_tarantool_modules:

Managing modules
================

This section covers the installation and reloading of Tarantool modules.
To learn about writing your own module and contributing it,
check the :ref:`Contributing a module <app_server-contributing_module>` section.

.. _app_server-installing_module:

Installing a module
-------------------

Modules in Lua and C that come from Tarantool developers and community
contributors are available in the following locations:

* Tarantool modules repository (see :ref:`below <app_server-installing_module_luarocks>`)
* Tarantool deb/rpm repositories (see :ref:`below <app_server-installing_module_debrpm>`)

.. _app_server-installing_module_luarocks:

Installing a module from a repository
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See
`README in tarantool/rocks repository <https://github.com/tarantool/rocks#managing-modules-with-tarantool-174>`_
for detailed instructions.

.. _app_server-installing_module_debrpm:

Installing a module from deb/rpm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Follow these steps:

1. Install Tarantool as recommended on the
   `download page <https://tarantool.io/download.html>`_.

2. Install the module you need. Look up the module's name on
   `Tarantool rocks page <https://tarantool.io/rocks.html>`_ and put the prefix
   "tarantool-" before the module name to avoid ambiguity:

   .. code-block:: console

       $ # for Ubuntu/Debian:
       $ sudo apt-get install tarantool-<module-name>

       $ # for RHEL/CentOS/Amazon:
       $ sudo yum install tarantool-<module-name>

   For example, to install the module
   `vshard <http://github.com/tarantool/vshard>`_ on Ubuntu, say:

   .. code-block:: console

       $ sudo apt-get install tarantool-vshard

Once these steps are complete, you can:

* load any module with

  .. code-block:: tarantoolsession

       tarantool> name = require('module-name')

  for example:

  .. code-block:: tarantoolsession

      tarantool> vshard = require('vshard')

* search locally for installed modules using ``package.path`` (Lua) or
  ``package.cpath`` (C):

  .. code-block:: tarantoolsession

      tarantool> package.path
      ---
      - ./?.lua;./?/init.lua; /usr/local/share/tarantool/?.lua;/usr/local/share/
      tarantool/?/init.lua;/usr/share/tarantool/?.lua;/usr/share/tarantool/?/ini
      t.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/
      usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;
      ...

      tarantool> package.cpath
      ---
      - ./?.so;/usr/local/lib/x86_64-linux-gnu/tarantool/?.so;/usr/lib/x86_64-li
      nux-gnu/tarantool/?.so;/usr/local/lib/tarantool/?.so;/usr/local/lib/x86_64
      -linux-gnu/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/local/
      lib/lua/5.1/?.so;
      ...

  .. NOTE::

      Question-marks stand for the module name that was specified earlier when
      saying ``require('module-name')``.

.. _app_server-reloading_module:

Reloading a module
------------------

You can reload any Tarantool application or module with zero downtime.

.. _app_server-reloading_lua_module:

Reloading a module in Lua
~~~~~~~~~~~~~~~~~~~~~~~~~

Here's an example that illustrates the most typical case -- "update and reload".

.. NOTE::

    In this example, we use recommended :ref:`administration practices <admin>`
    based on :ref:`instance files <admin-instance_file>` and
    :ref:`tarantoolctl <tarantoolctl>` utility.

1. Update the application file.

   For example, a module in ``/usr/share/tarantool/app.lua``:

   .. code-block:: lua

       local function start()
         -- initial version
         box.once("myapp:v1.0", function()
           box.schema.space.create("somedata")
           box.space.somedata:create_index("primary")
           ...
         end)

         -- migration code from 1.0 to 1.1
         box.once("myapp:v1.1", function()
           box.space.somedata.index.primary:alter(...)
           ...
         end)

         -- migration code from 1.1 to 1.2
         box.once("myapp:v1.2", function()
           box.space.somedata.index.primary:alter(...)
           box.space.somedata:insert(...)
           ...
         end)
       end

       -- start some background fibers if you need

       local function stop()
         -- stop all background fibers and clean up resources
       end

       local function api_for_call(xxx)
         -- do some business
       end

       return {
         start = start,
         stop = stop,
         api_for_call = api_for_call
       }

2. Update the :ref:`instance file <admin-instance_file>`.

   For example, ``/etc/tarantool/instances.enabled/my_app.lua``:

   .. code-block:: lua

       #!/usr/bin/env tarantool
       --
       -- hot code reload example
       --

       box.cfg({listen = 3302})

       -- ATTENTION: unload it all properly!
       local app = package.loaded['app']
       if app ~= nil then
         -- stop the old application version
         app.stop()
         -- unload the application
         package.loaded['app'] = nil
         -- unload all dependencies
         package.loaded['somedep'] = nil
       end

       -- load the application
       log.info('require app')
       app = require('app')

       -- start the application
       app.start({some app options controlled by sysadmins})

   The important thing here is to properly unload the application and its
   dependencies.

3. Manually reload the application file.

   For example, using ``tarantoolctl``:

   .. code-block:: console

       $ tarantoolctl eval my_app /etc/tarantool/instances.enabled/my_app.lua

.. _app_server-reloading_c_module:

Reloading a module in C
~~~~~~~~~~~~~~~~~~~~~~~

After you compiled a new version of a C module (``*.so`` shared library), call
:doc:`box.schema.func.reload('module-name') </reference/reference_lua/box_schema/func_reload>`
from your Lua script to reload the module.


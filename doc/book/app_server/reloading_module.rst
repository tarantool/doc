.. _app_server-reloading_module:

================================================================================
Reloading a module
================================================================================

You can reload any Tarantool application or module with zero downtime.

.. _app_server-reloading_lua_module:

--------------------------------------------------------------------------------
Reloading a module in Lua
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
Reloading a module in C
--------------------------------------------------------------------------------

After you compiled a new version of a C module (``*.so`` shared library), call
:ref:`box.schema.func.reload('module-name') <box_schema-func_reload>`
from your Lua script to reload the module.

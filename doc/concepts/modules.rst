..  _concepts-modules:

Modules
=======

Any logic that is used in Tarantool can be packaged as an application or a reusable **module**.
A module is an optional library that extends Tarantool functionality.
It can be used by Tarantool applications or other modules.
Modules allow for easier code management and hot code reload without restarting the Tarantool instance.
Like applications, modules in Tarantool can be written in Lua,
C, or C++. Lua modules are also referred to as "rocks".

For example, here is a Lua module named ``mymodule.lua`` that exports
one function named ``myfun``:

.. code-block:: lua

   local exports = {}
   exports.myfun = function(input_string)
      print('Hello', input_string)
   end
   return exports

To launch the function ``myfun()`` -- from another module, from a Lua application,
or from Tarantool itself, -- save this module as a file, then load
this module with the ``require()`` directive and call the exported function.

For example, here's a Lua application that uses ``myfun()`` from
``mymodule.lua``:

.. code-block:: lua

   -- loading the module
   local mymodule = require('mymodule')

   -- calling myfun() from within test()
   local test = function()
     mymodule.myfun()
   end

Tarantool provides an `extensive library <https://www.tarantool.io/en/download/rocks>`_ of compatible modules.
Install them using Tarantool's CLI utility :ref:`tt <tt-cli>`.
Some modules are also included in the Tarantool repository and can be installed
via your operating system's package manager.

Learn how to:

*   :ref:`install a module <app_server-installing_module>`
*   :ref:`contribute a module <app_server-contributing_module>`

.. _app_server-modules:

Modules, rocks and applications
-------------------------------

To make our game logic available to other developers and Lua applications, let's
put it into a Lua module.

A **module** (called "rock" in Lua) is an optional library which enhances
Tarantool functionality. So, we can install our logic as a module in Tarantool
and use it from any Tarantool application or module. Like applications, modules
in Tarantool can be written in Lua (rocks), C or C++.

Modules are good for two things:

* easier **code management** (reuse, packaging, versioning), and
* hot **code reload** without restarting the Tarantool instance.

Technically, a module is a file with source code that exports its functions in
an API. For example, here is a Lua module named ``mymodule.lua`` that exports
one function named ``myfun``:

.. code-block:: lua

   local exports = {}
   exports.myfun = function(input_string)
      print('Hello', input_string)
   end
   return exports

To launch the function ``myfun()`` -- from another module, from a Lua application,
or from Tarantool itself, -- we need to save this module as a file, then load
this module with the ``require()`` directive and call the exported function.

For example, here's a Lua application that uses ``myfun()`` function from
``mymodule.lua`` module:

.. code-block:: lua

   -- loading the module
   local mymodule = require('mymodule')

   -- calling myfun() from within test() function
   local test = function()
     mymodule.myfun()
   end

A thing to remember here is that the ``require()`` directive takes load paths
to Lua modules from the ``package.path`` variable. This is a semicolon-separated
string, where a question mark is used to interpolate the module name. By default,
this variable contains system-wide Lua paths and the working directory.
But if we put our modules inside a specific folder (e.g. ``scripts/``), we need
to add this folder to ``package.path`` before any calls to ``require()``:

.. code-block:: lua

   package.path = 'scripts/?.lua;' .. package.path

For our microservice, a simple and convenient solution would be to put all
methods in a Lua module (say ``pokemon.lua``) and to write a Lua application
(say ``game.lua``) that initializes the gaming environment and starts the game
loop.

.. image:: aster.svg
    :align: center

Now let's get down to implementation details. In our game, we need three entities:

* **map**, which is an array of pokémons with coordinates of respawn locations;
  in this version of the game, let a location be a rectangle identified with two
  points, upper-left and lower-right;
* **player**, which has an ID, a name, and coordinates of the player's location
  point;
* **pokémon**, which has the same fields as the player, plus a status
  (active/inactive, that is present on the map or not) and a catch probability
  (well, let's give our pokémons a chance to escape :-) )

We'll store these entities as tuples in Tarantool spaces. But to deliver our
backend application as a microservice, the good practice would be to send/receive
our data in the universal JSON format, thus using Tarantool as a document storage.
.. _app_server-avro_schemas:

Avro schemas
------------

To store JSON data as tuples, we will apply a savvy practice which reduces data
footprint and ensures all stored documents are valid. We will use Tarantool
module `avro-schema <https://github.com/tarantool/avro-schema>`_ which checks
the schema of a JSON document and converts it to a Tarantool tuple. The tuple
will contain only field values, and thus take a lot less space than the original
document. In avro-schema terms, converting JSON documents to tuples is
"flattening", and restoring the original documents is "unflattening".

First you need to
`install <https://www.tarantool.io/en/doc/1.10/book/app_server/installing_module/>`_
the module with ``tarantoolctl rocks install avro-schema``.

Further usage is quite straightforward:

(1) For each entity, we need to define a schema in
    `Apache Avro schema <https://en.wikipedia.org/wiki/Apache_Avro>`_ syntax,
    where we list the entity's fields with their names and
    `Avro data types <http://avro.apache.org/docs/current/spec.html#schema_primitive>`_.
(2) At initialization, we call ``avro-schema.create()`` that creates objects
    in memory for all schema entities, and ``compile()`` that generates
    flatten/unflatten methods for each entity.
(3) Further on, we just call flatten/unflatten methods for a respective entity
    on receiving/sending the entity's data.

Here's what our schema definitions for the player and pokémon entities look like:

.. code-block:: lua

   local schema = {
       player = {
           type="record",
           name="player_schema",
           fields={
               {name="id", type="long"},
               {name="name", type="string"},
               {
                   name="location",
                   type= {
                       type="record",
                       name="player_location",
                       fields={
                           {name="x", type="double"},
                           {name="y", type="double"}
                       }
                   }
               }
           }
       },
       pokemon = {
           type="record",
           name="pokemon_schema",
           fields={
               {name="id", type="long"},
               {name="status", type="string"},
               {name="name", type="string"},
               {name="chance", type="double"},
               {
                   name="location",
                   type= {
                       type="record",
                       name="pokemon_location",
                       fields={
                           {name="x", type="double"},
                           {name="y", type="double"}
                       }
                   }
               }
           }
       }
   }

And here's how we create and compile our entities at initialization:

.. code-block:: lua

   -- load avro-schema module with require()
   local avro = require('avro_schema')

   -- create models
   local ok_m, pokemon = avro.create(schema.pokemon)
   local ok_p, player = avro.create(schema.player)
   if ok_m and ok_p then
       -- compile models
       local ok_cm, compiled_pokemon = avro.compile(pokemon)
       local ok_cp, compiled_player = avro.compile(player)
       if ok_cm and ok_cp then
           -- start the game
           <...>
       else
           log.error('Schema compilation failed')
       end
   else
       log.info('Schema creation failed')
   end
   return false

As for the map entity, it would be an overkill to introduce a schema for it,
because we have only one map in the game, it has very few fields, and -- which
is most important -- we use the map only inside our logic, never exposing it
to external users.

.. image:: aster.svg
    :align: center

Next, we need methods to implement the game logic. To simulate object-oriented
programming in our Lua code, let's store all Lua functions and shared variables
in a single local variable (let's name it as ``game``). This will allow us to
address functions or variables from within our module as ``self.func_name`` or
``self.var_name``. Like this:

.. code-block:: lua

   local game = {
       -- a local variable
       num_players = 0,

       -- a method that prints a local variable
       hello = function(self)
         print('Hello! Your player number is ' .. self.num_players .. '.')
       end,

       -- a method that calls another method and returns a local variable
       sign_in = function(self)
         self.num_players = self.num_players + 1
         self:hello()
         return self.num_players
       end
   }

In OOP terms, we can now regard local variables inside ``game`` as object fields,
and local functions as object methods.

.. NOTE::

   In this manual, Lua examples use **local** variables. Use **global**
   variables with caution, since the module’s users may be unaware of them.

   To enable/disable the use of undeclared global variables in your Lua code,
   use Tarantool's :ref:`strict <strict-module>` module.

So, our game module will have the following methods:

* ``catch()`` to calculate whether the pokémon was caught (besides the
  coordinates of both the player and pokémon, this method will apply
  a probability factor, so not every pokémon within the player's reach
  will be caught);
* ``respawn()`` to add missing pokémons to the map, say, every 60 seconds
  (we assume that a frightened pokémon runs away, so we remove a pokémon from
  the map on any catch attempt and add it back to the map in a while);
* ``notify()`` to log information about caught pokémons (like
  "Player 1 caught pokémon A");
* ``start()`` to initialize the game (it will create database spaces, create
  and compile avro schemas, and launch ``respawn()``).

Besides, it would be convenient to have methods for working with Tarantool
storage. For example:

* ``add_pokemon()`` to add a pokémon to the database, and
* ``map()`` to populate the map with all pokémons stored in Tarantool.

We'll need these two methods primarily when initializing our game, but we can
also call them later, for example to test our code.
.. _app_server-creating_app:

================================================================================
Creating an application
================================================================================

Further we walk you through key programming practices that will give you a good
start in writing Lua applications for Tarantool. For an adventure, this is a
story of implementing... a real microservice based on Tarantool! We implement
a backend for a simplified version of
`Pokémon Go <https://en.wikipedia.org/wiki/Pokémon_Go>`_,
a location-based augmented reality game released in mid-2016. In this game,
players use a mobile device's GPS capability to locate, capture, battle and
train virtual monsters called "pokémon", who appear on the screen as if they
were in the same real-world location as the player.

To stay within the walk-through format, let's narrow the original gameplay as
follows. We have a map with pokémon spawn locations. Next, we have multiple
players who can send catch-a-pokémon requests to the server (which runs our
Tarantool microservice). The server replies whether the pokémon is caught or not,
increases the player's pokémon counter if yes, and triggers the
respawn-a-pokémon method that spawns a new pokémon at the same location
in a while.

We leave client-side applications outside the scope of this story. Yet we
promise a mini-demo in the end to simulate real users and give us some fun. :-)

.. image:: aster.svg
    :align: center

First, what would be the best way to deliver our microservice?

.. _app_server-modules:

--------------------------------------------------------------------------------
Modules, rocks and applications
--------------------------------------------------------------------------------

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

.. _app_server-avro_schemas:

--------------------------------------------------------------------------------
Avro schemas
--------------------------------------------------------------------------------

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

.. _app_server-db_bootstrap:

--------------------------------------------------------------------------------
Bootstrapping a database
--------------------------------------------------------------------------------

Let's discuss game initialization. In ``start()`` method, we need to populate
Tarantool spaces with pokémon data. Why not keep all game data in memory?
Why use a database? The answer is: :ref:`persistence <index-box_persistence>`.
Without a database, we risk losing data on power outage, for example.
But if we store our data in an in-memory database, Tarantool takes care to
persist it on disk whenever it's changed. This gives us one more benefit:
quick startup in case of failure.
Tarantool has a :ref:`smart algorithm <internals-recovery_process>` that quickly
loads all data from disk into memory on startup, so the warm-up takes little time.

We'll be using functions from Tarantool built-in :ref:`box <box-module>` module:

* ``box.schema.create_space('pokemons')`` to create a space named ``pokemon`` for
  storing information about pokémons (we don't create a similar space for players,
  because we intend to only send/receive player information via API calls, so we
  needn't store it);
* ``box.space.pokemons:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})``
  to create a primary HASH index by pokémon ID;
* ``box.space.pokemons:create_index('status', {type = 'tree', parts = {2, 'str'}})``
  to create a secondary TREE index by pokémon status.

Notice the ``parts =`` argument in the index specification. The pokémon ID is
the first field in a Tarantool tuple since it’s the first member of the respective
Avro type. So does the pokémon status. The actual JSON document may have ID or
status fields at any position of the JSON map.

The implementation of ``start()`` method looks like this:

.. code-block:: lua

   -- create game object
   start = function(self)
       -- create spaces and indexes
       box.once('init', function()
           box.schema.create_space('pokemons')
           box.space.pokemons:create_index(
               "primary", {type = 'hash', parts = {1, 'unsigned'}}
           )
           box.space.pokemons:create_index(
               "status", {type = "tree", parts = {2, 'str'}}
           )
       end)

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
   end

.. _app_server-gis:

--------------------------------------------------------------------------------
GIS
--------------------------------------------------------------------------------

Now let's discuss ``catch()``, which is the main method in our gaming logic.

Here we receive the player's coordinates and the target pokémon's ID number,
and we need to answer whether the player has actually caught the pokémon or not
(remember that each pokémon has a chance to escape).

First thing, we validate the received player data against its
:ref:`Avro schema <app_server-avro_schemas>`. And we check whether such a pokémon
exists in our database and is displayed on the map (the pokémon must have the
active status):

.. code-block:: lua

   catch = function(self, pokemon_id, player)
       -- check player data
       local ok, tuple = self.player_model.flatten(player)
       if not ok then
           return false
       end
       -- get pokemon data
       local p_tuple = box.space.pokemons:get(pokemon_id)
       if p_tuple == nil then
           return false
       end
       local ok, pokemon = self.pokemon_model.unflatten(p_tuple)
       if not ok then
           return false
       end
       if pokemon.status ~= self.state.ACTIVE then
           return false
       end
       -- more catch logic to follow
       <...>
   end

Next, we calculate the answer: caught or not.

To work with geographical coordinates, we use Tarantool
`gis <https://github.com/tarantool/gis>`_ module.

To keep things simple, we don't load any specific map, assuming that we deal with
a world map. And we do not validate incoming coordinates, assuming again that all
received locations are within the planet Earth.

We use two geo-specific variables:

* ``wgs84``, which stands for the latest revision of the World Geodetic System
  standard, `WGS84 <https://en.wikipedia.org/wiki/World_Geodetic_System#WGS84>`_.
  Basically, it comprises a standard coordinate system for the Earth and
  represents the Earth as an ellipsoid.
* ``nationalmap``, which stands for the
  `US National Atlas Equal Area <https://epsg.io/2163>`_. This is a projected
  coordinates system based on WGS84. It gives us a zero base for location
  projection and allows positioning our players and pokémons in meters.

Both these systems are listed in the EPSG Geodetic Parameter Registry, where each
system has a unique number. In our code, we assign these listing numbers to
respective variables:

.. code-block:: lua

   wgs84 = 4326,
   nationalmap = 2163,

For our game logic, we need one more variable, ``catch_distance``, which defines
how close a player must get to a pokémon before trying to catch it. Let's set
the distance to 100 meters.

.. code-block:: lua

   catch_distance = 100,

Now we're ready to calculate the answer. We need to project the current location
of both player (``p_pos``) and pokémon (``m_pos``) on the map, check whether the
player is close enough to the pokémon (using ``catch_distance``), and calculate
whether the player has caught the pokémon (here we generate some random value and
let the pokémon escape if the random value happens to be less than 100 minus
pokémon's chance value):

.. code-block:: lua

   -- project locations
   local m_pos = gis.Point(
       {pokemon.location.x, pokemon.location.y}, self.wgs84
   ):transform(self.nationalmap)
   local p_pos = gis.Point(
       {player.location.x, player.location.y}, self.wgs84
   ):transform(self.nationalmap)

   -- check catch distance condition
   if p_pos:distance(m_pos) > self.catch_distance then
       return false
   end
   -- try to catch pokemon
   local caught = math.random(100) >= 100 - pokemon.chance
   if caught then
       -- update and notify on success
       box.space.pokemons:update(
           pokemon_id, {{'=', self.STATUS, self.state.CAUGHT}}
       )
       self:notify(player, pokemon)
   end
   return caught

.. _app_server-index_iterators:

--------------------------------------------------------------------------------
Index iterators
--------------------------------------------------------------------------------

By our gameplay, all caught pokémons are returned back to the map. We do this
for all pokémons on the map every 60 seconds using ``respawn()`` method.
We iterate through pokémons by status using Tarantool index iterator function
:ref:`index:pairs <box_index-index_pairs>` and reset the statuses of all
"caught" pokémons back to "active" using ``box.space.pokemons:update()``.

.. code-block:: lua

   respawn = function(self)
       fiber.name('Respawn fiber')
       for _, tuple in box.space.pokemons.index.status:pairs(
              self.state.CAUGHT) do
           box.space.pokemons:update(
               tuple[self.ID],
               {{'=', self.STATUS, self.state.ACTIVE}}
           )
       end
    end

For readability, we introduce named fields:

   ID = 1,
   STATUS = 2,

The complete implementation of ``start()`` now looks like this:

.. code-block:: lua

   -- create game object
   start = function(self)
       -- create spaces and indexes
       box.once('init', function()
          box.schema.create_space('pokemons')
          box.space.pokemons:create_index(
              "primary", {type = 'hash', parts = {1, 'unsigned'}}
          )
          box.space.pokemons:create_index(
              "status", {type = "tree", parts = {2, 'str'}}
          )
       end)

       -- create models
       local ok_m, pokemon = avro.create(schema.pokemon)
       local ok_p, player = avro.create(schema.player)
       if ok_m and ok_p then
           -- compile models
           local ok_cm, compiled_pokemon = avro.compile(pokemon)
           local ok_cp, compiled_player = avro.compile(player)
           if ok_cm and ok_cp then
               -- start the game
               self.pokemon_model = compiled_pokemon
               self.player_model = compiled_player
               self.respawn()
               log.info('Started')
               return true
            else
               log.error('Schema compilation failed')
            end
       else
           log.info('Schema creation failed')
       end
       return false
   end

--------------------------------------------------------------------------------
Fibers
--------------------------------------------------------------------------------

But wait! If we launch it as shown above -- ``self.respawn()`` -- the function
will be executed only once, just like all the other methods. But we need to
execute ``respawn()`` every 60 seconds. Creating a :ref:`fiber <fiber-module>`
is the Tarantool way of making application logic work in the background at all
times.

A **fiber** exists for executing instruction sequences but it is not a thread.
The key difference is that threads use
preemptive multitasking, while fibers use cooperative multitasking. This gives
fibers the following two advantages over threads:

* Better controllability. Threads often depend on the kernel's thread scheduler
  to preempt a busy thread and resume another thread, so preemption may occur
  unpredictably. Fibers yield themselves to run another fiber while executing,
  so yields are controlled by application logic.
* Higher performance. Threads require more resources to preempt as they need to
  address the system kernel. Fibers are lighter and faster as they don't need to
  address the kernel to yield.

Yet fibers have some limitations as compared with threads, the main limitation
being no multi-core mode. All fibers in an application belong to a single thread,
so they all use the same CPU core as the parent thread. Meanwhile, this
limitation is not really serious for Tarantool applications, because a typical
bottleneck for Tarantool is the HDD, not the CPU.

A fiber has all the features of a Lua
`coroutine <http://www.lua.org/pil/contents.html#9>`_ and all programming
concepts that apply for Lua coroutines will apply for fibers as well. However,
Tarantool has made some enhancements for fibers and has used fibers internally.
So, although use of coroutines is possible and supported, use of fibers is
recommended.

Well, performance or controllability are of little importance in our case. We'll
launch ``respawn()`` in a fiber to make it work in the background all the time.
To do so, we'll need to amend ``respawn()``:

.. code-block:: lua

   respawn = function(self)
       -- let's give our fiber a name;
       -- this will produce neat output in fiber.info()
       fiber.name('Respawn fiber')
       while true do
           for _, tuple in box.space.pokemons.index.status:pairs(
                   self.state.CAUGHT) do
               box.space.pokemons:update(
                   tuple[self.ID],
                   {{'=', self.STATUS, self.state.ACTIVE}}
               )
           end
           fiber.sleep(self.respawn_time)
       end
   end

and call it as a fiber in ``start()``:

.. code-block:: lua

    start = function(self)
        -- create spaces and indexes
            <...>
        -- create models
            <...>
        -- compile models
            <...>
        -- start the game
           self.pokemon_model = compiled_pokemon
           self.player_model = compiled_player
           fiber.create(self.respawn, self)
           log.info('Started')
        -- errors if schema creation or compilation fails
           <...>
    end

--------------------------------------------------------------------------------
Logging
--------------------------------------------------------------------------------

One more helpful function that we used in ``start()`` was ``log.infо()`` from
Tarantool :ref:`log <log-module>` module. We also need this function in
``notify()`` to add a record to the log file on every successful catch:

.. code-block:: lua

   -- event notification
   notify = function(self, player, pokemon)
       log.info("Player '%s' caught '%s'", player.name, pokemon.name)
   end

We use default Tarantool :ref:`log settings <cfg_logging>`, so we'll see the log
output in console when we launch our application in script mode.

.. image:: aster.svg
    :align: center

Great! We've discussed all programming practices used in our Lua module (see
`pokemon.lua <https://github.com/tarantool/pokemon/blob/1.9/src/pokemon.lua>`_).

Now let's prepare the test environment. As planned, we write a Lua application
(see `game.lua <https://github.com/tarantool/pokemon/blob/1.9/game.lua>`_) to
initialize Tarantool's database module, initialize our game, call the game loop
and simulate a couple of player requests.

To launch our microservice, we put both ``pokemon.lua`` module and ``game.lua``
application in the current directory, install all external modules, and launch
the Tarantool instance running our ``game.lua`` application (this example is for
Ubuntu):

.. code-block:: console

   $ ls
   game.lua  pokemon.lua
   $ sudo apt-get install tarantool-gis
   $ sudo apt-get install tarantool-avro-schema
   $ tarantool game.lua

Tarantool starts and initializes the database. Then Tarantool executes the demo
logic from ``game.lua``: adds a pokémon named Pikachu (its chance to be caught
is very high, 99.1), displays the current map (it contains one active pokémon,
Pikachu) and processes catch requests from two players. Player1 is located just
near the lonely Pikachu pokémon and Player2 is located far away from it.
As expected, the catch results in this output are "true" for Player1 and "false"
for Player2. Finally, Tarantool displays the current map which is empty, because
Pikachu is caught and temporarily inactive:

.. code-block:: console

   $ tarantool game.lua
   2017-01-09 20:19:24.605 [6282] main/101/game.lua C> version 1.7.3-43-gf5fa1e1
   2017-01-09 20:19:24.605 [6282] main/101/game.lua C> log level 5
   2017-01-09 20:19:24.605 [6282] main/101/game.lua I> mapping 1073741824 bytes for tuple arena...
   2017-01-09 20:19:24.609 [6282] main/101/game.lua I> initializing an empty data directory
   2017-01-09 20:19:24.634 [6282] snapshot/101/main I> saving snapshot `./00000000000000000000.snap.inprogress'
   2017-01-09 20:19:24.635 [6282] snapshot/101/main I> done
   2017-01-09 20:19:24.641 [6282] main/101/game.lua I> ready to accept requests
   2017-01-09 20:19:24.786 [6282] main/101/game.lua I> Started
   ---
   - {'id': 1, 'status': 'active', 'location': {'y': 2, 'x': 1}, 'name': 'Pikachu', 'chance': 99.1}
   ...

   2017-01-09 20:19:24.789 [6282] main/101/game.lua I> Player 'Player1' caught 'Pikachu'
   true
   false
   --- []
   ...

   2017-01-09 20:19:24.789 [6282] main C> entering the event loop

--------------------------------------------------------------------------------
nginx
--------------------------------------------------------------------------------

In the real life, this microservice would work over HTTP. Let's add
`nginx <https://nginx.org/en/>`_ web server to our environment and make a similar
demo. But how do we make Tarantool methods callable via REST API? We use nginx
with `Tarantool nginx upstream <https://github.com/tarantool/nginx_upstream_module>`_
module and create one more Lua script
(`app.lua <https://github.com/tarantool/pokemon/blob/1.9/src/app.lua>`_) that
exports three of our game methods -- ``add_pokemon()``, ``map()`` and ``catch()``
-- as REST endpoints of the nginx upstream module:

.. code-block:: lua

   local game = require('pokemon')
   box.cfg{listen=3301}
   game:start()

   -- add, map and catch functions exposed to REST API
   function add(request, pokemon)
       return {
           result=game:add_pokemon(pokemon)
       }
   end

   function map(request)
       return {
           map=game:map()
       }
   end

   function catch(request, pid, player)
       local id = tonumber(pid)
       if id == nil then
           return {result=false}
       end
       return {
           result=game:catch(id, player)
       }
   end

An easy way to configure and launch nginx would be to create a Docker container
based on a `Docker image <https://hub.docker.com/r/tarantool/tarantool-nginx/>`_
with nginx and the upstream module already installed (see
`http/Dockerfile <https://github.com/tarantool/pokemon/blob/1.9/http/Dockerfile>`_).
We take a standard
`nginx.conf <https://github.com/tarantool/pokemon/blob/1.9/http/nginx.conf>`_,
where we define an upstream with our Tarantool backend running (this is another
Docker container, see details below):

.. code-block:: nginx

   upstream tnt {
         server pserver:3301 max_fails=1 fail_timeout=60s;
         keepalive 250000;
   }

and add some Tarantool-specific parameters (see descriptions in the upstream
module's `README <https://github.com/tarantool/nginx_upstream_module#directives>`_
file):

.. code-block:: nginx

   server {
     server_name tnt_test;

     listen 80 default deferred reuseport so_keepalive=on backlog=65535;

     location = / {
         root /usr/local/nginx/html;
     }

     location /api {
       # answers check infinity timeout
       tnt_read_timeout 60m;
       if ( $request_method = GET ) {
          tnt_method "map";
       }
       tnt_http_rest_methods get;
       tnt_http_methods all;
       tnt_multireturn_skip_count 2;
       tnt_pure_result on;
       tnt_pass_http_request on parse_args;
       tnt_pass tnt;
     }
   }

Likewise, we put Tarantool server and all our game logic in a second Docker
container based on the
`official Tarantool 1.9 image <https://github.com/tarantool/docker>`_ (see
`src/Dockerfile <https://github.com/tarantool/pokemon/blob/1.9/src/Dockerfile>`_)
and set the container's default command to ``tarantool app.lua``.
This is the backend.

--------------------------------------------------------------------------------
Non-blocking IO
--------------------------------------------------------------------------------

To test the REST API, we create a new script
(`client.lua <https://github.com/tarantool/pokemon/blob/1.9/client/client.lua>`_),
which is similar to our ``game.lua`` application, but makes HTTP POST and GET
requests rather than calling Lua functions:

.. code-block:: lua

   local http = require('curl').http()
   local json = require('json')
   local URI = os.getenv('SERVER_URI')
   local fiber = require('fiber')

   local player1 = {
       name="Player1",
       id=1,
       location = {
           x=1.0001,
           y=2.0003
       }
   }
   local player2 = {
       name="Player2",
       id=2,
       location = {
           x=30.123,
           y=40.456
       }
   }

   local pokemon = {
       name="Pikachu",
       chance=99.1,
       id=1,
       status="active",
       location = {
           x=1,
           y=2
       }
   }

   function request(method, body, id)
       local resp = http:request(
           method, URI, body
       )
       if id ~= nil then
           print(string.format('Player %d result: %s',
               id, resp.body))
       else
           print(resp.body)
       end
   end

   local players = {}
   function catch(player)
       fiber.sleep(math.random(5))
       print('Catch pokemon by player ' .. tostring(player.id))
       request(
           'POST', '{"method": "catch",
           "params": [1, '..json.encode(player)..']}',
           tostring(player.id)
       )
       table.insert(players, player.id)
   end

   print('Create pokemon')
   request('POST', '{"method": "add",
       "params": ['..json.encode(pokemon)..']}')
   request('GET', '')

   fiber.create(catch, player1)
   fiber.create(catch, player2)

   -- wait for players
   while #players ~= 2 do
       fiber.sleep(0.001)
   end

   request('GET', '')
   os.exit()

When you run this script, you’ll notice that both players have equal chances to
make the first attempt at catching the pokémon. In a classical Lua script,
a networked call blocks the script until it’s finished, so the first catch
attempt can only be done by the player who entered the game first. In Tarantool,
both players play concurrently, since all modules are integrated with Tarantool
:ref:`cooperative multitasking <atomic-cooperative_multitasking>` and use
non-blocking I/O.

Indeed, when Player1 makes its first REST call, the script doesn’t block.
The fiber running ``catch()`` function on behalf of Player1 issues a non-blocking
call to the operating system and yields control to the next fiber, which happens
to be the fiber of Player2. Player2’s fiber does the same. When the network
response is received, Player1's fiber is activated by Tarantool cooperative
scheduler, and resumes its work. All Tarantool :ref:`modules <built_in_modules>`
use non-blocking I/O and are integrated with Tarantool cooperative scheduler.
For module developers, Tarantool provides an :ref:`API <index-c_api_reference>`.

For our HTTP test, we create a third container based on the
`official Tarantool 1.9 image <https://github.com/tarantool/docker>`_ (see
`client/Dockerfile <https://github.com/tarantool/pokemon/blob/1.9/client/Dockerfile>`_)
and set the container's default command to ``tarantool client.lua``.

.. image:: aster.svg
    :align: center

To run this test locally, download our `pokemon <https://github.com/tarantool/pokemon>`_
project from GitHub and say:

.. code-block:: console

   $ docker-compose build
   $ docker-compose up

Docker Compose builds and runs all the three containers: ``pserver`` (Tarantool
backend), ``phttp`` (nginx) and ``pclient`` (demo client). You can see log
messages from all these containers in the console, pclient saying that it made
an HTTP request to create a pokémon, made two catch requests, requested the map
(empty since the pokémon is caught and temporarily inactive) and exited:

.. code-block:: console

   pclient_1  | Create pokemon
   <...>
   pclient_1  | {"result":true}
   pclient_1  | {"map":[{"id":1,"status":"active","location":{"y":2,"x":1},"name":"Pikachu","chance":99.100000}]}
   pclient_1  | Catch pokemon by player 2
   pclient_1  | Catch pokemon by player 1
   pclient_1  | Player 1 result: {"result":true}
   pclient_1  | Player 2 result: {"result":false}
   pclient_1  | {"map":[]}
   pokemon_pclient_1 exited with code 0

Congratulations! Here's the end point of our walk-through. As further reading,
see more about :ref:`installing <app_server-installing_module>` and
:ref:`contributing <app_server-contributing_module>` a module.

See also reference on :ref:`Tarantool modules <built_in_modules>` and
:ref:`C API <index-c_api_reference>`, and don't miss our
:ref:`Lua cookbook recipes <cookbook>`.

.. _app_server-gis:

GIS
---

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
.. _app_server-index_iterators:

Index iterators
---------------

By our gameplay, all caught pokémons are returned back to the map. We do this
for all pokémons on the map every 60 seconds using ``respawn()`` method.
We iterate through pokémons by status using Tarantool index iterator function
:doc:`/reference/reference_lua/box_index/pairs` and reset the statuses of all
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
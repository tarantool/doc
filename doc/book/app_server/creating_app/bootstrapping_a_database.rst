.. _app_server-db_bootstrap:

Bootstrapping a database
------------------------

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
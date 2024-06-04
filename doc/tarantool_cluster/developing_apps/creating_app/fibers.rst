..  _application_server_fibers:

Fibers, yields and cooperative multitasking
===========================================

But wait! If we launch it as shown above -- ``self.respawn()`` -- the function
will be executed only once, just like all the other methods. But we need to
execute ``respawn()`` every 60 seconds. Creating a :ref:`fiber <app-fibers>`
is the Tarantool way of making application logic work in the background at all
times.

A **fiber** is a set of instructions that are executed with
:ref:`cooperative multitasking <app-cooperative_multitasking>`:
the instructions contain :ref:`yield <app-yields>` signals, upon which control is passed to another fiber.

Let's launch ``respawn()`` in a fiber to make it work in the background all the time.
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
 
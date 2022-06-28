..  _application_server_fibers:

Fibers
------

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

To know more about yields and cooperative multitasking, see the following sections:

.. toctree::
    :maxdepth: 1

    fibers/yields
    fibers/cooperative_multitasking

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
 
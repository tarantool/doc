.. _app_server-logging:

Logging
-------

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

To launch our microservice, we put both the ``pokemon.lua`` module and the ``game.lua``
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

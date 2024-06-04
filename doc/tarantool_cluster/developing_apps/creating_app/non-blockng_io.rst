.. _app_server-nonblocking_io:

Non-blocking IO
---------------

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
:ref:`cooperative multitasking <app-cooperative_multitasking>` and use
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

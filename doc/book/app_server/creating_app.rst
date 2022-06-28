:noindex:
:fullwidth:

.. _app_server-creating_app:

Creating an application
=======================

Further we walk you through key programming practices that will give you a good 
start in writing Lua applications for Tarantool. We will implement a real microservice 
based on Tarantool! It is a backend for a simplified version of 
`Pokémon Go <https://en.wikipedia.org/wiki/Pokémon_Go>`_, a location-based 
augmented reality game launched in mid-2016. 


In this game, players use the GPS capability of a mobile device to locate, catch, 
battle, and train virtual monsters called "pokémon" that appear on the screen as 
if they were in the same real-world location as the player.


To stay within the walk-through format, let's narrow the original gameplay as 
follows. We have a map with pokémon spawn locations. Next, we have multiple 
players who can send catch-a-pokémon requests to the server (which runs our 
Tarantool microservice). The server responds whether the 
pokémon is caught or not, increases the player's pokémon counter if yes, 
and triggers the respawn-a-pokémon method that spawns a new pokémon at the same 
location in a while.


We leave client-side applications outside the scope of this story. However, we
promise a mini-demo in the end to simulate real users and give us some fun. :-)

.. image:: aster.svg
    :align: center


Follow these topics to implement our application:

.. toctree::
    :maxdepth: 2

    creating_app/modules_rocks_and_applications
    creating_app/avro_schemas
    creating_app/bootstrapping_a_database
    creating_app/GIS
    creating_app/index_iterators
    creating_app/fibers
    creating_app/yields
    creating_app/logging
    creating_app/nginx
    creating_app/non-blockng_io

 

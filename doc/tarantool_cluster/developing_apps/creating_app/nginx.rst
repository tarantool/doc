.. _app_server-nginx:

nginx
-----

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
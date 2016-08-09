-------------------------------------------------------------------------------
 Appendix F. Modules
-------------------------------------------------------------------------------

These are notes about modules.
They may be useful as either a supplement or an alternative to the
manual section :ref:`"Modules, LuaRocks, and requiring modules" <administration-modules_luarocks_and_requiring_modules>`.

================
Install a module
================

Use `LuaRocks <http://rocks.tarantool.org>`_ - a Lua module manager.

Install LuaRocks:

.. code-block:: bash

    sudo apt-get install luarocks

Add **Tarantool** repository to your config:

.. code-block:: bash

    mkdir ~/.luarocks
    echo "rocks_servers = {[[http://rocks.tarantool.org/]]}" >> ~/.luarocks/config.lua

Search modules:

.. code-block:: bash

    luarocks search http

Install module:

.. code-block:: bash

    luarocks install http --local # install to home dir

Use module:

.. code-block:: bash

    roman@work:~$ tarantool
    localhost> client = require('http.client')
    ---
    ...
    localhost> client
    ---
    - request: 'function: 0x4107cfa0'
      post: 'function: 0x4107d090'
      get: 'function: 0x4107d050'
    ...

See `tarantool/rocks <https://github.com/tarantool/rocks>`_ for additional
information.

==========
Lua module
==========

Create a file ``mymodule.lua`` in the current directory:

.. code-block:: lua

    -- mymodule - a simple Tarantool module

    local exports = {}
    exports.myfun = function(xxx)
        print('Hello', xxx)
    end

    return exports

Load the new module into Tarantool (restart is not required):

.. code-block:: bash

    tarantool> mymodule = require('mymodule')
    ---
    ...

    tarantool> mymodule
    ---
    - myfun: 'function: 0x405edf20'
      ...
    tarantool> mymodule.myfun(os.getenv('USER'))
    Hello   roman
    ---
    ...

============
C/C++ module
============

**You need ``tarantool-dev`` package installed for this example**.

Create a file ``myсmodule.с`` in the current directory:

.. code-block:: c

    /* mycmodule - a simple Tarantool module */
    #include <lua.h>
    #include <lauxlib.h>
    #include <lualib.h>

    #include <tarantool.h>

    static int
    myfun(lua_State *L)
    {
        if (lua_gettop(L) < 1)
            return luaL_error(L, "Usage: myfun(name)");

        /* Get first argument */
        const char *name = lua_tostring(L, 1);

        /* Push one result to Lua stack */
        lua_pushfstring(L, "Hello, %s", name);
        return 1; /* the function returns one result */
    }

    LUA_API int
    luaopen_mycmodule(lua_State *L)
    {
        static const struct luaL_reg reg[] = {
            { "myfun", myfun },
            { NULL, NULL }
        };
        luaL_register(L, "mycmodule", reg);
        return 1;
    }

Compile code to shared library (without "lib" prefix):

.. code-block:: bash

    roman@work:~$ gcc mycmodule.c -shared -fPIC -I/usr/include/tarantool -o mycmodule.so
    roman@work:~$ ls mycmodule.so -l
    -rwxr-xr-x 1 roman roman 7272 Jun  3 16:51 mycmodule.so

We recommend to use our `CMake scripts <https://github.com/tarantool/http>`_
which will do all the magic automatically.

Load the new module into Tarantool (restart is not required):

.. code-block:: bash

    tarantool> myсmodule = require('myсmodule')
    ---
    ...

    tarantool> myсmodule
    ---
    - myfun: 'function: 0x4100ec98'
    ...

    tarantool> mycmodule.myfun(os.getenv('USER'))
    ---
    - Hello, roman
    ...

Of course, you can use C++ too, but please don't throw exceptions.

==================
Mixed Lua/C module
==================

* Create a Lua module, say `myfunmodule`.
* Create C module and name it `myfunmodule.internal` or something like
  that (submodule).
* Load C module from Lua code using `require('myfunmodule.internal')` and then
  wrap or use it.

==============================
Forced reload module from disk
==============================

Lua caches all loaded modules in :code:`package.loaded` table.
To reload a module from disk just set key to `nil`:

.. code-block:: lua

    package.loaded['modulename'] = nil

=========================
Custom module search path
=========================

Take a look on ``package.path`` for ``.lua`` modules and ``package.cpath`` for
binary modules.

.. code-block:: bash

    tarantool> package.path
    ---
    - ./?.lua;./?/init.lua;/home/roman/.luarocks/share/lua/5.1/?.lua;/home/roman/.luarocks/share/lua/5.1/?/init.lua;/home/roman/.luarocks/share/lua/?.lua;/home/roman/.luarocks/share/lua/?/init.lua;/usr/share/tarantool/?.lua;/usr/share/tarantool/?/init.lua;./?.lua;/usr/local/share/luajit-2.0.3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua
    ...

    tarantool> package.cpath
    ---
    - ./?.so;/home/roman/.luarocks/lib/lua/5.1/?.so;/home/roman/.luarocks/lib/lua/?.so;/usr/lib/tarantool/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so
    ...

Question mark gets substituted with :code:`modulename` when you call
:code:`require('modulename')`.

============================
Internal state in Lua module
============================

Create a local variable inside scope of file:

.. code-block:: lua

    -- mymodule

    local exports = {}
    local state = {}

    exports.myfun = function()
        state.x = 42 -- use state
    end

    return exports

Don't use global variables because they pollute global namespace.

==========
References
==========

- `Lua Modules Tutorial <http://lua-users.org/wiki/ModulesTutorial>`_
- `A sample Lua + C module <https://github.com/tarantool/http>`_

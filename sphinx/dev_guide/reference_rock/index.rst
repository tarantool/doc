--------------------------------------------------------------------------------
Lua rocks reference
--------------------------------------------------------------------------------

.. _develop_modules:

A module (or "rock" in Lua) is an optional library which enhances Tarantool
functionality. For basic information about modules/rocks, see the section
:ref:`Application server <app_server>` in User's Guide.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating a new Lua module locally
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As an example, let's create a new Lua file named :file:`mymodule.lua`,
containing a named function which will be exported.
Then, in Tarantool: load, examine, and call.

The Lua file should look like this:

.. code-block:: lua

    -- mymodule - a simple Tarantool module
    local exports = {}
    exports.myfun = function(input_string)
        print('Hello', input_string)
    end
    return exports

The requests to load, examine and call look like this:

.. cssclass:: highlight
.. parsed-literal::

   tarantool> **mymodule = require('mymodule')**
   ---
   ...
 
   tarantool> **mymodule**
   ---
   - myfun: 'function: 0x405edf20'
   ...
   
   tarantool> **mymodule.myfun(os.getenv('USER'))**
   Hello world
   ---
   ...

.. _modules-example_c:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating a new C/C++ module locally
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As an example, let's create a new C file named :file:`mycmodule.c`,
containing a named function which will be exported.
Then, in Tarantool: load, examine, and call.

Prerequisite: install ``tarantool-dev`` first.

The C file should look like this:

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

Use :program:`gcc` to compile the code for a shared library (without a "lib"
prefix), then use :program:`ls` to examine it:

.. cssclass:: highlight
.. parsed-literal::

   $ **gcc mycmodule.c -shared -fPIC -I/usr/include/tarantool -o mycmodule.so**
   $ **ls mycmodule.so -l**
   -rwxr-xr-x 1 roman roman 7272 Jun  3 16:51 mycmodule.so

Tarantool's developers recommend using Tarantool's
`CMake scripts <https://github.com/tarantool/modulekit>`_
which will handle some of the build steps automatically.

The requests to load, examine and call look like this:

.. cssclass:: highlight
.. parsed-literal::

   tarantool> **myсmodule = require('myсmodule')**
   ---
   ...
   tarantool> **myсmodule**
   ---
   - myfun: 'function: 0x4100ec98'
   ...
   tarantool> **mycmodule.myfun(os.getenv('USER'))**
   ---
   - Hello, world
   ...

You can also create modules with C++, provided that the code does not throw
exceptions.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating a mixed Lua/C module locally
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(1) Create a Lua module and name it as you like, say ``myfunmodule``.

(2) Create a C module (submodule) and name it ``myfunmodule.internal`` or
    something like that.

(3) Load the C module from your Lua code using
    :samp:`require('myfunmodule.internal')` and then wrap or use it.

For a sample of a mixed Lua/C module, see
`"tarantool/http" repository at GitHub <https://github.com/tarantool/http>`_.

~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tips for special situations
~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Lua caches all loaded modules in the ``package.loaded`` table.
  To reload a module from disk, set its key to `nil`:

  .. cssclass:: highlight
  .. parsed-literal::

     tarantool> package.loaded['*modulename*'] = nil
   
* Use ``package.path`` to search for :file:`.lua` modules, and use
  ``package.cpath`` to search for C binary modules.

  .. cssclass:: highlight
  .. parsed-literal::

     tarantool> **package.path**
     ---
     - ./?.lua;./?/init.lua;/home/roman/.luarocks/share/lua/5.1/?.lua;/home/roma
     n/.luarocks/share/lua/5.1/?/init.lua;/home/roman/.luarocks/share/lua/?.lua;
     /home/roman/.luarocks/share/lua/?/init.lua;/usr/share/tarantool/?.lua;/usr/
     share/tarantool/?/init.lua;./?.lua;/usr/local/share/luajit-2.0.3/?.lua;/usr
     /local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua
     ...
     tarantool> **package.cpath**
     ---
     - ./?.so;/home/roman/.luarocks/lib/lua/5.1/?.so;/home/roman/.luarocks/lib/l
     ua/?.so;/usr/lib/tarantool/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/loc
     al/lib/lua/5.1/loadall.so
     ...

  Question-marks stand for the module name that was specified earlier when
  saying :extsamp:`require('{*{modulename}*}')`.

* To see the internal state from within a Lua module, use :samp:`state`
  and create a local variable inside the scope of the file:

  .. code-block:: lua

      -- mymodule
      local exports = {}
      local state = {}
      exports.myfun = function()
          state.x = 42 -- use state
      end
      return exports

* Notice that Lua examples in this manual use *local* variables.
  Use *global* variables with caution, since the module's users
  may be unaware of them.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
List of third-party modules for Tarantool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. toctree::
    :maxdepth: 2

    dbms
    expirationd
    shard
    tdb


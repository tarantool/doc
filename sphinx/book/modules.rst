.. _modules:

-------------------------------------------------------------------------------
                             Modules
-------------------------------------------------------------------------------

.. _modules-modules_luarocks_and_requiring_modules:

=====================================================================
       Modules, LuaRocks, and requiring modules
=====================================================================

To extend Tarantool there are modules,
which in Lua are also called "rocks".
Users who are unfamiliar with Lua modules may benefit from following
the Lua-Modules-Tutorial_
before reading this section.

**Install a module**

The modules that come from Tarantool developers and community contributors are
on rocks.tarantool.org_. Some of them
-- :ref:`expirationd <expirationd-module>`,
:ref:`mysql <dbms_modules-mysql-example>`,
:ref:`postgresql <dbms_modules-postgresql-example>`,
:ref:`shard <shard-module>` --
are discussed elsewhere in this manual.

Step 1: Install LuaRocks.
A general description for installing LuaRocks on a Unix system is in
the LuaRocks-Quick-Start-Guide_.
For example on Ubuntu one could say: |br|
:codenormal:`$` :codebold:`sudo apt-get install luarocks`

Step 2: Add the Tarantool repository to the list of rocks servers.
This is done by putting rocks.tarantool.org in the .luarocks/config.lua file: |br|
:codenormal:`$` :codebold:`mkdir ~/.luarocks` |br|
:codenormal:`$` :codebold:`echo "rocks_servers = {[[http://rocks.tarantool.org/]]}" >> ~/.luarocks/config.lua` |br|

Once these steps are complete, the repositories can be searched with |br|
:codenormal:`$` :codebold:`luarocks search` :codeitalic:`module-name` |br|
and new modules can be added to the local repository with |br|
:codenormal:`$` :codebold:`luarocks install` :codeitalic:`module-name` :codenormal:`--local` |br|
and any module can be loaded for Tarantool with |br|
:codenormal:`tarantool>` :codeitalic:`local-name` :codenormal:`=` :codebold:`require('`:codeitalic:`module-name`:codenormal:`')` |br|
... and that is why the examples in the manual's Modules section often begin with `require` requests.
See rocks_ on github.com/tarantool for more examples
and information about contributing.

========================================
Example: making a new Lua module locally
========================================

In this example, create a new Lua file named `mymodule.lua`,
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

The requests to load and examine and call look like this: |br|
:codenormal:`tarantool>`:codebold:`mymodule = require('mymodule')` |br|
:codenormal:`>---` |br|
:codenormal:`>...` |br|
|br|
:codenormal:`tarantool>`:codebold:`mymodule` |br|
:codenormal:`---` |br|
:codenormal:`>- myfun: 'function: 0x405edf20'` |br|
:codenormal:`>...` |br|
:codenormal:`tarantool>`:codebold:`mymodule.myfun(os.getenv('USER'))` |br|
:codenormal:`Hello world` |br|
:codenormal:`>---` |br|
:codenormal:`>...`

.. _modules-example_c:

==========================================
Example: making a new C/C++ module locally
==========================================

In this example, create a new C file named `mycmodule.c`,
containing a named function which will be exported.
Then, in Tarantool: load, examine, and call.

Prerequisite: install `tarantool-dev` first.

The C file should look like this:

.. code-block:: none

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

Use :codenormal:`gcc` to compile the code for a shared library (without a "lib" prefix),
then use :codenormal:`ls` to examine it: |br|

:codenormal:`$` :codebold:`gcc mycmodule.c -shared -fPIC -I/usr/include/tarantool -o mycmodule.so` |br|
:codenormal:`$` :codebold:`ls mycmodule.so -l` |br|
:codenormal:`-rwxr-xr-x 1 roman roman 7272 Jun  3 16:51 mycmodule.so`



Tarantool's developers recommend use of Tarantool's CMake-scripts_
which will handle some of the build steps automatically.

The requests to load and examine and call look like this: |br|
:codenormal:`tarantool>`:codebold:`myсmodule = require('myсmodule')` |br|
:codenormal:`---` |br|
:codenormal:`...` |br|
:codenormal:`tarantool>`:codebold:`myсmodule` |br|
:codenormal:`---` |br|
:codenormal:`- myfun: 'function: 0x4100ec98'` |br|
:codenormal:`...` |br|
:codenormal:`tarantool>`:codebold:`mycmodule.myfun(os.getenv('USER'))` |br|
:codenormal:`---` |br|
:codenormal:`- Hello, world` |br|
:codenormal:`...` |br|

One can also make modules with C++, provided that the code does not throw exceptions.


**Tips for special situations**

Lua caches all loaded modules in the :code:`package.loaded` table.
To reload a module from disk, set its key to `nil`: |br|
:codenormal:`tarantool>` :codebold:`package.loaded['`:codeitalic:`modulename`:codebold:`'] = nil`

Use ``package.path`` to search for ``.lua`` modules, and use
``package.cpath`` to search for C binary modules. |br|
:codenormal:`tarantool>`:codebold:`package.path` |br|
:codenormal:`---` |br|
:codenormal:`- ./?.lua;./?/init.lua;/home/roman/.luarocks/share/lua/5.1/?.lua;/home/roman/.luarocks/share/lua/5.1/?/init.lua;/home/roman/.luarocks/share/lua/?.lua;/home/roman/.luarocks/share/lua/?/init.lua;/usr/share/tarantool/?.lua;/usr/share/tarantool/?/init.lua;./?.lua;/usr/local/share/luajit-2.0.3/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua` |br|
:codenormal:`...`
:codenormal:`tarantool>`:codebold:`package.cpath` |br|
:codenormal:`---` |br|
:codenormal:`- ./?.so;/home/roman/.luarocks/lib/lua/5.1/?.so;/home/roman/.luarocks/lib/lua/?.so;/usr/lib/tarantool/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so` |br|
:codenormal:`...` |br|
Substitute question-mark with :code:`modulename` when calling
:code:`require('modulename')`.


To see the internal state from within a Lua module, use `state`
and create a local variable inside the scope of the file:

.. code-block:: none

    -- mymodule
    local exports = {}
    local state = {}
    exports.myfun = function()
        state.x = 42 -- use state
    end
    return exports

Notice that the Lua examples use local variables.
Use global variables with caution, since the module's users
may be unaware of them.

To see a sample Lua + C module, go to http_ on github.com/tarantool.

==================
Mixed Lua/C module
==================

* Create a Lua module, say `myfunmodule`.
* Create C module and name it `myfunmodule.internal` or something like
  that (submodule).
* Load C module from Lua code using `require('myfunmodule.internal')` and then
  wrap or use it.

.. _rocks.tarantool.org: http://rocks.tarantool.org
.. _LuaRocks-Quick-Start-Guide: http://luarocks.org/#quick-start
.. _Lua-Modules-Tutorial: http://lua-users.org/wiki/ModulesTutorial
.. _LuaRocks: http://rocks.tarantool.org
.. _CMake-scripts: https://github.com/tarantool/http
.. _http: https://github.com/tarantool/http
.. _rocks: github.com/tarantool/rocks <https://github.com/tarantool/rocks



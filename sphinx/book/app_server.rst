.. _app_server:

================================================================================
Application server
================================================================================

.. _modules:

--------------------------------------------------------------------------------
About modules/rocks
--------------------------------------------------------------------------------

Alongside with using Tarantool as a database manager, you can also use it
as an application server. This means that you can write your own logic, install
it as a module in Tarantool — and see Tarantool perform your logic.

Tarantool's native language for writing modules is Lua.
Modules in Lua are also called "rocks".
If you are new to Lua, we recommend following this
`Lua modules tutorial <http://lua-users.org/wiki/ModulesTutorial>`_ before
reading this section.

--------------------------------------------------------------------------------
Installing an existing module
--------------------------------------------------------------------------------

Modules that come from Tarantool developers and community contributors are
available at `rocks.tarantool.org <http://rocks.tarantool.org>`_. Some of them
-- :ref:`expirationd <expirationd-module>`,
:ref:`mysql <dbms_modules-mysql-example>`,
:ref:`postgresql <dbms_modules-postgresql-example>`,
:ref:`shard <shard-module>` --
are discussed elsewhere in this manual.

**Step 1:** Install LuaRocks.
A general description of installing LuaRocks on a Unix system is given in
the `LuaRocks Quick Start Guide <http://luarocks.org/#quick-start>`_.
For example, on Ubuntu you could say:

.. code-block:: console

   $ sudo apt-get install luarocks

**Step 2:** Add the Tarantool repository to the list of rocks servers.
This is done by putting `rocks.tarantool.org <http://rocks.tarantool.org>`_ in
the :file:`.luarocks/config.lua` file:

.. code-block:: console

   $ mkdir ~/.luarocks
   $ echo "rocks_servers = {[[http://rocks.tarantool.org/]]}" >> ~/.luarocks/config.lua

Once these steps are complete, you can:

* search the repositories with

  .. cssclass:: highlight
  .. parsed-literal::

     $ luarocks search *module-name*
       
* add new modules to the local repository with

  .. cssclass:: highlight
  .. parsed-literal::

     $ luarocks install *module-name* --local
   
* load any module for Tarantool with

  .. cssclass:: highlight
  .. parsed-literal::

     tarantool> *local-name* = require('*module-name*')
   
... and that is why examples in this manual often begin with ``require`` requests.

See `"tarantool/rocks" repository at GitHub <https://github.com/tarantool/rocks>`_
for more examples and information about contributing.

For developers, we provide
:ref:`instructions on creating their own Tarantool modules in Lua, C/C++ and Lua+C <develop_modules>`.

--------------------------------------------------------------------------------
Cookbook recipes
--------------------------------------------------------------------------------
.. include:: cookbook.rst

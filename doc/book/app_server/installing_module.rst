.. _app_server-installing_module:

================================================================================
Installing a module
================================================================================

Modules in Lua and C that come from Tarantool developers and community
contributors are available in the following locations:

* Tarantool modules repository (see :ref:`below <app_server-installing_module_luarocks>`)
* Tarantool deb/rpm repositories (see :ref:`below <app_server-installing_module_debrpm>`)

.. _app_server-installing_module_luarocks:

--------------------------------------------------------------------------------
Installing a module from a repository
--------------------------------------------------------------------------------

See
`README in tarantool/rocks repository <https://github.com/tarantool/rocks#managing-modules-with-tarantool-174>`_
for detailed instructions.

.. _app_server-installing_module_debrpm:

--------------------------------------------------------------------------------
Installing a module from deb/rpm
--------------------------------------------------------------------------------

Follow these steps:

1. Install Tarantool as recommended on the
   `download page <http://tarantool.org/download.html>`_.

2. Install the module you need. Look up the module's name on
   `Tarantool rocks page <http://tarantool.org/rocks.html>`_ and put the prefix
   "tarantool-" before the module name to avoid ambiguity:

   .. code-block:: console

       $ # for Ubuntu/Debian:
       $ sudo apt-get install tarantool-<module-name>

       $ # for RHEL/CentOS/Amazon:
       $ sudo yum install tarantool-<module-name>

   For example, to install the module
   `shard <http://github.com/tarantool/shard>`_ on Ubuntu, say:

   .. code-block:: console

       $ sudo apt-get install tarantool-shard

Once these steps are complete, you can:

* load any module with

  .. code-block:: tarantoolsession

       tarantool> name = require('module-name')

  for example:

  .. code-block:: tarantoolsession

      tarantool> shard = require('shard')

* search locally for installed modules using ``package.path`` (Lua) or
  ``package.cpath`` (C):

  .. code-block:: tarantoolsession

      tarantool> package.path
      ---
      - ./?.lua;./?/init.lua; /usr/local/share/tarantool/?.lua;/usr/local/share/
      tarantool/?/init.lua;/usr/share/tarantool/?.lua;/usr/share/tarantool/?/ini
      t.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/
      usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;
      ...

      tarantool> package.cpath
      ---
      - ./?.so;/usr/local/lib/x86_64-linux-gnu/tarantool/?.so;/usr/lib/x86_64-li
      nux-gnu/tarantool/?.so;/usr/local/lib/tarantool/?.so;/usr/local/lib/x86_64
      -linux-gnu/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/local/
      lib/lua/5.1/?.so;
      ...

  .. NOTE::

      Question-marks stand for the module name that was specified earlier when
      saying ``require('module-name')``.

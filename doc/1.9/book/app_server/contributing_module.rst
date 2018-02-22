.. _app_server-contributing_module:

================================================================================
Contributing a module
================================================================================

We have already discussed
:ref:`how to create a simple module in Lua for local usage <app_server-modules>`.
Now let's discuss how to create a more advanced Tarantool module and then get it
published on `Tarantool rocks page <http://tarantool.org/rocks.html>`_ and
included in
`official Tarantool images <http://github.com/tarantool/docker>`_ for Docker.

To help our contributors, we have created
`modulekit <http://github.com/tarantool/modulekit>`_, a set of templates for
creating Tarantool modules in Lua and C.

.. NOTE::

   As a prerequisite for using ``modulekit``, install ``tarantool-dev`` package
   first. For example, in Ubuntu say:

   .. code-block:: console

       $ sudo apt-get install tarantool-dev

.. _app_server-contributing_module_lua:

--------------------------------------------------------------------------------
Contributing a module in Lua
--------------------------------------------------------------------------------

See
`README in "luakit" branch of tarantool/modulekit repository <http://github.com/tarantool/modulekit/blob/luakit/README.md>`_
for detailed instructions and examples.

.. _app_server-contributing_module_c:

--------------------------------------------------------------------------------
Contributing a module in C
--------------------------------------------------------------------------------

In some cases, you may want to create a Tarantool module in C rather than in Lua.
For example, to work with specific hardware or low-level system interfaces.

See
`README in "ckit" branch of tarantool/modulekit repository <http://github.com/tarantool/modulekit/blob/ckit/README.md>`_
for detailed instructions and examples.

.. NOTE::

   You can also create modules with C++, provided that the code does not throw
   exceptions.

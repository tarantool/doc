.. _tt-check:

Checking an application file
============================

..  code-block:: console

    $ tt check {FILEPATH | APPLICATION[:APP_INSTANCE]}

``tt check`` checks the syntax correctness of Lua files within Tarantool applications
or separate Lua scripts. The files must be stored inside the ``instances_enabled``
directory specified in the :ref:`tt configuration file <tt-config_file_app>`.

Examples
--------

To check all Lua files in an application directory at once, specify the directory name:

..  code-block:: console

    $ tt check app

To check a single Lua file from an application directory, add the path to this file:

..  code-block:: console

    $ tt check app/router
    # or
    $ tt check app/router.lua

.. note::

    The ``.lua`` extension can be omitted.




.. _admin-instance_config:

Instance configuration
======================

For each Tarantool instance, you need two files:

* [Optional] An :ref:`application file <app_server-launching_app>` with
  instance-specific logic. Put this file into the ``/usr/share/tarantool/``
  directory.

  For example, ``/usr/share/tarantool/my_app.lua`` (here we implement it as a
  :ref:`Lua module <app_server-modules>` that bootstraps the database and
  exports ``start()`` function for API calls):

  .. code-block:: lua

     local function start()
         box.schema.space.create("somedata")
         box.space.somedata:create_index("primary")
         <...>
     end

     return {
       start = start;
     }

* An :ref:`instance file <admin-instance_file>` with
  instance-specific initialization logic and parameters. Put this file, or a
  symlink to it, into the **instance directory**
  (see :ref:`instance_dir <admin-instance_dir>` parameter in ``tarantoolctl``
  configuration file).

  For example, ``/etc/tarantool/instances.enabled/my_app.lua`` (here we load
  ``my_app.lua`` module and make a call to ``start()`` function from that
  module):

  .. code-block:: lua

     #!/usr/bin/env tarantool

     box.cfg {
         listen = 3301;
     }

     -- load my_app module and call start() function
     -- with some app options controlled by sysadmins
     local m = require('my_app').start({...})

.. _admin-instance_file:

Instance file
-------------

After this short introduction, you may wonder what an instance file is, what it
is for, and how ``tarantoolctl`` uses it. After all, Tarantool is an application
server, so why not start the application stored in ``/usr/share/tarantool``
directly?

A typical Tarantool application is not a script, but a daemon running in
background mode and processing requests, usually sent to it over a TCP/IP
socket. This daemon needs to be started automatically when the operating system
starts, and managed with the operating system standard tools for service
management -- such as ``systemd`` or ``init.d``. To serve this very purpose, we
created **instance files**.

You can have more than one instance file. For example, a single application in
``/usr/share/tarantool`` can run in multiple instances, each of them having its
own instance file. Or you can have multiple applications in
``/usr/share/tarantool`` -- again, each of them having its own instance file.

An instance file is typically created by a system administrator. An application
file is often provided by a developer, in a Lua rock or an rpm/deb package.

An instance file is designed to not differ in any way from a Lua application.
It must, however, configure the database, i.e. contain a call to
:doc:`box.cfg{} </reference/reference_lua/box_cfg>` somewhere in it, because it’s the
only way to turn a Tarantool script into a background process, and
``tarantoolctl`` is a tool to manage background processes. Other than that, an
instance file may contain arbitrary Lua code, and, in theory, even include the
entire application business logic in it. We, however, do not recommend this,
since it clutters the instance file and leads to unnecessary copy-paste when
you need to run multiple instances of an application.

.. _admin-tt-preload:

Preloading Lua scripts and modules
----------------------------------

Tarantool supports loading and running chunks of Lua code before the loading instance file.
To load or run Lua code immediately upon Tarantool startup, specify the ``TT_PRELOAD``
environment variable. Its value can be either a path to a Lua script or a Lua module name:

*   To run the Lua script ``script.lua`` from the ``preload/path/`` directory inside
    the working directory in Tarantool before ``main.lua``, set ``TT_PRELOAD`` as follows:

    .. code-block:: console

        $ TT_PRELOAD=/preload/path/script.lua tarantool main.lua

    Tarantool runs the ``script.lua`` code, waits for it to complete, and
    then starts running ``main.lua``.

*   To load the ``preload.module`` into the Tarantool Lua interpreter
    executing ``main.lua``, set ``TT_PRELOAD`` as follows:

    .. code-block:: console

        $ TT_PRELOAD=preload.module tarantool main.lua

    Tarantool loads the ``preload.module`` code into the interpreter and
    starts running ``main.lua`` as if its first statement was ``require('preload.module')``.

    .. warning::

        ``TT_PRELOAD`` values that end with ``.lua`` are considered scripts,
        so avoid module names with this ending.

To load several scripts or modules, pass them in a single quoted string, separated
by semicolons:

.. code-block:: console

    $ TT_PRELOAD="/preload/path/script.lua;preload.module" tarantool main.lua

In the preload script, the three dots (``...``) value contains the module name
if you're preloading a module or the path to the script if you're running a script.

The :ref:`arg <index-init_label>` value from the main script is visible in
the preload script or module.

For example, when preloading this script:

.. code-block:: lua

    -- preload.lua --
    print("Preloading:")
    print("... arg is:", ...)
    print("Passed args:", arg[1], arg[2])

You get the following output:

.. code-block:: console

    $ TT_PRELOAD=preload.lua tarantool main.lua arg1 arg2
    Preloading:
    ... arg is:	preload.lua
    Passed args:	arg1	arg2
    'strip_core' is set but unsupported
    ... main/103/main.lua I> Tarantool 2.11.0-0-g247a9a4 Darwin-x86_64-Release
    ... main/103/main.lua I> log level 5
    ... main/103/main.lua I> wal/engine cleanup is paused
    < ... >

If an error happens during the execution of the preload script or module, Tarantool
reports the problem and exits.

.. _admin-tarantoolctl_config_file:

tarantoolctl configuration file
-------------------------------

While instance files contain instance configuration, the ``tarantoolctl``
configuration file contains the configuration that ``tarantoolctl`` uses to
override instance configuration. In other words, it contains system-wide
configuration defaults. If ``tarantoolctl`` fails to find this file with
the method described in section
:ref:`Starting/stopping an instance <admin-start_stop_instance>`, it uses
default settings.

Most of the parameters are similar to those used by
:doc:`box.cfg{} </reference/reference_lua/box_cfg>`. Here are the default settings
(possibly installed in ``/etc/default/tarantool`` or ``/etc/sysconfig/tarantool``
as part of Tarantool distribution -- see OS-specific default paths in
:ref:`Notes for operating systems <admin-os_notes>`):

.. code-block:: lua

   default_cfg = {
       pid_file  = "/var/run/tarantool",
       wal_dir   = "/var/lib/tarantool",
       memtx_dir = "/var/lib/tarantool",
       vinyl_dir = "/var/lib/tarantool",
       log       = "/var/log/tarantool",
       username  = "tarantool",
       language  = "Lua",
   }
   instance_dir = "/etc/tarantool/instances.enabled"

where:

* | ``pid_file``
  | Directory for the pid file and control-socket file; ``tarantoolctl`` will
    add “/instance_name” to the directory name.

* | ``wal_dir``
  | Directory for write-ahead .xlog files; ``tarantoolctl`` will add
    "/instance_name" to the directory name.

* | ``memtx_dir``
  | Directory for snapshot .snap files; ``tarantoolctl`` will add
    "/instance_name" to the directory name.

* | ``vinyl_dir``
  | Directory for vinyl files; ``tarantoolctl`` will add "/instance_name" to the
    directory name.

* | ``log``
  | The place where the application log will go; ``tarantoolctl`` will add
    "/instance_name.log" to the name.

* | ``username``
  | The user that runs the Tarantool instance. This is the operating-system user
    name rather than the Tarantool-client user name. Tarantool will change its
    effective user to this user after becoming a daemon.

* | ``language``
  | The :ref:`interactive console <interactive_console>` language. Can be either ``Lua`` or ``SQL``.

.. _admin-instance_dir:

* | ``instance_dir``
  | The directory where all instance files for this host are stored. Put
    instance files in this directory, or create symbolic links.

  The default instance directory depends on Tarantool's ``WITH_SYSVINIT``
  build option: when ON, it is ``/etc/tarantool/instances.enabled``,
  otherwise (OFF or not set) it is ``/etc/tarantool/instances.available``.
  The latter case is typical for Tarantool builds for Linux distros with
  ``systemd``.

  To check the build options, say ``tarantool --version``.

As a full-featured example, you can take
`example.lua <https://github.com/tarantool/tarantool/blob/2.1/extra/dist/example.lua>`_
script that ships with Tarantool and defines all configuration options.

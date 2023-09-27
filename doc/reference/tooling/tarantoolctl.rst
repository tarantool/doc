.. _tarantoolctl:

tarantoolctl utility (deprecated)
=================================

.. important::

    ``tarantoolctl`` is deprecated in favor of :ref:`tt CLI <tt-cli>`.
    Find the instructions on switching from ``tarantoolctl`` to ``tt`` in
    :ref:`Migration from tarantoolctl to tt <tarantoolctl-migration-to-tt>`.

``tarantoolctl`` is a utility for administering Tarantool
:ref:`instances <tarantoolctl-instance_management>`,
:ref:`checkpoint files <tarantoolctl-checkpoint_management>` and
:ref:`modules <tarantoolctl-module_management>`.
It is shipped and installed as part of Tarantool distribution.
This utility is intended for use by administrators only.

See also ``tarantoolctl`` usage examples in :ref:`Server administration <admin>`
section.

.. _tarantoolctl-command_format:

Command format
--------------

``tarantoolctl COMMAND NAME [URI] [FILE] [OPTIONS..]``

where:

* ``COMMAND`` is one of the following: ``start``, ``stop``, ``status``,
  ``restart``, ``logrotate``, ``check``, ``enter``, ``eval``, ``connect``,
  ``cat``, ``play``, ``rocks``.

* ``NAME`` is the name of an :ref:`instance file <admin-instance_file>` or a
  :ref:`module <app_server-modules>`.

* ``FILE`` is the path to some file (.lua, .xlog or .snap).

* ``URI`` is the URI of some Tarantool instance.

* ``OPTIONS`` are options taken by some ``tarantoolctl`` commands.

.. _tarantoolctl-instance_management:

Commands for managing Tarantool instances
-----------------------------------------

``tarantoolctl start NAME``
        Start a Tarantool instance.

        Additionally, this command sets the TARANTOOLCTL environment variable to
        'true', to mark that the instance was started by ``tarantoolctl``.

        .. NOTE::

            ``tarantoolctl`` works for instances without ``box.cfg{}`` called or
            with delayed ``box.cfg{}`` call.

            For example, this can be used to manage instances which receive configuration
            from an external server. For such instances, ``tarantoolctl start`` goes to
            background when ``box.cfg{}`` is called, so it will wait until options
            for ``box.cfg`` are received. However this is not the case for daemon
            management systems like ``systemd``, as they handle backgrounding on
            their side.

``tarantoolctl stop NAME``
        Stop a Tarantool instance.

``tarantoolctl status NAME``
        Show an instance's status (started/stopped).
        If pid file exists and an alive control socket exists, the return code
        is ``0``. Otherwise, the return code is not ``0``.

        Reports typical problems to stderr (e.g. pid file exists and control
        socket doesn't).

``tarantoolctl restart NAME``
        Stop and start a Tarantool instance.

        Additionally, this command sets the TARANTOOL_RESTARTED environment
        variable to 'true', to mark that the instance was restarted by
        ``tarantoolctl``.

``tarantoolctl logrotate NAME``
        Rotate logs of a started Tarantool instance.
        Works only if logging-into-file is enabled in the instance file.
        Pipe/syslog make no effect.

``tarantoolctl check NAME``
        Check an instance file for syntax errors.

``tarantoolctl enter NAME [--language=language]``
        Enter an instance's interactive Lua or SQL console.

        Supported option:

        * ``--language=language`` to set :ref:`interactive console <interactive_console>` language.
          Can be either ``Lua`` or ``SQL``.

``tarantoolctl eval NAME FILE``
        Evaluate a local Lua file on a running Tarantool instance.

``tarantoolctl connect URI``
        Connect to a Tarantool instance on an admin-console port.
        Supports both TCP/Unix sockets.

.. _tarantoolctl-checkpoint_management:

Commands for managing checkpoint files
--------------------------------------

``tarantoolctl cat FILE.. [--space=space_no ..] [--show-system] [--from=from_lsn] [--to=to_lsn] [--replica=replica_id ..] [--format=format_name]``
        Print into stdout the contents of .snap/.xlog files.

``tarantoolctl play URI FILE.. [--space=space_no ..] [--show-system] [--from=from_lsn] [--to=to_lsn] [--replica=replica_id ..]``
        Play the contents of .snap/.xlog files to another Tarantool instance.

Supported options:

* ``--space=space_no`` to filter the output by space number.
  May be passed more than once.
* ``--show-system`` to show the contents of system spaces.
* ``--from=from_lsn`` to show operations starting from the given lsn.
* ``--to=to_lsn`` to show operations ending with the given lsn.
* ``--replica=replica_id`` to filter the output by replica id.
  May be passed more than once.
* ``--format=format_name`` to indicate format (defaults to ``yaml``, can also be ``json`` or ``lua``).

.. _tarantoolctl-module_management:

Commands for managing Tarantool modules
---------------------------------------

``tarantoolctl rocks build NAME``
        Build/compile and install a rock. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks config URI``
        Query and set the LuaRocks configuration. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks doc NAME``
        Show documentation for an installed rock.

``tarantoolctl rocks download [NAME]``
        Download a specific rock or rockspec file from a rocks server.
        Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks help NAME``
        Help on commands.

``tarantoolctl rocks init NAME``
        Initialize a directory for a Lua project using LuaRocks. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks install NAME``
        Install a module in the ``.rocks`` directory, nested in the current directory.

``tarantoolctl rocks lint FILE``
        Check the syntax of a rockspec. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks list``
        List all installed modules.

``tarantoolctl rocks make``
        Compile a package in the current directory using a rockspec and install it.

``tarantoolctl rocks make_manifest``
        Compile a manifest file for a repository.

``tarantoolctl rocks new_version NAME``
        Auto-write a rockspec for a new version of a rock. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks pack NAME``
        Create a rock by packing sources or binaries.

``tarantoolctl rocks purge NAME``
        Remove all installed rocks from a tree. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks remove NAME``
        Remove a module.

``tarantoolctl rocks show NAME``
        Show information about an installed module.

``tarantoolctl rocks search NAME``
        Search the repository for modules.

``tarantoolctl rocks unpack NAME``
        Unpack the contents of a rock.

``tarantoolctl rocks which NAME``
        Tell which file corresponds to a given module name. Since version :doc:`2.4.1 </release/2.4.1>`.

``tarantoolctl rocks write_rockspec``
        Write a template for a rockspec file. Since version :doc:`2.4.1 </release/2.4.1>`.


        As an argument, you can specify:

        * a ``.rockspec`` file to create a source rock containing the module's
          sources, or
        * the name of an installed module (and its version if there are more
          than one) to create a binary rock containing the compiled module.

``tarantoolctl rocks unpack {<rock_file> | <rockspec> | <name> [version]}``
        Unpack the contents of a rock into a new directory under the current one.

        As an argument, you can specify:

        * source or binary rock files,
        * ``.rockspec`` files, or
        * names of rocks or ``.rockspec`` files in remote repositories
          (and the rock version if there are more than one).

Supported options:

* ``--server=server_name`` check this server first, then the usual list.
* ``--only-server=server_name`` check this server only, ignore the usual list.

.. _tarantoolctl-config_file:

tarantoolctl configuration file
-------------------------------

The ``tarantoolctl`` configuration file named ``.tarantoolctl``
contains the configuration that ``tarantoolctl`` uses to
override instance configuration. In other words, it contains system-wide
configuration defaults. If ``tarantoolctl`` fails to find this file with
the method described in the section
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
  | The user that runs the Tarantool instance. This is the operating system user
    name rather than the Tarantool-client user name. Tarantool will change its
    effective user to this user after becoming a daemon.
* | ``language``
  | The :ref:`interactive console <interactive_console>` language. Can be either ``Lua`` or ``SQL``.

* | ``instance_dir``
  | The directory where all instance files for this host are stored. Put
    instance files in this directory, or create symbolic links.

  The default instance directory depends on Tarantool's ``WITH_SYSVINIT``
  build option: when ON, it is ``/etc/tarantool/instances.enabled``,
  otherwise (OFF or not set) it is ``/etc/tarantool/instances.available``.
  The latter case is typical for Tarantool builds for Linux distros with
  ``systemd``.

  To check the build options, say ``tarantool --version``.

.. _tarantoolctl-log-rotation:

Log rotation in tarantooctl
---------------------------

With ``tarantoolctl``, :ref:`log rotation <admin-logs>` is pre-configured to use
``logrotate`` program, which you must have installed.

File ``/etc/logrotate.d/tarantool`` is part of the standard Tarantool
distribution, and you can modify it to change the default behavior. This is what
this file is usually like:

.. code-block:: text

   /var/log/tarantool/*.log {
       daily
       size 512k
       missingok
       rotate 10
       compress
       delaycompress
       create 0640 tarantool adm
       postrotate
           /usr/bin/tt logrotate `basename ${1%%.*}`
       endscript
   }

If you use a different log rotation program, you can invoke
``tarantoolctl logrotate`` command to request instances to reopen their log
files after they were moved by the program of your choice.

.. _tarantoolctl-freebsd:

Using tarantooctl on FreeBSD
----------------------------

To make ``tarantoolctl`` work along with ``init.d`` utilities on FreeBSD, use
paths other than those suggested in
:ref:`Instance configuration <admin-instance_config>`. Instead of
``/usr/share/tarantool/`` directory, use ``/usr/local/etc/tarantool/`` and
create the following subdirectories:

* ``default`` for ``tarantoolctl`` defaults (see example below),
* ``instances.available`` for all available instance files, and
* ``instances.enabled`` for instance files to be auto-started by sysvinit.

Here is an example of ``tarantoolctl`` defaults on FreeBSD:

.. code-block:: lua

   default_cfg = {
       pid_file   = "/var/run/tarantool", -- /var/run/tarantool/${INSTANCE}.pid
       wal_dir    = "/var/db/tarantool", -- /var/db/tarantool/${INSTANCE}/
       snap_dir   = "/var/db/tarantool", -- /var/db/tarantool/${INSTANCE}
       vinyl_dir = "/var/db/tarantool", -- /var/db/tarantool/${INSTANCE}
       logger     = "/var/log/tarantool", -- /var/log/tarantool/${INSTANCE}.log
       username   = "admin"
   }

   -- instances.available - all available instances
   -- instances.enabled - instances to autostart by sysvinit
   instance_dir = "/usr/local/etc/tarantool/instances.available"

.. _tarantooctl-start_stop_instance:

Starting and stopping instances
-------------------------------

While a Lua application is executed by Tarantool, an instance file is executed
by ``tarantoolctl`` which is a Tarantool script.

Here is what ``tarantoolctl`` does when you issue the command:

.. code-block:: console

    $ tarantoolctl start <instance_name>

1. Read and parse the command line arguments. The last argument, in our case,
   contains an instance name.

2. Read and parse its own configuration file. This file contains ``tarantoolctl``
   defaults, like the path to the directory where instances should be searched
   for.

   When ``tarantool`` is invoked by root, it looks for a configuration file in
   ``/etc/default/tarantool``. When ``tarantool`` is invoked by a local (non-root)
   user, it looks for a configuration file first in the current directory
   (``$PWD/.tarantoolctl``), and then in the current user's home directory
   (``$HOME/.config/tarantool/tarantool``). If no configuration file is found
   there, or in the ``/usr/local/etc/default/tarantool`` file,
   then ``tarantoolctl`` falls back to
   :ref:`built-in defaults <admin-tt_config_file>`.

3. Look up the instance file in the instance directory, for example
   ``/etc/tarantool/instances.enabled``. To build the instance file path,
   ``tarantoolctl`` takes the instance name, prepends the instance directory and
   appends ".lua" extension to the instance file.

4. Override :doc:`box.cfg{} </reference/reference_lua/box_cfg>` function to pre-process
   its parameters and ensure that instance paths are pointing to the paths
   defined in the ``tarantoolctl`` configuration file. For example, if the
   configuration file specifies that instance work directory must be in
   ``/var/tarantool``, then the new implementation of ``box.cfg{}`` ensures that
   :ref:`work_dir <cfg_basic-work_dir>` parameter in ``box.cfg{}`` is set to
   ``/var/tarantool/<instance_name>``, regardless of what the path is set to in
   the instance file itself.

5. Create a so-called "instance control file". This is a Unix socket with Lua
   console attached to it. This file is used later by ``tarantoolctl`` to query
   the instance state, send commands to the instance and so on.

6. Set the TARANTOOLCTL environment variable to 'true'. This allows the user to
   know that the instance was started by ``tarantoolctl``.

7. Finally, use Lua ``dofile`` command to execute the instance file.

To check the instance file for syntax errors prior to starting ``my_app``
instance, say:

.. code-block:: console

    $ tarantoolctl check my_app

To stop a running ``my_app`` instance, say:

.. code-block:: console

    $ tarantoolctl stop my_app

To restart (i.e. stop and start) a running ``my_app`` instance, say:

.. code-block:: console

    $ tarantoolctl restart my_app

.. _tarantoolctl-start_stop_instance-running_locally:

Running Tarantool locally
~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes you may need to run a Tarantool instance locally, e.g. for test
purposes. Let's configure a local instance, then start and monitor it with
``tarantoolctl``.

First, we create a sandbox directory on the user's path:

.. code-block:: console

    $ mkdir ~/tarantool_test

... and set default ``tarantoolctl`` configuration in
``$HOME/.config/tarantool/tarantool``. Let the file contents be:

.. code-block:: lua

   default_cfg = {
       pid_file  = "/home/user/tarantool_test/my_app.pid",
       wal_dir   = "/home/user/tarantool_test",
       snap_dir  = "/home/user/tarantool_test",
       vinyl_dir = "/home/user/tarantool_test",
       log       = "/home/user/tarantool_test/log",
   }
   instance_dir = "/home/user/tarantool_test"

.. NOTE::

   * Specify a full path to the user's home directory instead of "~/".

   * Omit ``username`` parameter. ``tarantoolctl`` normally doesn't have
     permissions to switch current user when invoked by a local user. The
     instance will be running under 'admin'.

Next, we create the instance file ``~/tarantool_test/my_app.lua``. Let the file
contents be:

.. code-block:: lua

   box.cfg{listen = 3301}
   box.schema.user.passwd('Gx5!')
   box.schema.user.grant('guest','read,write,execute','universe')
   fiber = require('fiber')
   box.schema.space.create('tester')
   box.space.tester:create_index('primary',{})
   i = 0
   while 0 == 0 do
       fiber.sleep(5)
       i = i + 1
       print('insert ' .. i)
       box.space.tester:insert{i, 'my_app tuple'}
   end

Let’s verify our instance file by starting it without ``tarantoolctl`` first:

.. code-block:: console

    $ cd ~/tarantool_test
    $ tarantool my_app.lua
    2017-04-06 10:42:15.762 [54085] main/101/my_app.lua C> version 1.7.3-489-gd86e36d5b
    2017-04-06 10:42:15.763 [54085] main/101/my_app.lua C> log level 5
    2017-04-06 10:42:15.764 [54085] main/101/my_app.lua I> mapping 268435456 bytes for tuple arena...
    2017-04-06 10:42:15.774 [54085] iproto/101/main I> binary: bound to [::]:3301
    2017-04-06 10:42:15.774 [54085] main/101/my_app.lua I> initializing an empty data directory
    2017-04-06 10:42:15.789 [54085] snapshot/101/main I> saving snapshot `./00000000000000000000.snap.inprogress'
    2017-04-06 10:42:15.790 [54085] snapshot/101/main I> done
    2017-04-06 10:42:15.791 [54085] main/101/my_app.lua I> vinyl checkpoint done
    2017-04-06 10:42:15.791 [54085] main/101/my_app.lua I> ready to accept requests
    insert 1
    insert 2
    insert 3
    <...>

Now we tell ``tarantoolctl`` to start the Tarantool instance:

.. code-block:: console

    $ tarantoolctl start my_app

Expect to see messages indicating that the instance has started. Then:

.. code-block:: console

    $ ls -l ~/tarantool_test/my_app

Expect to see the .snap file and the .xlog file. Then:

.. code-block:: console

    $ less ~/tarantool_test/log/my_app.log

Expect to see the contents of ``my_app``‘s log, including error messages, if
any. Then:

.. code-block:: console

    $ tarantoolctl enter my_app
    tarantool> box.cfg{}
    tarantool> console = require('console')
    tarantool> console.connect('localhost:3301')
    tarantool> box.space.tester:select({0}, {iterator = 'GE'})

Expect to see several tuples that ``my_app`` has created.

Stop now. A polite way to stop ``my_app`` is with ``tarantoolctl``, thus we say:

.. code-block:: console

    $ tarantoolctl stop my_app

Finally, we make a cleanup.

.. code-block:: console

    $ rm -R tarantool_test

.. _tarantoolctl-migration-to-tt:

Migration from tarantoolctl to tt
---------------------------------

:ref:`tt <tt-cli>` is a command-line utility for managing Tarantool applications
that comes to replace ``tarantoolctl``. Starting from version 3.0, ``tarantoolctl``
is no longer shipped as a part of Tarantool distribution; ``tt`` is the only
recommended tool for managing Tarantool applications from the command line.

``tarantoolctl`` remains fully compatible with Tarantool 2.* versions. However,
it doesn't receive major updates anymore.

We recommend that you migrate from ``tarantoolctl`` to ``tt`` to ensure the full
support and timely updates and fixes.

System-wide configuration
~~~~~~~~~~~~~~~~~~~~~~~~~

``tt`` supports system-wide environment configuration by default. If you have
Tarantool instances managed by ``tarantoolctl`` in such an environment, you can
switch to ``tt`` without additional migration steps or use ``tt`` along with ``tarantoolctl``.

Example:

..  code-block:: bash

    $ sudo tt instances
    List of enabled applications:
    • example

    $ tarantoolctl start example
    Starting instance example...
    Forwarding to 'systemctl start tarantool@example'

    $ tarantoolctl status example
    Forwarding to 'systemctl status tarantool@example'
    ● tarantool@example.service - Tarantool Database Server
        Loaded: loaded (/lib/systemd/system/tarantool@.service; enabled; vendor preset: enabled)
        Active: active (running)
        Docs: man:tarantool(1)
        Main PID: 6698 (tarantool)
    . . .

    $ sudo tt status
    • example: RUNNING. PID: 6698.

    $ sudo tt connect example
    • Connecting to the instance...
    • Connected to /var/run/tarantool/example.control

    /var/run/tarantool/example.control>

    $ sudo tt stop example
    • The Instance example (PID = 6698) has been terminated.

    $ tarantoolctl status example
    Forwarding to 'systemctl status tarantool@example'
    ○ tarantool@example.service - Tarantool Database Server
        Loaded: loaded (/lib/systemd/system/tarantool@.service; enabled; vendor preset: enabled)
        Active: inactive (dead)

Local configuration
~~~~~~~~~~~~~~~~~~~

If you have a local ``tarantoolctl`` configuration, create a ``tt`` environment
based on the existing ``.tarantoolctl`` configuration file. To do this, run
``tt init`` in the directory where the file is located.

Example:

..  code-block:: bash

    $ cat .tarantoolctl
    default_cfg = {
        pid_file  = "./run/tarantool",
        wal_dir   = "./lib/tarantool",
        memtx_dir = "./lib/tarantool",
        vinyl_dir = "./lib/tarantool",
        log       = "./log/tarantool",
        language  = "Lua",
    }
    instance_dir = "./instances.enabled"

    $ tt init
    • Found existing config '.tarantoolctl'
    • Environment config is written to 'tt.yaml'

After that, you can start managing Tarantool instances in this environment with ``tt``:

..  code-block:: bash

    $ tt start app1
    • Starting an instance [app1]...

    $ tt status app1
    • app1: RUNNING. PID: 33837.

    $ tt stop app1
    • The Instance app1 (PID = 33837) has been terminated.

    $ tt check app1
    • Result of check: syntax of file '/home/user/instances.enabled/app1.lua' is OK

Commands difference
~~~~~~~~~~~~~~~~~~~

Most ``tarantoolctl`` commands look the same in ``tt``: ``tarantoolctl start`` and
``tt start``, ``tarantoolctl play`` and ``tt play``, and so on. To migrate such
calls, it is usually enough to replace the utility name. There can be slight differences
in command flags and format. For details on ``tt`` commands, see the
:ref:`tt commands reference <tt-commands>`.

The following commands are different in ``tt``:

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 1

        *   -   ``tarantoolctl`` command
            -   ``tt`` command
        *   -   ``tarantoolctl enter``
            -   ``tt connect``
        *   -   ``tarantoolctl eval``
            -   ``tt connect`` with ``-f`` flag

..  note::

    ``tt connect`` also covers ``tarantoolctl connect`` with the same syntax.

Example:

..  code-block:: bash

    # tarantoolctl enter > tt connect
    $ tarantoolctl enter app1
    connected to unix/:./run/tarantool/app1.control
    unix/:./run/tarantool/app1.control>

    $ tt connect app1
    • Connecting to the instance...
    • Connected to /home/user/run/tarantool/app1/app1.control

    # tarantoolctl eval > tt connect -f
    $ tarantoolctl eval app1 eval.lua
    connected to unix/:./run/tarantool/app1.control
    ---
    - 42
    ...

   $ tt connect app1 -f eval.lua
    ---
    - 42
    ...

    # tarantoolctl connect > tt connect
    $ tarantoolctl connect localhost:3301
    connected to localhost:3301
    localhost:3301>

    $ tt connect localhost:3301
    • Connecting to the instance...
    • Connected to localhost:3301
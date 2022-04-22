.. _tarantoolctl:

--------------------------------------------------------------------------------
Utility `tarantoolctl`
--------------------------------------------------------------------------------

``tarantoolctl`` is a utility for administering Tarantool
:ref:`instances <tarantoolctl-instance_management>`,
:ref:`checkpoint files <tarantoolctl-checkpoint_management>` and
:ref:`modules <tarantoolctl-module_management>`.
It is shipped and installed as part of Tarantool distribution.
This utility is intended for use by administrators only.

See also ``tarantoolctl`` usage examples in :ref:`Server administration <admin>`
section.

.. _tarantoolctl-command_format:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Command format
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Commands for managing Tarantool instances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Commands for managing checkpoint files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tarantoolctl cat FILE.. [--space=space_no ..] [--show-system] [--from=from_lsn] [--to=to_lsn] [--replica=replica_id ..]``
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

.. _tarantoolctl-module_management:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Commands for managing Tarantool modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

.. _tarantoolctl:

--------------------------------------------------------------------------------
Utility `tarantoolctl`
--------------------------------------------------------------------------------

``tarantoolctl`` is a utility for administering Tarantool
:ref:`instances <tarantoolctl-instance_management>`,
:ref:`checkpoint files <tarantoolctl-checkpoint_management>` and
:ref:`modules <tarantoolctl-module_management>`.
It is shipped and installed as part of Tarantool distribution.

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

``tarantoolctl enter NAME``
        Enter an instance's interactive Lua console.

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

``tarantoolctl rocks install NAME``
        Install a module in the current directory.

``tarantoolctl rocks remove NAME``
        Remove a module.

``tarantoolctl rocks show NAME``
        Show information about an installed module.

``tarantoolctl rocks search NAME``
        Search the repository for modules.

``tarantoolctl rocks list``
        List all installed modules.

``tarantoolctl rocks pack {<rockspec> | <name> [<version>]}``
        Create a rock by packing sources or binaries.

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

.. _tarantool_cli:
.. _configuration_command_options:

tarantool command-line options
==============================

``tarantool`` is the Tarantool database and application server.
This command can be used for different purposes, for example, running a single Tarantool instance or starting an external coordinator used for a :ref:`supervised failover <repl_supervised_failover>`.
The ``tarantool`` command also provides additional :ref:`options <tarantool_cli_options>` that might be helpful for development purposes.

..  NOTE::

    The :ref:`tt <tt-cli>` utility is the recommended way to start Tarantool instances.
    Learn more from :ref:`admin-start_stop_instance`.



.. _configuration_run_instance_tarantool:

Starting instances using the tarantool command
----------------------------------------------

Below is the syntax for starting a Tarantool instance configured in a file:

..  code-block:: console

    $ tarantool [OPTION ...] --name INSTANCE_NAME --config CONFIG_FILE_PATH

The command below starts ``router-a-001`` configured in the ``config.yaml`` file:

.. code-block:: console

    $ tarantool --name router-a-001 --config config.yaml


.. _tarantool_cli_options:

Options
-------

.. _tarantool_cli_help:

..  option:: -h, --help

    Print an annotated list of all available options and exit.

.. _tarantool_cli_help_env_list:

..  option:: --help-env-list

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Show a list of :ref:`environment variables <configuration_environment_variable>` that can be used to configure Tarantool.

.. _tarantool_cli_failover:

..  option:: --failover

    **Since:** :doc:`3.1.0 </release/3.1.0>`.

    ..  admonition:: Enterprise Edition
        :class: fact

        This option is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

    Start an external coordinator used for a :ref:`supervised failover <repl_supervised_failover>`.

.. _tarantool_cli_force_recovery:

..  option:: --force-recovery

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Try to start an instance if there is an error while reading a corrupted snapshot or write-ahead log file during the recovery process:

    -   For a corrupted :ref:`snapshot file <index-box_persistence>` -- at the instance start.
    -   For a corrupted :ref:`write-ahead log file <internals-wal>` -- at the instance start or when applying an update at a replica.

    With this option enabled, Tarantool skips invalid records, reads as much data as possible, and lets the process finish with a warning.
    Then call :ref:`box.snapshot() <box-snapshot>` to make a new snapshot so that the corrupted snapshots or write-ahead logs aren't used for recovery anymore.

    You can also enable this option using the ``TT_FORCE_RECOVERY`` environment variable.
    ``TT_FORCE_RECOVERY`` has a lower priority than the ``--force-recovery`` option.

    Example on GitHub: `force_recovery <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/force_recovery>`_

.. _index-tarantool_version:

..  option:: -v, -V, --version

    Print the product name and version.

    **Example**

    ..  code-block:: console

        $ tarantool --version
        Tarantool Enterprise 3.0.0-beta1-2-gcbb569b4c-r607-gc64
        Target: Linux-x86_64-RelWithDebInfo
        ...

    In this example:

    *   ``3.0.0`` is a Tarantool version.
        Tarantool follows semantic versioning, which is described in the :ref:`Tarantool release policy <release-policy>` section.

    *   ``Target`` is the platform Tarantool is built on.
        Platform-specific details may follow this line.

.. _tarantool_cli_config:

..  option:: -c, --config PATH

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Set a path to a :ref:`YAML configuration file <configuration_file>`.
    You can also configure this value using the ``TT_CONFIG`` environment variable.

    See also: :ref:`configuration_run_instance_tarantool`


.. _tarantool_cli_name:

..  option:: -n, --name INSTANCE

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Set the name of an instance to run.
    You can also configure this value using the ``TT_INSTANCE_NAME`` environment variable.

    See also: :ref:`configuration_run_instance_tarantool`

.. _tarantool_cli_i:

..  option:: -i

    Enter an :ref:`interactive mode <interactive_console>`.

    **Example**

    ..  code-block:: console

        $ tarantool -i

.. _tarantool_cli_e:

..  option:: -e EXPR

    Execute the 'EXPR' string. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -e 'print("Hello, world!")'
        Hello, world!

.. _tarantool_cli_l:

..  option:: -l NAME

    Require the 'NAME' library. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -l luatest.coverage script.lua

.. _tarantool_cli_j:

..  option:: -j cmd

    Perform a LuaJIT control command. See also: `Command Line Options <https://luajit.org/running.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -j off app.lua

.. _tarantool_cli_b:

..  option:: -b ...

    Save or list bytecode. See also: `Command Line Options <https://luajit.org/running.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -b test.lua test.out

.. _tarantool_cli_d:

..  option:: -d SCRIPT

    Activate a debugging session for 'SCRIPT'. See also: `luadebug.lua <https://github.com/tarantool/tarantool/blob/master/third_party/lua/README-luadebug.md>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -d app.lua

.. _tarantool_cli_stop_handing_opts:

..  option:: --

    Stop handling options. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

.. _tarantool_cli_stop_handing_opts_execute_stdin:

..  option:: -

    Stop handling options and execute the standard input as a file. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

.. _admin-start_stop_instance:

Starting and stopping instances
===============================

This section describes how to manage instances in a Tarantool cluster using the :ref:`tt <tt-cli>` utility.
A cluster can include multiple instances that run different code.
A typical example is a cluster application that includes router and storage instances.
For example, you can manage instances in the following ways:

*   start all instances in a cluster or only specific ones
*   check the status of instances
*   connect to a specific instance
*   stop all instances or only specific ones

To get more context on how the application's environment might look, refer to :ref:`Application environment <admin-instance_config>`.

..  NOTE::

    In this section, a `sharded_cluster <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster>`_ application is used to demonstrate how to start, stop, and manage instances in a cluster.


.. _configuration_run_instance:

Starting Tarantool instances
----------------------------

.. _configuration_run_instance_tt:

Starting instances using the tt utility
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`tt <tt-cli>` utility is the recommended way to start Tarantool instances.

.. code-block:: console

    $ tt start sharded_cluster
       • Starting an instance [sharded_cluster:storage-a-001]...
       • Starting an instance [sharded_cluster:storage-a-002]...
       • Starting an instance [sharded_cluster:storage-b-001]...
       • Starting an instance [sharded_cluster:storage-b-002]...
       • Starting an instance [sharded_cluster:router-a-001]...

After the cluster has started and worked for some time, you can find its artifacts
in the directories specified in the ``tt`` configuration. These are the default
locations in the local :ref:`launch mode <tt-config_modes>`:

*   ``sharded_cluster/var/log/<instance_name>/`` -- instance :ref:`logs <admin-logs>`.
*   ``sharded_cluster/var/lib/<instance_name>/`` -- :ref:`snapshots and write-ahead logs <concepts-data_model-persistence>`.
*   ``sharded_cluster/var/run/<instance_name>/`` -- control sockets and PID files.

In the system launch mode, artifacts are created in these locations:

*   ``/var/log/tarantool/<instance_name>/``
*   ``/var/lib/tarantool/<instance_name>/``
*   ``/var/run/tarantool/<instance_name>/``


.. _configuration_run_instance_tarantool:

Starting an instance using the tarantool command
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``tarantool`` command provides additional :ref:`options <configuration_command_options>` that might be helpful for development purposes.
Below is the syntax for starting a Tarantool instance configured in a file:

..  code-block:: console

    $ tarantool [OPTION ...] --name INSTANCE_NAME --config CONFIG_FILE_PATH

The command below starts ``router-a-001`` configured in the ``config.yaml`` file:

.. code-block:: console

    $ tarantool --name router-a-001 --config config.yaml



.. _admin-start_stop_instance_management:

Basic instance management
-------------------------

Most of the commands described in this section can be called with or without an instance name.
Without the instance name, they are executed for all instances defined in ``instances.yaml``.


.. _admin-start_stop_instance_check_status:

Checking an instance's status
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To check the status of instances, execute :ref:`tt status <tt-status>`:

.. code-block:: console

    $ tt status sharded_cluster
    INSTANCE                          STATUS      PID
    sharded_cluster:storage-a-001     RUNNING     2023
    sharded_cluster:storage-a-002     RUNNING     2026
    sharded_cluster:storage-b-001     RUNNING     2020
    sharded_cluster:storage-b-002     RUNNING     2021
    sharded_cluster:router-a-001      RUNNING     2022

To check the status of a specific instance, you need to specify its name:

.. code-block:: console

    $ tt status sharded_cluster:storage-a-001
    INSTANCE                          STATUS      PID
    sharded_cluster:storage-a-001     RUNNING     2023


.. _admin-start_stop_instance_connect:

Connecting to an instance
~~~~~~~~~~~~~~~~~~~~~~~~~

To connect to the instance, use the :ref:`tt connect <tt-connect>` command:

..  code-block:: console

    $ tt connect sharded_cluster:storage-a-001
       • Connecting to the instance...
       • Connected to sharded_cluster:storage-a-001

    sharded_cluster:storage-a-001>

In the instance's console, you can execute commands provided by the :ref:`box <box-module>` module.
For example, :ref:`box.info <box_introspection-box_info>` can be used to get various information about a running instance:

..  code-block:: console

    sharded_cluster:storage-a-001> box.info.ro
    ---
    - false
    ...



.. _admin-start_stop_instance_restart:

Restarting instances
~~~~~~~~~~~~~~~~~~~~

To restart an instance, use :ref:`tt restart <tt-restart>`:

.. code-block:: console

    $ tt restart sharded_cluster:storage-a-002

After executing ``tt restart``, you need to confirm this operation:

.. code-block:: console

    Confirm restart of 'sharded_cluster:storage-a-002' [y/n]: y
       • The Instance sharded_cluster:storage-a-002 (PID = 2026) has been terminated.
       • Starting an instance [sharded_cluster:storage-a-002]...


.. _admin-start_stop_instance_stop:

Stopping instances
~~~~~~~~~~~~~~~~~~

To stop the specific instance, use :ref:`tt stop <tt-stop>` as follows:

.. code-block:: console

    $ tt stop sharded_cluster:storage-a-002

You can also stop all the instances at once as follows:

.. code-block:: console

    $ tt stop sharded_cluster
       • The Instance sharded_cluster:storage-b-001 (PID = 2020) has been terminated.
       • The Instance sharded_cluster:storage-b-002 (PID = 2021) has been terminated.
       • The Instance sharded_cluster:router-a-001 (PID = 2022) has been terminated.
       • The Instance sharded_cluster:storage-a-001 (PID = 2023) has been terminated.
       • can't "stat" the PID file. Error: "stat /home/testuser/myapp/instances.enabled/sharded_cluster/var/run/storage-a-002/tt.pid: no such file or directory"

..  note::

    The error message indicates that ``storage-a-002`` is already not running.


.. _admin-start_stop_instance_remove_artifacts:

Removing instance artifacts
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`tt clean <tt-clean>` command removes instance artifacts (such as logs or snapshots):

.. code-block:: console

    $ tt clean sharded_cluster
       • List of files to delete:

       • /home/testuser/myapp/instances.enabled/sharded_cluster/var/log/storage-a-001/tt.log
       • /home/testuser/myapp/instances.enabled/sharded_cluster/var/lib/storage-a-001/00000000000000001062.snap
       • /home/testuser/myapp/instances.enabled/sharded_cluster/var/lib/storage-a-001/00000000000000001062.xlog
       • ...

    Confirm [y/n]:

Enter ``y`` and press ``Enter`` to confirm removing of artifacts for each instance.

..  note::

    The ``-f`` option of the ``tt clean`` command can be used to remove the files without confirmation.





.. _admin-tt-preload:

Preloading Lua scripts and modules
----------------------------------

Tarantool supports loading and running chunks of Lua code before starting instances.
To load or run Lua code immediately upon Tarantool startup, specify the ``TT_PRELOAD``
environment variable. Its value can be either a path to a Lua script or a Lua module name:

*   To run the Lua script ``preload_script.lua`` from the ``sharded_cluster`` directory, set ``TT_PRELOAD`` as follows:

    .. code-block:: console

        $ TT_PRELOAD=preload_script.lua tt start sharded_cluster

    Tarantool runs the ``preload_script.lua`` code, waits for it to complete, and
    then starts instances.

*   To load the ``preload_module`` from the ``sharded_cluster`` directory, set ``TT_PRELOAD`` as follows:

    .. code-block:: console

        $ TT_PRELOAD=preload_module tt start sharded_cluster

    .. note::

        ``TT_PRELOAD`` values that end with ``.lua`` are considered scripts,
        so avoid module names with this ending.

To load several scripts or modules, pass them in a single quoted string, separated
by semicolons:

.. code-block:: console

    $ TT_PRELOAD="preload_script.lua;preload_module" tt start sharded_cluster

If an error happens during the execution of the preload script or module, Tarantool
reports the problem and exits.




.. _configuration_command_options:

tarantool command-line options
------------------------------

Options that can be passed when :ref:`starting a Tarantool instance <configuration_run_instance_tarantool>`:

..  option:: -h, --help

    Print an annotated list of all available options and exit.

..  option:: --help-env-list

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Show a list of :ref:`environment variables <configuration_environment_variable>` that can be used to configure Tarantool.

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


..  option:: -c, --config PATH

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Set a path to a :ref:`YAML configuration file <configuration_file>`.
    You can also configure this value using the ``TT_CONFIG`` environment variable.

    See also: :ref:`Starting an instance using the tarantool command <configuration_run_instance_tarantool>`

..  option:: -n, --name INSTANCE

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Set the name of an instance to run.
    You can also configure this value using the ``TT_INSTANCE_NAME`` environment variable.

    See also: :ref:`Starting an instance using the tarantool command <configuration_run_instance_tarantool>`


..  option:: -i

    Enter an :ref:`interactive mode <interactive_console>`.

    **Example**

    ..  code-block:: console

        $ tarantool -i


..  option:: -e EXPR

    Execute the 'EXPR' string. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -e 'print("Hello, world!")'
        Hello, world!

..  option:: -l NAME

    Require the 'NAME' library. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -l luatest.coverage script.lua

..  option:: -j cmd

    Perform a LuaJIT control command. See also: `Command Line Options <https://luajit.org/running.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -j off app.lua

..  option:: -b ...

    Save or list bytecode. See also: `Command Line Options <https://luajit.org/running.html>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -b test.lua test.out

..  option:: -d SCRIPT

    Activate a debugging session for 'SCRIPT'. See also: `luadebug.lua <https://github.com/tarantool/tarantool/blob/master/third_party/lua/README-luadebug.md>`_.

    **Example**

    ..  code-block:: console

        $ tarantool -d app.lua


..  option:: --

    Stop handling options. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.


..  option:: -

    Stop handling options and execute the standard input as a file. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.
.. _admin-start_stop_instance:

Starting and stopping instances
===============================

This section describes how to manage instances in a Tarantool cluster using the :ref:`tt <tt-cli>` utility.
A cluster can include multiple instances that run different code.
A typical example is a cluster application that includes router and storage instances.
Particularly, you can perform the following actions:

*   start all instances in a cluster or only specific ones
*   check the status of instances
*   connect to a specific instance
*   stop all instances or only specific ones

To get more context on how the application's environment might look, refer to :ref:`Application environment <admin-instance_config>`.

..  NOTE::

    In this section, a `sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_ application is used to demonstrate how to start, stop, and manage instances in a cluster.


.. _configuration_run_instance:
.. _configuration_run_instance_tt:

Starting Tarantool instances
----------------------------

To start Tarantool instances use the :ref:`tt start <tt-start>` command:

.. code-block:: console

    $ tt start sharded_cluster_crud
       • Starting an instance [sharded_cluster_crud:storage-a-001]...
       • Starting an instance [sharded_cluster_crud:storage-a-002]...
       • Starting an instance [sharded_cluster_crud:storage-b-001]...
       • Starting an instance [sharded_cluster_crud:storage-b-002]...
       • Starting an instance [sharded_cluster_crud:router-a-001]...

After the cluster has started and worked for some time, you can find its artifacts
in the directories specified in the ``tt`` configuration. These are the default
locations in the local :ref:`launch mode <tt-config_modes>`:

*   ``sharded_cluster_crud/var/log/<instance_name>/`` -- instance :ref:`logs <admin-logs>`.
*   ``sharded_cluster_crud/var/lib/<instance_name>/`` -- :ref:`snapshots and write-ahead logs <concepts-data_model-persistence>`.
*   ``sharded_cluster_crud/var/run/<instance_name>/`` -- control sockets and PID files.

In the system launch mode, artifacts are created in these locations:

*   ``/var/log/tarantool/<instance_name>/``
*   ``/var/lib/tarantool/<instance_name>/``
*   ``/var/run/tarantool/<instance_name>/``




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

    $ tt status sharded_cluster_crud
     INSTANCE                            STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
     sharded_cluster_crud:router-a-001   RUNNING  8382  RW    ready   running  --
     sharded_cluster_crud:storage-a-001  RUNNING  8386  RW    ready   running  --
     sharded_cluster_crud:storage-a-002  RUNNING  8390  RO    ready   running  --
     sharded_cluster_crud:storage-b-001  RUNNING  8379  RW    ready   running  --
     sharded_cluster_crud:storage-b-002  RUNNING  8380  RO    ready   running  --

To check the status of a specific instance, you need to specify its name:

.. code-block:: console

    $ tt status sharded_cluster_crud:storage-a-001
     INSTANCE                            STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
     sharded_cluster_crud:storage-a-001  RUNNING  8386  RW    ready   running  --

.. _admin-start_stop_instance_connect:

Connecting to an instance
~~~~~~~~~~~~~~~~~~~~~~~~~

To connect to the instance, use the :ref:`tt connect <tt-connect>` command:

..  code-block:: console

    $ tt connect sharded_cluster_crud:storage-a-001
       • Connecting to the instance...
       • Connected to sharded_cluster_crud:storage-a-001

    sharded_cluster_crud:storage-a-001>

In the instance's console, you can execute commands provided by the :ref:`box <box-module>` module.
For example, :ref:`box.info <box_introspection-box_info>` can be used to get various information about a running instance:

..  code-block:: tarantoolsession

    sharded_cluster_crud:storage-a-001> box.info.ro
    ---
    - false
    ...



.. _admin-start_stop_instance_restart:

Restarting instances
~~~~~~~~~~~~~~~~~~~~

To restart an instance, use :ref:`tt restart <tt-restart>`:

.. code-block:: console

    $ tt restart sharded_cluster_crud:storage-a-002

After executing ``tt restart``, you need to confirm this operation:

.. code-block:: console

    Confirm restart of 'sharded_cluster_crud:storage-a-002' [y/n]: y
       • The Instance sharded_cluster_crud:storage-a-002 (PID = 2026) has been terminated.
       • Starting an instance [sharded_cluster_crud:storage-a-002]...


.. _admin-start_stop_instance_stop:

Stopping instances
~~~~~~~~~~~~~~~~~~

To stop the specific instance, use :ref:`tt stop <tt-stop>` as follows:

.. code-block:: console

    $ tt stop sharded_cluster_crud:storage-a-002

You can also stop all the instances at once as follows:

.. code-block:: console

    $ tt stop sharded_cluster_crud
       • The Instance sharded_cluster_crud:storage-b-001 (PID = 2020) has been terminated.
       • The Instance sharded_cluster_crud:storage-b-002 (PID = 2021) has been terminated.
       • The Instance sharded_cluster_crud:router-a-001 (PID = 2022) has been terminated.
       • The Instance sharded_cluster_crud:storage-a-001 (PID = 2023) has been terminated.
       • can't "stat" the PID file. Error: "stat /home/testuser/myapp/instances.enabled/sharded_cluster_crud/var/run/storage-a-002/tt.pid: no such file or directory"

..  note::

    The error message indicates that ``storage-a-002`` is already not running.


.. _admin-start_stop_instance_remove_artifacts:

Removing instance artifacts
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`tt clean <tt-clean>` command removes instance artifacts (such as logs or snapshots):

.. code-block:: console

    $ tt clean sharded_cluster_crud
       • List of files to delete:

       • /home/testuser/myapp/instances.enabled/sharded_cluster_crud/var/log/storage-a-001/tt.log
       • /home/testuser/myapp/instances.enabled/sharded_cluster_crud/var/lib/storage-a-001/00000000000000001062.snap
       • /home/testuser/myapp/instances.enabled/sharded_cluster_crud/var/lib/storage-a-001/00000000000000001062.xlog
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

*   To run the Lua script ``preload_script.lua`` from the ``sharded_cluster_crud`` directory, set ``TT_PRELOAD`` as follows:

    .. code-block:: console

        $ TT_PRELOAD=preload_script.lua tt start sharded_cluster_crud

    Tarantool runs the ``preload_script.lua`` code, waits for it to complete, and
    then starts instances.

*   To load the ``preload_module`` from the ``sharded_cluster_crud`` directory, set ``TT_PRELOAD`` as follows:

    .. code-block:: console

        $ TT_PRELOAD=preload_module tt start sharded_cluster_crud

    .. note::

        ``TT_PRELOAD`` values that end with ``.lua`` are considered scripts,
        so avoid module names with this ending.

To load several scripts or modules, pass them in a single quoted string, separated
by semicolons:

.. code-block:: console

    $ TT_PRELOAD="preload_script.lua;preload_module" tt start sharded_cluster_crud

If an error happens during the execution of the preload script or module, Tarantool
reports the problem and exits.

.. _admin-start_stop_instance:

Starting and stopping instances
===============================

Starting an instance
--------------------

To start a Tarantool instance from an :ref:`instance file <admin-instance_file>`
using the :ref:`tt <tt-cli>` utility:

1.  Place the instance file into ``/etc/tarantool/instances.enabled/``. This is
    the default location where ``tt`` searches for instance files.

2.  Run ``tt start``:

    .. code-block:: console

        $ tt start
           • Starting an instance [my_app]...

In this case, ``tt`` starts an instance from any ``*.lua`` file it finds in ``/etc/tarantool/instances.enabled/``.
If there are several Lua files, ``tt`` starts a separate instance for each of them.
Learn more about working with multiple Tarantool instances in
:ref:`Managing multiple instances <tt-multi-instances>`.

To select a specific instance to start, specify its name in the ``tt start`` argument:

.. code-block:: console

    $ tt start my_app
       • Starting an instance [my_app]...

When starting an instance, ``tt`` uses its :ref:`configuration file <tt-config>`
``tt.yaml`` to set up a :ref:`tt environment <tt-cli-environments>` in which the instance runs.
The default ``tt`` configuration file is created automatically in ``/etc/tarantool/`.
Learn how to set up a ``tt`` environment in a directory of your choice in
:ref:`Running Tarantool locally <admin-start_stop_instance-running_locally>`.

After the instance has started and worked for some time, you can find its artifacts
in the directories specified in the ``tt`` configuration. These are the default
locations:

*   ``/var/log/tarantool/<instance_name>.log`` -- instance :ref:`logs <admin-logs>`
*   ``/var/lib/tarantool/<instance_name>/`` -- snapshots and write-ahead logs
*   ``/var/run/tarantool/<instance_name>.control`` and ``/var/run/tarantool/<instance_name>.pid``
    --  control socket and PID file

Basic instance management
-------------------------

``tt`` provides a set of commands for performing basic operations over instances:

*   ``tt check`` -- check the instance file for syntax errors:

    .. code-block:: console

        $ tt check my_app
           • Result of check: syntax of file '/etc/tarantool/instances.enabled/my_app.lua' is OK

*   ``tt status`` -- check the instance's status:

    .. code-block:: console

        $ tt status my_app
        INSTANCE     STATUS          PID
        my_app       NOT RUNNING

*   ``tt restart`` -- restart the instance (the ``-y`` option responds "yes"
    to confirmation prompt automatically):

    .. code-block:: console

    $ tt restart my_app -y
       • The Instance my_app (PID = 729) has been terminated.
       • Starting an instance [my_app]...

*   ``tt stop`` -- stop the instance:

    .. code-block:: console

    $ tt stop my_app
       • The Instance my_app (PID = 639) has been terminated.

* ``tt clean`` -- remove instance artifacts: logs, snapshots, an other files.

    .. code-block:: console

        $ tt clean my_app -f
           • List of files to delete:

           • /var/log/tarantool/my_app.log
           • /var/lib/tarantool/my_app/00000000000000000000.snap
           • /var/lib/tarantool/my_app/00000000000000000000.xlog


These commands can be called without an instance name. In this case, they are
executed for all instances from ``instances.enabled``.

.. _admin-start_stop_instance-running_locally:

Running Tarantool locally
-------------------------

Sometimes you may need to run a Tarantool instance locally,for example, for test
purposes. ``tt`` runs in a local environment if it finds a ``tt.yaml`` configuration
file in the current directory or any of its enclosing directories.
To force ``tt`` into the local mode, add the ``-L`` or ``--local`` argument.

To set up a local environment for ``tt``:

1.  Create a home directory for the environment.

2.   Run ``tt init`` in this directory:

    .. code-block:: console

        $ tt init
           • Environment config is written to 'tt.yaml'

This command creates a default ``tt`` configuration file ``tt.yaml`` and the
required directories for instance files, control sockets, logs, and other Tarantool
artifacts:

.. code-block:: console

    $ ls
    bin  distfiles  include  instances.enabled  modules  templates  tt.yaml

To run a Tarantool instance in the local environment:

1.  Place the instance file into the ``instances.enabled/`` directory inside the
    current directory.

2.  Run ``tt start``:

    .. code-block:: console

        $ tt start

After the instance is started, you can find its artifacts in their locations inside
the current directory:

*   logs in ``var/log/<instance_name>``
*   snapshots and write-ahead logs in ``var/lib/<instance_name>``
*   control sockets in ``var/run/<instance_name>``
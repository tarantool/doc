.. _admin-start_stop_instance:

Starting and stopping instances
===============================

To start a Tarantool instance from an :ref:`instance file <admin-instance_file>`
using the :ref:`tt <tt-cli>` utility:

1.  Place the instance file (for example, ``my_app.lua``) into ``/etc/tarantool/instances.enabled/``.
    This is the default location where ``tt`` searches for instance files.

2.  Run ``tt start``:

    .. code-block:: console

        $ tt start
           • Starting an instance [my_app]...

In this case, ``tt`` starts an instance from any ``*.lua`` file it finds in ``/etc/tarantool/instances.enabled/``.

Starting instances
------------------

All the instance files or directories placed in the ``instances_enabled`` directory
specified in :ref:`tt configuration <tt-config_file>` are called *enabled instances*.
If there are several enabled instances, ``tt start`` starts a separate Tarantool
instance for each of them.

Learn more about working with multiple Tarantool instances in
:ref:`Multi-instance applications <admin-start_stop_instance-multi-instance>`.

To start a specific enabled instance, specify its name in the ``tt start`` argument:

.. code-block:: console

    $ tt start my_app
       • Starting an instance [my_app]...

When starting an instance, ``tt`` uses its :ref:`configuration file <tt-config>`
``tt.yaml`` to set up a :ref:`tt environment <tt-cli-environments>` in which the instance runs.
The default ``tt`` configuration file is created automatically in ``/etc/tarantool/``.
Learn how to set up a ``tt`` environment in a directory of your choice in
:ref:`Running Tarantool locally <admin-start_stop_instance-running_locally>`.

After the instance has started and worked for some time, you can find its artifacts
in the directories specified in the ``tt`` configuration. These are the default
locations:

*   ``/var/log/tarantool/<instance_name>.log`` -- instance :ref:`logs <admin-logs>`.
*   ``/var/lib/tarantool/<instance_name>/`` -- snapshots and write-ahead logs.
*   ``/var/run/tarantool/<instance_name>.control`` -- a control socket. This is
    a Unix socket with the Lua console attached to it. This file is used to connect
    to the instance console.
*   ``/var/run/tarantool/<instance_name>.pid`` -- a PID file that ``tt`` uses to
    check the instance status and send control commands.

Basic instance management
-------------------------

.. note::

    These commands can be called without an instance name. In this case, they are
    executed for all enabled instances.

``tt`` provides a set of commands for performing basic operations over instances:

*   ``tt check`` -- check the instance file for syntax errors:

    .. code-block:: console

        $ tt check my_app
           • Result of check: syntax of file '/etc/tarantool/instances.enabled/my_app.lua' is OK

*   ``tt status`` -- check the instance status:

    .. code-block:: console

        $ tt status my_app
        INSTANCE     STATUS          PID
        my_app       NOT RUNNING

*   ``tt restart`` -- restart the instance:

    .. code-block:: console

        $ tt restart my_app -y
           • The Instance my_app (PID = 729) has been terminated.
           • Starting an instance [my_app]...

    The ``-y`` option responds "yes" to the confirmation prompt automatically.

*   ``tt stop`` -- stop the instance:

    .. code-block:: console

        $ tt stop my_app
           • The Instance my_app (PID = 639) has been terminated.

*   ``tt clean`` -- remove instance artifacts: logs, snapshots, and other files.

    .. code-block:: console

        $ tt clean my_app -f
           • List of files to delete:

           • /var/log/tarantool/my_app.log
           • /var/lib/tarantool/my_app/00000000000000000000.snap
           • /var/lib/tarantool/my_app/00000000000000000000.xlog

    The ``-f`` option removes the files without confirmation.

.. _admin-start_stop_instance-multi-instance:

Multi-instance applications
---------------------------

Tarantool applications can include multiple instances that run different code.
A typical example is a cluster application that includes router and storage
instances. The ``tt`` utility enables managing such applications.
With a single ``tt`` call, you can:

*   start an application on multiple instances
*   check the status of application instances
*   connect to a specific instance of an application
*   stop a specific instance of an application or all its instances

Application layout
~~~~~~~~~~~~~~~~~~

To create a multi-instance application, prepare its layout
in a directory inside ``instances_enabled``. The directory name is used as
the application identifier.

This directory should contain the following files:

*   The default instance file named ``init.lua``. This file is used for all
    instances of the application unless there are specific instance files (see below).
*   The instances configuration file ``instances.yml`` with instance names followed by colons:

    ..  code-block:: yaml

        <instance_name1>:
        <instance_name2>:
        ...

    ..  note::

        Do not use the dot (``.``) and dash (``-``) characters in the instance names.
        They are reserved for system use.

*   (Optional) Specific instances files.
    These files should have names ``<instance_name>.init.lua``, where ``<instance_name>``
    is the name specified in ``instances.yml``.
    For example, if your application has separate source files for the ``router`` and ``storage``
    instances, place the router code in the ``router.init.lua`` file.

For example, take a ``demo`` application that has three instances:``storage1``,
``storage2``, and ``router``. Storage instances share the same code, and ``router`` has its own.
The application directory ``demo`` inside ``instances_enabled`` must contain the following files:

*   ``instances.yml`` -- the instances configuration:

    ..  code-block:: yaml

        storage1:
        storage2:
        router:

*   ``init.lua`` -- the code of ``storage1`` and ``storage2``
*   ``router.init.lua`` -- the code of ``router``


Identifying instances in code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When the application is working, each instance has associated environment variables
``TARANTOOL_INSTANCE_NAME`` and ``TARANTOOL_APP_NAME``. You can use them in the application
code to identify the instance on which the code runs.

To obtain the instance and application names, use the following code:

..  code:: lua

    local inst_name = os.getenv('TARANTOOL_INSTANCE_NAME')
    local app_name = os.getenv('TARANTOOL_APP_NAME')


Managing multi-instance applications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start all three instances of the ``demo`` application:

..  code-block:: console

    $ tt start demo
       • Starting an instance [demo:router]...
       • Starting an instance [demo:storage1]...
       • Starting an instance [demo:storage2]...

Check the status of ``demo`` instances:

..  code-block:: console

    $ tt status demo
    INSTANCE         STATUS      PID
    demo:router      RUNNING     55
    demo:storage1    RUNNING     56
    demo:storage2    RUNNING     57

Check the status of a specific instance:

..  code-block:: console

    $ tt status demo:router
    INSTANCE         STATUS      PID
    demo:router      RUNNING     55

Connect to an instance:

..  code-block:: console

    $ tt connect demo:router
       • Connecting to the instance...
       • Connected to /var/run/tarantool/demo/router/router.control

    /var/run/tarantool/demo/router/router.control>

Stop a specific instance:

..  code-block:: console

    $ tt stop demo:storage1
       • The Instance demo:storage1 (PID = 56) has been terminated.

Stop all running instances of the ``demo`` application:

..  code-block:: console

    $ tt stop demo
       • The Instance demo:router (PID = 55) has been terminated.
       • can't "stat" the PID file. Error: "stat /var/run/tarantool/demo/storage1/storage1.pid: no such file or directory"
       • The Instance demo:storage2 (PID = 57) has been terminated.

.. note::

    The error message indicates that ``storage1`` is already not running.

.. _admin-start_stop_instance-running_locally:

Running Tarantool locally
-------------------------

Sometimes you may need to run a Tarantool instance locally, for example, for test
purposes. ``tt`` runs in a local environment if it finds a ``tt.yaml`` configuration
file in the current directory or any of its enclosing directories.

To set up a local environment for ``tt``:

1.  Create a home directory for the environment.

2.   Run ``tt init`` in this directory:

    .. code-block:: console

        $ tt init
           • Environment config is written to 'tt.yaml'

This command creates a default ``tt`` configuration file ``tt.yaml`` for a local
environment and the directories for instance files, control sockets, logs, and other
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
*   control sockets and PID files in ``var/run/<instance_name>``

To work with a local environment from a directory outside it, issue ``tt`` calls with
the ``-L`` or ``--local`` argument with the path to this environment as its value:

.. code-block:: console

    $ tt --local=/usr/tt/env/ start

.. _admin-start_stop_instance-systemd:

Using systemd tools
-------------------

If you start an instance using ``systemd`` tools, like this (the instance name
is ``my_app``):

.. code-block:: console

    $ systemctl start tarantool@my_app
    $ ps axuf|grep my_app
    taranto+  5350  1.3  0.3 1448872 7736 ?        Ssl  20:05   0:28 tarantool my_app.lua <running>

This actually calls ``tarantoolctl`` like in case of
``tarantoolctl start my_app``.

To enable ``my_app`` instance for auto-load during system startup, say:

.. code-block:: console

    $ systemctl enable tarantool@my_app

To stop a running ``my_app`` instance with ``systemctl``, run:

.. code-block:: console

    $ systemctl stop tarantool@my_app

To restart a running ``my_app`` instance with ``systemctl``, run:

.. code-block:: console

    $ systemctl restart tarantool@my_app

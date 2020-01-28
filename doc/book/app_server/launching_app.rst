.. _app_server-launching_app:

================================================================================
Launching an application
================================================================================

Using Tarantool as an application server, you can write your own applications.
Tarantool’s native language for writing applications is
`Lua <http://www.lua.org/about.html>`_, so a typical application would be
a file that contains your Lua script. But you can also write applications
in C or C++.

.. NOTE::

   If you're new to Lua, we recommend going over the interactive Tarantool
   tutorial before proceeding with this chapter. To launch the tutorial, say
   ``tutorial()`` in Tarantool console:

   .. code-block:: tarantoolsession

       tarantool> tutorial()
       ---
       - |
        Tutorial -- Screen #1 -- Hello, Moon
        ====================================

        Welcome to the Tarantool tutorial.
        It will introduce you to Tarantool’s Lua application server
        and database server, which is what’s running what you’re seeing.
        This is INTERACTIVE -- you’re expected to enter requests
        based on the suggestions or examples in the screen’s text.
        <...>

Let's create and launch our first Lua application for Tarantool.
Here's a simplest Lua application, the good old "Hello, world!":

.. code-block:: lua

    #!/usr/bin/env tarantool
    print('Hello, world!')

We save it in a file. Let it be ``myapp.lua`` in the current directory.

Now let's discuss how we can launch our application with Tarantool.

.. _app_server-launching_app_docker:

--------------------------------------------------------------------------------
Launching in Docker
--------------------------------------------------------------------------------

If we run Tarantool in a :ref:`Docker container <getting_started-using_docker>`,
the following command will start Tarantool without any application:

.. code-block:: console

    $ # create a temporary container and run it in interactive mode
    $ docker run --rm -t -i tarantool/tarantool:1

To run Tarantool with our application, we can say:

.. code-block:: console

    $ # create a temporary container and
    $ # launch Tarantool with our application
    $ docker run --rm -t -i \
                 -v `pwd`/myapp.lua:/opt/tarantool/myapp.lua \
                 -v /data/dir/on/host:/var/lib/tarantool \
                 tarantool/tarantool:1 tarantool /opt/tarantool/myapp.lua

Here two resources on the host get mounted in the container:

* our application file (myapp.lua) and
* Tarantool data directory (``/data/dir/on/host``).

By convention, the directory for Tarantool application code inside a container
is ``/opt/tarantool``, and the directory for data is ``/var/lib/tarantool``.

.. _app_server-launching_app_binary:

--------------------------------------------------------------------------------
Launching a binary program
--------------------------------------------------------------------------------

If we run Tarantool from a :ref:`binary package <getting_started-using_binary>`
or from a :ref:`source build <building_from_source>`, we can launch our
application:

* in the script mode,
* as a server application, or
* as a daemon service.

The simplest way is to pass the filename to Tarantool at start:

.. code-block:: console

    $ tarantool myapp.lua
    Hello, world!
    $

Tarantool starts, executes our script in the **script mode** and exits.

Now let’s turn this script into a **server application**. We use
:ref:`box.cfg <box_introspection-box_cfg>` from Tarantool’s built-in
Lua module to:

* launch the database (a database has a persistent on-disk state, which needs
  to be restored after we start an application) and
* configure Tarantool as a server that accepts requests over a TCP port.

We also add some simple database logic, using
:ref:`space.create() <box_schema-space_create>` and
:ref:`create_index() <box_space-create_index>` to create a space with a primary
index. We use the function :ref:`box.once() <box-once>` to make sure that our
logic will be executed only once when the database is initialized for the first
time, so we don't try to create an existing space or index on each invocation
of the script:

.. code-block:: lua

    #!/usr/bin/env tarantool
    -- Configure database
    box.cfg {
       listen = 3301
    }
    box.once("bootstrap", function()
       box.schema.space.create('tweedledum')
       box.space.tweedledum:create_index('primary',
           { type = 'TREE', parts = {1, 'unsigned'}})
    end)

Now we launch our application in the same manner as before:

.. code-block:: console

    $ tarantool myapp.lua
    Hello, world!
    2016-12-19 16:07:14.250 [41436] main/101/myapp.lua C> version 1.7.2-146-g021d36b
    2016-12-19 16:07:14.250 [41436] main/101/myapp.lua C> log level 5
    2016-12-19 16:07:14.251 [41436] main/101/myapp.lua I> mapping 1073741824 bytes for tuple arena...
    2016-12-19 16:07:14.255 [41436] main/101/myapp.lua I> recovery start
    2016-12-19 16:07:14.255 [41436] main/101/myapp.lua I> recovering from `./00000000000000000000.snap'
    2016-12-19 16:07:14.271 [41436] main/101/myapp.lua I> recover from `./00000000000000000000.xlog'
    2016-12-19 16:07:14.271 [41436] main/101/myapp.lua I> done `./00000000000000000000.xlog'
    2016-12-19 16:07:14.272 [41436] main/102/hot_standby I> recover from `./00000000000000000000.xlog'
    2016-12-19 16:07:14.274 [41436] iproto/102/iproto I> binary: started
    2016-12-19 16:07:14.275 [41436] iproto/102/iproto I> binary: bound to [::]:3301
    2016-12-19 16:07:14.275 [41436] main/101/myapp.lua I> done `./00000000000000000000.xlog'
    2016-12-19 16:07:14.278 [41436] main/101/myapp.lua I> ready to accept requests

This time, Tarantool executes our script and keeps working as a server,
accepting TCP requests on port 3301. We can see Tarantool in the current
session’s process list:

.. code-block:: console

    $ ps | grep "tarantool"
      PID TTY       	TIME CMD
    41608 ttys001	0:00.47 tarantool myapp.lua <running>

But the Tarantool instance will stop if we close the current terminal window.
To detach Tarantool and our application from the terminal window, we can launch
it in the **daemon mode**. To do so, we add some parameters to ``box.cfg{}``:

* :ref:`background <cfg_basic-background>` = ``true`` that actually tells
  Tarantool to work as a daemon service,
* :ref:`log <cfg_logging-log>` = ``'dir-name'`` that tells the Tarantool
  daemon where to store its log file (other log settings are available in
  Tarantool :ref:`log <log-module>` module), and
* :ref:`pid_file <cfg_basic-pid_file>` = ``'file-name'`` that tells the
  Tarantool daemon where to store its pid file.

For example:

.. code-block:: lua

    box.cfg {
       listen = 3301,
       background = true,
       log = '1.log',
       pid_file = '1.pid'
    }

We launch our application in the same manner as before:

.. code-block:: console

    $ tarantool myapp.lua
    Hello, world!
    $

Tarantool executes our script, gets detached from the current shell session
(you won't see it with ``ps | grep "tarantool"``) and continues working in the
background as a daemon attached to the global session (with SID = 0):

.. code-block:: console

    $ ps -ef | grep "tarantool"
      PID SID     TIME  CMD
    42178   0  0:00.72 tarantool myapp.lua <running>

Now that we have discussed how to create and launch a Lua application for
Tarantool, let's dive deeper into programming practices.

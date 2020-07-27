.. _admin-start_stop_instance:

================================================================================
Starting/stopping an instance
================================================================================

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
   :ref:`built-in defaults <admin-tarantoolctl_config_file>`.

3. Look up the instance file in the instance directory, for example
   ``/etc/tarantool/instances.enabled``. To build the instance file path,
   ``tarantoolctl`` takes the instance name, prepends the instance directory and
   appends ".lua" extension to the instance file.

4. Override :ref:`box.cfg{} <box_introspection-box_cfg>` function to pre-process
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

If you start an instance using ``systemd`` tools, like this (the instance name
is ``my_app``):

.. code-block:: console

    $ systemctl start tarantool@my_app
    $ ps axuf|grep my_app
    taranto+  5350  1.3  0.3 1448872 7736 ?        Ssl  20:05   0:28 tarantool my_app.lua <running>

... this actually calls ``tarantoolctl`` like in case of
``tarantoolctl start my_app``.

To check the instance file for syntax errors prior to starting ``my_app``
instance, say:

.. code-block:: console

    $ tarantoolctl check my_app

To enable ``my_app`` instance for auto-load during system startup, say:

.. code-block:: console

    $ systemctl enable tarantool@my_app

To stop a running ``my_app`` instance, say:

.. code-block:: console

    $ tarantoolctl stop my_app
    $ # - OR -
    $ systemctl stop tarantool@my_app

To restart (i.e. stop and start) a running ``my_app`` instance, say:

.. code-block:: console

    $ tarantoolctl restart my_app
    $ # - OR -
    $ systemctl restart tarantool@my_app

.. _admin-start_stop_instance-running_locally:

--------------------------------------------------------------------------------
Running Tarantool locally
--------------------------------------------------------------------------------

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

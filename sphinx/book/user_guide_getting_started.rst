.. _user_guide_getting_started:

===============================================================================
Getting started
===============================================================================

This chapter shows how to download, how to install, and how to start Tarantool
for the first time.

For production, if possible, you should download a binary (executable) package.
This will ensure that you have the same build of the same version that the
developers have. That makes analysis easier if later you need to report a problem,
and avoids subtle problems that might happen if you used different tools or
different parameters when building from source. The section about binaries is
":ref:`user_guide_getting_started-downloading_and_installing_a_binary_package`".

For development, you will want to download a source package and make the binary
by yourself using a C/C++ compiler and common tools. Although this is a bit harder,
it gives more control. And the source packages include additional files, for example
the Tarantool test suite. The section about source is
":ref:`Building from source <building_from_source>`" in
:ref:`Contributor's Guide <contrib_guide>`.

If the installation has already been done, then you should try it out. So we've
provided some instructions that you can use to make a temporary “sandbox”. In a
few minutes you can start the server and type in some database-manipulation
statements. The section about the sandbox is
":ref:`user_guide_getting_started-first_database`".

.. _user_guide_getting_started-downloading_and_installing_a_binary_package:

-------------------------------------------------------------------------------
Downloading and installing a binary package
-------------------------------------------------------------------------------

Binary packages for two Tarantool versions -- for the stable 1.6 and the latest
1.7 -- are provided at http://tarantool.org/download.html. An automatic build
system creates, tests and publishes packages for every push into the 1.7 branch.

To download and install the package that's appropriate for your OS, start a
shell (terminal) and enter the command-line instructions provided for your OS
at http://tarantool.org/download.html.

.. _user_guide_getting_started-first_database:

-------------------------------------------------------------------------------
Starting Tarantool and making your first database
-------------------------------------------------------------------------------

Here is how to create a simple test database after installing.

Create a new directory. It's just for tests, you can delete it when the tests
are over.

.. code-block:: console

    $ mkdir ~/tarantool_sandbox
    $ cd ~/tarantool_sandbox

Here is how to create a simple test database after installing.

Start the server. The server name is tarantool.

.. code-block:: console

    $ # if you downloaded a binary with apt-get or yum, say this:
    $ /usr/bin/tarantool
    $ # if you downloaded and untarred a binary
    $ # tarball to ~/tarantool, say this:
    $ ~/tarantool/bin/tarantool
    $ # if you built from a source download, say this:
    $ ~/tarantool/src/tarantool

The server starts in interactive mode and outputs a command prompt.
To turn on the database, :ref:`configure <box_introspection-box_cfg>` it. This
minimal example is sufficient:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}

If all goes well, you will see the server displaying progress as it initializes,
something like this:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}
    2015-08-07 09:41:41.077 ... version 1.7.0-1216-g73f7154
    2015-08-07 09:41:41.077 ... log level 5
    2015-08-07 09:41:41.078 ... mapping 1073741824 bytes for a shared arena...
    2015-08-07 09:41:41.079 ... initialized
    2015-08-07 09:41:41.081 ... initializing an empty data directory
    2015-08-07 09:41:41.095 ... creating './00000000000000000000.snap.inprogress'
    2015-08-07 09:41:41.095 ... saving snapshot './00000000000000000000.snap.inprogress'
    2015-08-07 09:41:41.127 ... done
    2015-08-07 09:41:41.128 ... primary: bound to 0.0.0.0:3301
    2015-08-07 09:41:41.128 ... ready to accept requests

Now that the server is up, you could start up a different shell and connect to
its primary port with:

.. code-block:: console

    $ telnet 0 3301

but for example purposes it is simpler to just leave the server running in
"interactive mode". On production machines the
:ref:`interactive mode <administration-using_tarantool_as_a_client>` is just for
administrators, but because it's convenient for learning it will be used for
most examples in this manual. Tarantool is waiting for the user to type
instructions.

To create the first space and the first :ref:`index <box_index>`, try this:

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('tester')
    tarantool> s:create_index('primary', {
             >   type = 'hash',
             >   parts = {1, 'unsigned'}
             > })

To insert three “tuples” (our name for “records”) into the first “space” of the
database try this:

.. code-block:: tarantoolsession

    tarantool> t = s:insert({1})
    tarantool> t = s:insert({2, 'Music'})
    tarantool> t = s:insert({3, 'Length', 93})

To select a tuple from the first space of the database, using the first defined
key, try this:

.. code-block:: tarantoolsession

    tarantool> s:select{3}

Your terminal screen should now look like this:

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('tester')
    2015-06-10 12:04:18.158 ... creating './00000000000000000000.xlog.inprogress'
    ---
    ...
    tarantool>s:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
    ---
    ...
    tarantool> t = s:insert{1}
    ---
    ...
    tarantool> t = s:insert{2, 'Music'}
    ---
    ...
    tarantool> t = s:insert{3, 'Length', 93}
    ---
    ...
    tarantool> s:select{3}
    ---
    - - [3, 'Length', 93]
    ...
    tarantool> 

Now, to prepare for the example in the next section, try this:

.. code-block:: tarantoolsession

    tarantool> box.schema.user.grant('guest', 'read,write,execute', 'universe')

-------------------------------------------------------------------------------
Connecting remotely
-------------------------------------------------------------------------------

In the previous section the first request was with ``box.cfg{listen = 3301}``.
The ``listen`` value can be any form of URI (uniform resource identifier);
in this case it's just a local port: port 3301. It's possible to send requests
to the listen URI via:

1. telnet,
2. a connector (which will be the subject of the ":ref:`index-box_connectors`"
   chapter),
3. another instance of Tarantool via the :ref:`console module <console-module>`,
4. ``tarantoolctl connect``.

Let's try (4).

Switch to another terminal. On Linux, for example, this means starting another
instance of a Bash shell. There is no need to use cd to switch to the
``~/tarantool_sandbox`` directory.

Start the ``tarantoolctl`` utility:

.. cssclass:: highlight
.. parsed-literal::

    :extsamp:`$ {**{tarantoolctl connect '3301'}**}`

This means "use :ref:`tarantoolctl connect <administration-tarantoolctl_connect>`
to connect to the Tarantool server that's listening on ``localhost:3301``".

Try this request:

.. cssclass:: highlight
.. parsed-literal::

    tarantool> {**{box.space.tester:select{2}}**}

This means "send a request to that Tarantool server, and display the result".
The result in this case is one of the tuples that was inserted earlier. Your
terminal screen should now look like this:

.. code-block:: tarantoolsession

    $ tarantoolctl connect 3301
    /usr/local/bin/tarantoolctl: connected to localhost:3301
    localhost:3301> box.space.tester:select{2}
    ---
    - - [2, 'Music']
    ...

    localhost:3301> 

You can repeat ``box.space...:insert{}`` and ``box.space...:select{}``
indefinitely, on either Tarantool instance.

When the testing is over:

* To drop the space: ``s:drop()``
* To stop ``tarantoolctl``: Ctrl+C or Ctrl+D
* To stop Tarantool (an alternative): the standard Lua function
  `os.exit() <http://www.lua.org/manual/5.1/manual.html#pdf-os.exit>`_
* To stop Tarantool (from another terminal): ``sudo pkill -f tarantool``
* To destroy the test: ``rm -r ~/tarantool_sandbox``

**To review...** If you followed all the instructions in this chapter, then so
far you have: installed Tarantool from a binary repository,
started up the Tarantool server, inserted and selected tuples.

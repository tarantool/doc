.. _getting_started-using_binary:

================================================================================
Using a binary package
================================================================================

For production purposes, we recommend
`official binary packages <http://tarantool.org/download.html>`_.
You can choose from two Tarantool versions: the stable 1.6 and the latest 1.7.
An automatic build system creates, tests and publishes 1.7 packages for every
push into the 1.7 branch at
`Tarantool's GitHub repository <https://github.com/tarantool/tarantool>`_.

To download and install the package that’s appropriate for your OS,
start a shell (terminal) and enter the command-line instructions provided
for your OS at Tarantool's `download page <http://tarantool.org/download.html>`_.

--------------------------------------------------------------------------------
Starting Tarantool
--------------------------------------------------------------------------------

To start the Tarantool server, say this:

.. code-block:: console

   $ # if you downloaded a binary with apt-get or yum, say this:
   $ /usr/bin/tarantool
   $ # if you downloaded and untarred a binary tarball to ~/tarantool, say this:
   $ ~/tarantool/bin/tarantool

Tarantool starts in the interactive mode and displays a prompt:

.. code-block:: tarantoolsession

   tarantool>

Now you can enter requests on the command line.

.. NOTE::

   On production machines, Tarantool's interactive mode is for system
   administration only. But we use it for most examples in this manual,
   because the interactive mode is convenient for learning.

--------------------------------------------------------------------------------
Creating a database
--------------------------------------------------------------------------------

Here is how to create a simple test database after installing.

Create a new directory (it’s just for tests, so you can delete it when the tests
are over):

.. code-block:: console

   $ mkdir ~/tarantool_sandbox
   $ cd ~/tarantool_sandbox

To start Tarantool's database module and make the server accept TCP requests
on port 3001, say this:

.. code-block:: tarantoolsession

   tarantool> box.cfg{listen = 3301}

First, create the first :ref:`space <index-box_space>` (named 'tester')
and the first :ref:`index <index-box_index>` (named 'primary'):

.. code-block:: tarantoolsession

   tarantool> s = box.schema.space.create('tester')
   tarantool> s:create_index('primary', {
                 >  type = 'hash',
                 >  parts = {1, 'unsigned'}
                 > })

Next, insert three :ref:`tuples <index-box_tuple>` (our name for "records")
into the space:

.. code-block:: tarantoolsession

   tarantool> t = s:insert({1, 'Roxette'})
   tarantool> t = s:insert({2, 'Scorpions', 2015})
   tarantool> t = s:insert({3, 'Ace of Base', 1993})


To select a tuple from the first space of the database, using the first defined
key, say:

.. code-block:: tarantoolsession

   tarantool> s:select{3}

The terminal screen now looks like this:

.. code-block:: tarantoolsession

   tarantool> s = box.schema.space.create('tester')
   2017-01-17 12:04:18.158 ... creating './00000000000000000000.xlog.inprogress'
   ---
   ...
   tarantool>s:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
   ---
   ...
   tarantool> t = s:insert{1, 'Roxette'}
   ---
   ...
   tarantool> t = s:insert{2, 'Scorpions', 2015}
   ---
   ...
   tarantool> t = s:insert{3, 'Ace of Base', 1993}
   ---
   ...
   tarantool> s:select{3}
   ---
   - - [3, 'Length', 93]
   ...
   tarantool>

--------------------------------------------------------------------------------
Connecting remotely
--------------------------------------------------------------------------------

In the request ``box.cfg{listen = 3301}`` that we made earlier, the ``listen``
value can be any form of a :ref:`URI <index-uri>` (uniform resource identifier).
In this case, it’s just a local port: port 3301. You can send requests to the
listen URI via:

(1) ``telnet``,
(2) a :ref:`connector <index-box_connectors>`,
(3) another instance of Tarantool (using the :ref:`console <console-module>` module), or
(4) :ref:`tarantoolctl <administration-tarantoolctl>` utility.

Let’s try (4).

Switch to another terminal. On Linux, for example, this means starting another
instance of a Bash shell. You can switch to any working directory in the new
terminal, not necessarily to ``~/tarantool_sandbox``.

Start the ``tarantoolctl`` utility:

.. code-block:: console

   $ tarantoolctl connect '3301'

This means "use ``tarantoolctl connect`` to connect to the Tarantool server
that’s listening on ``localhost:3301``".

Try this request:

.. code-block:: tarantoolsession

   tarantool> {{box.space.tester:select{2}}}

This means "send a request to that Tarantool server, and display the result".
The result in this case is one of the tuples that was inserted earlier.
Your terminal screen should now look like this:

.. code-block:: tarantoolsession

   $ tarantoolctl connect 3301
   /usr/local/bin/tarantoolctl: connected to localhost:3301
   localhost:3301> box.space.tester:select{2}
   ---
   - - [2, 'Scorpions', 2015]
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

.. _getting_started-using_package_manager:

--------------------------------------------------------------------------------
Using a package manager
--------------------------------------------------------------------------------

For production purposes, we recommend that you install Tarantool via the 
`official package manager <http://tarantool.org/download.html>`_.
You can choose one of three versions: LTS, stable, or beta.
An automatic build system creates, tests and publishes packages for every
push into a corresponding branch at
`Tarantool's GitHub repository <https://github.com/tarantool/tarantool>`_.

To download and install the package that's appropriate for your OS,
start a shell (terminal) and enter the command-line instructions provided
for your OS at Tarantool's `download page <http://tarantool.org/download.html>`_.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Starting Tarantool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To start working with Tarantool, start a terminal and run this:

.. code-block:: console

    $ tarantool
    $ # by doing this, you create a new Tarantool instance

Tarantool starts in interactive mode and displays a prompt:

.. code-block:: tarantoolsession

    tarantool>

Now you can enter requests on the command line.

.. NOTE::

    On production machines, Tarantool's interactive mode is designed for system
    administration only. We use it for most examples in this manual 
    because it is convenient for learning.

.. _creating-db-locally:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating a database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is how to create a simple test database after installation.

#. To let Tarantool store data in a separate place, create a new directory
   dedicated for tests:

   .. code-block:: console

      $ mkdir ~/tarantool_sandbox
      $ cd ~/tarantool_sandbox

   You can delete the directory when the tests are completed.

#. Check if the default port that the database instance will listen to is vacant.

   In versions before :doc:`2.4.2 </release/2.4.2>`, during installation
   the Tarantool packages for Debian and Ubuntu automatically enable and start
   the demonstrative global ``example.lua`` instance that
   listens to the ``3301`` port by default. The ``example.lua`` file showcases
   the basic configuration and can be found in the ``/etc/tarantool/instances.enabled``
   or ``/etc/tarantool/instances.available`` directories.

   However, we encourage you to perform the instance startup manually, so you
   can learn.

   Make sure the default port is vacant:

   #. To check if the demonstrative instance is running, run:

      .. code-block:: console

         $ lsof -i :3301
         COMMAND    PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
         tarantool 6851 root   12u  IPv4  40827      0t0  TCP *:3301 (LISTEN)

   #. If it is running, kill the corresponding process. In this example:

      .. code-block:: console

         $ kill 6851

#. To start Tarantool's database module and make the instance accept TCP requests
   on port ``3301``, run:

   .. code-block:: tarantoolsession

      tarantool> box.cfg{listen = 3301}

#. Create the first :term:`space <space>` (named ``tester``):

   .. code-block:: tarantoolsession

      tarantool> s = box.schema.space.create('tester')

#. Format the created space by specifying :term:`field` names and :ref:`types <index-box_data-types>`:

   .. code-block:: tarantoolsession

      tarantool> s:format({
               > {name = 'id', type = 'unsigned'},
               > {name = 'band_name', type = 'string'},
               > {name = 'year', type = 'unsigned'}
               > })

#. Create the first :ref:`index <index-box_index>` (named ``primary``):

   .. code-block:: tarantoolsession

      tarantool> s:create_index('primary', {
               > type = 'tree',
               > parts = {'id'}
               > })

   This is a primary index based on the ``id`` field of each tuple.

#. Insert three :term:`tuples <tuple>` (our name for records)
   into the space:

   .. code-block:: tarantoolsession

      tarantool> s:insert{1, 'Roxette', 1986}
      tarantool> s:insert{2, 'Scorpions', 2015}
      tarantool> s:insert{3, 'Ace of Base', 1993}

#. To select a tuple using the ``primary`` index, run:

   .. code-block:: tarantoolsession

      tarantool> s:select{3}

   The terminal screen now looks like this:

   .. code-block:: tarantoolsession

      tarantool> s = box.schema.space.create('tester')
      ---
      ...
      tarantool> s:format({
               > {name = 'id', type = 'unsigned'},
               > {name = 'band_name', type = 'string'},
               > {name = 'year', type = 'unsigned'}
               > })
      ---
      ...
      tarantool> s:create_index('primary', {
               > type = 'tree',
               > parts = {'id'}
               > })
      ---
      - unique: true
        parts:
        - type: unsigned
          is_nullable: false
          fieldno: 1
        id: 0
        space_id: 512
        name: primary
        type: TREE
      ...
      tarantool> s:insert{1, 'Roxette', 1986}
      ---
      - [1, 'Roxette', 1986]
      ...
      tarantool> s:insert{2, 'Scorpions', 2015}
      ---
      - [2, 'Scorpions', 2015]
      ...
      tarantool> s:insert{3, 'Ace of Base', 1993}
      ---
      - [3, 'Ace of Base', 1993]
      ...
      tarantool> s:select{3}
      ---
      - - [3, 'Ace of Base', 1993]
      ...

#. To add a secondary index based on the ``band_name`` field, run:

   .. code-block:: tarantoolsession

      tarantool> s:create_index('secondary', {
               > type = 'tree',
               > parts = {'band_name'}
               > })

#. To select tuples using the ``secondary`` index, run:

   .. code-block:: tarantoolsession

      tarantool> s.index.secondary:select{'Scorpions'}
      ---
      - - [2, 'Scorpions', 2015]
      ...

#. Now, to prepare for the example in the next section, try this:

   .. code-block:: tarantoolsession

      tarantool> box.schema.user.grant('guest', 'read,write,execute', 'universe')

.. _connecting-remotely:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Connecting remotely
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the request ``box.cfg{listen = 3301}`` that we made earlier, the ``listen``
value can be any form of a :ref:`URI <index-uri>` (uniform resource identifier).
In this case, it’s just a local port: port ``3301``. You can send requests to the
listen URI via:

(1) ``telnet``,
(2) a :ref:`connector <index-box_connectors>`,
(3) another instance of Tarantool (using the :ref:`console <console-module>` module), or
(4) :ref:`tarantoolctl <tarantoolctl>` administrative utility.

Let’s try (3).

Switch to another terminal. On Linux, for example, this means starting another
instance of a Bash shell. You can switch to any working directory in the new
terminal, not necessarily to ``~/tarantool_sandbox``.

Start another instance of ``tarantool``:

.. code-block:: console

    $ tarantool

Use ``net.box`` to connect to the Tarantool instance
that’s listening on ``localhost:3301``":

.. code-block:: tarantoolsession

    tarantool> net_box = require('net.box')
    ---
    ...
    tarantool> conn = net_box.connect(3301)
    ---
    ...

Try this request:

.. code-block:: tarantoolsession

    tarantool> conn.space.tester:select{2}

This means "send a request to that Tarantool instance, and display the result".
It is equivalent to the local request ``box.space.tester:select{2}``.
The result in this case is one of the tuples that was inserted earlier.
Your terminal screen should now look like this:

.. code-block:: tarantoolsession

    $ tarantool

    Tarantool 2.6.1-32-g53dbba7c2
    type 'help' for interactive help
    tarantool> net_box = require('net.box')
    ---
    ...
    tarantool> conn = net_box.connect(3301)
    ---
    ...
    tarantool> conn.space.tester:select{2}
    ---
    - - [2, 'Scorpions', 2015]
    ...

You can repeat ``box.space...:insert{}`` and ``box.space...:select{}``
(or ``conn.space...:insert{}`` and ``conn.space...:select{}``)
indefinitely, on either Tarantool instance.

When the testing is over:

* To drop the space: ``s:drop()``
* To stop ``tarantool``: Ctrl+C or Ctrl+D
* To stop Tarantool (an alternative): the standard Lua function
  `os.exit() <http://www.lua.org/manual/5.1/manual.html#pdf-os.exit>`_
* To stop Tarantool (from another terminal): ``sudo pkill -f tarantool``
* To destroy the test: ``rm -r ~/tarantool_sandbox``

.. _getting_started-using_binary:

--------------------------------------------------------------------------------
Using a binary package
--------------------------------------------------------------------------------

For production purposes, we recommend
`official binary packages <http://tarantool.org/download.html>`_.
You can choose from two Tarantool versions: ``1.10`` (stable) or ``2.2`` (beta).
An automatic build system creates, tests and publishes packages for every
push into a corresponding branch (``1.10`` or ``2.2``) at
`Tarantool's GitHub repository <https://github.com/tarantool/tarantool>`_.

To download and install the package that’s appropriate for your OS,
start a shell (terminal) and enter the command-line instructions provided
for your OS at Tarantool's `download page <http://tarantool.org/download.html>`_.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Starting Tarantool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To start a Tarantool instance, say this:

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

   You can delete the directory when the tests are over.

#. Check if the default port the database instance will listen to is vacant.

   Depending on the release, during installation Tarantool may start a
   demonstrative global ``example.lua`` instance that listens to the
   ``3301`` port by default. The ``example.lua`` file showcases basic
   configuration and can be found in the ``/etc/tarantool/instances.enabled``
   or ``/etc/tarantool/instances.available`` directories.

   However, we encourage you to perform the instance startup manually, so you
   can learn.

   Make sure the default port is vacant:

   #. To check if the demonstrative instance is running, say:

      .. code-block:: console

         $ lsof -i :3301
         COMMAND    PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
         tarantool 6851 root   12u  IPv4  40827      0t0  TCP *:3301 (LISTEN)

   #. If it does, kill the corresponding process. In this example:

      .. code-block:: console

         $ kill 6851

#. To start Tarantool's database module and make the instance accept TCP requests
   on port ``3301``, say:

   .. code-block:: tarantoolsession

      tarantool> box.cfg{listen = 3301}

#. Create the first :ref:`space <index-box_space>` (named ``tester``):

   .. code-block:: tarantoolsession

      tarantool> s = box.schema.space.create('tester')

#. Format the created space by specifying field names and types:

   .. code-block:: tarantoolsession

      tarantool> s:format({
               > {name = 'id', type = 'unsigned'},
               > {name = 'band_name', type = 'string'},
               > {name = 'year', type = 'unsigned'}
               > })

#. Create the first :ref:`index <index-box_index>` (named ``primary``):

   .. code-block:: tarantoolsession

      tarantool> s:create_index('primary', {
               > type = 'hash',
               > parts = {'id'}
               > })

   This is a primary index based on the ``id`` field of each tuple.

#. Insert three :ref:`tuples <index-box_tuple>` (our name for records)
   into the space:

   .. code-block:: tarantoolsession

      tarantool> s:insert{1, 'Roxette', 1986}
      tarantool> s:insert{2, 'Scorpions', 2015}
      tarantool> s:insert{3, 'Ace of Base', 1993}

#. To select a tuple using the ``primary`` index, say:

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
               > type = 'hash',
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
        type: HASH
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

#. To add a secondary index based on the ``band_name`` field, say:

   .. code-block:: tarantoolsession

      tarantool> s:create_index('secondary', {
               > type = 'hash',
               > parts = {'band_name'}
               > })

#. To select tuples using the ``secondary`` index, say:

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
(4) :ref:`tarantoolctl <tarantoolctl>` utility.

Let’s try (4).

Switch to another terminal. On Linux, for example, this means starting another
instance of a Bash shell. You can switch to any working directory in the new
terminal, not necessarily to ``~/tarantool_sandbox``.

Start the ``tarantoolctl`` utility:

.. code-block:: console

    $ tarantoolctl connect '3301'

This means "use ``tarantoolctl connect`` to connect to the Tarantool instance
that’s listening on ``localhost:3301``".

Try this request:

.. code-block:: tarantoolsession

    localhost:3301> box.space.tester:select{2}

This means "send a request to that Tarantool instance, and display the result".
The result in this case is one of the tuples that was inserted earlier.
Your terminal screen should now look like this:

.. code-block:: tarantoolsession

    $ tarantoolctl connect 3301
    /usr/local/bin/tarantoolctl: connected to localhost:3301
    localhost:3301> box.space.tester:select{2}
    ---
    - - [2, 'Scorpions', 2015]
    ...

You can repeat ``box.space...:insert{}`` and ``box.space...:select{}``
indefinitely, on either Tarantool instance.

When the testing is over:

* To drop the space: ``s:drop()``
* To stop ``tarantoolctl``: Ctrl+C or Ctrl+D
* To stop Tarantool (an alternative): the standard Lua function
  `os.exit() <http://www.lua.org/manual/5.1/manual.html#pdf-os.exit>`_
* To stop Tarantool (from another terminal): ``sudo pkill -f tarantool``
* To destroy the test: ``rm -r ~/tarantool_sandbox``

.. _getting_started-using_docker:

================================================================================
Using a Docker image
================================================================================

For trial and test purposes, we recommend using
`official Tarantool images for Docker <https://github.com/tarantool/docker>`_.
An official image contains a particular Tarantool version (1.6 or 1.7) and
all popular external modules for Tarantool.
Everything is already installed and configured in Linux.
These images are the easiest way to install and use Tarantool.

.. NOTE::

    If you're new to Docker, we recommend going over
    `this tutorial <https://docs.docker.com/engine/getstarted/step_one/>`_
    before proceeding with this chapter.

.. _getting_started-launching_a-container:

--------------------------------------------------------------------------------
Launching a container
--------------------------------------------------------------------------------

If you don't have Docker installed, please follow the official
`installation guide <https://docs.docker.com/engine/getstarted/step_one/#/step-1-get-docker>`_
for your OS.

To start a fully functional Tarantool instance, run a container with minimal
options:

.. code-block:: console

   $ docker run \
     --name mytarantool \
     -d -p 3301:3301 \
     -v /data/dir/on/host:/var/lib/tarantool \
     tarantool/tarantool:1.7

This command runs a new container named 'mytarantool'.
Docker starts it from an official image named 'tarantool/tarantool:1.7',
with Tarantool version 1.7 and all external modules already installed.

Tarantool will be accepting incoming connections on ``localhost:3301``.
You may start using it as a key-value storage right away.

Tarantool :ref:`persists data <index-box_persistence>` inside the container.
To make your test data available after you stop the container,
this command also mounts the host's directory ``/data/dir/on/host``
(you need to specify here an absolute path to an existing local directory)
in the container's directory ``/var/lib/tarantool``
(by convention, Tarantool in a container uses this directory to persist data).
So, all changes made in the mounted directory on the container's side
are applied to the host's disk.

Tarantool's database module in the container is already
:ref:`configured <box_introspection-box_cfg>` and started.
You needn't do it manually, unless you use Tarantool as an
:ref:`application server <app_server>` and run it with an application.

--------------------------------------------------------------------------------
Attaching to Tarantool
--------------------------------------------------------------------------------

To attach to Tarantool that runs inside the container, say:

.. code-block:: console

   $ docker exec -i -t mytarantool console

This command:

* Instructs Tarantool to open an interactive console port for incoming connections.
* Attaches to the Tarantool server inside the container under 'admin' user via
  a standard Unix socket.

Tarantool displays a prompt:

.. code-block:: tarantoolsession

   tarantool.sock>

Now you can enter requests on the command line.

.. NOTE::

   On production machines, Tarantool's interactive mode is for system
   administration only. But we use it for most examples in this manual,
   because the interactive mode is convenient for learning.

--------------------------------------------------------------------------------
Creating a database
--------------------------------------------------------------------------------

While you're attached to the console, let's create a simple test database.

First, create the first :ref:`space <index-box_space>` (named 'tester')
and the first :ref:`index <index-box_index>` (named 'primary'):

.. code-block:: tarantoolsession

   tarantool.sock> s = box.schema.space.create('tester')
   tarantool.sock> s:create_index('primary', {
                 >  type = 'hash',
                 >  parts = {1, 'unsigned'}
                 > })

Next, insert three :ref:`tuples <index-box_tuple>` (our name for "records")
into the space:

.. code-block:: tarantoolsession

   tarantool.sock> t = s:insert({1, 'Roxette'})
   tarantool.sock> t = s:insert({2, 'Scorpions', 2015})
   tarantool.sock> t = s:insert({3, 'Ace of Base', 1993})

To select a tuple from the first space of the database, using the first
defined key, say:

.. code-block:: tarantoolsession

   tarantool.sock> s:select{3}

The terminal screen now looks like this:

.. code-block:: tarantoolsession

   tarantool.sock> s = box.schema.space.create('tester')
   2017-01-17 12:04:18.158 ... creating './00000000000000000000.xlog.inprogress'
   ---
   ...
   tarantool.sock> s:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
   ---
   ...
   tarantool.sock> t = s:insert{1, 'Roxette'}
   ---
   ...
   tarantool.sock> t = s:insert{2, 'Scorpions', 2015}
   ---
   ...
   tarantool.sock> t = s:insert{3, 'Ace of Base', 1993}
   ---
   ...
   tarantool.sock> s:select{3}
   ---
   - - [3, 'Ace of Base', 1993]
   ...
   tarantool.sock>

To add another index on the second field, say:

.. code-block:: tarantoolsession

   tarantool.sock> s:create_index('secondary', {
                 >  type = 'hash',
                 >  parts = {2, 'string'}
                 > })

--------------------------------------------------------------------------------
Stopping a container
--------------------------------------------------------------------------------

When the testing is over, stop the container politely:

.. code-block:: console

   $ docker stop mytarantool

This was a temporary container, and its disk/memory data were flushed when you
stopped it. But since you mounted a data directory from the host in the container,
Tarantool's data files were persisted to the host's disk. Now if you start a new
container and mount that data directory in it, Tarantool will recover all data
from disk and continue working with the persisted data.


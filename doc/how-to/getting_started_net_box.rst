.. _getting_started_net_box:

Getting started with net.box
============================

The tutorial shows the use of some of the ``net.box`` methods.

For more information about the ``net.box`` module,
check the :ref:`corresponding module reference <net_box-module>`.

Sandbox configuration
---------------------

The sandbox configuration for the tutorial assumes that:

*   The Tarantool instance is running on ``localhost 127.0.0.1:3301``.
*   There is a space named ``tester`` with a numeric primary key.
*   The space contains a tuple with a key value = ``800``.
*   The current user has read, write, and execute privileges.

Use the commands below for a quick sandbox setup:

..  code-block:: lua

    box.cfg{listen = 3301}
    s = box.schema.space.create('tester')
    s:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
    t = s:insert({800, 'TEST'})
    box.schema.user.grant('guest', 'read,write,execute', 'universe')

Creating a net.box connection
-----------------------------

To start working with ``net.box``, get the ``net.box`` object:

..  code-block:: tarantoolsession

    tarantool> net_box = require('net.box')
    ---
    ...

During the sandbox setup, ``box.cfg{...listen="3301"`` was called.
It means that the local server listen address is ``3301``.
If the connection fails, check the actual listen address.

The next step is to create a new connection.
In ``net.box``, self connection is pre-established.
That is, ``conn = net_box.connect('localhost:3301')`` can be replaced with the following command:

..  code-block:: tarantoolsession

    tarantool> conn = net_box.self
    ---
    ...

Then, make a ping:

..  code-block:: tarantoolsession

    tarantool> conn:ping()
    ---
    - true
    ...

Manipulating data
-----------------

The ``select`` command below returns all tuples in the ``tester`` space where the key value is 800:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:select{800}
    ---
    - - [800, 'TEST']
    ...

Now, let's insert two tuples in the space:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:insert({700, 'TEST700'})
    ---
    - [700, 'TEST700']
    ...
    tarantool> conn.space.tester:insert({600, 'TEST600'})
    ---
    - [600, 'TEST600']
    ...

After the insert, we have one tuple where the key value is ``600``.
To select this tuple, you can use the ``get()`` method.
Unlike the ``select()`` command, ``get()`` returns only one tuple that satisfies the stated condition.

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:get({600})
    ---
    - [600, 'TEST600']
    ...

To update the existing tuple, you can use either ``update()`` or ``upsert``.
Use the first one to ...

..  code-block:: tarantoolsession

    -- Update the existing tuple
    tarantool> conn.space.tester:update(800, {{'=', 2, 'TEST800'}})
    ---
    - [800, 'TEST800']
    ...

Use ``upsert`` to...

..  code-block:: tarantoolsession

    -- Update the existing tuple
    tarantool> conn.space.tester:upsert({500, 'TEST500'}, {{'=', 2, 'TEST'}})
    ---
    ...

To delete a tuple, run the method below:

..  code-block:: tarantoolsession

    -- Delete tuples where the key value is 600
    tarantool> conn.space.tester:delete{600}
    ---
    - [600, 'TEST600']
    ...

Now, let's replace the existing tuple with a new one

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:replace{500, 'New data', 'Extra data'}
    ---
    - [500, 'New data', 'Extra data']
    ...

Finally, let's select all tuples stored in the space:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:select{}
    ---
    - - [800, 'TEST800']
      - [500, 'New data', 'Extra data']
      - [700, 'TEST700']
    ...

In the end, close the connection when it is no longer needed:

..  code-block:: tarantoolsession

    tarantool> conn:close()
    ---
    ...
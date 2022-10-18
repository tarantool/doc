.. _getting_started_net_box:

Getting started with net.box
============================

The tutorial shows how to work with some common ``net.box`` methods.

For more information about the ``net.box`` module,
check the :ref:`corresponding module reference <net_box-module>`.

Sandbox configuration
---------------------

The sandbox configuration for the tutorial assumes that:

*   The Tarantool instance is running on ``localhost 127.0.0.1:3301``.
*   There is a space named ``tester`` with a numeric primary key.
*   The space contains a tuple with the key value = ``800``.
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

First, load the ``net.box`` module with the ``require('net.box')`` method:

..  code-block:: tarantoolsession

    tarantool> net_box = require('net.box')

The next step is to create a new connection.
In ``net.box``, self-connection is pre-established.
That is, ``conn = net_box.connect('localhost:3301')`` command can be replaced with the ``conn = net_box.self`` object call:

..  code-block:: tarantoolsession

    tarantool> conn = net_box.self

Then, make a ping:

..  code-block:: tarantoolsession

    tarantool> conn:ping()
    ---
    - true
    ...

Using data operations
---------------------

Select all tuples in the ``tester`` space where the key value is ``800``:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:select{800}
    ---
    - - [800, 'TEST']
    ...

Insert two tuples into the space:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:insert({700, 'TEST700'})
    ---
    - [700, 'TEST700']
    ...
    tarantool> conn.space.tester:insert({600, 'TEST600'})
    ---
    - [600, 'TEST600']
    ...

After the insert, there is one tuple where the key value is ``600``.
To select this tuple, you can use the ``get()`` method.
Unlike the ``select()`` command, ``get()`` returns only one tuple that satisfies the stated condition.

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:get({600})
    ---
    - [600, 'TEST600']
    ...

To update the existing tuple, you can use either ``update()`` or ``upsert()``.
The ``update()`` method can be used for assignment, arithmetic (if the field is numeric),
cutting and pasting fragments of a field, and deleting or inserting a field.

In this tutorial, the ``update()`` command is used to update the tuple identified by primary key value = ``800``.
The operation assigns a new value to the second field in the tuple:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:update(800, {{'=', 2, 'TEST800'}})
    ---
    - [800, 'TEST800']
    ...

As for the ``upsert`` function, if there is an existing tuple that matches the key field of tuple, then the command
has the same effect as ``update()``.
Otherwise, the effect is equal to the ``insert()`` method.

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:upsert({500, 'TEST500'}, {{'=', 2, 'TEST'}})

To delete a tuple where the key value is ``600``, run the ``delete()`` method below:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:delete{600}
    ---
    - [600, 'TEST600']
    ...

Then, replace the existing tuple with a new one:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:replace{500, 'New data', 'Extra data'}
    ---
    - [500, 'New data', 'Extra data']
    ...

Finally, select all tuples from the space:

..  code-block:: tarantoolsession

    tarantool> conn.space.tester:select{}
    ---
    - - [800, 'TEST800']
      - [500, 'New data', 'Extra data']
      - [700, 'TEST700']
    ...

Closing the connection
----------------------

In the end, close the connection when it is no longer needed:

..  code-block:: tarantoolsession

    tarantool> conn:close()
    ---
    ...
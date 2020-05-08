.. _getting_started-php:

--------------------------------------------------------------------------------
Connecting from PHP
--------------------------------------------------------------------------------

.. _getting_started-php-pre-requisites:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Pre-requisites
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before we proceed:

#. `Install <https://github.com/tarantool-php/client#installation>`_
   the ``tarantool/client`` library.

#. :ref:`Start <getting_started_db>` Tarantool (locally or in Docker)
   and make sure that you have created and populated a database as we suggested
   :ref:`earlier <creating-db-locally>`:

   .. code-block:: lua

       box.cfg{listen = 3301}
       s = box.schema.space.create('tester')
       s:format({
                {name = 'id', type = 'unsigned'},
                {name = 'band_name', type = 'string'},
                {name = 'year', type = 'unsigned'}
                })
       s:create_index('primary', {
                type = 'hash',
                parts = {'id'}
                })
       s:create_index('secondary', {
                type = 'hash',
                parts = {'band_name'}
                })
       s:insert{1, 'Roxette', 1986}
       s:insert{2, 'Scorpions', 2015}
       s:insert{3, 'Ace of Base', 1993}

   .. IMPORTANT::

       Please do not close the terminal window
       where Tarantool is running -- you'll need it soon.

#. In order to connect to Tarantool as an administrator, reset the password
   for the ``admin`` user:

   .. code-block:: lua

       box.schema.user.passwd('pass')

.. _getting_started-php-connecting:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Connecting to Tarantool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get connected to the Tarantool server, say this:

.. code-block:: php

    use Tarantool\Client\Client;

    require __DIR__.'/vendor/autoload.php';
    $client = Client::fromDefaults();

You can also specify the user name and password, if needed:

.. code-block:: php

    $client = Client::fromOptions([
        'uri' => 'tcp://127.0.0.1:3301',
        'username' => '<username>',
        'password' => '<password>'
    ]);

The default user is ``guest``.

.. _getting_started-php-manipulate:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Manipulating the data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A **space** is a container for **tuples**. To access a space as a named object,
use ``getSpace``:

.. code-block:: php

    $tester = $client->getSpace('tester');

.. _getting_started-php-insert:

********************************************************************************
Inserting data
********************************************************************************

To insert a tuple into a space, use ``insert``:

.. code-block:: php

    $result = $tester->insert([4, 'ABBA', 1972]);

.. _getting_started-php-query:

********************************************************************************
Querying data
********************************************************************************

Let's start with selecting a tuple by the primary key
(in our example, this is the index named ``primary``, based on the ``id`` field
of each tuple). Use ``select``:

.. code-block:: php

    use Tarantool\Client\Schema\Criteria;

    $result = $tester->select(Criteria::key([4]));
    printf(json_encode($result));

.. code-block:: none

    [[4, 'ABBA', 1972]]

Next, select tuples by a secondary key.
For this purpose, you need to specify the number *or* name of the index.

First off, select tuples using the index number:

.. code-block:: php

    $result = $tester->select(Criteria::index(1)->andKey(['Scorpions']));
    printf(json_encode($result));

.. code-block:: none

    [2, 'Scorpions', 2015]

(We say ``index(1)`` because index numbers in Tarantool start with 0,
and we're using our second index here.)

Now make a similar query by the index name and make sure that the result
is the same:

.. code-block:: php

    $result = $tester->select(Criteria::index('secondary')->andKey(['Scorpions']));
    printf(json_encode($result));

.. code-block:: none

    [2, 'Scorpions', 2015]

Finally, select all the tuples in a space via a ``select``:

.. code-block:: php

    $result = $tester->select(Criteria::allIterator());

.. _getting_started-php-update:

********************************************************************************
Updating data
********************************************************************************

Update a field value using ``update``:

.. code-block:: php

    use Tarantool\Client\Schema\Operations;

    $result = $tester->update([4], Operations::set(1, 'New group')->andAdd(2, 2));

This updates the value of field ``1`` and increases the value of field ``2``
in the tuple with ``id`` = 4. If a tuple with this ``id`` doesn't exist,
Tarantool will return an error.

Now use ``replace`` to totally replace the tuple that matches the
primary key. If a tuple with this primary key doesn't exist, Tarantool will
do nothing.

.. code-block:: php

    $result = $tester->replace([4, 'New band', 2015]);

You can also update the data using ``upsert`` that works similarly
to ``update``, but creates a new tuple if the old one was not found.

.. code-block:: php

    use Tarantool\Client\Schema\Operations;

    $tester->upsert([4, 'Another band', 2000], Operations::add(2, 5));

This increases by 5 the value of field ``2`` in the tuple with ``id`` = 4, -- or
inserts the tuple ``(4, "Another band", 2000)`` if a tuple with this ``id``
doesn't exist.

.. _getting_started-php-delete:

********************************************************************************
Deleting data
********************************************************************************

To delete a tuple, use ``delete(primary_key)``:

.. code-block:: php

    $result = $tester->delete([4]);

To delete all tuples in a space (or to delete an entire space), use ``call``.
We'll focus on this function in more detail in the
:ref:`next <getting_started-php-stored-procs>` section.

To delete all tuples in a space, call ``space:truncate``:

.. code-block:: php

    $result = $client->call('box.space.tester:truncate');

To delete an entire space, call ``space:drop``.
This requires connecting to Tarantool as the ``admin`` user:

.. code-block:: php

    $result = $client->call('box.space.tester:drop');

.. _getting_started-php-stored-procs:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Executing stored procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Switch to the terminal window where Tarantool is running.

.. NOTE::

    If you don't have a terminal window with remote connection to Tarantool,
    check out these guides:

    * :ref:`connecting to a local Tarantool instance <connecting-remotely>`
    * :ref:`attaching to a Tarantool instance that runs in a Docker container <getting_started-docker-attaching>`

Define a simple Lua function:

.. code-block:: lua

    function sum(a, b)
        return a + b
    end

Now we have a Lua function defined in Tarantool. To invoke this function from
``php``, use ``call``:

.. code-block:: php

    $result = $client->call('sum', 3, 2);

To send bare Lua code for execution, use ``eval``:

.. code-block:: php

    $result = $client->evaluate('return 4 + 5');

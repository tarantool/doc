.. _getting_started-go:

--------------------------------------------------------------------------------
Connecting from Go
--------------------------------------------------------------------------------

.. _getting_started-go-pre-requisites:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Pre-requisites
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before we proceed:

#. `Install <https://github.com/tarantool/go-tarantool#installation>`_
   the ``go-tarantool`` library.

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

.. _getting_started-go-connecting:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Connecting to Tarantool
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get connected to the Tarantool server, write a simple Go program:

.. code-block:: go

    package main

    import (
    	"fmt"

    	"github.com/tarantool/go-tarantool"
    )

    func main() {

    	conn, err := tarantool.Connect("127.0.0.1:3301", tarantool.Opts{
    		User: "admin",
    		Pass: "pass",
    	})

    	if err != nil {
    		log.Fatalf("Connection refused")
    	}

    	defer conn.Close()

    	// Your logic for interacting with the database
    }

The default user is ``guest``.

.. _getting_started-go-manipulate:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Manipulating the data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _getting_started-go-insert:

********************************************************************************
Inserting data
********************************************************************************

To insert a tuple into a space, use ``Insert``:

.. code-block:: go

    resp, err = conn.Insert("tester", []interface{}{4, "ABBA", 1972})

This inserts the tuple ``(4, "ABBA", 1972)`` into a space named ``tester``.

The response code and data are available in the
`tarantool.Response <https://github.com/tarantool/go-tarantool#usage>`_
structure:

.. code-block:: go

    code := resp.Code
    data := resp.Data

.. _getting_started-go-query:

********************************************************************************
Querying data
********************************************************************************

To select a tuple from a space, use
`Select <https://github.com/tarantool/go-tarantool#api-reference>`_:

.. code-block:: go

    resp, err = conn.Select("tester", "primary", 0, 1, tarantool.IterEq, []interface{}{4})

This selects a tuple by the primary key with ``offset`` = 0 and ``limit`` = 1
from a space named ``tester`` (in our example, this is the index named ``primary``,
based on the ``id`` field of each tuple).

Next, select tuples by a secondary key.

.. code-block:: go

    resp, err = conn.Select("tester", "secondary", 0, 1, tarantool.IterEq, []interface{}{"ABBA"})

Finally, it would be nice to select all the tuples in a space. But there is no
one-liner for this in Go; you would need a script like
:ref:`this one <cookbook-select-all-go>`.

For more examples, see https://github.com/tarantool/go-tarantool#usage

.. _getting_started-go-update:

********************************************************************************
Updating data
********************************************************************************

Update a field value using ``Update``:

.. code-block:: go

    resp, err = conn.Update("tester", "primary", []interface{}{4}, []interface{}{[]interface{}{"+", 2, 3}})

This increases by 3 the value of field ``2`` in the tuple with ``id`` = 4.
If a tuple with this ``id`` doesn't exist, Tarantool will return an error.

Now use ``Replace`` to totally replace the tuple that matches the
primary key. If a tuple with this primary key doesn't exist, Tarantool will
do nothing.

.. code-block:: go

    resp, err = conn.Replace("tester", []interface{}{4, "New band", 2011})

You can also update the data using ``Upsert`` that works similarly
to ``Update``, but creates a new tuple if the old one was not found.

.. code-block:: go

    resp, err = conn.Upsert("tester", []interface{}{4, "Another band", 2000}, []interface{}{[]interface{}{"+", 2, 5}})

This increases by 5 the value of the third field in the tuple with ``id`` = 4, -- or
inserts the tuple ``(4, "Another band", 2000)`` if a tuple with this ``id``
doesn't exist.

.. _getting_started-go-delete:

********************************************************************************
Deleting data
********************************************************************************

To delete a tuple, use ``сonnection.Delete``:

.. code-block:: go

    resp, err = conn.Delete("tester", "primary", []interface{}{4})

To delete all tuples in a space (or to delete an entire space), use ``Call``.
We'll focus on this function in more detail in the
:ref:`next <getting_started-go-stored-procs>` section.

To delete all tuples in a space, call ``space:truncate``:

.. code-block:: go

    resp, err = conn.Call("box.space.tester:truncate", []interface{}{})

To delete an entire space, call ``space:drop``.
This requires connecting to Tarantool as the ``admin`` user:

.. code-block:: go

    resp, err = conn.Call("box.space.tester:drop", []interface{}{})

.. _getting_started-go-stored-procs:

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
``go``, use ``Call``:

.. code-block:: go

    resp, err = conn.Call("sum", []interface{}{2, 3})

To send bare Lua code for execution, use ``Eval``:

.. code-block:: go

    resp, err = connection.Eval("return 4 + 5", []interface{}{})

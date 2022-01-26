.. _getting_started-go:

--------------------------------------------------------------------------------
Connecting from Go
--------------------------------------------------------------------------------

.. _getting_started-go-pre-requisites:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Pre-requisites
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Before we proceed:

#. `Install <https://github.com/tarantool/go-tarantool#installation>`__
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

To insert a :term:`tuple` into a :term:`space`, use ``Insert``:

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

This selects a tuple by the primary key with ``offset = 0`` and ``limit = 1``
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

Update a :term:`field` value using ``Update``:

.. code-block:: go

    resp, err = conn.Update("tester", "primary", []interface{}{4}, []interface{}{[]interface{}{"+", 2, 3}})

This increases by 3 the value of field ``2`` in the tuple with ``id = 4``.
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

This increases by 5 the value of the third field in the tuple with ``id = 4``, or
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

.. _getting_started-go-comparison:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Feature comparison
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are two more connectors from the open-source community available:
`viciious/go-tarantool <https://github.com/viciious/go-tarantool>`_ and
`FZambia/tarantool <https://github.com/FZambia/tarantool>`_. 

Last update: January 2022

..  list-table::
    :header-rows: 1
    :stub-columns: 1

    *   -
        -   `tarantool/go-tarantool <https://github.com/tarantool/go-tarantool>`_
        -   `viciious/go-tarantool <https://github.com/viciious/go-tarantool>`_
        -   `FZambia/tarantool <https://github.com/FZambia/tarantool>`_

    *   -   License
        -   BSD 2-Clause
        -   MIT
        -   BSD 2-Clause

    *   -   Last update
        -   2022
        -   2021
        -   2021

    *   -   Documentation
        -   README with examples, API described in code comments
        -   README with examples, code comments
        -   README with examples

    *   -   Testing / CI / CD
        -   GitHub Actions
        -   Travis CI
        -   GitHub Actions

    *   -   GitHub Stars
        -   127
        -   43
        -   12

    *   -   Static analysis
        -   No
        -   golint
        -   golangci-lint

    *   -   Packaging
        -   go get
        -   go get
        -   go get

    *   -   Code coverage
        -   No
        -   No
        -   No

    *   -   msgpack driver
        -   `vmihailenco/msgpack/v2 <https://github.com/vmihailenco/msgpack/tree/v2>`_ (`#124 <https://github.com/tarantool/go-tarantool/issues/124>`_)
        -   `tinylib/msgp <https://github.com/tinylib/msgp>`_
        -   `vmihailenco/msgpack/v5 <https://github.com/vmihailenco/msgpack/tree/v5>`_

    *   -   Async work
        -   Yes
        -   Yes
        -   Yes

    *   -   Schema reload
        -   Yes (manual pull)
        -   Yes (manual pull)
        -   Yes (manual pull)

    *   -   Space / index names
        -   Yes
        -   Yes
        -   Yes

    *   -   Tuples as structures
        -   Yes (structure and marshall functions must be predefined in Go code)
        -   No
        -   Yes (structure and marshall functions must be predefined in Go code)

    *   -   Access tuple fields by names
        -   Only if marshalled to structure
        -   No
        -   Only if marshalled to structure

    *   -   `SQL <https://www.tarantool.io/en/doc/latest/reference/reference_sql/>`_ support
        -   No (`#62 <https://github.com/tarantool/go-tarantool/issues/62>`_)
        -   No (`#18 <https://github.com/viciious/go-tarantool/issues/18>`_, closed)
        -   No

    *   -   `Interactive transactions <https://www.tarantool.io/en/doc/latest/book/box/stream/>`_
        -   No (`#101 <https://github.com/tarantool/go-tarantool/issues/101>`_)
        -   No
        -   No

    *   -   `Varbinary <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`_ support
        -   Yes (with in-built language tools)
        -   Yes (with in-built language tools)
        -   Yes (decodes to string by default, see `#6 <https://github.com/FZambia/tarantool/issues/6>`_)

    *   -   `UUID <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`_ support
        -   Yes
        -   No
        -   No

    *   -   Decimal support
        -   No (`#96 <https://github.com/tarantool/go-tarantool/issues/96>`_)
        -   No
        -   No

    *   -   `EXT_ERROR <https://www.tarantool.io/ru/doc/latest/dev_guide/internals/msgpack_extensions/#the-error-type>`_
            support
        -   No
        -   No
        -   No

    *   -   `Datetime <https://github.com/tarantool/tarantool/discussions/6244>`_ support
        -   No (`#118 <https://github.com/tarantool/go-tarantool/issues/118>`_)
        -   No
        -   No

    *   -   `box.session.push() responses <https://www.tarantool.io/ru/doc/latest/reference/reference_lua/box_session/push/>`_
        -   No (`#67 <https://github.com/tarantool/go-tarantool/issues/67>`_)
        -   No (`#21 <https://github.com/viciious/go-tarantool/issues/21>`_)
        -   Yes

    *   -   `Session settings <https://www.tarantool.io/en/doc/latest/reference/reference_lua/box_space/_session_settings/>`_
        -   No
        -   No
        -   No

    *   -   `Graceful shutdown <https://github.com/tarantool/tarantool/issues/5924>`_
        -   No
        -   No
        -   No

    *   -   `IPROTO_ID (feature discovering) <https://github.com/tarantool/tarantool/issues/6253>`_
        -   No
        -   No
        -   No

    *   -   `tarantool/crud <https://github.com/tarantool/crud>`_ support
        -   No
        -   No
        -   No

    *   -   Connection pool
        -   Yes (round-robin failover, no balancing, master discovering planned in `#113 <https://github.com/tarantool/go-tarantool/issues/113>`_)
        -   No
        -   No

    *   -   Transparent reconnecting
        -   Yes (see comments in `#129 <https://github.com/tarantool/go-tarantool/issues/129>`_)
        -   No (handle reconnects explicitly, refer to `#11 <https://github.com/viciious/go-tarantool/issues/11>`_)
        -   Yes (see comments in `#7 <https://github.com/FZambia/tarantool/issues/7>`_)

    *   -   Transparent request retrying
        -   No
        -   No
        -   No

    *   -   `Watchers <https://github.com/tarantool/tarantool/pull/6510>`_
        -   No
        -   No
        -   No

    *   -   Language features
        -   No  (`#48 <https://github.com/tarantool/go-tarantool/issues/48>`_)
        -   context
        -   context

    *   -   Miscellaneous
        -   Supports `tarantool/queue <https://github.com/tarantool/queue>`_ API
        -   Can mimic a Tarantool instance (also as replica)
        -   API is experimental and breaking changes may happen

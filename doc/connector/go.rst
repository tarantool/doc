.. _index_connector_go:
.. _getting_started-go:

Go
==

**Examples on GitHub**: `sample_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/sample_db>`_, `go <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/go>`_

`go-tarantool <https://github.com/tarantool/go-tarantool>`__ is the official Go connector for Tarantool.
It is not supplied as part of the Tarantool repository and should be installed separately.

This tutorial shows how to use the `go-tarantool <https://github.com/tarantool/go-tarantool>`__ 2.x library to create a Go application that connects to a remote Tarantool instance, performs CRUD operations, and executes a stored procedure.
You can find the full package documentation here: `Client in Go for Tarantool <https://pkg.go.dev/github.com/tarantool/go-tarantool/v2>`__.

..  NOTE::

    This tutorial shows how to make CRUD requests to a single-instance Tarantool database.
    To make requests to a sharded Tarantool cluster with the `CRUD <https://github.com/tarantool/crud>`__ module, use the `crud <https://pkg.go.dev/github.com/tarantool/go-tarantool/v2/crud>`__ package's API.



.. _getting_started_go_sample_db:

Sample database configuration
-----------------------------

..  include:: /reference/reference_lua/net_box.rst
    :start-after: connectors_sample_db_config_start
    :end-before: connectors_sample_db_config_end

.. _getting_started_go_sample_db_start:

Starting a sample database application
--------------------------------------

Before creating and starting a client Go application, you need to run the :ref:`sample_db <getting_started_net_box_sample_db>` application using :ref:`tt start <tt-start>`:

.. code-block:: console

    $ tt start sample_db

Now you can create a client Go application that makes requests to this database.


.. _getting_started_go_develop_client_app:

Developing a client application
-------------------------------

Before you start, make sure you have `Go installed <https://go.dev/doc/install>`__ on your computer.

.. _getting_started_go_create_client_app:

Creating an application
~~~~~~~~~~~~~~~~~~~~~~~

1.  Create the ``hello`` directory for your application and go to this directory:

    ..  code-block:: console

        $ mkdir hello
        $ cd hello

2.  Initialize a new Go module:

    ..  code-block:: console

        $ go mod init example/hello

3.  Inside the ``hello`` directory, create the ``hello.go`` file for application code.


.. _getting_started_go_import_:

Importing 'go-tarantool' packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the ``hello.go`` file, declare a ``main`` package and import the following packages:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: package main
    :end-before: func main()
    :dedent:

The packages for external MsgPack types, such as ``datetime``, ``decimal``, or ``uuid``, are required to parse these types in a response.


.. _getting_started_go_creating_connection:

Connecting to the database
~~~~~~~~~~~~~~~~~~~~~~~~~~

1.  Declare the ``main()`` function:

    ..  code-block:: go

        func main() {

        }

2.  Inside the ``main()`` function, add the following code:

    ..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
        :language: go
        :start-at: // Connect to the database
        :end-before: // Insert data
        :dedent:

    This code establishes a connection to a running Tarantool instance on behalf of ``sampleuser``.
    The ``conn`` object can be used to make CRUD requests and execute stored procedures.



.. _getting_started_go_manipulating_data:

Manipulating data
~~~~~~~~~~~~~~~~~

.. _getting_started_go_inserting_data:

Inserting data
**************

Add the following code to insert four tuples into the ``bands`` space:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Insert data
    :end-before: // Select by primary key
    :dedent:

This code makes insert requests asynchronously:

-   The ``Future`` structure is used as a handle for asynchronous requests.
-   The ``NewInsertRequest()`` method creates an insert request object that is executed by the connection.

..  NOTE::

    Making requests asynchronously is the recommended way to perform data operations.
    Further requests in this tutorial are made synchronously.


.. _getting_started_go_querying_data:

Querying data
*************

To get a tuple by the specified primary key value, use ``NewSelectRequest()`` to create an insert request object:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Select by primary key
    :end-at: Tuple selected by the primary key value
    :dedent:

You can also get a tuple by the value of the specified index by using ``Index()``:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Select by secondary key
    :end-at: Tuple selected by the secondary key value
    :dedent:



.. _getting_started_go_updating_data:

Updating data
*************

``NewUpdateRequest()`` can be used to update a tuple identified by the primary key as follows:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Update
    :end-at: Updated tuple
    :dedent:

``NewUpsertRequest()`` can be used to update an existing tuple or insert a new one.
In the example below, a new tuple is inserted:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Upsert
    :end-before: // Replace
    :dedent:


In this example, ``NewReplaceRequest()`` is used to delete the existing tuple and insert a new one:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Replace
    :end-at: Replaced tuple
    :dedent:




.. _getting_started_go_deleting_data:

Deleting data
*************

``NewDeleteRequest()`` in the example below is used to delete a tuple whose primary key value is ``5``:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Delete
    :end-at: Deleted tuple
    :dedent:



.. _getting_started_go_stored_procedures:

Executing stored procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To execute a stored procedure, use ``NewCallRequest()``:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Call
    :end-at: Stored procedure result
    :dedent:


.. _getting_started_go_closing_connection:

Closing the connection
~~~~~~~~~~~~~~~~~~~~~~

The ``CloseGraceful()`` method can be used to close the connection when it is no longer needed:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Close connection
    :end-at: Connection is closed
    :dedent:

..  NOTE::

    You can find the example with all the requests above on GitHub: `go <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/go>`_.



.. _getting_started_go_run_client_app:

Starting a client application
-----------------------------

1.  Execute the following ``go get`` commands to update dependencies in the ``go.mod`` file:

    .. code-block:: console

        $ go get github.com/tarantool/go-tarantool/v2
        $ go get github.com/tarantool/go-tarantool/v2/decimal
        $ go get github.com/tarantool/go-tarantool/v2/uuid

2.  To run the resulting application, execute the ``go run`` command in the application directory:

    .. code-block:: console

        $ go run .
        Inserted tuples:
        [[1 Roxette 1986]]
        [[2 Scorpions 1965]]
        [[3 Ace of Base 1987]]
        [[4 The Beatles 1960]]
        Tuple selected by the primary key value: [[1 Roxette 1986]]
        Tuple selected by the secondary key value: [[4 The Beatles 1960]]
        Updated tuple: [[2 Pink Floyd 1965]]
        Replaced tuple: [[1 Queen 1970]]
        Deleted tuple: [[5 The Rolling Stones 1962]]
        Stored procedure result: [[[2 Pink Floyd 1965] [4 The Beatles 1960]]]
        Connection is closed





.. _getting_started-go-comparison:
..  _go-feature-comparison:

Feature comparison
------------------

Last update: January 2023

There are also the following community-driven Go connectors:

*   `viciious/go-tarantool <https://github.com/viciious/go-tarantool>`_

*   `FZambia/tarantool <https://github.com/FZambia/tarantool>`_

The table below contains a feature comparison for the connectors mentioned above.

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
        -   2023
        -   2022
        -   2022

    *   -   Documentation
        -   README with examples and up-to-date GoDoc
        -   README with examples, code comments
        -   README with examples

    *   -   Testing / CI / CD
        -   GitHub Actions
        -   Travis CI
        -   GitHub Actions

    *   -   GitHub Stars
        -   147
        -   45
        -   14

    *   -   Static analysis
        -   golangci-lint, luacheck
        -   golint
        -   golangci-lint

    *   -   Packaging
        -   go get
        -   go get
        -   go get

    *   -   Code coverage
        -   Yes
        -   No
        -   No

    *   -   msgpack driver
        -   `vmihailenco/msgpack/v2 <https://github.com/vmihailenco/msgpack/tree/v2>`_ or `vmihailenco/msgpack/v5 <https://github.com/vmihailenco/msgpack/tree/v5>`_
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
        -   Yes
        -   No (`#18 <https://github.com/viciious/go-tarantool/issues/18>`_, closed)
        -   No

    *   -   `Interactive transactions <https://www.tarantool.io/en/doc/latest/book/box/stream/>`_
        -   Yes
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
        -   Yes
        -   No
        -   No

    *   -   `EXT_ERROR <https://www.tarantool.io/ru/doc/latest/dev_guide/internals/msgpack_extensions/#the-error-type>`_
            support
        -   Yes
        -   No
        -   No

    *   -   `Datetime <https://github.com/tarantool/tarantool/discussions/6244>`_ support
        -   Yes
        -   No
        -   No

    *   -   `box.session.push() responses <https://www.tarantool.io/ru/doc/latest/reference/reference_lua/box_session/push/>`_
        -   Yes
        -   No (`#21 <https://github.com/viciious/go-tarantool/issues/21>`_)
        -   Yes

    *   -   `Session settings <https://www.tarantool.io/en/doc/latest/reference/reference_lua/box_space/_session_settings/>`_
        -   Yes
        -   No
        -   No

    *   -   `Graceful shutdown <https://github.com/tarantool/tarantool/issues/5924>`_
        -   Yes
        -   No
        -   No

    *   -   `IPROTO_ID (feature discovering) <https://github.com/tarantool/tarantool/issues/6253>`_
        -   Yes
        -   No
        -   No

    *   -   `tarantool/crud <https://github.com/tarantool/crud>`_ support
        -   No
        -   No
        -   No

    *   -   Connection pool
        -   Yes (round-robin failover, no balancing)
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
        -   Yes
        -   No
        -   No

    *   -   `Pagination <https://github.com/tarantool/tarantool/issues/7639>`_
        -   Yes
        -   No
        -   No

    *   -   Language features
        -   context
        -   context
        -   context

    *   -   Miscellaneous
        -   Supports `tarantool/queue <https://github.com/tarantool/queue>`_ API
        -   Can mimic a Tarantool instance (also as replica). Provides instrumentation for reading snapshot and xlog files
            via `snapio module <https://github.com/viciious/go-tarantool/tree/master/snapio>`_.
            Implements unpacking of query structs if you want to implement your own iproto proxy
        -   API is experimental and breaking changes may happen

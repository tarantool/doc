.. _getting_started-go:

Connecting from Go
==================

**Examples on GitHub**: `sample_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/sample_db>`_, `go <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/go>`_

The tutorial shows how to use the 2.x version of the `go-tarantool <https://github.com/tarantool/go-tarantool>`__ library to create a Go application that connects to a remote Tarantool instance, performs CRUD operations, and executes a stored procedure.
You can find the full package documentation here: `Client in Go for Tarantool <https://pkg.go.dev/github.com/tarantool/go-tarantool/v2>`__.



.. _getting_started_go_sample_db:

Sample database configuration
-----------------------------

..  include:: getting_started_net_box.rst
    :start-after: connectors_sample_db_config_start
    :end-before: connectors_sample_db_config_end

.. _getting_started_go_sample_db_start:

Starting a sample database application
--------------------------------------

Before creating and starting a client Go application, you need to run the :ref:`sample_db <getting_started_net_box_sample_db>` application using ``tt start``:

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
        :start-after: func main()
        :end-at: // Interacting with the database
        :dedent:

    This code establishes a connection to a running Tarantool instance on behalf of ``sampleuser``.
    The ``conn`` object can be used to make CRUD requests and execute stored procedures.



.. _getting_started_go_using_data_operations:

Using data operations
~~~~~~~~~~~~~~~~~~~~~

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
    :end-at: Tuple selected the primary key value
    :dedent:

You can also get a tuple by the value of the specified index by using ``Index()``:

..  literalinclude:: /code_snippets/snippets/connectors/go/hello.go
    :language: go
    :start-at: // Select by secondary key
    :end-at: Tuple selected the secondary key value
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
        Tuple selected the primary key value: [[1 Roxette 1986]]
        Tuple selected the secondary key value: [[4 The Beatles 1960]]
        Updated tuple: [[2 Pink Floyd 1965]]
        Replaced tuple: [[1 Queen 1970]]
        Deleted tuple: [[5 The Rolling Stones 1962]]
        Stored procedure result: [[[2 Pink Floyd 1965] [4 The Beatles 1960]]]
        Connection is closed



.. _getting_started-go-comparison:

Feature comparison
------------------

There are two more connectors from the open-source community:

*   `viciious/go-tarantool <https://github.com/viciious/go-tarantool>`_

*   `FZambia/tarantool <https://github.com/FZambia/tarantool>`_.

See the :ref:`feature comparison table <index_connector_go>` of all Go connectors available.

.. _getting_started-python:

Connecting from Python
======================

**Examples on GitHub**: `sample_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/sample_db>`_, `python <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/python>`_

The tutorial shows how to use the `tarantool-python <https://github.com/tarantool/tarantool-python>`__ library to create a Python script that connects to a remote Tarantool instance, performs CRUD operations, and executes a stored procedure.
You can find the full package documentation here: `Python client library for Tarantool <https://tarantool-python.readthedocs.io/>`__.



.. _getting_started_python_sample_db:

Sample database configuration
-----------------------------

..  include:: getting_started_net_box.rst
    :start-after: connectors_sample_db_config_start
    :end-before: connectors_sample_db_config_end

.. _getting_started_python_sample_db_start:

Starting a sample database application
--------------------------------------

Before creating and starting a client Python application, you need to run the :ref:`sample_db <getting_started_net_box_sample_db>` application using :ref:`tt start <tt-start>`:

.. code-block:: console

    $ tt start sample_db

Now you can a client Python application that makes requests to this database.


.. _getting_started_python_develop_client_app:

Developing a client application
-------------------------------

Before you start, make sure you have `Python installed <https://www.python.org/downloads/>`__ on your computer.

.. _getting_started_python_create_client_app:

Creating an application
~~~~~~~~~~~~~~~~~~~~~~~

1.  Create the ``hello`` directory for your application and go to this directory:

    ..  code-block:: console

        $ mkdir hello
        $ cd hello

2.  Create and activate a Python virtual environment:

    ..  code-block:: console

        $ python -m venv .venv
        $ source .venv/bin/activate

3.  Install the ``tarantool`` module:

    ..  code-block:: console

        $ pip install tarantool

4.  Inside the ``hello`` directory, create the ``hello.py`` file for application code.


.. _getting_started_python_import_:

Importing 'tarantool'
~~~~~~~~~~~~~~~~~~~~~

In the ``hello.py`` file, import the ``tarantool`` package:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: import
    :end-at: import
    :dedent:


.. _getting_started_python_creating_connection:

Connecting to the database
~~~~~~~~~~~~~~~~~~~~~~~~~~

Add the following code:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Connect to the database
    :end-before: # Insert data
    :dedent:

This code establishes a connection to a running Tarantool instance on behalf of ``sampleuser``.
The ``conn`` object can be used to make CRUD requests and execute stored procedures.



.. _getting_started_python_manipulating_data:

Manipulating data
~~~~~~~~~~~~~~~~~

.. _getting_started_python_inserting_data:

Inserting data
**************

Add the following code to insert four tuples into the ``bands`` space:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Insert data
    :end-before: # Select by primary key
    :dedent:

``connection.insert()`` is used to insert a tuple to the space.


.. _getting_started_python_querying_data:

Querying data
*************

To get a tuple by the specified primary key value, use ``connection.select()``:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Select by primary key
    :end-at: Tuple selected by the primary key value
    :dedent:

You can also get a tuple by the value of the specified index using the ``index`` argument:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Select by secondary key
    :end-at: Tuple selected by the secondary key value
    :dedent:



.. _getting_started_python_updating_data:

Updating data
*************

``connection.update()`` can be used to update a tuple identified by the primary key as follows:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Update
    :end-at: Updated tuple
    :dedent:

``connection.upsert()`` updates an existing tuple or inserts a new one.
In the example below, a new tuple is inserted:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Upsert
    :end-before: # Replace
    :dedent:


In this example, ``connection.replace()`` deletes the existing tuple and inserts a new one:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Replace
    :end-at: Replaced tuple
    :dedent:




.. _getting_started_python_deleting_data:

Deleting data
*************

``connection.delete()`` in the example below deletes a tuple whose primary key value is ``5``:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Delete
    :end-at: Deleted tuple
    :dedent:



.. _getting_started_python_stored_procedures:

Executing stored procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To execute a stored procedure, use ``connection.call()``:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Call
    :end-at: Stored procedure result
    :dedent:


.. _getting_started_python_closing_connection:

Closing the connection
~~~~~~~~~~~~~~~~~~~~~~

The ``connection.close()`` method can be used to close the connection when it is no longer needed:

..  literalinclude:: /code_snippets/snippets/connectors/python/hello.py
    :language: python
    :start-at: # Close connection
    :end-at: Connection is closed
    :dedent:

..  NOTE::

    You can find the example with all the requests above on GitHub: `python <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/python>`_.



.. _getting_started_python_run_client_app:

Starting a client application
-----------------------------

To run the resulting application, pass the script name to the ``python`` command:

.. code-block:: console

    $ python hello.py
    Inserted tuples:
    [1, 'Roxette', 1986]
    [2, 'Scorpions', 1965]
    [3, 'Ace of Base', 1987]
    [4, 'The Beatles', 1960]
    Tuple selected by the primary key value: [1, 'Roxette', 1986]
    Tuple selected by the secondary key value: [4, 'The Beatles', 1960]
    Updated tuple: [2, 'Pink Floyd', 1965]
    Replaced tuple: [1, 'Queen', 1970]
    Deleted tuple: [5, 'The Rolling Stones', 1962]
    Stored procedure result: [[2, 'Pink Floyd', 1965], [4, 'The Beatles', 1960]]
    Connection is closed


.. _getting_started-python-comparison:

Python connectors feature comparison
------------------------------------

See the :ref:`feature comparison table <index_connector_py>` of all Python connectors available.

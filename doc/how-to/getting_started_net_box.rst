.. _getting_started_net_box:

Connecting to a database using net.box
======================================

**Examples on GitHub**: `sample_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/sample_db>`_, `net_box <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/net_box>`_

The tutorial shows how to use ``net.box`` to connect to a remote Tarantool instance, perform CRUD operations, and execute stored procedures.
For more information about the ``net.box`` module API, check :ref:`net_box-module`.


.. _getting_started_net_box_sample_db:

Sample database configuration
-----------------------------

This section describes the :ref:`configuration <configuration_file>` of a sample database that allows remote connections:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/sample_db/config.yaml
    :language: yaml
    :dedent:

-   The configuration contains one instance that listens incoming requests on the ``127.0.0.1:3301`` address.
-   ``sampleuser`` has :ref:`privileges <authentication-owners_privileges>` to select and modify data in the ``bands`` space and execute the ``get_bands_older_than`` stored function. This user can be used to connect to the instance remotely.
-   ``myapp.lua`` defines how data is stored in a database and includes a stored function.

The ``myapp.lua`` file looks as follows:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/sample_db/myapp.lua
    :language: lua
    :dedent:

You can find the full example on GitHub: `sample_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/sample_db>`_.




.. _getting_started_net_box_interactive:

Making net.box requests interactively
-------------------------------------

To try out ``net.box`` requests in the interactive console, start the :ref:`sample_db <getting_started_net_box_sample_db>` application using ``tt start``:

.. code-block:: console

    $ tt start sample_db

Then, use the :ref:`tt run -i <tt-run>` command to start an interactive console:

..  code-block:: console

    $ tt run -i
    Tarantool 3.0.0-entrypoint-1144-geaff238d9
    type 'help' for interactive help
    tarantool>

In the console, you can create a ``net.box`` connection and try out data operations.



.. _getting_started_net_box_creating_connection:

Creating a net.box connection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To load the ``net.box`` module, use the ``require()`` directive:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: net_box = require
    :end-before: net_box.connect
    :dedent:

To create a connection, pass a database URI to the :ref:`net_box.connect() <net_box-connect>` method:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: net_box.connect
    :end-before: conn:ping
    :dedent:

:ref:`connection:ping() <conn-ping>` can be used to check the connection status:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn:ping
    :end-before: net_box_data_operations
    :dedent:


.. _getting_started_net_box_using_data_operations:

Using data operations
~~~~~~~~~~~~~~~~~~~~~

To get a space object and perform CRUD operations on it, use ``conn.space.<space_name>``.

..  NOTE::

    Learn more about performing data operations from the :ref:`box_space_examples` section.


.. _getting_started_net_box_inserting_data:

Inserting data
**************

In the example below, four tuples are inserted into the ``bands`` space:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-after: Start net.box session
    :end-before: conn.space.bands:select
    :dedent:



.. _getting_started_net_box_querying_data:

Querying data
*************

The example below shows how to get a tuple by the specified primary key value:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:select
    :end-before: conn.space.bands.index.band:select
    :dedent:

You can also get a tuple by the value of the specified index as follows:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands.index.band:select
    :end-before: conn.space.bands:update
    :dedent:



.. _getting_started_net_box_updating_data:

Updating data
*************

:ref:`space_object.update()  <box_space-update>` updates a tuple identified by the primary key.
This method accepts a full key and an operation to execute:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:update
    :end-before: conn.space.bands:upsert
    :dedent:

:ref:`space_object.upsert() <box_space-upsert>` updates an existing tuple or inserts a new one.
In the example below, a new tuple is inserted:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:upsert
    :end-before: conn.space.bands:replace
    :dedent:


In this example, :ref:`space_object.replace() <box_space-replace>` is used to delete the existing tuple and insert a new one:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:replace
    :end-before: conn.space.bands:delete
    :dedent:




.. _getting_started_net_box_deleting_data:

Deleting data
*************

The :ref:`space_object.delete() <box_space-delete>` call in the example below deletes a tuple whose primary key value is ``5``:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:delete
    :end-before: conn:call
    :dedent:



.. _getting_started_net_box_stored_procedures:

Executing stored procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To execute a stored procedure, use the :ref:`connection:call() <net_box-call>` method:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn:call
    :end-before: End net.box session
    :dedent:


.. _getting_started_net_box_closing_connection:

Closing the connection
~~~~~~~~~~~~~~~~~~~~~~

The :ref:`connection:close() <conn-close>` method can be used to close the connection when it is no longer needed:

..  literalinclude:: /code_snippets/snippets/connectors/net_box/myapp.lua
    :language: lua
    :start-at: conn:close()
    :end-before: Close net.box connection
    :dedent:

..  NOTE::

    You can find the example with all the requests above on GitHub: `net_box <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/net_box>`_.

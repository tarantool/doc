.. _getting_started_net_box:

Connecting to a database using net.box
======================================

**Examples on GitHub**: `sample_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/sample_db>`_, `net_box <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/connectors/instances.enabled/net_box>`_

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




.. _getting_started_net_box_creating-app:

Creating an application connecting to the database
--------------------------------------------------

The :ref:`tt create <tt-create>` command can be used to :ref:`create an application <admin-instance_config-develop-app>` from a predefined or custom template.
In this tutorial, the application layout is prepared manually:

#.  Create a tt environment in the current directory using the :ref:`tt init <tt-init>` command.

#.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``net_box`` directory.

#.  Inside ``instances.enabled/net_box``, create the  ``instances.yml``, ``config.yaml``, and ``myapp.lua`` files:

    *   ``instances.yml`` specifies instances to run in the current environment. In this example, there is one instance:

        ..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/instances.yml
            :language: yaml
            :dedent:

    *   ``config.yaml`` contains basic instance :ref:`configuration <configuration_file>`:

        ..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/config.yaml
            :language: yaml
            :dedent:

    *   ``myapp.lua`` contains ``net.box`` requests used to interact with a :ref:`sample database <getting_started_net_box_sample_db>`. These requests are explained below in the :ref:`getting_started_net_box_developing_app` section.



.. _getting_started_net_box_developing_app:

Developing the application
--------------------------

Creating a net.box connection
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To load the ``net.box`` module, use the ``require()`` directive:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: net_box = require
    :end-at: net_box = require
    :dedent:

To create a connection, pass a database URI to the ``connect()`` method:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: net_box.connect
    :end-at: net_box.connect
    :dedent:

``ping()`` can be used to check the connection status:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn:ping
    :end-at: conn:ping
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

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: Roxette
    :end-before: conn.space.bands:select
    :dedent:



.. _getting_started_net_box_querying_data:

Querying data
*************

The example below shows how to get a tuple by the specified primary key value:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:select
    :end-before: conn.space.bands.index.band:select
    :dedent:

You can also get a tuple by the value of the specified index as follows:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands.index.band:select
    :end-before: conn.space.bands:update
    :dedent:



.. _getting_started_net_box_updating_data:

Updating data
*************

``space_object.update`` updates a tuple identified by the primary key.
This method accepts a full key and an operation to execute:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:update
    :end-before: conn.space.bands:upsert
    :dedent:

``space_object.upsert`` updates an existing tuple or inserts a new one.
In the example below, a new tuple is inserted:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:upsert
    :end-before: conn.space.bands:replace
    :dedent:


In this example, ``space_object.replace`` is used to delete the existing tuple and insert a new one:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:replace
    :end-before: conn.space.bands:delete
    :dedent:




.. _getting_started_net_box_deleting_data:

Deleting data
*************

The ``space_object.delete`` call in the example below deletes a tuple whose primary key value is ``5``:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn.space.bands:delete
    :end-before: conn:call
    :dedent:



.. _getting_started_net_box_stored_procedures:

Executing stored procedures
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To execute a stored procedure, use the ``connection:call()`` method:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn:call
    :end-before: conn:close()
    :dedent:


.. _getting_started_net_box_closing_connection:

Closing the connection
~~~~~~~~~~~~~~~~~~~~~~

The ``connection:close()`` method can be used to close the connection when it is no longer needed:

..  literalinclude:: /code_snippets/snippets/connectors/instances.enabled/net_box/myapp.lua
    :language: lua
    :start-at: conn:close()
    :end-before: end
    :dedent:



.. _getting_started_net_box_interactive:

Making net.box requests interactively
-------------------------------------

To try out ``net.box`` requests in the interactive console, you need to start sample applications:

1.  Start the :ref:`sample_db <getting_started_net_box_sample_db>` application using ``tt start``:

    .. code-block:: console

        $ tt start sample_db

2.  Start the :ref:`net_box <getting_started_net_box_creating-app>` application:

    .. code-block:: console

        $ tt start net_box

3.  Connect to ``net_box:instance001`` using ``tt connect``:

    ..  code-block:: console

        $ tt connect net_box:instance001
           • Connecting to the instance...
           • Connected to net_box:instance001

        net_box:instance001>

    In the instance's console, you can create a ``net.box`` connection and try out data operations described in :ref:`getting_started_net_box_developing_app`:

    ..  code-block:: console

        net_box:instance001> net_box = require('net.box')
        ---
        ...

        net_box:instance001> conn = net_box.connect('sampleuser:123456@127.0.0.1:3301')
        ---
        ...

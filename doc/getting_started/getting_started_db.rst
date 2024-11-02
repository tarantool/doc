..  _getting_started_db:

Creating your first Tarantool database
======================================

**Example on GitHub**: `create_db <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/create_db>`_

In this tutorial, you create a Tarantool database, write data to it, and select data from this database.


..  _getting_started_db_prerequisites:

Prerequisites
-------------

Before starting this tutorial:

*   Install the :ref:`tt <tt-installation>` utility.
*   Install `Tarantool <https://www.tarantool.io/en/download/os-installation/>`_.

    .. NOTE::

        The tt utility provides the ability to install Tarantool software using the :ref:`tt install <tt-install>` command.



..  _getting_started_db_creating-app:

Creating an application
-----------------------

The :ref:`tt create <tt-create>` command can be used to :ref:`create an application <admin-instance_config-develop-app>` from a predefined or custom template.
In this tutorial, the application layout is prepared manually:

#.  Create a tt environment in the current directory using the :ref:`tt init <tt-init>` command.

#.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``create_db`` directory.

#.  Inside ``instances.enabled/create_db``, create the ``instances.yml`` and ``config.yaml`` files:

    *   ``instances.yml`` specifies instances to run in the current environment. In this example, there is one instance:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/instances.yml
            :language: yaml
            :dedent:

    *   ``config.yaml`` contains basic instance :ref:`configuration <configuration_file>`:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/config.yaml
            :language: yaml
            :dedent:

        The instance in the configuration accepts incoming requests on the ``3301`` port.




..  _getting_started_db_working_with_database:

Working with the database
-------------------------

..  _getting_started_db-start:

Starting an instance
~~~~~~~~~~~~~~~~~~~~

#.  Start the Tarantool instance from the tt environment directory using :ref:`tt start <tt-start>`:

    ..  code-block:: console

        $ tt start create_db

#.  To check the running instance, use the :ref:`tt status <tt-status>` command:

    ..  code-block:: console

        $ tt status create_db
        INSTANCE               STATUS   PID   MODE  CONFIG  BOX      UPSTREAM
        create_db:instance001  RUNNING  8685  RW    ready   running  --

#.  Connect to the instance with :ref:`tt connect <tt-connect>`:

    ..  code-block:: console

        $ tt connect create_db:instance001
           • Connecting to the instance...
           • Connected to create_db:instance001

        create_db:instance001>

    This command opens an interactive Tarantool console with the ``create_db:instance001>`` prompt.
    Now you can enter requests in the command line.


..  _creating-db-locally:

Creating a space
~~~~~~~~~~~~~~~~

#.  Create a :term:`space <space>` named ``bands``:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.schema.space.create('bands')
        ---
        - engine: memtx
          before_replace: 'function: 0x010229d788'
          field_count: 0
          is_sync: false
          is_local: false
          on_replace: 'function: 0x010229d750'
          temporary: false
          index: []
          type: normal
          enabled: false
          name: bands
          id: 512
        - created
        ...

#.  Format the created space by specifying :term:`field` names and :ref:`types <index-box_data-types>`:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.space.bands:format({
                                   { name = 'id', type = 'unsigned' },
                                   { name = 'band_name', type = 'string' },
                                   { name = 'year', type = 'unsigned' }
                               })
        ---
        ...


..  _creating-db-indexes:

Creating indexes
~~~~~~~~~~~~~~~~

#.  Create the primary :ref:`index <index-box_index>` based on the ``id`` field:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.space.bands:create_index('primary', { parts = { 'id' } })
        ---
        - unique: true
          parts:
          - fieldno: 1
            sort_order: asc
            type: unsigned
            exclude_null: false
            is_nullable: false
          hint: true
          id: 0
          type: TREE
          space_id: 512
          name: primary
        ...

#.  Create the secondary index based on the ``band_name`` field:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.space.bands:create_index('secondary', { parts = { 'band_name' } })
        ---
        - unique: true
          parts:
          - fieldno: 2
            sort_order: asc
            type: string
            exclude_null: false
            is_nullable: false
          hint: true
          id: 1
          type: TREE
          space_id: 512
          name: secondary
        ...



..  _getting_started_db-start_writing_selecting_data:

Writing and selecting data
~~~~~~~~~~~~~~~~~~~~~~~~~~

#.  Insert three :term:`tuples <tuple>` into the space:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.space.bands:insert { 1, 'Roxette', 1986 }
        ---
        - [1, 'Roxette', 1986]
        ...
        create_db:instance001> box.space.bands:insert { 2, 'Scorpions', 1965 }
        ---
        - [2, 'Scorpions', 1965]
        ...
        create_db:instance001> box.space.bands:insert { 3, 'Ace of Base', 1987 }
        ---
        - [3, 'Ace of Base', 1987]
        ...

#.  Select a tuple using the ``primary`` index:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.space.bands:select { 3 }
        ---
        - - [3, 'Ace of Base', 1987]
        ...

#.  Select tuples using the ``secondary`` index:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.space.bands.index.secondary:select{'Scorpions'}
        ---
        - - [2, 'Scorpions', 1965]
        ...

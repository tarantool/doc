..  _getting_started_db:

Creating your first Tarantool database
======================================

In this tutorial, you connect to Tarantool instances using the :ref:`tt CLI <tt-installation>` utility,
create a database, and establish a remote connection using the :ref:`net.box <net_box-module>` module.

Installing Tarantool
--------------------

For production purposes, we recommend that you install Tarantool via the
`official package manager <https://www.tarantool.io/en/download/>`_.
To download and install the package that's appropriate for your OS,
start a shell (terminal) and enter the command-line instructions provided
for your OS at Tarantool `download page <http://tarantool.org/download.html>`_.

..  _getting_started_tt-cli:

Installing tt CLI
-----------------

Before starting this tutorial:

#.  Install the :ref:`tt CLI <tt-installation>` utility.

#.  Create a tt environment in the current directory using the :ref:`tt init <tt-init>` command.

#.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``create_db`` directory.

#.  Inside ``instances.enabled/create_db``, create the ``instances.yml`` and ``config.yaml`` files:

    *   ``instances.yml`` specifies instances to run in the current environment, for example:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/instances.yml
            :language: yaml
            :dedent:

    *   ``config.yaml`` contains basic :ref:`configuration <configuration_file>`, for example:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/config.yaml
            :language: yaml
            :dedent:

        The instance in the configuration accepts TCP requests on port ``3301``.

Read more: :ref:`Starting instances using the tt utility <configuration_run_instance_tt>`.

..  _getting_started_db-start:

Starting Tarantool
------------------

First, start a Tarantool instance from the tt environment directory:

..  code-block:: console

    $ tt start create_db

To check the running instances, you can use the following command:

..  code-block:: console

    $ tt status create_db
    INSTANCE                       STATUS      PID
    create_db:instance001     RUNNING     54560

After that, connect to the instance:

..  code-block:: console

    $ tt connect create_db:instance001

This command opens an interactive Tarantool console with the ``create_db:instance001>`` prompt.
Now you can enter requests on the command line.

..  NOTE::

    On production machines, Tarantool's interactive mode is designed for system
    administration only. We use it for most examples in this manual
    because it is convenient for learning.

..  _creating-db-locally:

Creating a database
-------------------

To create a test database after installation:

#.  Create a :term:`space <space>` named ``bands``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 2
        :dedent:

#.  Format the created space by specifying :term:`field` names and :ref:`types <index-box_data-types>`:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 3-7
        :dedent:

#.  Create the first :ref:`index <index-box_index>` named ``primary``:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 8
        :dedent:

    This is a primary index based on the ``id`` field of each tuple.
    ``TREE`` is the most universal index type. To learn more, check the documentation on Tarantool :ref:`index types <index-types>`.

#.  Insert three :term:`tuples <tuple>` into the space:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 14-16
        :dedent:

#.  Then select a tuple using the ``primary`` index:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 27
        :dedent:

#.  Add a secondary index based on the ``band_name`` field:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 9
        :dedent:

#.  Select tuples using the ``secondary`` index:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 28
        :dedent:

#.  To prepare for the example in the next section, grant read, write, and execute
    privileges to the current user:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/data.lua
        :language: lua
        :lines: 10
        :dedent:

#.  The full example in the terminal looks like this:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.schema.space.create('bands')
        ---
        ...
        create_db:instance001> box.space.bands:format({
                             > {name = 'id', type = 'unsigned'},
                             > {name = 'band_name', type = 'string'},
                             > {name = 'year', type = 'unsigned'}
                             > })
        ---
        ...
        create_db:instance001> box.space.bands:create_index('primary', { parts = { 'id' } })
        ---
        - unique: true
          parts:
          - type: unsigned
            is_nullable: false
            fieldno: 1
          id: 0
          space_id: 512
          name: primary
          type: TREE
        ...
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
        create_db:instance001> box.space.bands:select { 3 }
        ---
        - - [3, 'Ace of Base', 1987]
        ...
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
        create_db:instance001> s.index.secondary:select{'Scorpions'}
        ---
        - - [2, 'Scorpions', 1965]
        ...
        create_db:instance001> box.schema.user.grant('guest', 'read,write,execute', 'universe')
        ---
        ...

..  _connecting-remotely:

Connecting remotely
-------------------

In the configuration file (``config.yaml``), the instance listens on ``127.0.0.1:3301``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/create_db/config.yaml
    :language: yaml
    :lines: 6-9
    :dedent:

The ``listen`` value can be any form of a :ref:`URI <index-uri>` (uniform resource identifier).
You can send requests to the listen URI using:

*   ``telnet``
*   a :ref:`connector <index-box_connectors>`
*   another instance of Tarantool (using the :ref:`console <console-module>` module)
*   :ref:`tt <tt-cli>` administrative utility

In this tutorial, the requests are sent using the second Tarantool instance.

To start working, switch to another terminal and start another Tarantool instance:

..  code-block:: console

    $ tt connect create_db:instance001

Use ``net.box`` to connect to the Tarantool instance
that is listening on ``localhost:3301``":

..  code-block:: tarantoolsession

    create_db:instance001> net_box = require('net.box')
    ---
    ...
    create_db:instance001> conn = net_box.connect(3301)
    ---
    ...

Then send a select request to ``instance001``:

..  code-block:: tarantoolsession

    create_db:instance001> conn.space.tester:select{2}
    ---
    - - [2, 'Scorpions', 2015]
    ...

This request is equivalent to the local request ``box.space.tester:select{2}``.
The result in this case is one of the tuples that was inserted earlier.

You can repeat ``box.space...:insert{}`` and ``box.space...:select{}``
(or ``conn.space...:insert{}`` and ``conn.space...:select{}``)
indefinitely, on either Tarantool instance.

When the tutorial is over, you can use :ref:`box.space.s:drop() <box_space-drop>` to drop the space.
To exit interactive console, enter ``Ctrl+D``.
After that, to stop Tarantool instances, use the following command:

..  code-block:: console

    $ tt stop create_db
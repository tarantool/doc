..  _getting_started_db:

Creating your first Tarantool database
======================================

In this tutorial, th
First, let's install Tarantool, start it, and create a database.

You can install Tarantool and work with it locally or in Docker.

Installing Tarantool
--------------------

For production purposes, we recommend that you install Tarantool via the
`official package manager <http://tarantool.org/download.html>`_.
You can choose one of three versions: LTS, stable, or beta.
An automatic build system creates, tests, and publishes packages for every
push into a corresponding branch at
`Tarantool's GitHub repository <https://github.com/tarantool/tarantool>`_.

To download and install the package that's appropriate for your OS,
start a shell (terminal) and enter the command-line instructions provided
for your OS at Tarantool's `download page <http://tarantool.org/download.html>`_.

..  _getting_started_tt-cli:

Installing tt CLI
-----------------

Before starting this tutorial:

#.  Install the :ref:`tt CLI <tt-installation>` utility.

#.  Create a tt environment in the current directory using the :ref:`tt init <tt-init>` command.

#.  Inside the ``instances.enabled`` directory of the created tt environment, create the ``db_tutorial`` directory.

#.  Inside ``instances.enabled/db_tutorial``, create the ``instances.yml`` and ``config.yaml`` files:

    *   ``instances.yml`` specifies instances to run in the current environment, for example:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/instances.yml
            :language: yaml
            :dedent:

    *   ``config.yaml`` contains basic :ref:`configuration <configuration_file>`, for example:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/config.yaml
            :language: yaml
            :dedent:

        The instance in the configuration accepts TCP requests on port ``3301`.

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
    instance_scope:instance001     RUNNING     54560

After that, connect to the instance:

..  code-block:: console

    $ tt connect create_db:instance001

This command opens an interactive Tarantool console with a prompt.
Now you can enter requests on the command line.

..  NOTE::

    On production machines, Tarantool's interactive mode is designed for system
    administration only. We use it for most examples in this manual
    because it is convenient for learning.

..  _creating-db-locally:

Creating a database
-------------------

To create a test database after installation:

#.  Create a :term:`space <space>` named ``tester``:

    ..  code-block:: tarantoolsession

        create_db:instance001> s = box.schema.space.create('tester')

#.  Format the created space by specifying :term:`field` names and :ref:`types <index-box_data-types>`:

    ..  code-block:: tarantoolsession

        create_db:instance001> s:format({
                             > {name = 'id', type = 'unsigned'},
                             > {name = 'band_name', type = 'string'},
                             > {name = 'year', type = 'unsigned'}
                             > })

#.  Create the first :ref:`index <index-box_index>` named ``primary``:

    ..  code-block:: tarantoolsession

        create_db:instance001> s:create_index('primary', {
                             > type = 'tree',
                             > parts = {'id'}
                             > })
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

    This is a primary index based on the ``id`` field of each tuple.
    ``TREE`` is the most universal index type. To learn more, check the documentation on Tarantool :ref:`index types <index-types>`.

#.  Insert three :term:`tuples <tuple>` into the space:

    ..  code-block:: tarantoolsession

        create_db:instance001> s:insert{1, 'Roxette', 1986}
        create_db:instance001> s:insert{2, 'Scorpions', 2015}
        create_db:instance001> s:insert{3, 'Ace of Base', 1993}

#.  Then select a tuple using the ``primary`` index:

    ..  code-block:: tarantoolsession

        create_db:instance001> s:select{3}
        ---
        - - [3, 'Ace of Base', 1993]
        ...

#.  Add a secondary index based on the ``band_name`` field:

    ..  code-block:: tarantoolsession

        create_db:instance001> s:create_index('secondary', {
                             > type = 'tree',
                             > parts = {'band_name'}
                             > })
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

#.  Select tuples using the ``secondary`` index:

    ..  code-block:: tarantoolsession

        create_db> s.index.secondary:select{'Scorpions'}
        ---
        - - [2, 'Scorpions', 2015]
        ...

#.  To prepare for the example in the next section, grant read, write, and execute
    privileges to the current user:

    ..  code-block:: tarantoolsession

        create_db:instance001> box.schema.user.grant('guest', 'read,write,execute', 'universe')

..  _connecting-remotely:

Connecting remotely
-------------------

In the configuration file (``config.yaml``) the instance  listens on port ``3301``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/config.yaml
    :language: yaml
    :lines: 7-8
    :dedent:

The ``listen`` value can be any form of a :ref:`URI <index-uri>` (uniform resource identifier).
In this case, it is a local port: port ``3301``. You can send requests to the
listen URI using:

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
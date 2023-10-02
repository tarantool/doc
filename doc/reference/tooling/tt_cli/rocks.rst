.. _tt-rocks:

Using the LuaRocks package manager
==================================

..  code-block:: console

    $ tt rocks [FLAG ...] [VAR=VALUE] COMMAND [ARGUMENT]

``tt rocks`` provides means to manage Lua modules (rocks) via the
`LuaRocks <https://luarocks.org/>`_ package manager. `tt` uses its own
LuaRocks installation connected to the `Tarantool rocks repository <https://www.tarantool.io/en/download/rocks>`_.

Below are lists of supported LuaRocks flags and commands. For detailed information on
their usage, refer to `LuaRocks documentation <https://github.com/luarocks/luarocks/wiki/Documentation>`_.

Options
-------

.. option:: --dev

    Enable the sub-repositories in rocks servers for rockspecs of in-development versions.

.. option:: --server=SERVER

    Fetch rocks/rockspecs from this server (takes priority over config file).

.. option:: --only-server=SERVER

    Fetch rocks/rockspecs from this server only (overrides any entries in the config file).

.. option:: --only-sources=URL

    Restrict downloads to paths matching the given URL.

.. option:: --lua-dir=PREFIX

    Specify which Lua installation to use

.. option:: --lua-version=VERSION

    Specify which Lua version to use.

.. option:: --tree=TREE

    Specify which tree to operate on.

.. option:: --local

    Use the tree in the user's home directory.
    Call ``tt rocks help path`` to learn how to enable it.

.. option:: --global

    Use the system tree when ``local_by_default`` is ``true``.

.. option:: --verbose

    Display verbose output for the command executed.

.. option:: --timeout=SECONDS

    Timeout on network operations, in seconds.
    ``0`` means no timeout (wait forever). Default: ``30``.

Commands
--------

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``build``
            -   Build and compile a rock
        *   -   ``config``
            -   Query information about the LuaRocks configuration
        *   -   ``doc``
            -   Show documentation for an installed rock
        *   -   ``download``
            -   Download a specific rock file from a rocks server
        *   -   ``help``
            -   Help on commands. Type ``tt rocks help <command>`` for more
        *   -   ``init``
            -   Initialize a directory for a Lua project using LuaRocks
        *   -   ``install``
            -   Install a rock
        *   -   ``lint``
            -   Check syntax of a rockspec
        *   -   ``list``
            -   List the currently installed rocks
        *   -   ``make``
            -   Compile package in the current directory using a rockspec
        *   -   ``make_manifest``
            -   Compile a manifest file for a repository
        *   -   ``new_version``
            -   Auto-write a rockspec for a new version of a rock
        *   -   ``pack``
            -   Create a rock, packing sources or binaries
        *   -   ``purge``
            -   Remove all installed rocks from a tree
        *   -   ``remove``
            -   Uninstall a rock
        *   -   ``search``
            -   Query the LuaRocks servers
        *   -   ``show``
            -   Show information about an installed rock
        *   -   ``test``
            -   Run the test suite in the current directory
        *   -   ``unpack``
            -   Unpack the contents of a rock
        *   -   ``which``
            -   Tell which file corresponds to a given module name
        *   -   ``write_rockspec``
            -   Write a template for a rockspec file

Examples
--------

*   Install the rock ``queue`` from the Tarantool rocks repository:

    ..  code-block:: console

        $ tt rocks install queue

*   Search for the rock ``queue`` in **both** the Tarantool rocks repository and
    the `default LuaRocks repository <https://luarocks.org>`_:

    ..  code-block:: console

        $ tt rocks search queue --server='https://luarocks.org'

*   List the documentation files for the installed rock ``queue``:

    ..  code-block:: console

        $ tt rocks doc queue --list

    Without the ``--list`` flag, this command displays documentation in the user's default browser.

*   Create a ``*.rock`` file from the installed rock ``queue``:

    ..  code-block:: console

        $ tt rocks pack queue

*   Unpack a ``*.rock`` file:

    ..  code-block:: console

        $ tt rocks unpack queue-scm-1.all.rock

*   Remove the installed rock ``queue``:

    ..  code-block:: console

        $ tt rocks remove queue
        
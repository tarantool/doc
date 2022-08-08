Using the LuaRocks package manager
==================================

..  code-block:: bash

    tt rocks [FLAG ...] [VAR=VALUE] COMMAND [ARGUMENT]

``tt rocks`` call the functions of the `LuaRocks <https://luarocks.org/>`_ package manager.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``--dev``
            -   Enable the sub-repositories in rocks servers
	            for rockspecs of in-development versions
        *   -   ``--server=<server>``
            -   Fetch rocks/rockspecs from this server
	            (takes priority over config file)
        *   -   ``--only-server=<server>``
            -   Fetch rocks/rockspecs from this server only
	            (overrides any entries in the config file)
        *   -   ``--only-sources=<url>``
            -   Restrict downloads to paths matching the
	            given URL.
        *   -   ``--lua-dir=<prefix>``
            -   Which Lua installation to use.
        *   -   ``--lua-version=<ver>``
            -   Which Lua version to use.
        *   -   ``--tree=<tree>``
            -   Which tree to operate on.
        *   -   ``--local``
            -   Use the tree in the user's home directory.
                To enable it, see './tt rocks help path'.
        *   -   ``--global``
            -   Use the system tree when `local_by_default` is `true`.
        *   -   ``--verbose``
            -   Display verbose output of commands executed.
        *   -   ``--timeout=<seconds>``
            -   Timeout on network operations, in seconds.
	            0 means no timeout (wait forever).
	            Default is 30.

Commands
--------

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``build``
            -   Build and compile a rock.
        *   -   ``config``
            -   Query information about the LuaRocks configuration.
        *   -   ``doc``
            -   Show documentation for an installed rock.
        *   -   ``download``
            -   Download a specific rock file from a rocks server.
        *   -   ``help``
            -   Help on commands. Type './tt rocks help <command>' for more.
        *   -   ``init``
            -   Initialize a directory for a Lua project using LuaRocks.
        *   -   ``install``
            -   Install a rock.
        *   -   ``lint``
            -   Check syntax of a rockspec.
        *   -   ``list``
            -   List currently installed rocks.
        *   -   ``make``
            -   Compile package in current directory using a rockspec.
        *   -   ``make_manifest``
            -   Compile a manifest file for a repository.
        *   -   ``new_version``
            -   Auto-write a rockspec for a new version of a rock.
        *   -   ``pack``
            -   Create a rock, packing sources or binaries.
        *   -   ``purge``
            -   Remove all installed rocks from a tree.
        *   -   ``remove``
            -   Uninstall a rock.
        *   -   ``search``
            -   Query the LuaRocks servers.
        *   -   ``show``
            -   Show information about an installed rock.
        *   -   ``test``
            -   Run the test suite in the current directory.
        *   -   ``unpack``
            -   Unpack the contents of a rock.
        *   -   ``which``
            -   Tell which file corresponds to a given module name.
        *   -   ``write_rockspec``
            -   Write a template for a rockspec file.

kExamples
--------

*   TODO: description

    ..  code-block:: bash

        tt rocks


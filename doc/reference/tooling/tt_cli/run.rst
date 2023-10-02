.. _tt-run:

Running code in a Tarantool instance
====================================

..  code-block:: bash

    tt run [SCRIPT|-e EXPR] [OPTION ...]

``tt run`` executes Lua code in a Tarantool instance.

Options
-------

.. option:: -e EXPR, --evaluate EXPR

    Execute the specified expression in a Tarantool instance.

.. option:: -l LIB_NAME, --library LIB_NAME

    Require the specified library.

.. option:: -i, --interactive

    Enter the interactive mode after the script execution.

.. option:: -v, --version

    Print the Tarantool version that is used for script execution.

Details
-------

``tt run`` executes arbitrary Lua code in a Tarantool instance. The code can be
provided either in a Lua file, or in a string passed after the ``-e``/``--evaluate``
flag. When called without arguments or flags, ``tt run`` opens the Tarantool console.

If libraries are required for execution, pass their names after the ``-l``/``--library``
flag.

By default, a Tarantool instance started by ``tt run`` shuts down after code
execution completes. To leave this instance running and continue working in its
console, add the ``-i``/``--interactive`` flag.

Examples
--------

*   Execute the ``app.lua`` file in a Tarantool instance:

    ..  code-block:: console

        $ tt run app.lua

*   Execute an expression in a Tarantool instance:

    ..  code-block:: console

        $ tt run -e "print('hi there')"

*   Execute the ``app.lua`` file in a Tarantool instance and leave it running:

    ..  code-block:: console

        $ tt run app.lua -i

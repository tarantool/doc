tt CLI commands
===============

Below is a list of `tt` commands. Run ``tt COMMAND help`` to see the detailed
help for the given command.

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``start``
            -   Start a Tarantool :ref:`instance <admin-instance_file>`
        *   -   ``stop``
            -   Stop a Tarantool instance
        *   -   ``status``
            -   Get the current status of a Tarantool instance
        *   -   ``restart``
            -   Restart a Tarantool instance
        *   -   ``version``
            -   Show the ``tt`` version information
        *   -   ``completion``
            -   Generate autocompletion for a specified shell
        *   -   ``help``
            -   Display help for ``tt`` of a specific command
        *   -   ``logrotate``
            -   :ref:`Rotate logs <admin-logs>`
        *   -   ``check``
            -   Check an application file for syntax errors
        *   -   ``connect``
            -   Connect to a Tarantool instance
        *   -   ``rocks``
            -   LuaRocks package manager
        *   -   ``cat``
            -   Print the contents of ``.snap`` or ``.xlog`` files into stdout
        *   -   ``play``
            -   Play the contents of ``.snap`` or ``.xlog`` files to another Tarantool instance
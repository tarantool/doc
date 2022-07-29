.. _tt-commands:

Commands
========

Below is a list of `tt` commands. Run ``tt COMMAND help`` to see the detailed
help for the given command.

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   :doc:`start <start>`
            -   Start a Tarantool instance
        *   -   :doc:`stop <stop>`
            -   Stop a Tarantool instance
        *   -   :doc:`status <status>`
            -   Get the current status of a Tarantool instance
        *   -   :doc:`restart <restart>`
            -   Restart a Tarantool instance
        *   -   :doc:`version <version>`
            -   Show the ``tt`` version information
        *   -   :doc:`completion <completion>`
            -   Generate completion for a specified shell
        *   -   :doc:`help <help>`
            -   Display help for ``tt`` or a specific command
        *   -   :doc:`logrotate <logrotate>`
            -   Rotate instance logs
        *   -   :doc:`check <check>`
            -   Check an application file for syntax errors
        *   -   :doc:`connect <connect>`
            -   Connect to a Tarantool instance
        *   -   ``rocks``
            -   Use the LuaRocks package manager
        *   -   :doc:`cat <cat>`
            -   Print the contents of ``.snap`` or ``.xlog`` files into stdout
        *   -   :doc:`play <play>`
            -   Play the contents of ``.snap`` or ``.xlog`` files to another Tarantool instance

..  toctree::
    :hidden:

    start <start>
    stop <stop>
    status <status>
    restart <restart>
    version <version>
    completion <completion>
    help <help>
    logrotate <logrotate>
    check <check>
    connect <connect>
    cat <cat>
    play <play>
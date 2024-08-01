.. _tt-status:

Checking instance status
========================

..  code-block:: console

    $ tt status [APPLICATION[:APP_INSTANCE]] [-p|--pretty]

``tt status`` prints the information about Tarantool applications and instances
in the current environment. This includes:

- Application and instance names
- Instance statuses: running or not
- PIDs
- Instance modes: read-write or read-only

When called without arguments, prints the status of all enabled applications in the current environment.

Examples
--------

*   Print the status of all instances of the ``app`` application:

    ..  code-block:: console

        $ tt status app

*   Print the status of the ``replica`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt status app:replica

*   Pretty-print the status of the ``replica`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt status app:replica --pretty

Options
-------

..  option:: -p, --pretty

    Print the status as a pretty-formatted table.
.. _tt-status:

Checking instance status
========================

..  code-block:: console

    $ tt status [APPLICATION[:APP_INSTANCE]] [OPTION ...]

``tt status`` prints the information about Tarantool applications and instances
in the current environment. This includes:

-   ``INSTANCE`` -- application and instance names
-   ``STATUS`` -- instance status: running, not running, or terminated with an error
-   ``PID`` -- process IDs
-   ``MODE`` -- instance modes: read-write or read-only
-   ``CONFIG`` -- the instances' states in regard to configuration for Tarantool 3.0 or later (see :ref:`config.info() <config_api_reference_info>`)
-   ``BOX`` -- the instances' :ref:`box.info() <box_info_info>` statuses
-   ``UPSTREAM`` -- the instances' :ref:`box.info.replication[*].upstream <box_info_replication>` statuses

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

..  option:: -d, --details

    Print detailed alerts.

..  option:: -p, --pretty

    Print the status as a pretty-formatted table.
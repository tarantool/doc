.. _tt-start:

Starting Tarantool applications
===============================

..  code-block:: console

    $ tt start {APPLICATION[:APP_INSTANCE] | SINGLE_INSTANCE}

``tt start`` starts Tarantool applications. The application files must be stored
inside the ``instances_enabled`` directory specified in the :ref:`tt configuration file <tt-config_file_app>`.
For detailed instructions on preparing and running Tarantool applications, see
:ref:`admin-instance-environment-overview` and :ref:`admin-start_stop_instance`.

When called without arguments, starts all enabled applications in the current environment.

Cluster application
-------------------

``tt start`` can start entire Tarantool clusters based on their YAML configurations.
A cluster application directory inside ``instances_enabled`` must contain the following files:

*   ``config.yaml`` -- a :ref:`YAML configuration <configuration>` that defines
    the cluster topology and settings.
    It can either contain an explicit configuration in the YAML format or point
    to a centralized configuration storage (for Enterprise Edition).
*   ``instances.yml`` -- a file that defines the list of cluster instances to run
    in the current environment.
*   (Optionally) ``*.lua`` files with code to load and run in the cluster.

For more information about Tarantool application layout, see :ref:`admin-instance-environment-overview`.

Examples:

*   Start instances of the application stored in the ``app/`` directory inside
    ``instances_enabled`` in accordance with its ``instances.yml``:

    ..  code-block:: console

        $ tt start app

*   Start only the ``master`` instance of the application stored in the ``app/``
    directory inside ``instances_enabled``:

    ..  code-block:: console

        $ tt start app:master


Single instances
----------------

``tt start`` can start single Tarantool instances without cluster configurations.
Such instances are based on Lua code provided in files inside the ``instances_enabled``
directory.

Example: start an instance with the ``app.lua`` application from the ``instances_enabled``
directory:

..  code-block:: console

    $ tt start app

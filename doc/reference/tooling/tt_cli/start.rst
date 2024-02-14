.. _tt-start:

Starting Tarantool applications
===============================

..  code-block:: console

    $ tt start APPLICATION[:APP_INSTANCE]

``tt start`` starts Tarantool applications. The application files must be stored
inside the ``instances_enabled`` directory specified in the :ref:`tt configuration file <tt-config_file_app>`.
For detailed instructions on preparing and running Tarantool applications, see
:ref:`admin-instance-environment-overview` and :ref:`admin-start_stop_instance`.

When called without arguments, starts all enabled applications in the current environment.

See also: :ref:`tt-stop`, :ref:`tt-restart`, :ref:`tt-status`.

Application layout
------------------

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

.. note::

    ``tt`` also supports Tarantool applications with :ref:`configuration in code <configuration_code>`,
    which is considered a legacy approach since Tarantool 3.0. For information
    about using ``tt`` with such applications, refer to the Tarantool 2.11 documentation.

Examples
--------

*   Start instances of the application stored in the ``app`` directory inside
    ``instances_enabled`` in accordance with its ``instances.yml``:

    ..  code-block:: console

        $ tt start app

*   Start the ``router`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt start app:router


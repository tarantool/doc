.. _tt-instances:

Managing multiple instances
===========================

The ``tt`` utility can manage Tarantool applications that run on
multiple instances. With a single ``tt`` call, you can:

*   start an application on multiple instances (``tt start``)
*   check the status of an application instances (``tt status``)
*   connect to a specific instance of an application (``tt connect``)
*   stop a specific instance of an application or all its instances (``tt stop``)

To make an application run on multiple instances, prepare its configuration
in a directory. The directory name is used as the application's identifier.

This directory should contain the following files:

*   The application file named ``init.lua``.
*   The instances configuration file ``instances.yml`` with the following format:

    ..  code:: yaml

        <instance_name>:
          <parameter>:<value>

*   (Optional) Application files to run on specific instances.
    These files should have names ``<instance_name>.init.lua``, where ``<instance_name>``
    is the name specified in ``instances.yml``.
    For example, if your application has separate source files for the router and storage
    instances, place the router code in the ``router.init.lua`` file.


Example
-------

The ``demo`` application runs on three instances: ``master`` and ``replica`` for
storing data and ``router`` for connections. ``master`` and ``replica`` share
the same code, and ``router`` has its own code.

The application configuration is stored in the ``demo`` directory. The directory
contains the following files:

*   ``instances.yml`` -- the instances configuration:

    ..  code:: yaml

        master:
        replica:
        router:

*   ``init.lua`` -- the code of ``master`` and ``replica``.
*   ``router.init.lua`` -- the code of ``router``.


Start all three instances of the ``demo`` application:

..  code-block:: bash

    tt start demo

Check the status of ``demo`` instances:

..  code-block:: bash

    tt status demo

Check the status of a specific instance:

..  code-block:: bash

    tt status demo:replica

Connect to an instance:

..  code-block:: bash

    tt connect demo:router

Stop a specific instance:

..  code-block:: bash

    tt stop demo:replica

Stop all ``demo`` instances:

..  code-block:: bash

    tt stop demo


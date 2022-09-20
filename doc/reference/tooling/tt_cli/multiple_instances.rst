.. _tt-instances:

Managing multiple instances
===========================

The ``tt`` utility can manage Tarantool applications that run on
multiple instances. With a single ``tt`` call, you can:

*   start an application on multiple instances (``tt start``)
*   check the status of application instances (``tt status``)
*   connect to a specific instance of an application (``tt connect``)
*   stop a specific instance of an application or all its instances (``tt stop``)


Application directory
---------------------

To create an application that runs on multiple instances, prepare its configuration
in a directory. The directory name is used as the application's identifier.

This directory should contain the following files:

*   The application file named ``init.lua``.
*   The instances configuration file ``instances.yml`` with the following format:

    ..  code:: yaml

        <instance_name1>:
        <instance_name2>:
        ...

    ..  note::

        Do not use the dot (``.``) and dash (``-``) characters in the instance names.
        They are reserved for system use.

*   (Optional) Application files to run on specific instances.
    These files should have names ``<instance_name>.init.lua``, where ``<instance_name>``
    is the name specified in ``instances.yml``.
    For example, if your application has separate source files for the ``router`` and ``storage``
    instances, place the router code in the ``router.init.lua`` file.

Identifying instances in code
-----------------------------

When the application is working, each instance has associated environment variables
``TARANTOOL_INSTANCE_NAME`` and ``TARANTOOL_APP_NAME``. You can use them in the application
code to identify the instance on which the code runs.

To obtain the instance and application names, use the following code:

..  code:: lua

    local inst_name = os.getenv('TARANTOOL_INSTANCE_NAME')
    local app_name = os.getenv('TARANTOOL_APP_NAME')


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


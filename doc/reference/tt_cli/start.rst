.. _tt-start:

Starting a Tarantool instance
=============================

..  code-block:: bash

    tt start [INSTANCE]

``tt start`` starts the specified Tarantool :ref:`instance <admin-instance_file>`.
The specified ``[INSTANCE]`` value is used as this instance's identifier.

Details
-------

The ``[INSTANCE]`` argument must specify a path to the instance file:

*   from the ``instances_available`` path specified in the
    :ref:`tt configuration file <tt-config_file_app>`.
*   from the ``tt`` :ref:`working directory <tt-config_modes>` if ``instances_available``
    is not specified.

..  important::

  The ``[INSTANCE]`` value must not include the ``.lua`` file extension.

The ``[INSTANCE]`` value can be a directory name. In this case, ``tt`` starts
the ``init.lua`` instance from this directory.

Examples
--------

All paths in the examples below are relative to the ``tt`` working directory or
``instances_available`` directory if it is specified.

*   Start the ``app.lua`` instance:

    ..  code-block:: bash

        tt start app

*   Start the ``app.lua`` instance from the ``instances`` directory:

    ..  code-block:: bash

        tt start instances/app


*   Start the ``init.lua`` instance from the ``app/instance1/`` directory:

    ..  code-block:: bash

        tt start app/instance1
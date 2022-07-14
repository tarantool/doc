.. _tt-start:

Starting a Tarantool instance
=============================

..  code-block:: bash

    tt start INSTANCE

``tt start`` starts the specified Tarantool :ref:`instance <admin-instance_file>`.

Details
-------

``INSTANCE`` is a name of an instance from the ``instances_available`` directory
specified in the :ref:`tt configuration file <tt-config_file_app>`. This can be:

*   a name of an :ref:`instance file <admin-instance_file>` without the ``.lua`` extension.
*   a name of a directory containing the ``init.lua`` file.


Examples
--------

*   Start the ``app.lua`` instance from the ``instances_available`` directory:

    ..  code-block:: bash

        tt start app


*   Start the ``init.lua`` instance from the ``instance1/`` directory inside ``instances_available``:

    ..  code-block:: bash

        tt start instance1
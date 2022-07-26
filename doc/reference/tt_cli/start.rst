.. _tt-start:

Starting a Tarantool instance
=============================

..  code-block:: bash

    tt start INSTANCE

``tt start`` starts a Tarantool instance from an application file.

Details
-------

The application file must be stored inside the ``instances_available``
directory specified in the :ref:`tt configuration file <tt-config_file_app>`.
The ``INSTANCE`` value can be:

*   the name of an application file without the ``.lua`` extension.
*   the name of a directory containing the ``init.lua`` file. In this case, the instance is started from ``init.lua``.


Examples
--------

*   Start the ``app.lua`` instance from the ``instances_available`` directory:

    ..  code-block:: bash

        tt start app


*   Start the ``init.lua`` instance from the ``instance1/`` directory inside ``instances_available``:

    ..  code-block:: bash

        tt start instance1
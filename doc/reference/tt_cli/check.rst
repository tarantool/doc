.. _tt-start:

Checking an application file
============================

..  code-block:: bash

    tt check APP_FILE

``tt check`` checks the specified Tarantool application file for syntax errors.

Details
-------

``tt`` searches for ``APP_FILE`` inside the ``instances_available`` directory
specified in the :ref:`tt configuration file <tt-config_file_app>`. ``APP_FILE`` can be:

*   the name of an application file without the ``.lua`` extension.
*   the name of a directory containing the ``init.lua`` file. In this case, ``init.lua`` is checked.


Examples
--------

*   Check the syntax of the ``app.lua`` file from the ``instances_available`` directory:

    ..  code-block:: bash

        tt check app


*   Check the syntax of the ``init.lua`` file from the ``instance1/`` directory inside ``instances_available``:

    ..  code-block:: bash

        tt check instance1
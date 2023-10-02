.. _tt-check:

Checking an application file
============================

..  code-block:: console

    $ tt check APP_FILE

``tt check`` checks the specified Tarantool application file for syntax errors.

Details
-------

``tt`` searches for ``APP_FILE`` inside the ``instances_enabled`` directory
specified in the :ref:`tt configuration file <tt-config_file_app>`. ``APP_FILE`` can be:

*   the name of an application file without the ``.lua`` extension.
*   the name of a directory containing the ``init.lua`` file. In this case, ``init.lua`` is checked.


Examples
--------

*   Check the syntax of the ``app.lua`` file from the ``instances_enabled`` directory:

    ..  code-block:: console

        $ tt check app


*   Check the syntax of the ``init.lua`` file from the ``instance1/`` directory inside ``instances_enabled``:

    ..  code-block:: console

        $ tt check instance1
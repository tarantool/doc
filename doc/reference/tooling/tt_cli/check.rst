.. _tt-check:

Checking an application file
============================

..  code-block:: console

    $ tt check {INSTANCE|APPLICATION[:APP_INSTANCE]}

``tt check`` checks the specified Tarantool application or instance for syntax errors.

Details
-------

``tt`` searches for ``APP_FILE`` inside the ``instances_enabled`` directory
specified in the :ref:`tt configuration file <tt-config_file_app>`. ``APP_FILE`` can be:

*   the name of an application file without the ``.lua`` extension.
*   the name of a directory containing the ``init.lua`` file. In this case, ``init.lua`` is checked.


Examples
--------

Single instance
~~~~~~~~~~~~~~~

*   Check the syntax of the ``app.lua`` file from the ``instances_enabled`` directory:

    ..  code-block:: console

        $ tt check app


*   Check the syntax of the ``init.lua`` file from the ``instance1/`` directory inside ``instances_enabled``:

    ..  code-block:: console

        $ tt check instance1

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Check all source files of the application stored in the ``app/`` directory inside
    ``instances_enabled`` in accordance with the :ref:`instances configuration <tt-instances>`:

    ..  code-block:: console

        $ tt check app

*   Check the source of the ``master`` instance of the application stored in the
    ``app/`` directory inside ``instances_enabled``:

    ..  code-block:: console

        $ tt check app:master
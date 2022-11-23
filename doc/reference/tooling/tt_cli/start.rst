.. _tt-start:

Starting a Tarantool instance
=============================

..  code-block:: bash

    tt start APPLICATION

``tt start`` starts Tarantool applications.

Details
-------

The application files must be stored inside the ``instances_available``
directory specified in the :ref:`tt configuration file <tt-config_file_app>`.
The ``APPLICATION`` value can be:

*   the name of an application file without the ``.lua`` extension.
*   the name of an application directory. It must contain the ``init.lua``
    application file and, optionally, the instances configuration if the
    application runs on multiple instances. Learn more about
    :ref:`instances configuration <tt-instances>`.


Examples
--------

Single instance
~~~~~~~~~~~~~~~

*   Start an instance with the ``app.lua`` application from the ``instances_available``
    directory:

    ..  code-block:: bash

        tt start app


Multiple instances
~~~~~~~~~~~~~~~~~~

*   Start all instances of the application stored in the ``app/`` directory inside
    ``instances_available`` in accordance with the :ref:`instances configuration <tt-instances>`:

    ..  code-block:: bash

        tt start app

*   Start only the ``master`` instance of the application stored in the ``app/`` directory inside ``instances_available``:
    ..  code-block:: bash

        tt start app:master
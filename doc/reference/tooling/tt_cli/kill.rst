.. _tt-kill:

Terminating Tarantool instances
===============================

..  code-block:: console

    $ tt kill APPLICATION[:APP_INSTANCE]

``tt kill`` terminates instances with ``SIGQUIT`` and ``SIGKILL`` signals.

To terminate all instances of the ``app`` application:

..  code-block:: console

    $ tt stop app

To terminate the ``storage-001-r`` instance of the ``app`` application without confirmation:

..  code-block:: console

    $ tt stop app:storage-001-r --force

To terminate the ``storage-001-r`` instance of the ``app`` application and generate its core dump:

..  code-block:: console

    $ tt stop app:storage-001-r --dump

Options
-------

.. option:: -d, --dump

    Generate core dumps of terminated processes.

.. option:: -f, --force

    Kill instances without confirmation.

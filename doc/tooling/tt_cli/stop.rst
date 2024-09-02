.. _tt-stop:

Stopping a Tarantool instance
=============================

..  code-block:: console

    $ tt stop [APPLICATION[:APP_INSTANCE]]

``tt stop`` stops the specified running Tarantool applications or instances.
When called without arguments, stops all running applications in the current environment.

See also: :ref:`tt-start`, :ref:`tt-restart`, :ref:`tt-status`.

Examples
--------

*   Stop all instances of the ``app`` application:

    ..  code-block:: console

        $ tt stop app

*   Stop the ``replica`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt stop app:replica


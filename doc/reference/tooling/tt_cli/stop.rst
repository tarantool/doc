.. _tt-stop:

Stopping a Tarantool instance
=============================

..  code-block:: console

    $ tt stop {APPLICATION[:APP_INSTANCE] | SINGLE_INSTANCE}}

``tt stop`` stops the specified running Tarantool applications or instances.
When called without arguments, stops all running applications in the current environment.

Cluster application
-------------------

*   Stop all instances of the ``app`` application:

    ..  code-block:: console

        $ tt stop app

*   Stop the ``replica`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt stop app:replica

Single instance
---------------

*   Stop the ``instance1`` instance:

    ..  code-block:: console

        $ tt stop instance1

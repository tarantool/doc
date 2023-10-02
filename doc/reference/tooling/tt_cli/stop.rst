.. _tt-stop:

Stopping a Tarantool instance
=============================

..  code-block:: console

    $ tt stop {INSTANCE|APPLICATION[:APP_INSTANCE]}

``tt stop`` stops the specified running Tarantool instances.

Examples
--------

Single instance
~~~~~~~~~~~~~~~

*   Stop the ``app`` instance:

    ..  code-block:: console

        $ tt stop app

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Stop all instances of the ``app`` application:

    ..  code-block:: console

        $ tt stop app

*   Stop the ``replica`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt stop app:replica
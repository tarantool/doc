.. _tt-status:

Checking instance status
========================

..  code-block:: console

    $ tt status {APPLICATION[:APP_INSTANCE] | SINGLE_INSTANCE}

``tt status`` prints the current status of Tarantool applications and instances
in the current environment. When called without arguments, prints the status of
all enabled applications in the current environment.

Cluster application
-------------------

*   Check the status of all instances of the ``app`` application:

    ..  code-block:: console

        $ tt status app

*   Check the status of the ``replica`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt status app:replica

Single instance
---------------

*   Check the status of the ``instance1`` instance:

    ..  code-block:: console

        $ tt status instance1



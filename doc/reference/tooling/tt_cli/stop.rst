.. _tt-stop:

Stopping a Tarantool instance
=============================

..  code-block:: bash

    tt stop INSTANCE|APPLICATION

``tt stop`` stops the specified running Tarantool instances.

Examples
--------

Single instance
~~~~~~~~~~~~~~~
*   Stop the ``app`` instance:

    ..  code-block:: bash

        tt stop app

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Stop all instances of the ``app`` application:

    ..  code-block:: bash

        tt stop app

*   Stop the ``replica`` instance of the ``app`` application:

    ..  code-block:: bash

        tt stop app:replica
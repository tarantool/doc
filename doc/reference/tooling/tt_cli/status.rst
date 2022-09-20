.. _tt-status:

Checking instance status
========================

..  code-block:: bash

    tt status INSTANCE|APPLICATION

``tt status`` prints the current status of the specified Tarantool instance or
all instances of an application.

Examples
--------

Single instance
~~~~~~~~~~~~~~~

*   Check the status of the ``app`` instance:

    ..  code-block:: bash

        tt status app

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Check the status of all instances of the ``app`` application:

    ..  code-block:: bash

        tt status app

*   Check the status of the ``replica`` instance of the ``app`` application:

    ..  code-block:: bash

        tt status app:replica
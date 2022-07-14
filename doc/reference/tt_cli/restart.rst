Restarting a Tarantool instance
===============================

..  code-block:: bash

    tt restart INSTANCE

``tt restart`` restarts the specified running Tarantool instance.
A ``tt restart`` call is equivalent to subsequent calls of
:doc:`tt stop <stop>` and :doc:`tt start <start>`.

Examples
--------

Restart the ``app`` instance:

..  code-block:: bash

    tt restart app


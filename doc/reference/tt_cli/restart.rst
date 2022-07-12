Restarting a Tarantool instance
===============================

..  code-block:: bash

    tt stop [INSTANCE]

``tt restart`` restarts the specified Tarantool instance.
A ``tt restart`` call is equivalent to subsequent calls of
:ref:`tt stop <tt-stop>` and :ref:`tt start <tt-start>`.

Details
-------

The ``[INSTANCE]`` argument must contain the value specified when :ref:`starting the instance <tt-start>`.

Examples
--------

Assuming that the instance was started with the ``tt start app`` command.
Restart the ``app`` instance:

..  code-block:: bash

    tt restart app


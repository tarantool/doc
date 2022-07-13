Checking instance status
========================

..  code-block:: bash

    tt status INSTANCE

``tt status`` prints the current status of the specified Tarantool instance.

Details
-------

The ``INSTANCE`` argument must contain the value specified when :ref:`starting the instance <tt-start>`.

Examples
--------

Check the status of the ``app`` instance:

..  code-block:: bash

    tt status app
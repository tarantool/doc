.. _tt-stop:

Stopping a Tarantool instance
=============================

..  code-block:: bash

    tt stop [INSTANCE]

``tt stop`` stops the specified Tarantool instance.

Details
-------

The ``[INSTANCE]`` argument must contain the value specified when :ref:`starting the instance <tt-start>`.

Examples
--------

Stop the ``app`` instance:

..  code-block:: bash

    tt stop app
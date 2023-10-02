.. _tt-restart:

Restarting a Tarantool instance
===============================

..  code-block:: console

    $ tt restart INSTANCE

``tt restart`` restarts the specified running Tarantool instance.
A ``tt restart`` call is equivalent to consecutive calls of
:doc:`tt stop <stop>` and :doc:`tt start <start>`.

Options
-------

..  option:: -y, --yes

    Automatic "Yes" to confirmation prompt.

Examples
--------

Restart the ``app`` instance with automatic confirmation:

..  code-block:: console

    $ tt restart app -y


.. _tt-restart:

Restarting a Tarantool instance
===============================

..  code-block:: console

    $ tt restart {APPLICATION[:APP_INSTANCE] | SINGLE_INSTANCE} [OPTION ...]

``tt restart`` restarts the specified running Tarantool instance.
A ``tt restart`` call is equivalent to consecutive calls of
:doc:`tt stop <stop>` and :doc:`tt start <start>`.

When called without arguments, restarts all running applications in the current environment.

Cluster application
-------------------

To restart all instances of the application stored in the ``app/`` directory inside
``instances_enabled`` in accordance with the :ref:`instances configuration <tt-instances>`:

..  code-block:: console

    $ tt restart app

To restart only the ``master`` instance of the application stored in the ``app/`` directory inside ``instances_enabled``:

..  code-block:: console

    $ tt restart app:master

Single instance
---------------

Restart the ``instance1`` instance with automatic confirmation:

..  code-block:: console

    $ tt restart instance1 -y

Options
-------

..  option:: -y, --yes

    Automatic "Yes" to confirmation prompt.


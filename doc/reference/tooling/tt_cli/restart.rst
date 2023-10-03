.. _tt-restart:

Restarting a Tarantool instance
===============================

..  code-block:: console

    $ tt restart {INSTANCE | APPLICATION[:APP_INSTANCE]} [OPTION ...]

``tt restart`` restarts the specified running Tarantool instance.
A ``tt restart`` call is equivalent to consecutive calls of
:doc:`tt stop <stop>` and :doc:`tt start <start>`.

Options
-------

..  option:: -y, --yes

    Automatic "Yes" to confirmation prompt.

Examples
--------

Single instance
~~~~~~~~~~~~~~~

Restart the ``app`` instance with automatic confirmation:

..  code-block:: console

    $ tt restart app -y

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Restart all instances of the application stored in the ``app/`` directory inside
    ``instances_enabled`` in accordance with the :ref:`instances configuration <tt-instances>`:

    ..  code-block:: console

        $ tt restart app

*   Restart only the ``master`` instance of the application stored in the ``app/`` directory inside ``instances_enabled``:

    ..  code-block:: console

        $ tt restart app:master
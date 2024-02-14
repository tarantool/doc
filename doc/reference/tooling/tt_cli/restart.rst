.. _tt-restart:

Restarting a Tarantool instance
===============================

..  code-block:: console

    $ tt restart APPLICATION[:APP_INSTANCE] [OPTION ...]

``tt restart`` restarts the specified running Tarantool instance.
A ``tt restart`` call is equivalent to consecutive calls of
:doc:`tt stop <stop>` and :doc:`tt start <start>`.

When called without arguments, restarts all running applications in the current environment.

See also: :ref:`tt-start`, :ref:`tt-stop`, :ref:`tt-status`.


Options
-------

..  option:: -y, --yes

    Automatic "Yes" to confirmation prompt.

Examples
--------

*   Restart all instances of the application stored in the ``app`` directory inside
    ``instances_enabled`` in accordance with the :ref:`instances configuration <tt-instances>`:

    ..  code-block:: console

        $ tt restart app

    .. note::

        This call starts all application instances specified in its ``instances.yml``,
        even those that were not running before the call.

 *   Restart only the ``master`` instance of the ``app`` application  with automatic confirmation:

    ..  code-block:: console

        $ tt restart app:master -y



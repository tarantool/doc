.. _tt-logrotate:

Rotating instance logs
======================

..  code-block:: console

    $ tt logrotate {INSTANCE|APPLICATION[:APP_INSTANCE]}

``tt logrotate`` rotates logs of a specified Tarantool instance.
Learn more about :ref:`rotating logs <admin-logs>`.

Examples
--------

Rotate logs of the ``app`` instance:

..  code-block:: console

    $ tt logrotate app
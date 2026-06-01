.. _tt-logrotate:

Rotating instance logs
======================

..  code-block:: console

    $ tt logrotate {INSTANCE | APPLICATION[:APP_INSTANCE]}

``tt logrotate`` rotates logs of a Tarantool application or specific instances,
and the ``tt`` log. For example, you need to call this function to continue logging
after a log rotation program renames or moves instances' logs.
Learn more about :ref:`rotating logs <admin-logs>`.

Calling ``tt logrotate`` on an application has the same effect as executing the
built-in :ref:`log.rotate() <log-rotate>` function on all its instances.

Examples
--------

Rotate logs of the ``app`` application's instances:

..  code-block:: console

    $ tt logrotate app
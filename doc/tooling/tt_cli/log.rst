.. _tt-log:

Printing Tarantool logs
=======================

..  code-block:: console

    $ tt log APPLICATION[:APP_INSTANCE]

``tt log`` prints the last lines of instance logs.

To print 10 last log lines of all the ``app`` application instances:

..  code-block:: console

    $ tt log app

To print 50 last log lines of the ``router`` instance of the ``app`` application:

..  code-block:: console

    $ tt log -n 50 app:router

To keep printing logs of the ``app`` application instances as they grow:

..  code-block:: console

    $ tt log -f app

Options
-------

.. option:: -f, --follow

    Keep printing new lines added to the log file.

.. option:: -n, --lines

    The number of last lines to output. Default: ``10``.

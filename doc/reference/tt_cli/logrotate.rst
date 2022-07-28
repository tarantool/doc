    Rotate instance logs
====================

..  code-block:: bash

    tt logrotate INSTANCE

``tt logrotate`` rotates logs of a specified Tarantool instance.
Learn more about :ref:`rotating logs <admin-logs>`.

Examples
--------

Rotate logs of the ``app`` instance:

..  code-block:: bash

    tt logrotate app
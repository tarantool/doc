.. _tt-stop:

Cleaning instance files
=======================

..  code-block:: bash

    tt clean INSTANCE

``tt clean`` cleans stored files of Tarantool instances: logs, snapshots, and
other files. To avoid accidental deletion of files, ``tt clean`` shows
the files it is going to delete and asks for confirmation.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``-f``

                ``--force``
            -   Clean files without confirmation


Examples
--------

Single instance
~~~~~~~~~~~~~~~

*   Clean files of the ``app`` instance:

    ..  code-block:: bash

        tt clean app

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Clean files of all instances of the ``app`` application:

    ..  code-block:: bash

        tt clean app

*   Clean files of the ``master`` instance of the ``app`` application:

    ..  code-block:: bash

        tt clean app:master
.. _tt-clean:

Cleaning instance files
=======================

..  code-block:: console

    $ tt clean {INSTANCE | APPLICATION[:APP_INSTANCE]} [OPTION ...]

``tt clean`` cleans stored files of Tarantool instances: logs, snapshots, and
other files. To avoid accidental deletion of files, ``tt clean`` shows
the files it is going to delete and asks for confirmation.

Options
-------

..  option:: -f, --force

    Clean files without confirmation.


Examples
--------

Single instance
~~~~~~~~~~~~~~~

*   Clean the files of the ``app`` instance:

    ..  code-block:: console

        $ tt clean app

Multiple instances
~~~~~~~~~~~~~~~~~~

*   Clean the files of all instances of the ``app`` application:

    ..  code-block:: console

        $ tt clean app

*   Clean the files of the ``master`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt clean app:master
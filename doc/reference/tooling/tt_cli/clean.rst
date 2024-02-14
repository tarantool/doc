.. _tt-clean:

Cleaning instance files
=======================

..  code-block:: console

    $ tt clean APPLICATION[:APP_INSTANCE] [OPTION ...]

``tt clean`` cleans stored files of Tarantool instances: logs, snapshots, and
other files. To avoid accidental deletion of files, ``tt clean`` shows
the files it is going to delete and asks for confirmation.

When called without arguments, cleans files of all applications in the current environment.


Options
-------

..  option:: -f, --force

    Clean files without confirmation.


Examples
--------

*   Clean the files of all instances of the ``app`` application:

    ..  code-block:: console

        $ tt clean app

*   Clean the files of the ``master`` instance of the ``app`` application:

    ..  code-block:: console

        $ tt clean app:master

..  _admin-upgrades_instance:

Standalone instance upgrade
===========================

This page describes the process of upgrading a standalone Tarantool instance in production.
Note that this **always implies a downtime** because the application needs to be
stopped and restarted on the target version.

To upgrade **without downtime**, you need multiple Tarantool servers running in a
replication cluster. Find detailed instructions in :ref:`Replication cluster upgrade <admin-upgrades-replication-cluster>`.

Checking your application
-------------------------

..  include:: ../_includes/upgrade_check_app.rst

Upgrading a standalone instance
-------------------------------

#.  Stop the Tarantool instance.

#.  Make a copy of all data and the package from which the current (old)
    version was installed. You may need it for rollback purposes. Find the
    backup instruction in the appropriate hot backup procedure in
    :ref:`Backups <admin-backups>`.

#.  Install the target Tarantool version on the host. You can do this
    using a package manager or the :ref:`tt utility <tt-cli>`.
    See the installation instructions at Tarantool `download page <http://tarantool.org/download.html>`_
    and in the :ref:`tt install reference <tt-install>`.
   To check that the target Tarantool version is installed, run ``tarantool -v``.

#.  Start your application on the target version.

#.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>`.
    This will update the Tarantool system spaces to match the currently installed version of Tarantool.

    .. NOTE::

        To undo schema upgrade in a case of failed upgrade, you can use :ref:`box.schema.downgrade() <box_schema-downgrade>`.

Rollback
--------

The rollback procedure for a standalone instance is almost the same as the upgrade.
The only difference is in the last step: you should call :ref:`box.schema.downgrade() <box_schema-downgrade>`
to return the schema to the original version.
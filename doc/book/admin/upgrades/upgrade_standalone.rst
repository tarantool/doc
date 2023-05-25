
..  _admin-upgrades_instance:

Standalone instance upgrade
===========================

This procedure is for upgrading a standalone Tarantool instance in production.
Notice that this will **always imply a downtime**.
To upgrade **without downtime**, you need several Tarantool servers running in a
replication cluster. Find detailed instructions in :ref:`Replication cluster upgrade <admin-upgrades_replication_cluster>`).

..  include:: ./../_includes/upgrade_procedure.rst

Upgrading a standalone instance
-------------------------------

#.  Stop the Tarantool instance.

#.  Make a copy of all data and the package from which the current (old)
    version was installed. You may need the for rollback purposes. Find the
    backup instruction in the appropriate hot backup procedure in
    :ref:`Backups <admin-backups>`.

#.  Install the target Tarantool version on the host. You can do this
    using a package manager or the :ref:`tt utility <tt-cli>`.
    See the installation instructions at Tarantool `download page <http://tarantool.org/download.html>`_
    and in the :ref:`tt install reference <tt-install>`.

#.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>`.
    This will update the Tarantool system spaces to match the currently installed version of Tarantool.

    .. NOTE::

        To undo schema upgrade in a case of failed upgrade, you can use :ref:`box.schema.downgrade() <box_schema-downgrade>`.

#.  Update your application files, if needed.

#.  Launch the updated Tarantool server using ``tarantoolctl``, ``tt``, or ``systemctl``.
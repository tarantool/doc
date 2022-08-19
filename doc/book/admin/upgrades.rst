.. _admin-upgrades:

Upgrades
========

For information about backwards compatibility,
see the :ref:`compatibility guarantees <compatibility_guarantees>` description.

.. _admin-upgrades_instance:

Upgrading Tarantool on a standalone instance
--------------------------------------------

This procedure is for upgrading a standalone Tarantool instance in production.
Notice that this will **always imply a downtime**.
To upgrade **without downtime**, you need several Tarantool servers running in a
replication cluster (see :ref:`below <admin-upgrades_replication_cluster>`).

1. Stop the Tarantool server.

2. Make a copy of all data (see an appropriate hot backup procedure in
   :ref:`Backups <admin-backups>`) and the package from which the current (old)
   version was installed (for rollback purposes).

3. Update the Tarantool server. See installation instructions at Tarantool
   `download page <http://tarantool.org/download.html>`_.

After that, make sure to :ref:`finish the upgrade properly <admin-upgrades_db>`.

.. _admin-upgrades_replication_cluster:

Upgrading Tarantool in a replica set with no downtime
-----------------------------------------------------

Below are the general instructions for upgrading Tarantool in a replica set.
Upgrading from some versions can involve certain specifics. You can find
instructions for individual versions :ref:`in the list below <admin-upgrades_version_specifics>`.

..  important::

    The only way to upgrade Tarantool from version 1.6, 1.7, or 1.9 to 2.x **without downtime** is
    taking an intermediate step by upgrading to 1.10 and then to 2.x.

    Before upgrading Tarantool from 1.6 to 2.x, please read about the associated
    :ref:`caveats <admin-upgrades-1.6-1.10>`.

Preparations
~~~~~~~~~~~~

#. Check the replica set health by running the following code on every instance:

   ..  code-block:: tarantoolsession

       box.info.ro -- "false" at least on one instance
       box.info.status -- should be "running"
 
   If all instances have ``box.info.ro = true``, this means there are no writable nodes.
   If you're running Tarantool :doc:`v. 2.10.0 </release/2.10.0>` or later,
   you can find out the reason by running ``box.info.ro_reason``.
   If it has the value ``orphan``, the instance doesn't see the rest of the replica set.
   Similarly, if ``box.info.status`` has the value ``orphan``, the instance doesn't see the rest of the replica set.
   First resolve the replication issues and only then continue.

   If you're running Cartridge, you can also check node health in the UI.

#. Make sure each replica connected to the rest of the replica set.
   Run ``box.info.replication`` and check the output table.
   For each instance ``id``, there are ``upstream`` and ``downstream`` values.
   Both of them should have the value ``follow``, except on the instance where you run this code.
   This means that the replicas are connected and there are no errors in the data flow.

   The value of the ``lag`` field can be less or equal than ``box.cfg.replication_timeout``,
   but it can also be moderately larger.
   For example, if ``box.cfg.replication_timeout`` is 1 second and the write load on the master is high,
   it's generally OK to have a lag of about 10 seconds on the master.
   It is up to the user to decide what lag values are fine.

If the replica set is healthy, proceed to the upgrade.

Upgrade procedure
~~~~~~~~~~~~~~~~~

..  include:: ./_includes/upgrade_procedure.rst

After upgrading the replica set, make sure to run ``box.schema.upgrade()`` on the new master
as described below in the section ":ref:`Finishing the upgrade <admin-upgrades_db>`".
There is no need  to run ``box.schema.upgrade()`` on every node:
changes are propagated to other nodes via the regular replication mechanism.

Finally, run ``box.snapshot()`` on every node in the replica set
to make sure that the replicas immediately see the upgraded database state in case of restart.

.. _admin-upgrades_db:

Finalizing the upgrade
----------------------

1.  If you created a database with an older Tarantool version and have now installed
    a newer version, make the request ``box.schema.upgrade()``. This updates
    Tarantool system spaces to match the currently installed version of Tarantool.

    For example, here is what happens when you run ``box.schema.upgrade()`` with a
    database created with Tarantool version 1.6.4 to version 1.7.2 (only a small
    part of the output is shown):

    .. code-block:: tarantoolsession

       tarantool> box.schema.upgrade()
       alter index primary on _space set options to {"unique":true}, parts to [[0,"unsigned"]]
       alter space _schema set options to {}
       create view _vindex...
       grant read access to 'public' role for _vindex view
       set schema version to 1.7.0
       ---
       ...
 
    You can also put the request ``box.schema.upgrade()``
    inside a :doc:`box.once() </reference/reference_lua/box_once>` function in your Tarantool
    :ref:`initialization file <index-init_label>`.
    On startup, this will create new system spaces, update data type names (for example,
    ``num`` -> ``unsigned``, ``str`` -> ``string``) and options in Tarantool system spaces.

2.  Update your application files, if needed.

3.  Launch the updated Tarantool server using ``tarantoolctl``, ``tt``, or ``systemctl``.


..  _admin-upgrades_version_specifics:

Version specifics
-----------------

..  toctree::
    :maxdepth: 1

    upgrades/1.6-1.10
    upgrades/1.6-2.0-downtime
    upgrades/2.10.1

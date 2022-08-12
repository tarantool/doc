.. _admin-upgrades:

Upgrades
========

For information about backwards compatibility,
see the :ref:`compatibility guarantees <compatibility_guarantees>` description.

.. _admin-upgrades_db:

Upgrading a database
--------------------

If you created a database with an older Tarantool version and have now installed
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


.. _admin-upgrades_instance:

Upgrading Tarantool on an instance
----------------------------------

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

4. Update the Tarantool database. Put the request ``box.schema.upgrade()``
   inside a :doc:`box.once() </reference/reference_lua/box_once>` function in your Tarantool
   :ref:`initialization file <index-init_label>`.
   On startup, this will create new system spaces, update data type names (e.g.
   num -> unsigned, str -> string) and options in Tarantool system spaces.

5. Update application files, if needed.

6. Launch the updated Tarantool server using ``tarantoolctl`` or ``systemctl``.


.. _admin-upgrades_replication_cluster:

Upgrading Tarantool in a replication cluster
--------------------------------------------

Below are the general instructions for upgrading Tarantool in a cluster.
Upgrading from some versions can involve certain specifics. You can find
instructions for individual versions on Tarantool's
`GitHub Wiki pages <https://github.com/tarantool/tarantool/wiki/Upgrade-instructions>`__.

..  important::

    The only way to upgrade Tarantool from 1.6 to 2.x **without downtime** is
    taking an intermediate step by upgrading from 1.6 to 1.10 and then to 2.x.
    This also applies to upgrading Tarantool from 1.7 and 1.9.

    Before upgrading Tarantool from 1.x to 2.y, please read about the associated
    `caveats <https://github.com/tarantool/tarantool/wiki/Caveats-when-upgrading-from-tarantool-1.6>`_.


#. Pick any replica in the cluster.

#. Upgrade this replica to the new Tarantool version. See details in
   :ref:`Upgrading a Tarantool instance <admin-upgrades_instance>`.

#. Make sure the replica connected to the rest of the cluster just fine:

   ..  code-block:: tarantoolsession

       box.info.replication[id].upstream
       box.info.replication[id].downstream
      
   The ``status`` field in both outputs should have the value ``follow``.
   This means that the replicas are connected and there are no errors in the data flow.

#. :ref:`Upgrade <admin-upgrades_instance>` all the replicas by repeating steps 1--3
   until only the master keeps running the old Tarantool version.

#. Make one of the updated replicas the new master.
   Check that it continues following and being followed by all other replicas.

#. :ref:`Upgrade <admin-upgrades_instance>` the former master.

#. :ref:`Upgrade <admin-upgrades_db>` the database on the new master by running ``box.schema.upgrade()``.
   Changes are propagated to other
   nodes via the regular replication mechanism.

#. Run ``box.snapshot()`` on every node in the cluster to take a snapshot of all the data.

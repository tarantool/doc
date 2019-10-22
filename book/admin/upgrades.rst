.. _admin-upgrades:

================================================================================
Upgrades
================================================================================

.. _admin-upgrades_db:

--------------------------------------------------------------------------------
Upgrading a Tarantool database
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
Upgrading a Tarantool instance
--------------------------------------------------------------------------------

Tarantool is backward compatible between two adjacent versions. For example, you
should have no or little trouble when upgrading from Tarantool 1.6 to 1.7, or
from Tarantool 1.7 to 1.8. Meanwhile Tarantool 1.8 may have incompatible changes
when migrating from Tarantool 1.6. to 1.8 directly.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
How to upgrade from Tarantool 1.6 to 1.7 / 1.10
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This procedure is for upgrading a standalone Tarantool instance in production
from 1.6.x to 1.7.x (or to 1.10.x).
Notice that this will **always imply a downtime**.
To upgrade **without downtime**, you need several Tarantool servers running in a
replication cluster (see :ref:`below <admin-upgrades_replication_cluster>`).

Tarantool 1.7 has an incompatible :ref:`.snap <internals-snapshot>` and
:ref:`.xlog <internals-wal>` file format: 1.6 files are
supported during upgrade, but you won’t be able to return to 1.6 after running
under 1.7 for a while. It also renames a few configuration parameters, but old
parameters are supported. The full list of breaking changes is available in
`release notes for Tarantool 1.7 / 1.9 / 1.10 <https://github.com/tarantool/tarantool/releases>`_.

To upgrade from Tarantool 1.6 to 1.7 (or to 1.10.x):

1. Check with application developers whether application files need to be
   updated due to incompatible changes (see
   `1.7 / 1.9 / 1.10 release notes <https://github.com/tarantool/tarantool/releases>`_).
   If yes, back up the old application files.

2. Stop the Tarantool server.

3. Make a copy of all data (see an appropriate hot backup procedure in
   :ref:`Backups <admin-backups>`) and the package from which the current (old)
   version was installed (for rollback purposes).

4. Update the Tarantool server. See installation instructions at Tarantool
   `download page <http://tarantool.org/download.html>`_.

5. Update the Tarantool database. Put the request ``box.schema.upgrade()``
   inside a :ref:`box.once() <box-once>` function in your Tarantool
   :ref:`initialization file <index-init_label>`.
   On startup, this will create new system spaces, update data type names (e.g.
   num -> unsigned, str -> string) and options in Tarantool system spaces.

6. Update application files, if needed.

7. Launch the updated Tarantool server using ``tarantoolctl`` or ``systemctl``.

.. _admin-upgrades_replication_cluster:

--------------------------------------------------------------------------------
Upgrading Tarantool in a replication cluster
--------------------------------------------------------------------------------

Tarantool 1.7 (as well as Tarantool 1.9 and 1.10)
can work as a :ref:`replica <replication-architecture>` for Tarantool 1.6 and vice versa. Replicas
perform capability negotiation on handshake, and new 1.7 replication features
are not used with 1.6 replicas. This allows upgrading clustered configurations.

This procedure allows for a rolling upgrade **without downtime** and works for
any cluster configuration: master-master or master-replica.

1. Upgrade Tarantool at all replicas (or at any master in a master-master
   cluster). See details in
   :ref:`Upgrading a Tarantool instance <admin-upgrades_instance>`.

2. Verify installation on the replicas:

   a. Start Tarantool.

   b. Attach to the master and start working as before.

   The master runs the old Tarantool version, which is always compatible with
   the next major version.

3. Upgrade the master. The procedure is similar to upgrading a replica.

4. Verify master installation:

   a. Start Tarantool with replica configuration to catch up.

   b. Switch to master mode.

5. Upgrade the database on any master node in the cluster. Make the request
   ``box.schema.upgrade()``. This updates Tarantool system spaces to match the
   currently installed version of Tarantool. Changes are propagated to other
   nodes via the regular replication mechanism.

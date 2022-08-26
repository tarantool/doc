1.  Pick any read-only instance in the replica set.

2.  Upgrade this replica to the new Tarantool version. See details in
    :ref:`Upgrading Tarantool on a standalone instance <admin-upgrades_instance>`.
    This requires stopping the instance for a while,
    which won't interrupt the replica set operation.
    When the upgraded replica is up again, it will synchronize with the other instances in the replica set
    so that the data are consistent across all the instances.

3.  Make sure the upgraded replica is running and connected to the rest of the replica set just fine.
    To do this, run ``box.info.replication`` in the instance's console
    and check the output table for values like ``upstream``, ``downstream``, and ``lag``.

    For each instance ``id``, there are ``upstream`` and ``downstream`` values.
    Both of them should have the value ``follow``, except on the instance where you run this code.
    This means that the replicas are connected and there are no errors in the data flow.

    The value of the ``lag`` field can be less or equal than ``box.cfg.replication_timeout``,
    but it can also be moderately larger.
    For example, if ``box.cfg.replication_timeout`` is 1 second and the write load on the master is high,
    it's generally OK to have a lag of about 10 seconds on the master.
    It is up to the user to decide what lag values are fine.

4.  :ref:`Upgrade <admin-upgrades_instance>` all the read-only instances by repeating steps 1--3
    until only the master keeps running the old Tarantool version.

5.  Make one of the updated replicas the new master:
    
    -   If the replica set is using asynchronous replication without
        :ref:`RAFT-based leader elections <repl_leader_elect>`,
        first run ``box.cfg{ read_only = true }`` on the old master
        and then run ``box.cfg{ read_only = false }`` on the replica that will be the new master.

    -   If the replica set is using :ref:`synchronous replication <repl_sync>` or
        :ref:`RAFT-based leader elections <repl_leader_elect>`,
        run ``box.ctl.promote()`` on the new master and then run
        ``box.cfg{ election_mode = 'voter' }`` on the old master.
        This will automatically change the ``read_only`` statuses on the instances.

    -   For a Cartridge replica set, it is possible to select the new master in the web UI.

    There is no need to restart the new master.

    Check that the new master continues following and being followed by all other replicas, similarly to step 3.

6.  :ref:`Upgrade <admin-upgrades_instance>` the former master, which is now a read-only instance.

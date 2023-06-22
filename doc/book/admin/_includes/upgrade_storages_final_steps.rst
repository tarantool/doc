.. // this instruction does not include the final step (calling box.snapshot())
.. // because we need to add a warning after step 5 in one use of this instruction

Upgrade storage instances by performing the following steps for each replica set:

.. note::

    To detect possible upgrade issues early, we recommend that you perform
    a :ref:`replication check <admin-upgrades-replication-check>` on all instances of
    the replica set **after each step**.

1.  Pick a replica (a **read-only** instance) from the replica set. Stop this replica
    and start it again on the target Tarantool version. Wait until it reaches the
    ``running`` status (``box.info.status == running``).
2.  Restart all other **read-only** instances of the replica set on the target
    version one by one.
3.  Make one of the updated replicas the new master using the applicable instruction
    from :ref:`Switching the master <admin-upgrades-switch-master>`.
4.  Restart the last instance of the replica set (the former master, now
    a replica) on the target version.

.. _admin-upgrades-no-return:

5.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>` on the new master.
    This will update the Tarantool system spaces to match the currently installed
    version of Tarantool. The changes will be propagated to other nodes via the
    replication mechanism later.



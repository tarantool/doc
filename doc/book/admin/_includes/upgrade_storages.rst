Before upgrading **storage** instances:

*   Disable :doc:`Cartridge failover </book/cartridge/cartridge_cli/commands/failover/>`: run

    ..  code-block:: bash

        cartridge failover disable

    or use the Cartridge web interface (**Cluster** tab, **Failover: <Mode>** button).

*   Disable :ref:`rebalancer <storage_api-rebalancer_disable>`: run

    ..  code-block:: tarantoolsession

        vshard.storage.rebalancer_disable()

*   Make sure that the Cartridge ``upgrade_schema`` :doc:`option </book/cartridge/cartridge_api/modules/cartridge/#cfg-opts-box-opts>`
    is disabled.

Then upgrade storage instances by performing the following steps for each replica set:

.. note::

    To detect possible upgrade issues early, we recommend that you perform
    a :ref:`replication check <admin-upgrades-replication-check>` on all instances of
    the replica set **after each step**.

1.  Pick a replica (a **read-only** instance) from the replica set and restart it
    on the target Tarantool version. Wait until it reaches the ``running`` status
    (``box.info.status == running``).
2.  Restart all other **read-only** instances of the replica set on the target
    version one by one.
3.  Make one of the updated replicas the new master using the applicable instruction
    from :ref:`Switching the master <admin-upgrades-switch-master>`.

    .. warning::

        This is the point of no return when upgrading from version 1.6: once you
        complete it, the schema is no longer compatible with the source Tarantool version.

4.  Restart the last instance of the replica set (the former master, now
    a replica) on the target version.

.. _admin-upgrades-no-return:

5.  Run :ref:`box.schema.upgrade() <box_schema-upgrade>` on the new master.
    This will update the Tarantool system spaces to match the currently installed
    version of Tarantool. The changes will be propagated to other nodes via the
    replication mechanism later.

    .. warning::

        This is the point of no return: once you complete it, the schema is no
        longer compatible with the source Tarantool version.

    .. NOTE::

        To undo schema upgrade in a case of failed upgrade, you can use :ref:`box.schema.downgrade() <box_schema-downgrade>`.

6.  Run ``box.snapshot()`` on every node in the replica set to make sure that the
    replicas immediately see the upgraded database state in case of restart.

Once you complete the steps, enable failover or rebalancer back:

*   Enable :doc:`Cartridge failover </book/cartridge/cartridge_cli/commands/failover/>`: run

    ..  code-block:: bash

        cartridge failover set [mode]

    or use the Cartridge web interface (**Cluster** tab, **Failover: Disabled** button).

*   Enable :ref:`rebalancer <storage_api-rebalancer_enable>`: run

    ..  code-block:: tarantoolsession

        vshard.storage.rebalancer_enable()
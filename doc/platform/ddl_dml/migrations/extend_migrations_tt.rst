..  _extend_migrations_tt:

Extending the cluster
=====================

**Example on GitHub:** `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations>`_

In this tutorial, you learn how to consistently define the data schema on newly
added cluster instances using the centralized migration management mechanism.

..  _extend_migrations_tt_prereq:

Prerequisites
-------------

Before starting this tutorial, complete the :ref:`basic_migrations_tt` and :ref:`upgrade_migrations_tt`.
As a result, you have a sharded Tarantool EE cluster that uses an etcd-based configuration
storage. The cluster has a space with two indexes.

..  _extend_migrations_tt_cluster:

Extending the cluster
---------------------

Having all migrations in a centralized etcd storage, you can extend the cluster
and consistently define the data schema on new instances on the fly.

Add one more storage replica set to the cluster. To do this, edit the cluster files in ``instances.enabled/myapp``:

-   ``instances.yml``: add the lines below to the end.

    ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/instances-3-storages.yml
        :language: yaml
        :start-at: storage-003-a:
        :dedent:

-   ``source.yaml``: add the lines below to the end.

    ..  literalinclude:: /code_snippets/snippets/migrations/instances.enabled/myapp/source-3-storages.yaml
        :language: yaml
        :start-at: storage-003:
        :dedent:

Publish the new cluster configuration to etcd:

.. code-block:: console

    $ tt cluster publish "http://app_user:config_pass@localhost:2379/myapp/" source.yaml

Run ``tt start`` to start up the new instances:

.. code-block:: console

    $ tt start myapp
       • The instance myapp:router-001-a (PID = 61631) is already running.
       • The instance myapp:storage-001-a (PID = 61632) is already running.
       • The instance myapp:storage-001-b (PID = 61634) is already running.
       • The instance myapp:storage-002-a (PID = 61639) is already running.
       • The instance myapp:storage-002-b (PID = 61640) is already running.
       • Starting an instance [myapp:storage-003-a]...
       • Starting an instance [myapp:storage-003-b]...

Now the cluster contains three storage replica sets.


..  _extend_migrations_tt_apply:

Applying migrations to the new replica set
------------------------------------------

The new replica set -- ``storage-003``-- is just started and has no data schema yet.
Apply all stored migrations to the cluster to load the same data schema to the new replica set:

.. code-block:: console

     $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp \
                           --tarantool-username=client --tarantool-password=secret
                           --replicaset storage-003

.. note::

    You can also apply migrations without specifying the replica set. All published
    migrations are already applied on other replica sets, so ``tt`` skips the
    operation on them.

    .. code-block:: console

        $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp \
                              --tarantool-username=client --tarantool-password=secret

To make sure that the space exists on the new instances, connect to ``storage-003-a``
and check ``box.space.writers``:

.. code-block:: console

    $ tt connect myapp:storage-003-a

.. code-block:: tarantoolsession

    myapp:storage-003-a> box.space.writers ~= nil
    ---
    - true
    ...

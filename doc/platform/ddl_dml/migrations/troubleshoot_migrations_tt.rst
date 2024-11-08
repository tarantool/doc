..  _centralized_migrations_tt_troubleshoot:

Troubleshooting migrations
==========================

The centralized migrations mechanism allows troubleshooting migration issues using
dedicated ``tt migration`` options. When troubleshooting migrations, remember that
any unfinished or failed migration can bring the data schema into to inconsistency.
Additional steps may be needed to fix this.

.. warning::

    The options used for migration troubleshooting can cause migration inconsistency
    in the cluster. Use them only for local development and testing purposes.

..  _centralized_migrations_tt_troubleshoot_publish:

Incorrect migration published
-----------------------------

If an incorrect migration was published to etcd but wasn't applied yet,
fix the migration file and publish it again with the ``--overwrite`` option:

.. code-block:: console

    $ tt migrations publish "http://app_user:config_pass@localhost:2379/myapp" \
                            000001_create_space.lua --overwrite

If the migration that needs a fix isn't the last in the lexicographical order,
add also ``--ignore-order-violation``:

.. code-block:: console

    $ tt migrations publish "http://app_user:config_pass@localhost:2379/myapp" \
                            000001_create_space.lua --overwrite --ignore-order-violation

If a migration was published by mistake and wasn't applied yet, you can delete it
from etcd using ``tt migrations remove``:

.. code-block:: console

    $ tt migrations remove "http://app_user:config_pass@localhost:2379/myapp" \
                        --migration 000003_not_needed.lua

..  _centralized_migrations_tt_troubleshoot_apply:

Incorrect migration applied
---------------------------

.. warning::

    Any schema change that was made by an incorrect migration before its fail or
    cancellation must be resolved manually on each replica set before reapply.
    ``--force-reapply`` and other ``tt migrations`` options affect only internal
    status of the migration and don't revert changes that it has made in the cluster.

If the migration is already applied, publish the fixed version and apply it with
the ``--force-reapply`` option:

.. code-block:: console

    $ tt migrations apply "http://app_user:config_pass@localhost:2379/myapp" \
                          --tarantool-username=client --tarantool-password=secret \
                          --force-reapply

If execution of the incorrect migration version has failed, you may also need to add
the ``--ignore-preceding-status`` option:

When you reapply a migration, ``tt`` checks the statuses of preceding migrations
to ensure consistency. To skip this check, add the ``--ignore-preceding-status`` option:

.. code-block:: console

    $ tt migrations apply "http://app_user:config_pass@localhost:2379/myapp" \
                          --tarantool-username=client --tarantool-password=secret \
                          --migration=00003_alter_space.lua
                          --force-reapply --ignore-preceding-status

..  _centralized_migrations_tt_troubleshoot_stop:

Migration execution takes too long
----------------------------------

To interrupt migration execution on the cluster, use ``tt migrations stop``:

.. code-block:: console

    $ tt migrations stop "http://app_user:config_pass@localhost:2379/myapp" \
                          --tarantool-username=client --tarantool-password=secret

You can adjust the maximum migration execution time using the ``--execution-timeout``
option of ``tt migrations apply``:

.. code-block:: console

    $ tt migrations apply "http://app_user:config_pass@localhost:2379/myapp" \
                          --tarantool-username=client --tarantool-password=secret \
                          --execution-timeout=60

.. note::

    If a migration timeout is reached, you may need to call ``tt migrations stop``
    to cancel requests that were sent when applying migrations.
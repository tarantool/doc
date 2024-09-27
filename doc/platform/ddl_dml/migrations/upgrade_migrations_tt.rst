..  _upgrade_migrations_tt:

Complex migrations with space.upgrade()
=======================================

**Example on GitHub:** `migrations <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/migrations>`_

In this tutorial, you learn to write migrations that include data migration using
the ``space.upgrade()`` function.

See also:

-   :ref:`tt migrations <tt-migrations>` for the full list of command-line options.
-   :ref:`tcm_cluster_migrations` to learn about managing migrations from |tcm_full_name|.

..  _upgrade_migrations_tt:

Prerequisites
-------------

Before starting this tutorial, complete the :ref:`basic_migrations_tt`.
As a result, you have a sharded Tarantool EE cluster that uses an etcd-based configuration
storage. The cluster has a space with two indexes.

..  _upgrade_migrations_tt_write:

Writing a complex migration
---------------------------

Complex migrations require data migration along with schema migration. Connect to
the router instance and insert some tuples into the space before proceeding to the next steps.

.. code-block:: $ tt connect myapp:router-001

.. code-block:: tarantoolsession

    myapp:router-001-a> require('crud').insert_object_many('writers', {
        {id = 1, name = 'Haruki Murakami', age = 75},
        {id = 2, name = 'Douglas Adams', age = 49},
        {id = 3, name = 'Eiji Mikage', age = 41},
    }, {noreturn = true})

The next migration changes the space format incompatibly: instead of one ``name``
field, the new format includes two fields ``first_name`` and ``last_name``.
To apply this migration, you need to change each tuple's structure preserving the stored
data. The :ref:`space.upgrade <enterprise-space_upgrade>` function helps with this task.

Create a new file ``000003_alter_writers_space.lua`` in ``/migrations/scenario``.
Prepare its initial structure the same way as in previous migrations:

.. code-block:: lua

    local function apply_scenario()
    --  migration code
    end
    return {
        apply = {
            scenario = apply_scenario,
        },
    }

Start the migration function with the new format description:

..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000003_alter_writers_space.lua
    :language: lua
    :start-at: local function apply_scenario()
    :end-at: box.space.writers.index.age:drop()
    :dedent:

.. note::

    ``box.space.writers.index.age:drop()`` drops an existing index. This is done
    because indexes rely on field numbers and may break during this format change.
    If you need the ``age`` field indexed, recreate the index after applying the
    new format.

Next, create a stored function that transforms tuples to fit the new format.
In this case, the functions extracts the first and the last name from the ``name`` field
and returns a tuple of the new format:

..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000003_alter_writers_space.lua
    :language: lua
    :start-at: box.schema.func.create
    :end-before: local future = space:upgrade
    :dedent:

Finally, call ``space:upgrade()`` with the new format and the transformation function
as its arguments. Here is the complete migration code:

..  literalinclude:: /code_snippets/snippets/migrations/migrations/scenario/000003_alter_writers_space.lua
    :language: lua
    :dedent:

Learn more about ``space.upgrade()`` execution in :ref:`enterprise-space_upgrade`.

..  _upgrade_migrations_tt_publish:

Publishing the migration
------------------------

Publish the new migration to etcd. Migrations that already exist in the storage are skipped.

.. code-block:: console

    $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp \
                            migrations/scenario/000003_alter_writers_space.lua

.. note::

    You can also publish all migrations from the default location ``/migrations/scenario``.
    All other migrations stored in this directory are already published, so ``tt``
    skips them.

    .. code-block:: console

        $ tt migrations publish http://app_user:config_pass@localhost:2379/myapp


..  _upgrade_migrations_tt_apply:

Applying the migration
----------------------

Apply the published migrations:

.. code-block:: console

    $ tt migrations apply http://app_user:config_pass@localhost:2379/myapp \
                          --tarantool-username=client --tarantool-password=secret

Connect to the router instance and check that the space and its tuples have the new format:

.. code-block:: $ tt connect myapp:router-001

.. code-block:: tarantoolsession

    myapp:router-001-a> require('crud').get('writers', 2)
    ---
    - rows: []
      metadata: [{'name': 'id', 'type': 'number'}, {'name': 'bucket_id', 'type': 'number'},
        {'name': 'first_name', 'type': 'string'}, {'name': 'last_name', 'type': 'string'},
        {'name': 'age', 'type': 'number'}]
    - null
    ...

.. _tt-migrations:

Performing migrations
=====================

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

..  code-block:: console

    $ tt migrations COMMAND [COMMAND_OPTION ...]

``tt migrations`` manages :ref:`migrations <migrations>` in a Tarantool EE cluster.

.. important::

    Only Tarantool EE clusters with etcd centralized configuration storage are supported.

Prereq:
- EE
- crud
- etcd

how to write migration files? tt-migrtions.helpers

Migration workflow

prepare files
publish to etcd
apply
check status

Handling errors

stop
rollback - show examples with force apply?


``COMMAND`` is one of the following:

*   :ref:`apply <tt-migrations-apply>`
*   :ref:`publish <tt-migrations-publish>`
*   :ref:`remove <tt-migrations-remove>`
*   :ref:`status <tt-migrations-status>`
*   :ref:`stop <tt-migrations-stop>`


.. _tt-migrations-apply:

apply
-----

..  code-block:: console

    $ tt migrations apply ETCD_URI [OPTION ...]

``tt migrations apply`` applies migrations :ref:`published <tt-migrations-publish>`
to the cluster to the cluster. It executes all migrations from the cluster's centralized
configuration storage on all its read-write instances (replica set leaders).

.. code-block:: console

    tt migrations apply https://user:pass@localhost:2379/myapp  \
                        -tarantool-username=admin --tarantool-password=pass

You can select a single migration for execution by adding the ``--migration`` option:

.. code-block:: console

    tt migrations apply https://user:pass@localhost:2379/myapp  \
                        --tarantool-username=admin --tarantool-password=pass  \
                        --migration=000001_create_space.lua

You can select a single replica set to apply migrations to:

.. code-block:: console

    tt migrations apply https://user:pass@localhost:2379/myapp  \
                        --tarantool-username=admin --tarantool-password=pass  \
                        --replicaset=storage-001

-- migration - single migration. --order violation


?? diff --force-reapply  --ignore-preceding-status

warning about dangerous options

.. _tt-migrations-publish:

publish
-------

..  code-block:: console

    $ tt migrations publish ETCD_URI [MIGRATIONS_DIR | MIGRATION_FILE] [OPTION ...]

``tt migrations publish`` sends the migration files to the cluster's centralized
configuration storage for future execution.

By default, the command sends all files stored in ``migrations/`` inside the current
directory.

..  code-block:: console

    $ tt migrations publish https://user:pass@localhost:2379/myapp

To select another directory with migration files, provide a path to it as the command
argument:

..  code-block:: console

    $ tt migrations publish https://user:pass@localhost:2379/myapp my_migrations

To publish a single migration from a file, use its name or path as the command argument:

..  code-block:: console

    $ tt migrations publish https://user:pass@localhost:2379/myapp migrations/000001_create_space.lua

Optionally, you can provide a key to use as a migration identifier instead of the file name:

..  code-block:: console

    $ tt migrations publish https://user:pass@localhost:2379/myapp file.lua  \
                            --key=000001_create_space.lua

When publishing migrations, ``tt`` performs several checks for:

-   Syntax errors in migration files. To skip syntax check, add the ``--skip-syntax-check`` option.
-   Existence of migrations with same names. To overwrite an existing migration with
    the same name, add the ``--overwirte`` option.
-   Migration names order. By default, ``tt migrations`` only adds new migrations
    to the end of the migrations list ordered lexicographically. For example, if
    migrations ``001.lua`` and ``003.lua`` are already published, an attempt to publish
    ``002.lua`` will fail. To force publishing migrations disregarding the order,
    add the ``--ignore-order-violation`` option.

.. warning::

    Using the options that ignore checks when publishing migration may cause
    migration inconsistency.

.. _tt-migrations-remove:

remove
------

..  code-block:: console

    $ tt migrations remove ETCD_URI [OPTION ...]

``tt migrations remove`` removes published migrations from the centralized storage.
With additional options, it can also remove the information about the migration execution
on the cluster instances.

To remove all migrations from a specified centralized storage:

.. code-block:: console

    tt migrations remove https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass

To remove a specific migration, pass its name in the ``--migration`` option:

.. code-block:: console

    tt migrations remove https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass  \
                         --migration=000001_create_writers_space.lua

Before removing migrations, the command checks their :ref:`status <tt-migrations-status>`
on the cluster. To ignore the status and remove migrations anyway, add the
``--force-remove-on=config-storage`` option:

.. code-block:: console

    tt migrations remove https://user:pass@localhost:2379/myapp  --force-remove-on=config-storage

.. note::

    In this case, cluster credentials are not required

To remove migration execution information from the cluster (clear the migration status),
use the ``--force-remove-on=cluster`` option:

.. code-block:: console

    tt migrations remove https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass  \
                         --force-remove-on=cluster

To clear all migration information from the centralized storage and cluster,
use the ``--force-remove-on=all`` option:

.. code-block:: console

    tt migrations remove https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass  \
                         --force-remove-on=all

?? dangers/warnings?

.. _tt-migrations-status:

status
------

..  code-block:: console

    $ tt migrations status ETCD_URI [OPTION ...]

``tt migrations status`` prints the list of migrations published to the centralized
storage and the result of their execution on the cluster instances.

Possible migration statuses are:

-  ``APPLY_STARTED`` -- the migration execution has started but not completed yet
-  ``APPLIED`` -- the migration is successfully applied on the instance
-  ``FAILED`` -- there were errors during the migration execution on the instance

To get the list of migrations stored in the given etcd storage and information about
their execution on the cluster, run:

.. code-block:: console

    tt migrations status https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass

If the cluster uses SSL encryption, add SSL options. Learn more in :ref:`Authentication <tt-migrations-auth>`.

Use the ``--migration`` and ``--replicaset`` options to get information about specific
migrations or replica sets:

.. code-block:: console

    tt migrations status https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass \
                         --replicaset=storage-001 --migration=000001_create_writers_space.lua

The ``--display-mode`` option allows to tailor the command output:

-   with ``--display-mode config-storage``, the command prints only the list of migrations
    published to the centralized storage.
-   with ``--display-mode cluster``, the command prints only the migration statuses
    on the cluster instances.

To find out the results of a migration execution on a specific replica set in the cluster, run:

.. code-block:: console

    tt migrations status https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=pass  \
                         --replicaset=storage-001 --display-mode=cluster


.. _tt-migrations-stop:

stop
----

..  code-block:: console

    $ tt migrations stop ETCD_URI [OPTION ...]

``tt migrations stop`` stops the execution of migrations in the cluster

.. warning::

    Calling ``tt migration stop`` may cause migration inconsistency in the cluster.

To stop execution of migrations currently running in the cluster:

..  code-block:: console

    $ tt migrations stop https://user:pass@localhost:2379/myapp  \
                         --tarantool-username=admin --tarantool-password=secret-cluster-cookie

all migration in the batch?
can any of them complete?
can it cause inconsistency?

.. _tt-migrations-auth:

Authentication
--------------

Since ``tt migrations`` operates migrations via a centralizes etcd storage, it
needs credentials to access this storage. There are two ways to pass etcd credentials:

-   command options ``--config-storage-username`` and ``--config-storage-password``
-   the etcd URI, for example, ``https://user:pass@localhost:2379/myapp``

?priority

For commands that connect to the cluster (that is, all except ``publish``), Tarantool
credentials are also required. The are passed in the ``--tarantool-username`` and
``--tarantool-password`` options.

If the cluster uses SSL traffic encryption, provide the necessary connection
parameters in the ``--tarantool-ssl*`` options: ``--tarantool-sslcertfile``,
``--tarantool-sslkeyfile``, and other. All options are listed in :ref:`tt-migrations-options`.

?auth type
?example

.. _tt-migrations-options:

Options
-------

.. option:: --acquire-lock-timeout int

    **Applicable to:** ``apply``

    migrations fiber lock acquire timeout (in seconds). Fiber lock is used to prevent concurrent migrations run (default 60)

.. option:: --config-storage-password STRING

    A password for connecting to the centralized migrations storage (etcd).

    See also: :ref:`tt-migrations-auth`.

.. option:: --config-storage-username STRING

    A username for connecting to the centralized migrations storage (etcd).

    See also: :ref:`tt-migrations-auth`.

.. option:: --display-mode STRING

    **Applicable to:** ``status``

    Display only specific information. Possible values:

    -   ``config-storage`` -- information about migrations published to the centralized storage.
    -   ``cluster`` -- information about migration applied on the cluster.

    See also: :ref:`tt-migrations-status`.

.. option:: --execution-timeout int

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    A timeout for completing the operation on a single Tarantool instance, in seconds.
    Default values:

    -   ``3`` for ``remove``, ``status``, and ``stop``
    -   ``3600`` for ``apply``

.. option:: --force-reapply

    **Applicable to:** ``apply``

    Apply migrations disregarding their previous status.

    .. warning::

        Using this option may result in cluster migrations inconsistency.

.. option:: --force-remove-on STRING

    **Applicable to:** ``remove``

    Remove migrations disregarding their status. Possible values:

    -   ``config-storage``: remove  migrations on etcd centralized migrations storage disregarding the cluster apply status.
    -   ``cluster``: remove  migrations status info only on a Tarantool cluster.
    -   ``all`` to execute both ``config-storage`` and ``cluster`` force removals.

    .. warning::

        Using this option may result in cluster migrations inconsistency.

.. option:: --ignore-order-violation

    **Applicable to:** ``apply``, ``publish``

    Skip migration scenarios order check before publish. Using this flag may result in cluster migrations inconsistency

.. option:: --ignore-preceding-status

    **Applicable to:** ``apply``

    skip preceding migrations status check on apply. Using this flag may result in cluster migrations inconsistency

.. option:: --key STRING

    **Applicable to:** ``publish``

    put scenario to /<prefix>/migrations/scenario/<key> etcd key instead. Only for single file publish

.. option:: --migration string

    **Applicable to:** ``apply``, ``remove``, ``status``

    migration to remove

.. option:: --overwrite

    **Applicable to:** ``publish``

    overwrite existing migration storage keys. Using this flag may result in cluster migrations inconsistency

.. option:: --replicaset string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    Execute the operation only on the specified replicaset.

.. option:: --skip-syntax-check

    **Applicable to:** ``publish``

    Skip syntax check before publish. Using this flag may cause other tt migrations operations to fail

.. option:: --tarantool-auth string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    authentication type (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-connect-timeout int

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    Tarantool cluster instances connection timeout,in seconds. Default: 3.

.. option:: --tarantool-password string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    A password used for connecting to the Tarantool cluster instances.

.. option:: --tarantool-sslcafile string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    SSL CA file (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-sslcertfile string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    SSL cert file (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-sslciphers string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    Colon-separated list of SSL ciphers (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-sslkeyfile string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    SSL key file (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-sslpassword string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    SSL key file password (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-sslpasswordfile string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    File with list of password to SSL key file (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-use-ssl

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    use SSL without providing any additional SSL info (used only to connect to Tarantool cluster instances)

.. option:: --tarantool-username string

    **Applicable to:** ``apply``, ``remove``, ``status``, ``stop``

    A username for connecting to the Tarantool cluster instances.

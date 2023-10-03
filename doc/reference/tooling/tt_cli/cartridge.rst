.. _tt_cartridge:

Managing a Cartridge application
================================

..  code-block:: console

    $ tt cartridge COMMAND {[OPTION ...]|SUBCOMMAND}

``tt cartridge`` manages a Cartridge application.
``COMMAND`` is one of the following:

*   :ref:`admin <tt_cartridge_admin>`
*   :ref:`bench <tt_cartridge_bench>`
*   :ref:`failover <tt_cartridge_failover>`
*   :ref:`repair <tt_cartridge_repair>`
*   :ref:`replicasets <tt_cartridge_replicasets>`


.. _tt_cartridge_admin:

admin
-----

..  code-block:: console

    $ tt cartridge admin ADMIN_FUNC_NAME [ADMIN_OPTION ...]

``tt cartridge admin`` calls `admin functions <https://github.com/tarantool/cartridge-cli-extensions/blob/master/doc/admin.md>`_ provided by the application.

.. _tt_cartridge_admin_options:

Options
~~~~~~~

..  option:: --name STRING

    (Required) An application name.

..  option:: -l, --list

    List the available admin functions.

..  option:: --instance STRING

    A name of the instance to connect to.

..  option:: --conn STRING

    An address to connect to.

..  option:: --run-dir STRING

    A directory where PID and socket files are stored. Defaults to ``/var/run/tarantool``.


.. _tt_cartridge_admin_examples:

Examples
~~~~~~~~

Get a list of the available admin functions:

.. code-block:: console

    tt cartridge admin --name APPNAME --list

       • Available admin functions:

    probe  Probe instance

Get help for a specific function:

.. code-block:: console

    tt cartridge admin --name APPNAME probe --help

       • Admin function "probe" usage:

    Probe instance

    Args:
      --uri string  Instance URI

Call a function with an argument:

.. code-block:: console

    tt cartridge admin --name APPNAME probe --uri localhost:3301

       • Probe "localhost:3301": OK



.. _tt_cartridge_bench:

bench
-----

..  code-block:: console

    $ tt cartridge bench [BENCH_OPTION ...]

``tt cartridge bench`` runs benchmarks for Tarantool.

.. _tt_cartridge_bench_options:

Options
~~~~~~~

..  option:: --url STRING

    A Tarantool instance address (the default is ``127.0.0.1:3301``).

..  option:: --user STRING

    A username used to connect to the instance (the default is ``guest``).

..  option:: --password STRING

    A password used to connect to the instance.

..  option:: --connections INT

    A number of concurrent connections (the default is ``10``).

..  option:: --requests INT

    A number of simultaneous requests per connection (the default is ``10``).

..  option:: --duration INT

    The duration of a benchmark test in seconds (the default is ``10``).

..  option:: --keysize INT

    The size of a key part of benchmark data in bytes (the default is ``10``).

..  option:: --datasize INT

    The size of a value part of benchmark data in bytes (the default is ``20``).

..  option:: --insert INT

    A percentage of inserts (the default is ``100``).

..  option:: --select INT

    A percentage of selects.

..  option:: --update INT

    A percentage of updates.

..  option:: --fill INT

    A number of records to pre-fill the space (the default is ``1000000``).


.. _tt_cartridge_failover:

failover
--------

..  code-block:: console

    $ tt cartridge failover COMMAND [COMMAND_OPTION ...]

``tt cartridge failover`` manages an application failover.

.. _tt_cartridge_failover_commands:

Subcommands
~~~~~~~~~~~

failover set
^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge failover set MODE [FAILOVER_SET_OPTION ...]

Setup failover in the specified mode:

*   ``stateful``
*   ``eventual``
*   ``disabled``

Options:

*   ``--state-provider STRING``: A failover's state provider. Can be ``stateboard`` or ``etcd2``. Used only in the ``stateful`` mode.
*   ``--params STRING``: Failover parameters specified in a JSON-formatted string, for example, ``"{'fencing_timeout': 10', 'fencing_enabled': true}"``.
*   ``--provider-params STRING``: Failover provider parameters specified in a JSON-formatted string, for example, ``"{'lock_delay': 14}"``.

failover setup
^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge failover setup --file STRING

Setup failover with parameters described in a file.
The failover configuration file defaults to ``failover.yml``.

The ``failover.yml`` file might look as follows:


failover status
^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge failover status

Get the current failover status.

failover disable
^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge failover disable

Disable failover.

.. code-block:: yaml

    mode: stateful
    state_provider: stateboard
    stateboard_params:
        uri: localhost:4401
        password: passwd
    failover_timeout: 15

..  container:: table

    ..  list-table::
        :widths: 25 75
        :header-rows: 0

        *   -   ``set``
            -   Setup failover in the specified mode:

                *   ``stateful``
                *   ``eventual``
                *   ``disabled``

                Usage:

                .. code-block:: console

                    $ tt cartridge failover set MODE [FAILOVER_SET_OPTION ...]

                Options:

                *   ``--state-provider STRING``: A failover's state provider. Can be ``stateboard`` or ``etcd2``. Used only in the ``stateful`` mode.
                *   ``--params STRING``: Failover parameters specified in a JSON-formatted string, for example, ``"{'fencing_timeout': 10', 'fencing_enabled': true}"``.
                *   ``--provider-params STRING``: Failover provider parameters specified in a JSON-formatted string, for example, ``"{'lock_delay': 14}"``.

        *   -   ``setup``
            -   Setup failover with parameters described in a file.
                The failover configuration file defaults to ``failover.yml``.

                Usage:

                .. code-block:: console

                    $ tt cartridge failover setup --file STRING

                The ``failover.yml`` file might look as follows:

                .. code-block:: yaml

                    mode: stateful
                    state_provider: stateboard
                    stateboard_params:
                        uri: localhost:4401
                        password: passwd
                    failover_timeout: 15

        *   -   ``status``
            -   Get the current failover status.

                Usage:

                .. code-block:: console

                    $ tt cartridge failover status

        *   -   ``disable``
            -   Disable failover.

                Usage:

                .. code-block:: console

                    $ tt cartridge failover disable


.. _tt_cartridge_failover_options:

Options
~~~~~~~

..  option:: --name STRING

    An application name. Defaults to "package" in rockspec.

..  option:: --file STRING

    A path to the file containing failover settings. Defaults to ``failover.yml``.


.. _tt_cartridge_repair:

repair
------

..  code-block:: console

    tt cartridge repair COMMAND [REPAIR_OPTION ...]

``tt cartridge repair`` repairs a running application.

.. _tt_cartridge_repair_commands:

Subcommands
~~~~~~~~~~~

repair list-topology
^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge repair list-topology [REPAIR_OPTION ...]

Get a summary of the current cluster topology.

repair remove-instance
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge repair remove-instance UUID [REPAIR_OPTION ...]

Remove the instance with the specified UUID from the cluster. If the instance isn't found, raise an error.

repair set-advertise-uri
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge repair set-advertise-uri INSTANCE-UUID NEW-URI [REPAIR_OPTION ...]

Change the instance's advertise URI. Raise an error if the instance isn't found or is expelled.

repair set-leader
^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge repair set-leader REPLICASET-UUID INSTANCE-UUID [REPAIR_OPTION ...]

Set the instance as the leader of the replica set. Raise an error in the following cases:

*   There is no replica set or instance with that UUID.
*   The instance doesn't belong to the replica set.
*   The instance has been disabled or expelled.


..  container:: table

    ..  list-table::
        :widths: 25 75
        :header-rows: 0

        *   -   ``list-topology``
            -   Get a summary of the current cluster topology.

                Usage:

                .. code-block:: console

                    $ tt cartridge repair list-topology [REPAIR_OPTION ...]

        *   -   ``remove-instance``
            -   Remove the instance with the specified UUID from the cluster. If the instance isn't found, raise an error.

                Usage:

                .. code-block:: console

                    $ tt cartridge repair remove-instance UUID [REPAIR_OPTION ...]

        *   -   ``set-advertise-uri``
            -   Change the instance's advertise URI. Raise an error if the instance isn't found or is expelled.

                Usage:

                .. code-block:: console

                    $ tt cartridge repair set-advertise-uri INSTANCE-UUID NEW-URI [REPAIR_OPTION ...]

        *   -   ``set-leader``
            -   Set the instance as the leader of the replica set. Raise an error in the following cases:

                *   There is no replica set or instance with that UUID.
                *   The instance doesn't belong to the replica set.
                *   The instance has been disabled or expelled.

                Usage:

                .. code-block:: console

                    tt cartridge repair set-leader REPLICASET-UUID INSTANCE-UUID [REPAIR_OPTION ...]


.. _tt_cartridge_repair_options:

Options
~~~~~~~

The following options work with any ``repair`` subcommand:

..  option:: --name

    (Required) An application name.

..  option:: --data-dir

    The directory containing the instances' working directories. Defaults to ``/var/lib/tarantool``.

The following options work with any ``repair`` command, except ``list-topology``:

..  option:: --run-dir

    The directory where PID and socket files are stored. Defaults to ``/var/run/tarantool``.

..  option:: --dry-run

    Launch in dry-run mode: show changes but do not apply them.

..  option:: --reload

    Enable instance configuration to reload after the patch.



.. _tt_cartridge_replicasets:

replicasets
-----------

..  code-block:: console

    $ tt cartridge replicasets COMMAND [COMMAND_OPTION ...]

``tt cartridge replicasets`` manages an application's replica sets.


.. _tt_cartridge_replicasets_commands:

Subcommands
~~~~~~~~~~~

replicasets setup
^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets setup [--file FILEPATH] [--bootstrap-vshard]

Setup replica sets using a file.

Options:

*   ``--file``: A file with a replica set configuration. Defaults to ``replicasets.yml``.
*   ``--bootstrap-vshard``: Bootstrap vshard upon setup.

replicasets save
^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets save [--file FILEPATH]

Save the current replica set configuration to a file.

Options:

*   ``--file``: A file to save the configuration to. Defaults to ``replicasets.yml``.

replicasets list
^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets list [--replicaset STRING]


List the current cluster topology.

Options:

*   ``--replicaset STRING``: A replica set name.


replicasets join
^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets join INSTANCE_NAME ... [--replicaset STRING]

Join the instance to a cluster.
If a replica set with the specified alias isn't found in cluster, it is created.
Otherwise, instances are joined to an existing replica set.

Options:

*   ``--replicaset STRING``: A replica set name.

replicasets list-roles
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets list-roles

List the available roles.

replicasets list-vshard-groups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets list-vshard-groups

List the available vshard groups.


replicasets add-roles
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets add-roles ROLE_NAME ... [--replicaset STRING] [--vshard-group STRING]

Add roles to the replica set.

Options:

*   ``--replicaset STRING``: A replica set name.
*   ``--vshard-group STRING``: A vshard group for ``vshard-storage`` replica sets.

replicasets remove-roles
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets remove-roles ROLE_NAME ... [--replicaset STRING]

Remove roles from the replica set.

Options:

*   ``--replicaset STRING``: A replica set name.

replicasets set-weight
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets set-weight WEIGHT [--replicaset STRING]

Specify replica set weight.

Options:

*   ``--replicaset STRING``: A replica set name.

replicasets set-failover-priority
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets set-failover-priority INSTANCE_NAME ... [--replicaset STRING]

Configure replica set failover priority.

Options:

*   ``--replicaset STRING``: A replica set name.

replicasets bootstrap-vshard
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets bootstrap-vshard

Bootstrap vshard.

replicasets expel
^^^^^^^^^^^^^^^^^

.. code-block:: console

    $ tt cartridge replicasets expel INSTANCE_NAME ...

Expel one or more instances from the cluster.

..  container:: table
    ..  list-table::
        :widths: 25 75
        :header-rows: 0

        *   -   ``setup``
            -   Setup replica sets using a file.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets setup [--file FILEPATH] [--bootstrap-vshard]

                Options:

                *   ``--file``: A file with a replica set configuration. Defaults to ``replicasets.yml``.
                *   ``--bootstrap-vshard``: Bootstrap vshard upon setup.

        *   -   ``save``
            -   Save the current replica set configuration to a file.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets save [--file FILEPATH]

                Options:

                *   ``--file``: A file to save the configuration to. Defaults to ``replicasets.yml``.

        *   -   ``list``
            -   List the current cluster topology.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets list [--replicaset STRING]

                Options:

                *   ``--replicaset STRING``: A replica set name.

        *   -   ``join``
            -   Join the instance to a cluster.
                If a replica set with the specified alias isn't found in cluster, it is created.
                Otherwise, instances are joined to an existing replica set.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets join INSTANCE_NAME ... [--replicaset STRING]

                Options:

                *   ``--replicaset STRING``: A replica set name.

        *   -   ``list-roles``
            -   List the available roles.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets list-roles

        *   -   ``list-vshard-groups``
            -   List the available vshard groups.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets list-vshard-groups

        *   -   ``add-roles``
            -   Add roles to the replica set.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets add-roles ROLE_NAME ... [--replicaset STRING] [--vshard-group STRING]

                Options:

                *   ``--replicaset STRING``: A replica set name.
                *   ``--vshard-group STRING``: A vshard group for ``vshard-storage`` replica sets.

        *   -   ``remove-roles``
            -   Remove roles from the replica set.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets remove-roles ROLE_NAME ... [--replicaset STRING]

                Options:

                *   ``--replicaset STRING``: A replica set name.

        *   -   ``set-weight``
            -   Specify replica set weight.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets set-weight WEIGHT [--replicaset STRING]

                Options:

                *   ``--replicaset STRING``: A replica set name.

        *   -   ``set-failover-priority``
            -   Configure replica set failover priority.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets set-failover-priority INSTANCE_NAME ... [--replicaset STRING]

                Options:

                *   ``--replicaset STRING``: A replica set name.

        *   -   ``bootstrap-vshard``
            -   Bootstrap vshard.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets bootstrap-vshard

        *   -   ``expel``
            -   Expel one or more instances from the cluster.

                Usage:

                .. code-block:: console

                    $ tt cartridge replicasets expel INSTANCE_NAME ...

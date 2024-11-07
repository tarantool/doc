.. _tt-cluster:

Managing cluster configurations
===============================

.. code-block:: console

    $ tt cluster COMMAND [COMMAND_OPTION ...]

``tt cluster`` manages :ref:`configurations <configuration>` of Tarantool applications.
This command works both with local YAML files in application directories
and with :ref:`centralized configuration storages <configuration_etcd>` (etcd or Tarantool-based).

``COMMAND`` is one of the following:

*   :ref:`publish <tt-cluster-publish>`
*   :ref:`show <tt-cluster-show>`
*   :ref:`replicaset <tt-cluster-replicaset>`
*   :ref:`failover <tt-cluster-failover>`

.. _tt-cluster-publish:

publish
-------

.. code-block:: console

    $ tt cluster publish {APPLICATION[:APP_INSTANCE] | CONFIG_URI} [FILE] [OPTION ...]

``tt cluster publish`` publishes a cluster configuration using an arbitrary YAML file as a source.

.. _tt-cluster-publish-local:

Publishing local configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster publish`` can modify local cluster configurations stored in
``config.yaml`` files inside application directories.

To write a configuration to a local ``config.yaml``, run ``tt cluster publish``
with two arguments:

*   the application name.
*   the path to a YAML file from which the configuration should be taken.

.. code-block:: console

    $ tt cluster publish myapp source.yaml

.. _tt-cluster-publish-centralized:

Publishing configurations in centralized storages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster publish`` can modify :ref:`centralized cluster configurations <configuration_etcd>`
in storages of both supported types: etcd or a Tarantool-based configuration storage.

To publish a configuration from a file to a centralized configuration storage,
run ``tt cluster publish`` with a URI of this storage's
instance as the target. For example, the command below publishes a configuration from ``source.yaml``
to a local etcd instance running on the default port ``2379``:

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/myapp" source.yaml

A URI must include a prefix that is unique for the application. It can also include
credentials and other connection parameters. Find the detailed description of the
URI format in :ref:`tt-cluster-uri`.

.. _tt-cluster-publish-instance:

Publishing configurations of specific instances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to whole cluster configurations, ``tt cluster publish`` can manage
configurations of specific instances within applications: rewrite configurations
of existing instances and add new instance configurations.

In this case, it operates with YAML fragments that describe a single :ref:`instance configuration section <configuration_overview>`.
For example, the following YAML file can be a source when publishing an instance configuration:

.. code-block:: yaml

    # instance_source.yaml
    iproto:
      listen:
      - uri: 127.0.0.1:3311

To send an instance configuration to a local ``config.yaml``, run ``tt cluster publish``
with the ``application:instance`` pair as the target argument:

.. code-block:: console

    $ tt cluster publish myapp:instance-002 instance_source.yaml

To send an instance configuration to a centralized configuration storage, specify
the instance name in the ``name`` argument of the storage URI:

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/myapp?name=instance-002" instance_source.yaml

If the instance already exists, this call overwrites its configuration with the one
from the file.

To add a new instance configuration from a YAML fragment, specify the name to assign to
the new instance and its location in the cluster topology -- replica set and group --
in the ``--replicaset`` and ``--group`` options.

.. note::

    The ``--group`` option can be omitted if the configuration contains only one group.

To add a new instance ``instance-003`` to the ``replicaset-001`` replica set:

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/myapp?name=instance-003" instance_source.yaml --replicaset replicaset-001


.. _tt-cluster-publish-validation:

Configuration validation
~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster publish`` validates configurations against the Tarantool configuration schema
and aborts in case of an error. To skip the validation, add the ``--force`` option:

.. code-block:: console

    $ tt cluster publish myapp source.yaml --force

.. _tt-cluster-publish-integrity:

Publishing configurations with integrity check
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  admonition:: Enterprise Edition
    :class: fact

    The integrity check functionality is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

When called with the ``--with-integrity-check`` option, ``tt cluster publish``
generates a checksum of the configurations it publishes. It signs the checksum using
the private key passed as the option argument, and writes it into the configuration store.

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/myapp" source.yaml --with-integrity-check private.pem

If an application configuration is published this way, it can be checked for integrity
using the ``--integrity-check`` :ref:`global option <tt-global-options>`.

.. code-block:: console

    $ tt --integrity-check public.pem cluster show myapp
    $ tt --integrity-check public.pem start myapp

Learn more about integrity checks upon application startup and in runtime in the :ref:`tt start <tt-start-integrity-check>` reference.

To ensure the configuration integrity when updating it, call ``tt cluster publish``
with two options:

-   ``--integrity-check PUBLIC_KEY`` global option checks that the configuration wasn't changed
    since it was published
-   ``--with-integrity-check PRIVATE_KEY`` generates new hash and signature
    for future integrity checks of the updated configuration.

.. code-block:: console

    $ tt --integrity-check public.pem cluster publish \
         --with-integrity-check private.pem \
         "http://localhost:2379/myapp" source.yaml

.. _tt-cluster-show:

show
----

.. code-block:: console

    $ tt cluster show {APPLICATION[:APP_INSTANCE] | CONFIG_URI} [OPTION ...]

``tt cluster show`` displays a cluster configuration.

.. _tt-cluster-show-local:

Displaying local configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster show`` can read local cluster configurations stored in ``config.yaml``
files inside application directories.

To print a local configuration from an application's ``config.yaml``, specify the
application name as an argument:

.. code-block:: console

    $ tt cluster show myapp

.. _tt-cluster-show-centralized:

Displaying configurations from centralized storages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster show`` can display :ref:`centralized cluster configurations <configuration_etcd>`
from configuration storages of both supported types: etcd  or a Tarantool-based configuration storage.

To print a cluster configuration from a centralized storage, run ``tt cluster show``
with a storage URI including the prefix identifying the application. For example, to print
``myapp``'s configuration from a local etcd storage:

.. code-block:: console

    $ tt cluster show "http://localhost:2379/myapp"


.. _tt-cluster-show-instance:

Displaying configurations of specific instances
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to whole cluster configurations, ``tt cluster show`` can display
configurations of specific instances within applications. In this case, it prints
YAML fragments that describe a single :ref:`instance configuration section <configuration_overview>`.

To print an instance configuration from a local ``config.yaml``, use the ``application:instance``
argument:

.. code-block:: console

    $ tt cluster show myapp:instance-002

To print an instance configuration from a centralized configuration storage, specify
the instance name in the ``name`` argument of the URI:

.. code-block:: console

    $ tt cluster show "http://localhost:2379/myapp?name=instance-002"

.. _tt-cluster-show-validation:

Configuration validation
~~~~~~~~~~~~~~~~~~~~~~~~

To validate configurations when printing them with ``tt cluster show``, enable the
validation by adding the ``--validate`` option:

.. code-block:: console

    $ tt cluster show "http://localhost:2379/myapp" --validate

.. _tt-cluster-replicaset:

replicaset
----------

.. code-block:: console

    $ tt cluster replicaset SUBCOMMAND {APPLICATION[:APP_INSTANCE] | CONFIG_URI} [OPTION ...]

``tt cluster replicaset`` manages instances in a replica set. It supports the following
subcommands:

-   :ref:`promote <tt-cluster-replicaset-promote>`
-   :ref:`demote <tt-cluster-replicaset-demote>`
-   :ref:`expel <tt-cluster-replicaset-expel>`
-   :ref:`roles <tt-cluster-replicaset-roles>`

.. important::

    ``tt cluster replicaset`` works only with centralized cluster configurations.
    To manage replica sets in clusters with local YAML configurations,
    use :ref:`tt replicaset <tt-replicaset>`.

.. _tt-cluster-replicaset-promote:

promote
~~~~~~~

.. code-block:: console

    $ tt cluster replicaset promote CONFIG_URI INSTANCE_NAME [OPTION ...]

``tt cluster replicaset promote`` promotes the specified instance,
making it a leader of its replica set.
This command works on Tarantool clusters with centralized configuration and
with :ref:`failover modes <configuration_reference_replication_failover>`
``off`` and ``manual``. It updates the centralized configuration according to
the specified arguments and reloads it:

-   ``off`` failover mode: the command sets :ref:`database.mode <configuration_reference_database_mode>`
    to ``rw`` on the specified instance.

    .. important::

        If failover is ``off``, the command doesn't consider the modes of other
        replica set members, so there can be any number of read-write instances in one replica set.

-   ``manual`` failover mode: the command updates the :ref:`leader <configuration_reference_replicasets_name_leader>`
    option of the replica set configuration. Other instances of this replica set become read-only.

Example:

..  code-block:: console

    $ tt cluster replicaset promote "http://localhost:2379/myapp" storage-001-a

.. _tt-cluster-replicaset-demote:

demote
~~~~~~

.. code-block:: console

    $ tt cluster replicaset demote CONFIG_URI INSTANCE_NAME [OPTION ...]

``tt cluster replicaset demote`` demotes an instance in a replica set.
This command works on Tarantool clusters with centralized configuration and
with :ref:`failover mode <configuration_reference_replication_failover>`
``off``.

.. note::

    In clusters with ``manual`` failover mode, you can demote a read-write instance
    by promoting a read-only instance from the same replica set with ``tt cluster replicaset promote``.

The command sets the instance's :ref:`database.mode <configuration_reference_database_mode>`
to ``ro`` and reloads the configuration.

.. important::

    If failover is ``off``, the command doesn't consider the modes of other
    replica set members, so there can be any number of read-write instances in one replica set.

.. _tt-cluster-replicaset-expel:

expel
~~~~~

.. code-block:: console

    $ tt cluster replicaset expel CONFIG_URI INSTANCE_NAME [OPTION ...]

``tt cluster replicaset expel`` expels an instance from the cluster. Example:

.. code-block:: console

    $ tt cluster replicaset expel "http://localhost:2379" storage-b-002

.. _tt-cluster-replicaset-roles:

roles
~~~~~

.. code-block:: console

    $ tt cluster replicaset roles [add|remove] CONFIG_URI ROLE_NAME [OPTION ...]

``tt cluster replicaset roles`` manages :ref:`application roles <application_roles>`
in the configuration scope specified in the command options. It has two subcommands:

*   ``add`` adds a role
*   ``remove`` removes a role

Use the ``--global``, ``--group``, ``--replicaset``, ``--instance`` options to specify
the configuration scope to add or remove roles. For example, to add a role to
all instances in a replica set:

.. code-block:: console

    $ tt cluster replicaset roles add "http://localhost:2379" roles.my-role --replicaset storage-a

To remove a role defined in the global configuration scope:

.. code-block:: console

    $ tt cluster replicaset roles remove "http://localhost:2379" roles.my-role --global


.. _tt-cluster-replicaset-details:

Implementation details
~~~~~~~~~~~~~~~~~~~~~~

The changes that ``tt cluster replicaset`` makes to the configuration storage
occur transactionally. Each call creates a new revision. In case of a revision mismatch,
an error is raised.

If the cluster configuration is distributed over multiple keys in the configuration
storage (for example, in two paths ``/myapp/config/k1`` and ``/myapp/config/k2``),
the affected instance configuration can be present in more that one of them.
If it is found under several different keys, the command prompts the user to choose
a key for patching. You can skip the selection by adding the ``-f``/``--force`` option:

..  code-block:: console

    $ tt cluster replicaset promote "http://localhost:2379/myapp" storage-001-a --force

In this case, the command selects the key for patching automatically. A key's priority
is determined by the detail level of the instance or replica set configuration stored
under this key. For example, when failover is ``off``, a key with
``instance.database`` options takes precedence over a key with the only ``instance`` field.
In case of equal priority, the first key in the lexicographical order is patched.

.. _tt-cluster-failover:

failover
--------

.. code-block:: console

    $ tt cluster failover SUBCOMMAND [OPTION ...]

``tt cluster failover`` manages a :ref:`supervised failover <repl_supervised_failover>` in Tarantool clusters.

-   :ref:`switch <tt-cluster-failover-switch>`
-   :ref:`switch-status <tt-cluster-failover-switch-status>`

.. important::

    ``tt cluster failover`` works only with centralized cluster configurations stored in etcd.


.. _tt-cluster-failover-switch:

switch
~~~~~~

.. code-block:: console

    $ tt cluster failover switch CONFIG_URI INSTANCE_NAME [OPTION ...]

``tt cluster failover switch`` appoints the specified instance to be a master.
This command accepts the following arguments and options:

-   ``CONFIG_URI``: A :ref:`URI <tt-cluster-uri>` of the cluster configuration storage.
-   ``INSTANCE_NAME``: An instance name.
-   ``[OPTION ...]``: :ref:`Options <tt-cluster-options>` to pass to the command.

In the example below, ``tt cluster failover switch`` appoints ``storage-a-002`` to be a master:

.. code-block:: console

    $ tt cluster failover switch http://localhost:2379/myapp storage-a-002
    To check the switching status, run:
    tt cluster failover switch-status http://localhost:2379/myapp b1e938dd-2867-46ab-acc4-3232c2ef7ffe

Note that the command output includes an identifier of the task responsible for switching a master.
You can use this identifier to see the status of switching a master instance using ``tt cluster failover switch-status``.


.. _tt-cluster-failover-switch-status:

switch-status
~~~~~~~~~~~~~

.. code-block:: console

    $ tt cluster failover switch-status CONFIG_URI TASK_ID

``tt cluster failover switch-status`` shows the status of switching a master instance.
This command accepts the following arguments:

-   ``CONFIG_URI``: A :ref:`URI <tt-cluster-uri>` of the cluster configuration storage.
-   ``TASK_ID``: An identifier of the task used to switch a master instance. You can find the task identifier in the ``tt cluster failover switch`` command output.

Example:

.. code-block:: console

    $ tt cluster failover switch-status http://localhost:2379/myapp b1e938dd-2867-46ab-acc4-3232c2ef7ffe

.. _tt-cluster-authentication:

Authentication
--------------

There are three ways to pass the credentials for connecting to the centralized configuration storage.
They all apply to both etcd and Tarantool-based storages. The following list
shows these ways ordered by precedence, from highest to lowest:

#.  Credentials specified in the storage URI: ``https://username:password@host:port/prefix``:

    .. code-block:: console

        $ tt cluster show "http://myuser:p4$$w0rD@localhost:2379/myapp"


#.  ``tt cluster`` options ``-u``/``--username`` and ``-p``/``--password``:

    .. code-block:: console

        $ tt cluster show "http://localhost:2379/myapp" -u myuser -p p4$$w0rD

#.  Environment variables ``TT_CLI_ETCD_USERNAME`` and ``TT_CLI_ETCD_PASSWORD``:

    .. code-block:: console

            $ export TT_CLI_ETCD_USERNAME=myuser
            $ export TT_CLI_ETCD_PASSWORD=p4$$w0rD
            $ tt cluster show "http://localhost:2379/myapp"

If connection encryption is enabled on the configuration storage, pass the required
SSL parameters in the :ref:`URI arguments <tt-cluster-uri>`.

.. _tt-cluster-uri:

URI format
----------

A URI of the cluster configuration storage has the following format:

.. code-block:: text

    http(s)://[username:password@]host:port[/prefix][?arguments]

*   ``username`` and ``password`` define credentials for connecting to the configuration storage.
*   ``prefix`` is a base path identifying a specific application in the storage.
*   ``arguments`` defines connection parameters. The following arguments are available:

    *   ``name`` -- a name of an instance in the cluster configuration.
    *   ``key`` -- a target configuration key in the specified ``prefix``.
    *   ``timeout`` -- a request timeout in seconds. Default: ``3.0``.
    *   ``ssl_key_file`` -- a path to a private SSL key file.
    *   ``ssl_cert_file`` -- a path to an SSL certificate file.
    *   ``ssl_ca_file`` -- a path to a trusted certificate authorities (CA) file.
    *   ``ssl_ca_path`` -- a path to a trusted certificate authorities (CA) directory.
    *   ``ssl_ciphers`` -- a colon-separated (``:``) list of SSL cipher suites the connection can use (for Tarantool-based storage only).
    *   ``verify_host`` -- verify the certificate’s name against the host. Default ``true``.
    *   ``verify_peer`` -- verify the peer’s SSL certificate. Default ``true``.

.. _tt-cluster-options:

Options
-------

..  option:: -u, --username STRING

    A username for connecting to the configuration storage.

    See also: :ref:`tt-cluster-authentication`.

..  option:: -p, --password STRING

    A password for connecting to the configuration storage.

    See also: :ref:`tt-cluster-authentication`.

..  option:: --force

    **Applicable to:** ``publish``, ``replicaset``

    -   ``publish``: skip validation when publishing. Default: `false` (validation is enabled).
    -   ``replicaset``: skip key selection for patching. Learn more in :ref:`tt-cluster-replicaset-details:`.

..  option:: -G, --global

    **Applicable to:** ``replicaset roles``

    Apply the operation to the global configuration scope, that is, to all instances.

..  option:: -g, --group

    **Applicable to:** ``publish``, ``replicaset roles``

    A name of the configuration group to which the operation applies.

..  option:: -i, --instance

    **Applicable to:** ``replicaset roles``

    A name of the instance to which the operation applies.

..  option:: -r, --replicaset

    **Applicable to:** ``publish``, ``replicaset roles``

    A name of the replica set to which the operation applies.

..  option:: -t, --timeout UINT

    **Applicable to:** ``failover``

    A timeout (in seconds) for executing a command. Default: `30`.

..  option:: --validate

    **Applicable to:** ``show``

    Validate the printed configuration. Default: `false` (validation is disabled).

..  option:: -w, --wait

    **Applicable to:** ``failover``

    Wait while the command completes the execution. Default: `false` (don't wait).

..  option:: --with-integrity-check STRING

    ..  admonition:: Enterprise Edition
        :class: fact

        This option is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

    **Applicable to:** ``publish``, ``replicaset``

    Generate hashes and signatures for integrity checks.

    See also: :ref:`tt-cluster-publish-integrity`

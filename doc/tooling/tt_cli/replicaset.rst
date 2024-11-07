.. _tt-replicaset:

Managing replica sets
=====================

..  code-block:: console

    $ tt replicaset COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

``tt replicaset`` (or ``tt rs``) manages a Tarantool replica set.

``COMMAND`` is one of the following:

*   :ref:`status <tt-replicaset-status>`
*   :ref:`promote <tt-replicaset-promote>`
*   :ref:`demote <tt-replicaset-demote>`
*   :ref:`expel <tt-replicaset-expel>`
*   :ref:`vshard <tt-replicaset-vshard>`
*   :ref:`bootstrap <tt-replicaset-bootstrap>`
*   :ref:`rebootstrap <tt-replicaset-rebootstrap>`
*   :ref:`roles <tt-replicaset-roles>`

.. _tt-replicaset-status:

status
------

..  code-block:: console

    $ tt replicaset status {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs status {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

``tt replicaset status`` (``tt rs status``) shows the current status of a replica set.

.. _tt-replicaset-status-application:

Displaying status of all replica sets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To view the status of all replica sets of an application in the current ``tt``
environment, run ``tt replicaset status`` with the application name:

..  code-block:: console

    $ tt replicaset status myapp

.. _tt-replicaset-status-instance:

Displaying status of a single replica set
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To view the status of a single replica set of an application, run ``tt replicaset status``
with a name or a URI of an instance from this replica set:

..  code-block:: console

    $ tt replicaset status myapp:storage-001-a

For a replica outside the current ``tt`` environment, specify its URI and access credentials:

..  code-block:: console

    $ tt replicaset status 192.168.10.10:3301 -u myuser -p p4$$w0rD

Learn about other ways to provide user credentials in :ref:`tt-replicaset-authentication`.

.. _tt-replicaset-promote:

promote
-------

..  code-block:: console

    $ tt replicaset promote {APPLICATION:APP_INSTANCE | URI} [OPTIONS ...]
    # or
    $ tt rs promote {APPLICATION:APP_INSTANCE | URI} [OPTIONS ...]

``tt replicaset promote`` (``tt rs promote``) promotes the specified instance,
making it a leader of its replica set.
This command works on Tarantool clusters with a local YAML
configuration and Cartridge clusters.

.. note::

    To promote an instance in a Tarantool cluster with a :ref:`centralized configuration <configuration_etcd>`,
    use :ref:`tt cluster replicaset promote <tt-cluster-replicaset-promote>`.

.. _tt-replicaset-promote-config:

Promoting in clusters with local YAML configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tt replicaset promote`` works on Tarantool clusters with local YAML configurations
with :ref:`failover modes <configuration_reference_replication_failover>`
``off``, ``manual``, and ``election``.

In failover modes ``off`` or ``manual``, this command updates the cluster
configuration file according to the specified arguments and reloads it:

-   ``off`` failover mode: the command sets :ref:`database.mode <configuration_reference_database_mode>`
    to ``rw`` on the specified instance.

    .. important::

        If failover is ``off``, the command doesn't consider the modes of other
        replica set members, so there can be any number of read-write instances in one replica set.

-   ``manual`` failover mode: the command updates the :ref:`leader <configuration_reference_replicasets_name_leader>`
    option of the replica set configuration. Other instances of this replica set become read-only.

Example:

..  code-block:: console

    $ tt replicaset promote my-app:storage-001-a

If some members of the affected replica set are running outside the current ``tt``
environment, ``tt replicaset promote`` can't ensure the configuration reload on
them and reports an error. You can skip this check by adding the ``-f``/``--force`` option:

..  code-block:: console

    $ tt replicaset promote my-app:storage-001-a --force

In the ``election`` failover mode, ``tt replicaset promote`` initiates the new leader
election by calling :ref:`box_ctl-promote` on the specified instance. The
``--timeout`` option can be used to specify the election completion timeout:

..  code-block:: console

    $ tt replicaset promote my-app:storage-001-a --timeout=10


.. _tt-replicaset-promote-cartridge:

Promoting in Cartridge clusters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: _includes/cartridge_deprecation_note.rst

``tt replicaset promote`` promotes instances in Cartridge clusters as follows:

-   ``disabled`` or ``eventual`` failover mode: the command changes the instance failover priority.

    .. important::

        In these cases, consistency is not guaranteed and replication conflicts may occur.

-   ``eventual`` or ``raft`` failover mode: the command calls ``cartridge.failover_promote()``
    and waits until the instance transitions to the read-write mode. If the ``-f``/``--force``
    option is specified, the ``force_inconsistency`` option of `cartridge.failover_promote <https://www.tarantool.io/en/doc/2.11/book/cartridge/cartridge_api/modules/cartridge/#failover-promote-replicaset-uuid-opts>`_
    is set to ``true``.

..  code-block:: console

    $ tt replicaset promote my-cartridge-app:storage-001-a --force

Learn more about `Cartridge failover modes <https://www.tarantool.io/en/doc/2.11/book/cartridge/cartridge_dev/#leader-appointment-rules>`_.


.. _tt-replicaset-demote:

demote
------

..  code-block:: console

    $ tt replicaset demote APPLICATION:APP_INSTANCE [OPTIONS ...]
    # or
    $ tt rs demote APPLICATION:APP_INSTANCE [OPTIONS ...]

``tt replicaset demote`` (``tt rs demote``) demotes an instance in a Tarantool
cluster with a local YAML configuration.

.. note::

    To demote an instance in a Tarantool cluster with a :ref:`centralized configuration <configuration_etcd>`,
    use :ref:`tt cluster replicaset demote <tt-cluster-replicaset-demote>`.

.. _tt-replicaset-demote-config:

Demoting in clusters with local YAML configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``tt replicaset demote`` can demote instances in Tarantool clusters with local
YAML configurations with :ref:`failover modes <configuration_reference_replication_failover>`
``off`` and ``election``.

.. note::

    In clusters with ``manual`` failover mode, you can demote a read-write instance
    by promoting a read-only instance from the same replica set with ``tt replicaset promote``.

In the ``off`` failover mode, ``tt replicaset demote`` sets the instance's :ref:`database.mode <configuration_reference_database_mode>`
to ``ro`` and reloads the configuration.

.. important::

    If failover is ``off``, the command doesn't consider the modes of other
    replica set members, so there can be any number of read-write instances in one replica set.

If some members of the affected replica set are running outside the current ``tt``
environment, ``tt replicaset demote`` can't ensure the configuration reload on
them and reports an error. You can skip this check by adding the ``-f``/``--force`` option:

..  code-block:: console

    $ tt replicaset demote my-app:storage-001-a --force

In the ``election`` failover mode, ``tt replicaset demote`` initiates a leader
election in the replica set. The specified instance's :ref:`replication.election_mode <configuration_reference_replication_election_mode>`
is changed to ``voter`` for this election, which guarantees that another instance
is elected as a new replica set leader.

The ``--timeout`` option can be used to specify the election completion timeout:

..  code-block:: console

    $ tt replicaset demote my-app:storage-001-a --timeout=10

.. _tt-replicaset-expel:

expel
-----

..  code-block:: console

    $ tt replicaset expel APPLICATION:APP_INSTANCE [OPTIONS ...]
    # or
    $ tt rs expel  APPLICATION[:APP_INSTANCE] [OPTIONS ...]

``tt replicaset expel`` (``tt rs expel``) expels an instance from the cluster.

..  code-block:: console

    $ tt replicaset expel myapp:storage-001-b

The command supports the ``--config``, ``--cartridge``, and ``--custom`` :ref:`options <tt-replicaset-options>`
that force the use of a specific orchestrator.

To expel an instance from a Cartridge cluster:

..  code-block:: console

    $ tt replicaset expel my-cartridge-app:storage-001-b --cartridge


.. _tt-replicaset-vshard:

vshard
------

..  code-block:: console

    $ tt replicaset vshard COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs vshard COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs vs COMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

``tt replicaset vshard`` (``tt rs vs``) manages :ref:`vshard <vshard>` in the cluster.

It has the following subcommands:

-   :ref:`bootstrap <tt-replicaset-vshard-bootstrap>`

.. _tt-replicaset-vshard-bootstrap:

vshard bootstrap
~~~~~~~~~~~~~~~~

..  code-block:: console

    $ tt replicaset vshard bootstrap {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs vshard bootstrap {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs vs bootstrap {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

``tt replicaset vshard bootstrap`` (``tt rs vs bootstrap``) bootstraps ``vshard``
in the cluster.

..  code-block:: console

    $ tt replicaset vshard bootstrap myapp

With a URI and credentials:

..  code-block:: console

    $ tt replicaset vshard bootstrap 192.168.10.10:3301 -u myuser -p p4$$w0rD

You can specify the application name or the name of any cluster instance. The command
automatically finds a ``vshard`` router in the cluster and calls :ref:`vshard.router.bootstrap() <router_api-bootstrap>` on it.

The command supports the ``--config``, ``--cartridge``, and ``--custom`` :ref:`options <tt-replicaset-options>`
that force the use of a specific orchestrator.

To bootstrap ``vshard`` in a Cartridge cluster:

..  code-block:: console

    $ tt replicaset vshard bootstrap my-cartridge-app --cartridge

.. _tt-replicaset-bootstrap:

bootstrap
---------

..  include:: _includes/cartridge_deprecation_note.rst

..  code-block:: console

    $ tt replicaset bootstrap APPLICATION[:APP_INSTANCE] [OPTIONS ...]
    # or
    $ tt rs bootstrap APPLICATION[:APP_INSTANCE] [OPTIONS ...]

``tt replicaset bootstrap`` (``tt rs bootstrap``) bootstraps a Cartridge cluster or
an instance. The command works within the current ``tt`` environment and uses
application and instance names.

.. note::

    ``tt replicasets bootstrap`` effectively duplicates two other commands:

    -   When called with an application name: :ref:`tt cartridge replicasets setup <tt_cartridge_replicasets_setup>`
    -   When called with an instance name: :ref:`tt cartridge replicasets join <tt_cartridge_replicasets_join>`

.. _tt-replicaset-bootstrap-cluster:

Bootstrapping a Cartridge cluster
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To bootstrap the ``cartridge_app`` application using its default replica sets file
``replicasets.yml``:

..  code-block:: console

    $ tt replicaset bootstrap cartridge_app

To use another file with replica set configuration, provide a path to it in the ``--file`` option:

..  code-block:: console

    $ tt replicaset bootstrap cartridge_app --file replicasets1.yml

To additionally bootstrap vshard after the cluster bootstrap, add ``--bootstrap-vshard``:

..  code-block:: console

    $ tt replicaset bootstrap --bootstrap-vshard cartridge_app


.. _tt-replicaset-bootstrap-instance:

Bootstrapping an instance
~~~~~~~~~~~~~~~~~~~~~~~~~

When called with the instance name, ``tt replicaset bootstrap`` joins the
instance to the replica set specified in the ``--replicaset`` option:

..  code-block:: console

    $ tt replicaset bootstrap --replicaset replicaset cartridge_app:instance1

.. _tt-replicaset-rebootstrap:

rebootstrap
-----------

..  code-block:: console

    $ tt replicaset rebootstrap APPLICATION:APP_INSTANCE [-y | --yes]
    # or
    $ tt rs rebootstrap APPLICATION:APP_INSTANCE [-y | --yes]

``tt replicaset rebootstrap`` (``tt rs rebootstrap``) rebootstraps an instance:
stops it, removes instance artifacts, starts it again.

To rebootstrap the ``storage-001`` instance of the ``myapp`` application:

..  code-block:: console

    $ tt replicaset rebootstrap myapp:storage-001

To automatically confirm reboostrap, add the ``-y``/``--yes`` option:

..  code-block:: console

    $ tt replicaset rebootstrap myapp:storage-001 -y

.. _tt-replicaset-roles:

roles
-----

..  code-block:: console

    $ tt replicaset roles [add|remove] APPLICATION[:APP_INSTANCE] ROLE_NAME [OPTIONS ...]
    # or
    $ tt rs roles [add|remove] APPLICATION[:APP_INSTANCE] ROLE_NAME [OPTIONS ...]

``tt replicaset roles`` (``tt rs roles``) manages :ref:`application roles <application_roles>`
in the cluster.
This command works on Tarantool clusters with a local YAML
configuration and Cartridge clusters. It has two subcommands:

*   ``add`` adds a role
*   ``remove`` removes a role

.. note::

    To manage roles in a Tarantool cluster with a :ref:`centralized configuration <configuration_etcd>`,
    use :ref:`tt cluster replicaset roles <tt-cluster-replicaset-roles>`.


.. _tt-replicaset-roles-config:

Managing roles in clusters with local YAML configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When called on clusters with local YAML configurations, ``tt replicaset roles``
subcommands add or remove the corresponding lines from the configuration file
and reload the configuration.

Use the ``--global``, ``--group``, ``--replicaset``, ``--instance`` options to specify
the configuration scope to add or remove roles. For example, to add a role to
all instances in a replica set:

.. code-block:: console

    $ tt replicaset roles add my-app roles.my-role --replicaset storage-a

You can also manage roles of a specific instance by specifying its name after the application name:

.. code-block:: console

    $ tt replicaset roles add my-app:router-001 roles.my-role

To remove a role defined in the global configuration scope:

.. code-block:: console

    $ tt replicaset roles remove my-app roles.my-role --global

If some instances of the affected scope are running outside the current ``tt``
environment, ``tt replicaset roles`` can't ensure the configuration reload on
them and reports an error. You can skip this check by adding the ``-f``/``--force`` option:

..  code-block:: console

    $ tt replicaset roles add my-app roles.my-role --replicaset storage-a --force


.. _tt-replicaset-roles-cartridge:

Managing roles in Cartridge clusters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: _includes/cartridge_deprecation_note.rst

When called on Cartridge clusters, ``tt replicaset roles`` subcommands add or remove
Cartridge `cluster roles <https://www.tarantool.io/en/doc/2.11/book/cartridge/cartridge_dev/#cluster-roles>`__.

Cartridge cluster roles are defined per replica set. Thus, you can use the
``--replicaset`` and ``--group`` options to define a role's scope. In this case,
a group is a `vshard group <https://www.tarantool.io/en/doc/2.11/book/cartridge/cartridge_dev/#using-multiple-vshard-storage-groups>`__.

To add a role to a Cartridge cluster replica set:

..  code-block:: console

    $ tt replicaset roles add my-cartridge-app my-role --replicaset storage-001

To remove a role from a vshard group:

..  code-block:: console

    $ tt replicaset roles remove my-cartridge-app my-role --group cold-data

Learn more about `Cartridge cluster roles <https://www.tarantool.io/en/doc/2.11/book/cartridge/cartridge_dev/#cluster-roles>`_.


.. _tt-replicaset-orchestrator:

Selecting the application orchestrator manually
-----------------------------------------------

You can specify the orchestrator to use for the application  when calling ``tt replicaset``
commands. The following options are available:

*   ``--config`` for applications that use YAML cluster configuration (Tarantool 3.x or later).
*   ``--cartridge`` for Cartridge applications (Tarantool 2.x).
*   ``--custom`` for any other orchestrators used on Tarantool 2.x clusters.

..  code-block:: console

    $ tt replicaset status myapp --config
    $ tt replicaset promote my-cartridge-app:storage-001-a --cartridge

If an actual orchestrator that the application uses does not match the specified
option, an error is raised.

.. _tt-replicaset-authentication:

Authentication
--------------

Use one of the following ways to pass the credentials of a Tarantool user when
connecting to the instance by its URI:

*   The ``-u`` (``--username``) and ``-p`` (``--password``) options:

    ..  code-block:: console

        $ tt replicaset status 192.168.10.10:3301 -u myuser -p p4$$w0rD

*   The connection string:

    ..  code-block:: console

        $ tt replicaset status myuser:p4$$w0rD@192.168.10.10:3301

*   Environment variables ``TT_CLI_USERNAME`` and ``TT_CLI_PASSWORD``:

    ..  code-block:: console

        $ export TT_CLI_USERNAME=myuser
        $ export TT_CLI_PASSWORD=p4$$w0rD
        $ tt replicaset status 192.168.10.10:3301

.. _tt-replicaset-options:

Options
-------

..  option:: --bootstrap-vshard

    **Applicable to:** ``bootstrap``

    Additionally bootstrap vshard when bootstrapping a Cartridge application.

..  option:: --cartridge

    Force the Cartridge orchestrator for Tarantool 2.x clusters.

..  option:: --config

    Force the YAML configuration orchestrator for Tarantool 3.0 or later clusters.

..  option:: --custom

    Force a custom orchestrator for Tarantool 2.x clusters.

..  option:: --file STRING

    **Applicable to:** ``bootstrap``

    A file with Cartridge replica sets configuration. Default: ``instances.yml``
    in the application directory.

    See also: :ref:`tt-replicaset-bootstrap-cluster`

..  option:: -f, --force

    **Applicable to:** ``promote``, ``demote``, ``roles``

    Skip operation on instances not running in the same environment.

..  option:: -G, --global

    **Applicable to:** ``roles`` on Tarantool 3.x and later

    Apply the operation to the global configuration scope, that is, to all instances.

..  option:: -g, --group STRING

    **Applicable to:** ``roles``

    A name of the configuration group to which the operation applies.


..  option:: -i, --instance STRING

    **Applicable to:** ``roles``

    A name of the instance to which the operation applies. Not applicable to Cartridge clusters.
    Learn more in :ref:`tt-replicaset-roles-cartridge`.

..  option:: -r, --replicaset STRING

    **Applicable to:** ``bootstrap``, ``roles``

    A name of the replica set to which the operation applies.

    See also: :ref:`tt-replicaset-bootstrap-instance`

..  option:: -u, --username STRING

    A Tarantool user for connecting to the instance using a URI.

..  option:: -p, --password STRING

    The user's password.

..  option:: --sslcertfile STRING

    The path to an SSL certificate file for encrypted connections for the URI case.

..  option:: --sslkeyfile STRING

    The path to a private SSL key file for encrypted connections for the URI case.

..  option:: --sslcafile STRING

    The path to a trusted certificate authorities (CA) file for encrypted connections for the URI case.

..  option:: --sslciphers STRING

    The list of SSL cipher suites used for encrypted connections for the URI case, separated by colons (``:``).

..  option:: --timeout UINT

    **Applicable to:** ``promote``, ``demote``, ``expel``, ``vshard``, ``bootstrap``

    The timeout for completing the operation, in seconds. Default:

    -   ``3`` for ``promote``, ``demote``, ``expel``, ``roles``
    -   ``10`` for ``vshard`` and ``bootstrap``

..  option:: --with-integrity-check STRING

    ..  admonition:: Enterprise Edition
        :class: fact

        This option is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

    **Applicable to:** ``promote``, ``demote``, ``expel``, ``roles``

    Generate hashes and signatures for integrity checks.

..  option:: -y, --yes

    **Applicable to:** ``rebootstrap``

    Automatically confirm rebootstrap.
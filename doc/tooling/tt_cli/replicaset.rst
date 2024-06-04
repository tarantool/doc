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


.. _tt-replicaset-status:

status
------

..  code-block:: console

    $ tt replicaset status {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]
    # or
    $ tt rs status  {APPLICATION[:APP_INSTANCE] | URI} [OPTIONS ...]

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

..  option:: --cartridge

    Force the Cartridge orchestrator for Tarantool 2.x clusters.

..  option:: --config

    Force the YAML configuration orchestrator for Tarantool 3.0 or later clusters.

..  option:: --custom

    Force a custom orchestrator for Tarantool 2.x clusters.

..  option:: -f, --force

    **Applicable to:** ``promote``, ``demote``

    Skip promotion or demotion if the specified instance is not running in the same environment.

..  option:: -u USERNAME, --username USERNAME

    A Tarantool user for connecting to the instance.

..  option:: -p PASSWORD, --password PASSWORD

    The user's password.

..  option:: --sslcertfile FILEPATH

    The path to an SSL certificate file for encrypted connections.

..  option:: --sslkeyfile FILEPATH

    The path to a private SSL key file for encrypted connections.

..  option:: --sslcafile FILEPATH

    The path to a trusted certificate authorities (CA) file for encrypted connections.

..  option:: --sslciphers STRING

    The list of SSL cipher suites used for encrypted connections, separated by colons (``:``).

..  option:: --timeout

    **Applicable to:** ``promote``, ``demote``

    The timeout for completing the promotion or demotion, in seconds. Default: ``3``.
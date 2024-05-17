.. _tt-cluster:

Managing cluster configurations
===============================

.. code-block:: console

    $ tt cluster COMMAND {APPLICATION[:APP_INSTANCE] | URI} [FILE] [OPTION ...]

``tt cluster`` manages :ref:`YAML configurations <configuration>` of Tarantool applications.
This command works both with local configuration files in application directories
and with centralized configuration storages (:ref:`etcd <configuration_etcd>` or Tarantool-based).

``COMMAND`` is one of the following:

*   ``publish``
*   ``show``: print a cluster configuration.
*   ``replicaset``


.. _tt-cluster-publish:

publish
-------

.. code-block:: console

    $ tt cluster publish {APPLICATION[:APP_INSTANCE] | URI} [FILE] [OPTION ...]

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

Managing configurations in centralized storages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
configurations of specific instances within applications. In this case, it operates
with YAML fragments that describe a single :ref:`instance configuration section <configuration_overview>`.
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


.. _tt-cluster-publish-validation:

Configuration validation
~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster`` can validate configurations against the Tarantool configuration schema.

``tt cluster publish`` validates configurations against the Tarantool configuration schema
and aborts in case of an error. To skip the validation, add the ``--force`` option:

.. code-block:: console

    $ tt cluster publish myapp source.yaml --force

.. _tt-cluster-show:

show
----

.. code-block:: console

    $ tt cluster show {APPLICATION[:APP_INSTANCE] | URI} [OPTION ...]

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

    $ tt cluster replicaset SUBCOMMAND {APPLICATION[:APP_INSTANCE] | URI} [OPTION ...]

``tt cluster replicaset`` manages instances in a replica set. It supports the following
subcommands:

-   ``promote``
-   ``demote``

.. important::

    ``tt cluster replicaset`` works only with centralized cluster configurations.
    To manage replica set leaders in clusters with local YAML configurations,
    use :ref:`tt replicaset promote <tt-replicaset-demote>` and :ref:`tt replicaset demote <tt-replicaset-demote>`.

.. _tt-cluster-replicaset-promote:

promote
~~~~~~~

``tt cluster replicaset promote`` promotes an instances in a replica set.

.. _tt-cluster-replicaset-demote:

demote
~~~~~~

``tt cluster replicaset demote`` demotes an instances in a replica set.




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
SSL parameters in the :ref:`URI arguments <tt-cluster-centralized-uri>`.

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

    See also: :ref:`tt-cluster-centralized-authentication`.

..  option:: -p, --password STRING

    A password for connecting to the configuration storage.

    See also: :ref:`tt-cluster-centralized-authentication`.

..  option:: --force

    **Applicable to:** ``publish``

    Skip validation when publishing. Default: `false` (validation is enabled).

..  option:: --validate

    **Applicable to:** ``show``

    Validate the printed configuration. Default: `false` (validation is disabled).

..  option:: --with-integrity-check STRING

    ..  admonition:: Enterprise Edition
        :class: fact

        This option is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

    **Applicable to:** ``publish``

    Generate hashes and signatures for integrity checks.
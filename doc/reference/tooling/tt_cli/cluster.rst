.. _tt-cluster2:

Managing cluster configurations
===============================

.. code-block:: console

    $ tt cluster COMMAND {APPLICATION[:APP_INSTANCE] | URI} [FILE] [OPTION ...]

``tt cluster`` manages :ref:`YAML configurations <configuration>` of Tarantool applications.
This command works both with local configuration files in application directories
and with centralized configuration storages (etcd or Tarantool-based).

``COMMAND`` is one of the following:

*   :ref:`tt-cluster-publish`: publish a cluster configuration from a file.
*   :ref:`tt-cluster-show`: print a cluster configuration.

.. _tt-cluster-local:

Managing local configurations
-----------------------------

``tt cluster`` can read and modify local cluster configurations stored in the
``config.yaml`` files inside application directories.

To write a configuration to a local ``config.yaml``, run ``tt cluster publish``
with two arguments: the application name and the path to a YAML file from which
the configuration should be taken:

.. code-block:: console

    $ tt cluster publish myapp source.yaml

To print a local configuration from ``config.yaml`` in an application directory,
run ``tt cluster show`` with the application name:

.. code-block:: console

    $ tt cluster show myapp

.. _tt-cluster-centralized:

Managing configurations in centralized storages
-----------------------------------------------

``tt cluster`` can manage centralized cluster configurations in storages of both
supported types: :ref:`etcd <configuration-etcd>` or a Tarantool-based storage.

To send a cluster configuration from a file to a centralized configuration storage,
run ``tt cluster publish`` with a URI of the storage instance as the target.
For example, to send a configuration from ``source.yaml``to a local etcd instance
on the default port ``2379``:

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/myapp" source.yaml

A URI must include a prefix that is unique for the application. It can also include
credentials and other connection parameters. Find the detailed description of the
URI format in :ref:`tt-cluster-centralized-uri`.

To print a cluster configuration from a centralized storage, run ``tt cluster show``
with a storage URI including the prefix identifying the application. For example, to print
``myapp``'s configuration from a local etcd storage:

.. code-block:: console

    $ tt cluster show "http://localhost:2379/myapp"

.. _tt-cluster-centralized-authentication:

Authentication
~~~~~~~~~~~~~~

There are three ways to pass the credentials for connecting to the centralized configuration storage:

*   Environment variables ``TT_CLI_ETCD_USERNAME`` and ``TT_CLI_ETCD_PASSWORD``:

    .. code-block:: console

            $ export TT_CLI_ETCD_USERNAME=myuser
            $ export TT_CLI_ETCD_PASSWORD=p4$$w0rD
            $ tt cluster show "http://localhost:2379/myapp"

*   ``tt cluster`` options ``-u``/``--username`` and ``-p``/``--password``:

    .. code-block:: console

        $ tt cluster show "http://localhost:2379/myapp" -u myuser -p p4$$w0rD

*   Credentials specified in the storage URI: ``https://username:password@host:port/prefix``:

    .. code-block:: console

        $ tt cluster show "http://myuser:p4$$w0rD@localhost:2379/myapp"

They are applied with the following precedence, from highest to lowest:

*   URI credentials.
*   ``tt cluster`` options.
*   Environment variables.

.. _tt-cluster-centralized-uri:

URI format
~~~~~~~~~~

A URI of the cluster configuration storage has the following format:

.. code-block:: text

    http(s)://[username:password@]host:port[/prefix][?arguments]

*   ``username`` and ``password`` define credentials for connecting to the configuration storage.
*   ``prefix`` is a base path identifying a specific application in the storage.
*   ``arguments`` defines connection parameters. The following arguments are available:

    *   ``name`` -- a name of an instance in the cluster configuration.
    *   ``timeout`` -- a request timeout in seconds. Default: ``3.0``.
    *   ``ssl_key_file`` -- a path to a private SSL key file.
    *   ``ssl_cert_file`` -- a path to an SSL certificate file.
    *   ``ssl_ca_file`` -- a path to a trusted certificate authorities (CA) file.
    *   ``ssl_ca_path`` -- a path to a trusted certificate authorities (CA) directory.
    *   ``verify_host`` -- verify the certificate’s name against the host. Default ``true``.
    *   ``verify_peer`` -- verify the peer’s SSL certificate. Default ``true``.

.. _tt-cluster-instance:

Managing configurations of specific instances
---------------------------------------------

In addition to whole cluster configurations, ``tt cluster`` can manage
configurations of specific instances within applications. In this case, it operates
with YAML fragments that describe a single :ref:`instance configuration section <configuration_overview>`.
For example, the following YAML file can be a source when publishing an instance configuration:

.. code-block:: yaml

    # instance.yaml
    iproto:
      listen:
      - uri: 127.0.0.1:3389
      threads: 10

To send an instance configuration to a local ``config.yaml``, run ``tt cluster publish``
with the ``application:instance`` pair as the target argument:

.. code-block:: console

    $ tt cluster publish myapp:instance-001 instance.yaml

To send an instance configuration to a centralized configuration storage, specify
the instance name in the ``name`` argument of the storage URI:

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/myapp?name=instance-002" instance.yaml

``tt cluster show`` can print configurations of specific cluster instances as well.
To print an instance configuration from a local ``config.yaml``, use the ``application:instance``
argument:

.. code-block:: console

    $ tt cluster show myapp:instance-002

To print an instance configuration from a centralized configuration storage, specify
the instance name in the ``name`` argument of the URI:

.. code-block:: console

    $ tt cluster show "http://localhost:2379/myapp?name=instance-002"

.. _tt-cluster-publish-validation:

Configuration validation
~~~~~~~~~~~~~~~~~~~~~~~~

``tt cluster publish`` validates the provided configuration against the Tarantool
configuration schema and aborts in case of an error. To skip the validation,
add the ``--force`` option:

.. code-block:: console

    $ tt cluster publish myapp source.yaml --force

To validate a cluster configuration against the Tarantool configuration schema
when printing it with ``tt cluster show``, add the ``--validate`` option:

.. code-block:: console

    $ tt cluster show "http://localhost:2379/myapp" --validate

.. _tt-cluster-publish:

publish
-------

.. code-block:: console

    $ tt cluster publish {APPLICATION[:APP_INSTANCE] | URI} FILE [OPTION ...]

``tt cluster publish`` publishes a cluster configuration from a file to the
specified destination: a `config.yaml` file in application directory or a centralized
configuration storage.

.. _tt-cluster-publish-options:

Options
~~~~~~~

..  option:: -u, --username STRING

    A username for connecting to the configuration storage.

..  option:: -p, --password STRING

    A password for connecting to the configuration storage.

.. note::

    The etcd user's credentials can also be passed in the URI or in environment
    variables. See :ref:`tt-cluster-centralized-authentication` for details.

..  option:: --force

    Skip configuration validation.

..  option:: --with-integrity-check STRING

    Generate hashes and signatures for integrity checks.

.. _tt-cluster-show:

show
----

..  code-block:: console

    $ tt cluster show {APPLICATION[:APP_INSTANCE] | URI} [OPTION ...]

``tt cluster show`` prints the requested cluster configuration from an application
directory or an centralized configuration storage.

.. _tt-cluster-show_options:

Options
~~~~~~~

..  option:: -u, --username STRING

    A username for connecting to the configuration storage.

..  option:: -p, --password STRING

    A username for connecting to the configuration storage.

.. note::

    The etcd user's credentials can also be passed in the URI or in environment
    variables. See :ref:`tt-cluster-centralized-authentication` for details.

..  option:: --validate

    Validate the configuration.

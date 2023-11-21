..  _configuration_etcd:

Storing configuration in etcd
=============================

.. ee_note_etcd_start

..  admonition:: Enterprise Edition
    :class: fact

    Storing configuration in etcd is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

.. ee_note_etcd_end

Tarantool enables you to store configuration data in one place using `etcd <https://etcd.io/>`_.
To achieve this, you need to define how to access etcd and publish a cluster's :ref:`YAML configuration <configuration_file>` to an etcd server.


.. _etcd_local_configuration:

Local etcd configuration
------------------------

To store a cluster's configuration in etcd, you need to provide etcd connection settings in a local configuration file.
These settings are used to :ref:`publish <etcd_publishing_configuration>` a cluster's configuration and :ref:`show <etcd_showing_configuration>` it.

Connection options for etcd should be specified in the ``config.etcd`` section of the configuration file.
At least, the following options should be specified:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/etcd/config.yaml
    :language: yaml
    :dedent:

-   :ref:`config.etcd.endpoints <config_etcd_endpoints>` specifies the list of etcd endpoints.
-   :ref:`config.etcd.prefix <config_etcd_prefix>` sets a key prefix used to search a configuration. Tarantool searches keys by the following path: ``<prefix>/config/*``. Note that ``<prefix>`` should start with a slash (``/``).

You can also provide additional etcd connection options.
In the example below, the following options are configured in addition to an endpoint and key prefix:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/etcd_full/config.yaml
    :language: yaml
    :dedent:

-   :ref:`config.etcd.username <config_etcd_username>` and :ref:`config.etcd.password <config_etcd_password>` specify credentials used for authentication.
-   :ref:`config.etcd.ssl.ca_file <config_etcd_ssl_ca_file>` specifies a path to a trusted certificate authorities (CA) file.
-   :ref:`config.etcd.http.request.timeout <config_etcd_http_request_timeout>` configures a request timeout for an etcd server.

You can find all the available configuration options in the :ref:`etcd <configuration_reference_config_etcd>` section.



.. _etcd_publishing_configuration:

Publishing a cluster's configuration to etcd
--------------------------------------------

.. _etcd_publishing_configuration_tt:

Publishing configuration using the tt utility
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The tt utility provides the :ref:`tt cluster <tt-cluster>` command for managing a cluster's configuration.
The ``tt cluster publish`` command can be used to publish a cluster's configuration to etcd.

The example below shows how a :ref:`layout <admin-start_stop_instance-multi-instance-layout>` of the application called ``app`` might look:

.. code-block:: none

    ├── tt.yaml
    └── instances.enabled
        └── app
            ├── config.yaml
            ├── cluster.yaml
            └── instances.yml

*   ``config.yaml`` contains a :ref:`local configuration <etcd_local_configuration>` used to connect to etcd.
*   ``cluster.yaml`` contains a cluster's configuration to be published.
*   ``instances.yml`` specifies :ref:`instances <admin-start_stop_instance-multi-instance>` to run in the current environment. ``tt cluster publish`` ignores the configured instances.

To publish a cluster's configuration (``cluster.yaml``) to an etcd server, execute ``tt cluster publish`` as follows:

.. code-block:: console

    $ tt cluster publish "http://localhost:2379/example" instances.enabled/app/cluster.yaml

.. NOTE::

    You can see a cluster's configuration using the :ref:`tt cluster show <tt-cluster>` command.


.. _etcd_publishing_configuration_etcdctl:

Publishing configuration using etcdctl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To publish a cluster's configuration using the ``etcdctl`` utility, use the ``put`` command:

.. code-block:: console

    $ etcdctl put /example/config/all < cluster.yaml

.. NOTE::

    For etcd versions earlier than 3.4, you need to set the ``ETCDCTL_API`` environment variable to ``3``.




.. _etcd_starting_instances:

Starting Tarantool instances
----------------------------

The :ref:`tt <tt-cli>` utility is the recommended way to start Tarantool instances.
You can learn how to do this from the :ref:`Starting instances using the tt utility <configuration_run_instance_tt>` section.

You can also use the ``tarantool`` command to :ref:`start a Tarantool instance <configuration_run_instance_tarantool>`.
In this case, you can eliminate creating a :ref:`local etcd configuration  <etcd_local_configuration>` and provide etcd connection settings using the ``TT_CONFIG_ETCD_ENDPOINTS`` and ``TT_CONFIG_ETCD_PREFIX`` :ref:`environment variables <configuration_environment_variable>`.

.. code-block:: console

    $ export TT_CONFIG_ETCD_ENDPOINTS=http://localhost:2379
    $ export TT_CONFIG_ETCD_PREFIX=/example

    $ tarantool --name instance001
    $ tarantool --name instance002
    $ tarantool --name instance003




.. _etcd_reloading_configuration:

Reloading configuration
-----------------------

By default, Tarantool watches etcd keys with the :ref:`specified prefix <etcd_local_configuration>` for changes in a cluster's configuration and reloads a changed configuration automatically.
If necessary, you can set the :ref:`config.reload <configuration_reference_config_reload>` option to ``manual`` to turn off configuration reloading:

.. code-block:: yaml

    config:
      reload: 'manual'
      etcd:
        # ...

In this case, you can reload a configuration in an :ref:`admin console <admin-security>` or :ref:`application code <configuration_application>` using the ``reload()`` function provided by the :ref:`config <config-module>` module:

.. code-block:: lua

    require('config'):reload()









..
    Generating certificates for testing:
    1) openssl genrsa -out ca.key 2048
    2) openssl req -new -x509 -days 365 -key ca.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Root CA" -out ca.cr
    3) openssl req -newkey rsa:2048 -nodes -keyout server.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=localhost" -out server.csr
    4) openssl x509 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1") -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
    5) sudo cp server.crt /etc/ssl/certs
    6) sudo cp server.key /etc/ssl/private

    Starting etcd:
    etcd --cert-file=ssl/server.crt --key-file=ssl/server.key --advertise-client-urls=https://localhost:2379 --listen-client-urls=https://localhost:2379

    Get keys:
    etcdctl get /tt/config/all --cert=ssl/server.crt --key=ssl/server.key

    Test using curl:
    curl --cacert ssl/ca.crt https://localhost:2379/v2/keys/foo -XPUT -d value=bar -v
..  _configuration_etcd:

Centralized configuration storages
==================================

.. ee_note_centralized_config_start

..  admonition:: Enterprise Edition
    :class: fact

    Centralized configuration storages are supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

.. ee_note_centralized_config_end

**Examples on GitHub**: `centralized_config <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/>`_

Tarantool enables you to store a cluster's configuration in one reliable place using a Tarantool or etcd-based storage:

-   A Tarantool-based configuration storage is a replica set that stores a cluster's configuration in :ref:`synchronous <repl_sync>` spaces.
-   `etcd <https://etcd.io/>`__ is a distributed key-value storage for any type of critical data used by distributed systems.

With a :ref:`local YAML configuration <configuration_file>`, you need to make sure that all cluster instances use identical configuration files:

|

.. image:: tarantool_config_local.png
    :align: left
    :width: 500
    :alt: Local configuration file

|

Using a centralized configuration storage, all instances get the actual configuration from one place:

|

.. image:: tarantool_config_centralized.png
    :align: left
    :width: 500
    :alt: Centralized configuration storage

|

This topic describes how to set up a configuration storage, publish a cluster configuration to this storage, and use this configuration for all cluster instances.



.. _centralized_configuration_storage_set_up:

Setting up a configuration storage
----------------------------------

.. _centralized_configuration_storage_set_up_tarantool:

Tarantool-based storage
~~~~~~~~~~~~~~~~~~~~~~~

To make a replica set act as a configuration storage, use the built-in ``config.storage`` :ref:`role <configuration_reference_roles_options>`.


.. _centralized_configuration_storage_tarantool_configure:

Configuring a storage
*********************

To :ref:`configure <configuration_file>` a Tarantool-based storage, follow the steps below:

1.  Define a replica set topology and specify the following options at the replica set level:

    *   Enable the ``config.storage`` role in :ref:`roles <configuration_reference_roles>`.
    *   Optionally, provide the role configuration in :ref:`roles_cfg <configuration_reference_roles_cfg>`. In the example below, the ``status_check_interval`` option sets the interval (in seconds) of status checks.

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/config.yaml
        :language: yaml
        :start-at: groups:
        :end-at: 127.0.0.1:4403
        :dedent:

2.  :ref:`Create a user <configuration_credentials_managing_users_roles>` and grant them the following privileges:

    *   The ``read`` and ``write`` permissions to the ``config_storage`` and ``config_storage_meta`` spaces used to store configuration data.
    *   The ``execute`` permission to ``universe`` to allow interacting with the storage using the tt utility.

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/config.yaml
        :language: yaml
        :start-at: credentials:
        :end-before: replicator:
        :dedent:

3.  Set the :ref:`replication.failover <configuration_reference_replication_failover>` option to ``election`` to enable automated failover:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/config.yaml
        :language: yaml
        :start-at: replication:
        :end-at: failover: election
        :dedent:

4.  Enable the :ref:`MVCC transaction mode <txn_mode_transaction-manager>` to provide linearizability of read operations:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/config.yaml
        :language: yaml
        :start-at: database:
        :end-at: use_mvcc_engine
        :dedent:

The resulting storage configuration might look as follows:

..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/config.yaml
    :language: yaml
    :end-before: Interact with config storage
    :dedent:

You can find the full example here: `tarantool_config_storage <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage>`_.


.. _centralized_configuration_storage_tarantool_start:

Starting a storage
******************

To start instances of the configured storage, use the ``tt start`` command, for example:

.. code-block:: console

    $ tt start tarantool_config_storage

Learn more from the :ref:`Starting and stopping instances <admin-start_stop_instance>` section.




.. _centralized_configuration_storage_set_up_etcd:

etcd-based storage
~~~~~~~~~~~~~~~~~~

To learn how to set up an etcd-based configuration storage, consult the `etcd documentation <https://etcd.io/docs/latest/>`__.

The example script below demonstrates how to use the ``etcdctl`` utility to create a user that has read and write access to configurations stored by the ``/myapp/`` prefix:

..  literalinclude:: /code_snippets/snippets/centralized_config/etcd_config_storage.sh
    :language: console
    :start-at: user add root:topsecret
    :end-at: auth enable
    :dedent:

The credentials of this user should be specified when :ref:`configuring a connection <etcd_local_configuration>` to the etcd cluster.




.. _centralized_configuration_storage_publish_config:

Publishing a cluster's configuration
------------------------------------

.. _centralized_configuration_storage_publish_config_tt:

Publishing configuration using the tt utility
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The tt utility provides the :ref:`tt cluster <tt-cluster>` command for managing centralized cluster configurations.
The ``tt cluster publish`` command can be used to publish a cluster's configuration to both Tarantool and etcd-based storages.

The example below shows how a tt environment and a :ref:`layout <admin-start_stop_instance-multi-instance-layout>` of the application called ``myapp`` might look:

.. code-block:: none

    ├── tt.yaml
    ├── source.yaml
    └── instances.enabled
        └── myapp
            ├── config.yaml
            └── instances.yml

*   ``tt.yaml``: a tt configuration file.
*   ``source.yaml`` contains a cluster's configuration to be published.
*   ``config.yaml`` contains a :ref:`local configuration <centralized_configuration_storage_connect>` used to connect to the centralized storage.
*   ``instances.yml`` specifies :ref:`instances <admin-start_stop_instance-multi-instance>` to run in the current environment.
    The configured instances are used by tt when :ref:`starting a cluster <etcd_starting_instances>`.
    ``tt cluster publish`` ignores this configuration file.

To publish a cluster's configuration (``source.yaml``) to a centralized storage, execute ``tt cluster publish`` as follows:

.. code-block:: console

    $ tt cluster publish "http://sampleuser:123456@localhost:2379/myapp" source.yaml

Executing this command publishes a cluster configuration by the ``/myapp/config/all`` path.

.. NOTE::

    You can see a cluster's configuration using the ``tt cluster show`` command.



.. _centralized_configuration_storage_publish_config_tarantool:

Publishing configuration using the 'config' module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`config module <config-module>` provides the API for interacting with a Tarantool-based configuration storage.
The example below shows how to read a configuration stored in the ``source.yaml`` file using the :ref:`fio module <fio-module>` API and put this configuration by the ``/myapp/config/all`` path:

..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
    :language: lua
    :start-after: function put_config
    :end-at: cluster_config_handle:close()
    :dedent:

Learn more from the :ref:`config_storage_api_reference` section.

..  NOTE::

    The ``net.box module`` provides the ability to monitor configuration updates by watching path or prefix changes. Learn more in :ref:`conn:watch() <conn-watch>`.


.. _centralized_configuration_storage_publish_config_etcdctl:

Publishing configuration using etcdctl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To publish a cluster's configuration to etcd using the ``etcdctl`` utility, use the ``put`` command:

.. code-block:: console

    $ etcdctl put /myapp/config/all < source.yaml

.. NOTE::

    For etcd versions earlier than 3.4, you need to set the ``ETCDCTL_API`` environment variable to ``3``.





.. _centralized_configuration_storage_connect:

Configuring connection to a storage
-----------------------------------

To use a configuration from a centralized storage for your cluster, you need to provide connection settings in a local configuration file.


.. _centralized_configuration_storage_connect_tarantool:

Configuring connection to a Tarantool storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Connection options for a Tarantool-based storage should be specified in the :ref:`config.storage <configuration_reference_config_storage>` section of the configuration file.
In the example below, the following options are specified:

..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/config_storage/config.yaml
    :language: yaml
    :end-before: Watch key changes
    :dedent:

-   ``endpoints`` specifies the list of configuration storage endpoints.
-   ``prefix`` sets a key prefix used to search a configuration. Tarantool searches keys by the following path: ``<prefix>/config/*``. Note that ``<prefix>`` should start with a slash (``/``).
-   ``timeout`` specifies the interval (in seconds) to perform the status check of a configuration storage.
-   ``reconnect_after`` specifies how much time to wait (in seconds) before reconnecting to a configuration storage.

You can find the full example here: `config_storage <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/config_storage>`_.



.. _etcd_local_configuration:

Configuring connection to an etcd storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Connection options for etcd should be specified in the :ref:`config.etcd <configuration_reference_config_etcd>` section of the configuration file.
In the example below, the following options are specified:

..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/config_etcd/config.yaml
    :language: yaml
    :dedent:

-   ``endpoints`` specifies the list of etcd endpoints.
-   ``prefix`` sets a key prefix used to search a configuration. Tarantool searches keys by the following path: ``<prefix>/config/*``. Note that ``<prefix>`` should start with a slash (``/``).
-   ``username`` and ``password`` specify credentials used for authentication.
-   ``http.request.timeout`` configures a request timeout for an etcd server.

You can find the full example here: `config_etcd <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/config_etcd>`_.




.. _etcd_starting_instances:

Starting a cluster
------------------

The :ref:`tt <tt-cli>` utility is the recommended way to start Tarantool instances.
You can learn how to do this from the :ref:`Starting and stopping instances <admin-start_stop_instance>` section.

You can also use the ``tarantool`` command to :ref:`start a Tarantool instance <configuration_run_instance_tarantool>`.
In this case, you can eliminate creating a :ref:`local configuration  <centralized_configuration_storage_connect>` and provide connection settings using the following :ref:`environment variables <configuration_environment_variable>`:

*   Tarantool-based storage: ``TT_CONFIG_STORAGE_ENDPOINTS`` and ``TT_CONFIG_STORAGE_PREFIX``.
*   etcd-based storage: ``TT_CONFIG_ETCD_ENDPOINTS`` and ``TT_CONFIG_ETCD_PREFIX``.

The example below shows how to provide etcd connection settings and start cluster instances using the ``tarantool`` command:

.. code-block:: console

    $ export TT_CONFIG_ETCD_ENDPOINTS=http://localhost:2379
    $ export TT_CONFIG_ETCD_PREFIX=/myapp

    $ tarantool --name instance001
    $ tarantool --name instance002
    $ tarantool --name instance003




.. _etcd_reloading_configuration:

Reloading configuration
-----------------------

By default, Tarantool watches keys with the :ref:`specified prefix <centralized_configuration_storage_connect>` for changes in a cluster's configuration and reloads a changed configuration automatically.
If necessary, you can set the :ref:`config.reload <configuration_reference_config_reload>` option to ``manual`` to turn off configuration reloading:

.. code-block:: yaml

    config:
      reload: 'manual'
      etcd:
        # ...

In this case, you can reload a configuration in an :ref:`admin console <admin-security>` or :ref:`application code <configuration_application>` using the :ref:`reload() <config_api_reference_reload>` function provided by the ``config`` module:

.. code-block:: lua

    require('config'):reload()

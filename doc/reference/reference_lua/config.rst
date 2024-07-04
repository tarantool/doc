..  _config-module:

Module config
=============

**Since:** :doc:`3.0.0 </release/3.0.0>`

The ``config`` module provides the ability to work with an instance's configuration.
For example, you can determine whether the current instance is up and running without errors after applying the :ref:`cluster's configuration <configuration_overview>`.

By using the ``config.storage`` :ref:`role <configuration_application_roles>`, you can set up a Tarantool-based :ref:`centralized configuration storage <configuration_etcd>` and interact with this storage using the ``config`` module API.


..  _config_module_loading:

Loading config
--------------

To load the ``config`` module, use the ``require()`` directive:

.. code-block:: lua

    local config = require('config')

Then, you can access its :ref:`API <config_api_reference>`:

.. code-block:: lua

    config:reload()


.. _config_module_api_reference:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **config API**
            -

        *   -   :ref:`config:get() <config_api_reference_get>`
            -   Get a configuration applied to the current or remote instance

        *   -   :ref:`config:info() <config_api_reference_info>`
            -   Get the current instance's state in regard to configuration

        *   -   :ref:`config:instance_uri() <config_api_reference_instance_uri>`
            -   Get a URI of the current or remote instance

        *   -   :ref:`config:instances() <config_api_reference_instances>`
            -   List all instances of the cluster

        *   -   :ref:`config:reload() <config_api_reference_reload>`
            -   Reload the current instance's configuration

        *   -   **config.storage API**
            -

        *   -   :ref:`config.storage.put() <config_storage_api_reference_put>`
            -   Put a value by the specified path

        *   -   :ref:`config.storage.get() <config_storage_api_reference_get>`
            -   Get a value stored by the specified path

        *   -   :ref:`config.storage.delete() <config_storage_api_reference_delete>`
            -   Delete a value stored by the specified path

        *   -   :ref:`config.storage.info() <config_storage_api_reference_info>`
            -   Get information about an instance's connection state

        *   -   :ref:`config.storage.txn() <config_storage_api_reference_txn>`
            -   Make an atomic request



..  _config_api_reference:

config API
~~~~~~~~~~

..  class:: config

    .. _config_api_reference_get:

    ..  method:: get([param, opts])

        Get a configuration applied to the current or remote instance.
        Note that there is the following difference between getting a configuration for the current and remote instance:

        -   For the current instance, ``get()`` returns an instance configuration considering :ref:`environment variables <configuration_environment_variable>`.
        -   For a remote instance, ``get()`` only considers a cluster configuration and ignores environment variables.

        :param string param: a configuration option name
        :param table opts: options to pass. The following options are available:

                           -   ``instance`` (since :doc:`3.1.0 </release/3.1.0>`) -- the name of a remote instance whose configuration should be obtained

        :return: an instance configuration

        **Examples:**

        The example below shows how to get the full instance configuration:

        .. code-block:: tarantoolsession

            app:instance001> require('config'):get()
            ---
            - fiber:
                io_collect_interval: null
                too_long_threshold: 0.5
                top:
                  enabled: false
              # Other configuration values
              # ...

        This example shows how to get an ``iproto.listen`` option value:

        .. code-block:: tarantoolsession

            app:instance001> require('config'):get('iproto.listen')
            ---
            - - uri: 127.0.0.1:3301
            ...

        ``config.get()`` can also be used in :ref:`application code <configuration_application>` to get the value of a custom configuration option.


    .. _config_api_reference_info:

    ..  method:: info([version])

        Get the current instance's state in regard to configuration.

        :param string version: (since :doc:`3.1.0 </release/3.1.0>`) the version of the information that should be returned. The ``version`` argument can be one of the following values:

                               * ``v1`` (default): the ``meta`` field returned by ``info()`` includes information about the last loaded configuration
                               * ``v2``: the ``meta`` field returned by ``info()`` includes two fields:

                                   * the ``last`` field includes information about the last loaded configuration
                                   * the ``active`` field includes information for the last successfully applied configuration


        :return: a table containing an instance's state. The returned state includes the following sections:

                 -   ``status`` -- one of the following statuses:

                     *   ``ready`` -- the configuration is applied successfully
                     *   ``check_warnings`` -- the configuration is applied with warnings
                     *   ``check_errors`` -- the configuration cannot be applied due to configuration errors

                 -   ``meta`` -- additional configuration information

                 -   ``alerts`` -- warnings or errors raised on an attempt to apply the configuration

        Below are a few examples demonstrating how the ``info()`` output might look.

        **Example: no configuration warnings or errors**

        In the example below, an instance's state is ``ready`` and no warnings are shown:

        ..  code-block:: tarantoolsession

            app:instance001> require('config'):info('v2')
            ---
            - status: ready
              meta:
                last: &0 []
                active: *0
              alerts: []
            ...

        **Example: configuration warnings**

        In the example below, the instance's state is ``check_warnings``.
        The ``alerts`` section informs that privileges to the ``bands`` space for ``sampleuser`` cannot be granted because the ``bands`` space has not created yet:

        ..  code-block:: tarantoolsession

            app:instance001> require('config'):info('v2')
            ---
            - status: check_warnings
              meta:
                last: &0 []
                active: *0
              alerts:
              - type: warn
                message: box.schema.user.grant("sampleuser", "read,write", "space", "bands") has
                  failed because either the object has not been created yet, a database schema
                  upgrade has not been performed, or the privilege write has failed (separate
                  alert reported)
                timestamp: 2024-07-03T18:09:18.826138+0300
            ...

        This warning is cleared when the ``bands`` space is created.

        **Example: configuration errors**

        In the example below, the instance's state is ``check_errors``.
        The ``alerts`` section informs that the ``log.level`` configuration option has an incorrect value:

        ..  code-block:: tarantoolsession

            app:instance001> require('config'):info('v2')
            ---
            - status: check_errors
              meta:
                last: []
                active: []
              alerts:
              - type: error
                message: '[cluster_config] log.level: Got 8, but only the following values are
                  allowed: 0, fatal, 1, syserror, 2, error, 3, crit, 4, warn, 5, info, 6, verbose,
                  7, debug'
                timestamp: 2024-07-03T18:13:19.755454+0300
            ...

        **Example: configuration errors (centralized configuration storage)**

        In this example, the ``meta`` field includes information about a :ref:`centralized storage <configuration_etcd>` the instance takes a configuration from:

        ..  code-block:: tarantoolsession

            app:instance001> require('config'):info('v2')
            ---
            - status: check_errors
              meta:
                last:
                  etcd:
                    mod_revision:
                      /myapp/config/all: 5
                    revision: 5
                active:
                  etcd:
                    mod_revision:
                      /myapp/config/all: 2
                    revision: 4
              alerts:
              - type: error
                message: 'etcd source: invalid config at key "/myapp/config/all": [cluster_config]
                  groups.group001.replicasets.replicaset001.instances.instance001.log.level: Got
                  8, but only the following values are allowed: 0, fatal, 1, syserror, 2, error,
                  3, crit, 4, warn, 5, info, 6, verbose, 7, debug'
                timestamp: 2024-07-03T15:22:06.438275Z
            ...


    .. _config_api_reference_instance_uri:

    ..  method:: instance_uri([uri_type, opts])

        **Since:** :doc:`3.1.0 </release/3.1.0>`

        Get a URI of the current or remote instance.

        :param string uri_type: a URI type. There are the following URI types are supported:

                                * ``peer`` -- a URI used to advertise the instance to other cluster members. See also: :ref:`iproto.advertise.peer <configuration_reference_iproto_advertise_peer>`.
                                * ``sharding`` -- a URI used to advertise the current instance to a router and rebalancer. See also: :ref:`iproto.advertise.sharding <configuration_reference_iproto_advertise_sharding>`.

        :param table opts: options to pass. The following options are available:

                           -   ``instance`` -- the name of a remote instance whose URI should be obtained

        :return: a table representing an instance URI. This table might include the following fields:

                 *   ``uri`` -- an instance URI
                 *   ``login`` -- a username used to connect to this instance
                 *   ``password`` -- a user's password
                 *   ``params`` -- URI parameters used to connect to this instance

        **Example**

        The example below shows how to get a URI used to advertise ``storage-b-003`` to other cluster members:

        ..  code-block:: lua

            local config = require('config')
            config:instance_uri('peer', { instance = 'storage-b-003' })


    .. _config_api_reference_instances:

    ..  method:: instances()

        **Since:** :doc:`3.1.0 </release/3.1.0>`

        List all instances of the cluster.

        :return: a table containing information about instances

        The returned table uses instance names as the keys and contains the following information for each instance:

        -   ``instance_name`` -- an instance name
        -   ``replicaset_name`` -- the name of a replica set the instance belongs to
        -   ``group_name`` -- the name of a group the instance belongs to

        **Example**

        The example below shows how to use ``instances()`` to get the names of all instances in the cluster, create a connection to each instance using the :ref:`connpool <connpool_module>` module, and log connection URIs using the :ref:`log <log-module>` module:

        ..  code-block:: lua

            local config = require('config')
            for instance_name in pairs(config:instances()) do
                local connpool = require('experimental.connpool')
                local conn = connpool.connect(instance_name)
                local log = require('log')
                log.info(string.format("Connection URI for '%s': %s:%s", instance_name, conn.host, conn.port))
            end


    .. _config_api_reference_reload:

    ..  method:: reload()

        Reload the current instance's configuration.
        Below are a few use cases when this function can be used:

        -   A configuration option value specific to this instance is changed in a cluster's configuration.
        -   A new instance is :ref:`added to a replica set <replication-add_instances>`.
        -   A centralized configuration with turned-off configuration reloading is updated. Learn more at :ref:`etcd_reloading_configuration`.


..  _config_storage_api_reference:

config.storage API
~~~~~~~~~~~~~~~~~~

The ``config.storage`` API allows you to interact with a Tarantool-based :ref:`centralized configuration storage <configuration_etcd>`.

.. module:: config.storage

.. _config_storage_api_reference_put:

.. function:: put(path, value)

    Put a value by the specified path.

    :param string path: a path to put the value by
    :param string value: a value to put

    :return:    a table containing the following fields:

                *   ``revision``: a revision after performing the operation

    :rtype: table

    **Example:**

    The example below shows how to read a configuration stored in the ``source.yaml`` file using the :ref:`fio module <fio-module>` API and put this configuration by the ``/myapp/config/all`` path:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
        :language: lua
        :start-after: function put_config
        :end-at: cluster_config_handle:close()
        :dedent:

    Example on GitHub: `tarantool_config_storage <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage>`_.


.. _config_storage_api_reference_get:

.. function:: get(path)

    Get a value stored by the specified path or prefix.

    :param string path: a path or prefix to get a value by; prefixes end with ``/``

    :return:    a table containing the following fields:

                *   ``data``: a table containing the information about the value:

                    * ``path``: a path
                    * ``mod_revision``: the last revision at which this value was modified
                    * ``value:``: a value

                *   ``revision``: a revision after performing the operation

    :rtype: table

    **Examples:**

    The example below shows how to get a configuration stored by the ``/myapp/config/all`` path:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
        :language: lua
        :start-after: get_config_by_path
        :end-at: get('/myapp/config/all')
        :dedent:

    This example shows how to get all configurations stored by the ``/myapp/`` prefix:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
        :language: lua
        :start-after: get_config_by_prefix
        :end-at: get('/myapp/')
        :dedent:

    Example on GitHub: `tarantool_config_storage <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage>`_.

.. _config_storage_api_reference_delete:

.. function:: delete(path)

    Delete a value stored by the specified path or prefix.

    :param string path: a path or prefix to delete the value by; prefixes end with ``/``

    :return:    a table containing the following fields:

                *   ``data``: a table containing the information about the value:

                    * ``path``: a path
                    * ``mod_revision``: the last revision at which this value was modified
                    * ``value:``: a value

                *   ``revision``: a revision after performing the operation

    :rtype: table

    **Examples:**

    The example below shows how to delete a configuration stored by the ``/myapp/config/all`` path:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
        :language: lua
        :start-after: delete_config
        :end-at: delete('/myapp/config/all')
        :dedent:

    In this example, all configuration are deleted:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
        :language: lua
        :start-after: delete_all_configs
        :end-at: delete('/')
        :dedent:

    Example on GitHub: `tarantool_config_storage <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage>`_.


.. _config_storage_api_reference_info:

.. function:: info()

    Get information about an instance's connection state.

    :return:    a table containing the following fields:

                *   ``status``: a connection status, which can be one of the following:

                    * ``connected``: if any instance from the quorum is available to the current instance
                    * ``disconnected``: if the current instance doesn't have a connection with the quorum

    :rtype: table


.. _config_storage_api_reference_txn:

.. function:: txn(request)

    Make an atomic request.

    :param table request:   a table containing the following optional fields:

                            *   ``predicates``: a list of predicates to check. Each predicate is a list that contains:

                                .. code-block:: none

                                    {target, operator, value[, path]}

                                *   ``target`` -- one of the following string values: ``revision``, ``mod_revision``, ``value``, ``count``
                                *   ``operator`` -- a string value: ``eq``, ``ne``, ``gt``, ``lt``, ``ge``, ``le`` or its symbolic equivalent, for example, ``==``, ``!=``, ``>``
                                *   ``value`` -- an unsigned or string value to compare
                                *   ``path`` (optional) -- a string value: can be a path with the ``mod_revision`` and ``value`` target or a path/prefix with the ``count`` target

                            * ``on_success``: a list with operations to execute if all predicates in the list evaluate to ``true``

                            * ``on_failure``: a list with operations to execute if any of a predicate evaluates to ``false``

    :return:    a table containing the following fields:

                *   ``data``: a table containing response data:

                    * ``responses``: the list of responses for all operations
                    * ``is_success``: a boolean value indicating whether the predicate is evaluated to ``true``

                *   ``revision``: a revision after performing the operation

    :rtype: table

    **Example:**

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage/myapp.lua
        :language: lua
        :start-at: config.storage.txn
        :end-at: })
        :dedent:

    Example on GitHub: `tarantool_config_storage <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/centralized_config/instances.enabled/tarantool_config_storage>`_.

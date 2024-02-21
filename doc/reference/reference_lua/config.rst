..  _config-module:

Module config
=============

**Since:** :doc:`3.0.0 </release/3.0.0>`

The ``config`` module provides the ability to work with an instance's configuration.
For example, you can determine whether the current instance is up and running without errors after applying the :ref:`cluster's configuration <configuration_overview>`.

By using the ``config.storage`` :ref:`role <configuration_reference_roles_options>`, you can set up a Tarantool-based :ref:`centralized configuration storage <configuration_etcd>` and interact with this storage using the ``config`` module API.


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
            -   Get a configuration applied to the current instance

        *   -   :ref:`config:info() <config_api_reference_info>`
            -   Get the current instance's state in regard to configuration

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

    ..  method:: get([param])

        Get a configuration applied to the current instance.
        Optionally, you can pass a configuration option name to get its value.

        :param string param: a configuration option name
        :return: an instance configuration

        **Examples:**

        The example below shows how to get the full instance configuration:

        .. code-block:: console

            app:instance001> require('config'):get()
            ---
            - fiber:
                io_collect_interval: null
                too_long_threshold: 0.5
                top:
                  enabled: false
              # other configuration values
              # ...

        This example shows how to get an ``iproto.listen`` option value:

        .. code-block:: console

            app:instance001> require('config'):get('iproto.listen')
            ---
            - - uri: 127.0.0.1:3301
            ...

        ``config.get()`` can also be used in :ref:`application code <configuration_application>` to get the value of a custom configuration option.


    .. _config_api_reference_info:

    ..  method:: info()

        Get the current instance's state in regard to configuration.

        :return: a table containing an instance's state

        The returned state includes the following sections:

        -   ``status`` -- one of the following statuses:

            *   ``ready`` -- the configuration is applied successfully
            *   ``check_warnings`` -- the configuration is applied with warnings
            *   ``check_errors`` -- the configuration cannot be applied due to configuration errors

        -   ``meta`` -- additional configuration information

        -   ``alerts`` -- warnings or errors raised on an attempt to apply the configuration

        **Examples:**

        Below are a few examples demonstrating how the ``info()`` output might look:

        *   In the example below, an instance's state is ``ready`` and no warnings are shown:

            ..  code-block:: console

                app:instance001> require('config'):info()
                ---
                - status: ready
                  meta: []
                  alerts: []
                ...

        *   In the example below, the instance's state is ``check_warnings``.
            The ``alerts`` section informs that privileges to the ``books`` space for ``sampleuser`` cannot be granted because the ``books`` space has not created yet:

            ..  code-block:: console

                app:instance001> require('config'):info()
                ---
                - status: check_warnings
                  meta: []
                  alerts:
                  - type: warn
                    message: box.schema.user.grant("sampleuser", "read,write", "space", "books") has
                      failed because either the object has not been created yet, or the privilege
                      write has failed (separate alert reported)
                    timestamp: 2024-02-27T15:07:41.815785+0300
                ...

            This warning is cleared when the ``books`` space is created.

        *   In the example below, the instance's state is ``check_errors``.
            The ``alerts`` section informs that the ``log.level`` configuration option has an incorrect value:

            ..  code-block:: console

                app:instance001> require('config'):info()
                ---
                - status: check_errors
                  meta: []
                  alerts:
                  - type: error
                    message: '[cluster_config] log.level: Got 8, but only the following values are
                      allowed: 0, fatal, 1, syserror, 2, error, 3, crit, 4, warn, 5, info, 6, verbose,
                      7, debug'
                    timestamp: 2024-02-29T12:55:54.366810+0300
                ...

        *   In this example, an instance's state includes information about a :ref:`centralized storage <configuration_etcd>` the instance takes a configuration from:

            ..  code-block:: console

                app:instance001> require('config'):info()
                ---
                - status: ready
                  meta:
                    storage:
                      revision: 8
                      mod_revision:
                        /myapp/config/all: 8
                  alerts: []
                ...


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
                    * ``mod_revision``: a last revision at which this value was modified
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
                    * ``mod_revision``: a last revision at which this value was modified
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

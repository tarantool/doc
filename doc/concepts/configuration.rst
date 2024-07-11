..  _configuration:

Configuration
=============

Tarantool provides the ability to configure the full topology of a cluster and set parameters specific for concrete instances, such as connection settings, memory used to store data, logging, and snapshot settings.
Each instance uses this configuration during :ref:`startup <configuration_run_instance>` to organize the cluster.

There are two approaches to configuring Tarantool:

*   *Since version 3.0*: In the YAML format.

    YAML configuration allows you to provide the full cluster topology and specify all configuration options.
    You can use local configuration in a YAML file for each instance or store configuration data in a reliable :ref:`centralized storage <configuration_etcd_overview>`.

*   *In version 2.11 and earlier*: :ref:`In code <configuration_code>` using the ``box.cfg`` API.

    In this case, configuration is provided in a Lua initialization script.

    .. NOTE::

        Starting with the 3.0 version, configuring Tarantool in code is considered a legacy approach.


..  _configuration_overview:

Configuration overview
----------------------

YAML configuration describes the full topology of a Tarantool cluster.
A cluster's topology includes the following elements, starting from the lower level:

..  code-block:: yaml
    :emphasize-lines: 1,3,5

    groups:
      group001:
        replicasets:
          replicaset001:
            instances:
              instance001:
                # ...
              instance002:
                # ...

-   ``instances``

    An *instance* represents a single running Tarantool instance.
    It stores data or might act as a router for handling CRUD requests in a :ref:`sharded <sharding>` cluster.
-   ``replicasets``

    A *replica set* is a pack of instances that operate on same data sets.
    :ref:`Replication <replication>` provides redundancy and increases data availability.
-   ``groups``

    A *group* provides the ability to organize replica sets.
    For example, in a sharded cluster, one group can contain :ref:`storage <vshard-architecture-storage>` instances and another group can contain :ref:`routers <vshard-architecture-router>` used to handle CRUD requests.

You can flexibly configure a cluster's settings on different levels: from global settings applied to all groups to parameters specific for concrete instances.

..  NOTE::

    All the available options are documented in the :ref:`Configuration reference <configuration_reference>`.


..  _configuration_file:

Configuration in a file
-----------------------

This section provides an overview on how to configure Tarantool in a YAML file.

.. _configuration_instance_basic:

Basic instance configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The example below shows a sample configuration of a single Tarantool instance:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/config.yaml
    :language: yaml
    :dedent:

-   The ``instances`` section includes only one instance named *instance001*.
    The ``iproto.listen.uri`` option sets an address used to listen for incoming requests.
-   The ``replicasets`` section contains one replica set named *replicaset001*.
-   The ``groups`` section contains one group named *group001*.


.. _configuration_scopes:

Configuration scopes
~~~~~~~~~~~~~~~~~~~~

This section shows how to control a scope the specified configuration option is applied to.
Most of the configuration options can be applied to a specific instance, replica set, group, or to all instances globally.

-   *Instance*

    To apply specific configuration options to a concrete instance,
    specify such options for this instance only.
    In the example below, ``iproto.listen`` is applied to *instance001* only.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/config.yaml
        :language: yaml
        :emphasize-lines: 7-9
        :dedent:

-   *Replica set*

    In this example, ``iproto.listen`` is in effect for all instances in *replicaset001*.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/replicaset_scope/config.yaml
        :language: yaml
        :emphasize-lines: 5-7
        :dedent:

-   *Group*

    In this example, ``iproto.listen`` is in effect for all instances in *group001*.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/group_scope/config.yaml
        :language: yaml
        :emphasize-lines: 3-5
        :dedent:

-   *Global*

    In this example, ``iproto.listen`` is applied to all instances of the cluster.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/global_scope/config.yaml
        :language: yaml
        :emphasize-lines: 1-3
        :dedent:

Configuration scopes above are listed in the order of their precedence -- from highest to lowest.
For example, if the same option is defined at the instance and global level, the instance's value takes precedence over the global one.


.. NOTE::

    The :ref:`Configuration reference <configuration_reference>` contains information about scopes to which each configuration option can be applied.


.. _configuration_replica_set_scopes:

Configuration scopes: Replica set example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The example below shows how specific configuration options work in different configuration scopes for a replica set with a manual failover.
You can learn more about configuring replication from :ref:`Replication tutorials <how-to-replication>`.

..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/config.yaml
    :language: yaml
    :end-before: Load sample data
    :dedent:

-   ``credentials`` (*global*)

    This section is used to create the *replicator* user and assign it the specified role.
    These options are applied globally to all instances.

-   ``iproto`` (*global*, *instance*)

    The ``iproto`` section is specified on both global and instance levels.
    The ``iproto.advertise.peer`` option specifies the parameters used by an instance to connect to another instance as a replica, for example, a URI, a login and password, or SSL parameters .
    In the example above, the option includes ``login`` only.
    An URI is taken from ``iproto.listen`` that is set on the instance level.

-   ``replication`` (*global*)

    The ``replication.failover`` global option sets a manual failover for all replica sets.

-   ``leader`` (*replica set*)

    The ``<replicaset-name>.leader`` option sets a :ref:`master <replication-roles>` instance for *replicaset001*.



.. _configuration_application:
.. _configuration_application_roles:

Enabling and configuring roles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An application role is a Lua module that implements specific functions or logic.
You can turn on or off a particular role for certain instances in a configuration without restarting these instances.

There can be built-in Tarantool roles, roles provided by third-party Lua modules, or custom roles that are developed as a part of a cluster application.
This section describes how to enable and configure roles.
To learn how to develop custom roles, see :ref:`application_roles`.



.. _configuration_application_roles_enable:

Enabling a role
***************

To turn on or off a role for a specific instance or a set of instances, use the :ref:`roles <configuration_reference_roles>` configuration option.
The example below shows how to enable the ``roles.crud-router`` role provided by the `CRUD <https://github.com/tarantool/crud>`__ module using the :ref:`roles <configuration_reference_roles>` option:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :start-at: roles.crud-router
    :end-at: roles.crud-router
    :dedent:

Similarly, you can enable the ``roles.crud-storage`` role to make instances act as CRUD storages:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :start-at: roles.crud-storage
    :end-at: roles.crud-storage
    :dedent:

Example on GitHub: `sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_


.. _configuration_application_roles_configure:

Configuring a role
******************

The :ref:`roles_cfg <configuration_reference_roles_cfg>` option allows you to specify the configuration for each role.
In this option, the role name is the key and the role configuration is the value.

The example below shows how to enable statistics on called operations by providing the ``roles.crud-router`` role's configuration:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud/config.yaml
    :language: yaml
    :start-at: roles.crud-router
    :end-at: stats_quantile_max_age_time
    :dedent:

Example on GitHub: `sharded_cluster_crud <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud>`_



.. _configuration_application_roles_scopes:

Roles and configuration scopes
******************************

As the most of configuration options, roles and their configurations can be defined at :ref:`different levels <configuration_scopes>`.
Given that the ``roles`` option has the ``array`` type and ``roles_cfg`` has the ``map`` type, there are some specifics of applying the configuration:

-   For ``roles``, an instance's role takes precedence over roles defined at another level.
    In the example below, ``instance001`` has only ``role3``:

    ..  code-block:: yaml

        # ...
        replicaset001:
          roles: [ role1, role2 ]
          instances:
            instance001:
              roles: [ role3 ]

    Learn more about the order of precedence for different configuration scopes in :ref:`configuration_scopes`.

-   For ``roles_cfg``, the following rules are applied:

    -   If a configuration *for the same role* is provided at different levels, an instance configuration takes precedence over the configuration defined at another level.
        In the example below, ``role1.greeting`` is ``'Hi'``:

        ..  code-block:: yaml

            # ...
            replicaset001:
              roles_cfg:
                role1:
                  greeting: 'Hello'
              instances:
                instance001:
                  roles: [ role1 ]
                  roles_cfg:
                    role1:
                      greeting: 'Hi'

    -   If the configurations *for different roles* are provided at different levels, both configurations are applied at the instance level.
        In the example below, ``instance001`` has ``role1.greeting`` set to ``'Hi'`` and ``role2.farewell`` set to ``'Bye'``:

        ..  code-block:: yaml

            # ...
            replicaset001:
              roles_cfg:
                role1:
                  greeting: 'Hi'
              instances:
                instance001:
                  roles: [ role1, role2 ]
                  roles_cfg:
                    role2:
                      farewell: 'Bye'


.. _configuration_labels:

Adding custom labels
~~~~~~~~~~~~~~~~~~~~

Labels allow adding custom attributes to your cluster configuration. A label is
a ``key: value`` pair with a string key and value.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/labels/config.yaml
    :language: yaml
    :start-at: labels:
    :end-at: 'false'
    :dedent:

Labels can be defined in any configuration scope. An instance receives labels from
all scopes in belongs to. A ``labels`` section in a group or a replica set scope
applies to all instances of the group or a replica set. To override these labels on
the instance level or add instance-specific labels define another ``labels`` section in the instance scope.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/labels/config.yaml
    :language: yaml
    :dedent:

Example on GitHub: `labels <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/labels>`_

To access the labels from the application code, call the :ref:`config:get() <config_api_reference_get>` function:

.. code-block:: lua

    require('config'):get('labels')

// how to use in connpool

ref:`connpool module <3-1-experimental_connpool>`

.. _configuration_predefined_variables:

Predefined variables
~~~~~~~~~~~~~~~~~~~~

In a configuration file, you can use the following predefined variables that are replaced with actual values at runtime:

-   ``instance_name``
-   ``replicaset_name``
-   ``group_name``

To reference these variables in a configuration file, enclose them in double curly braces with whitespaces.
In the example below, ``{{ instance_name }}`` is replaced with *instance001*.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/templating/config.yaml
    :language: yaml
    :dedent:

As a result, the paths to :ref:`snapshots and write-ahead logs <configuration_persistence>` differ for different instances.



..  _configuration_environment_variable:

Environment variables
---------------------

For each configuration parameter, Tarantool provides two sets of predefined environment variables:

*   ``TT_<CONFIG_PARAMETER>``. These variables are used to substitute parameters specified in a configuration file.
    This means that these variables have a higher :ref:`priority <configuration_precedence>` than the options specified in a configuration file.

*   ``TT_<CONFIG_PARAMETER>_DEFAULT``. These variables are used to specify default values for parameters missing in a configuration file.
    These variables have a lower :ref:`priority <configuration_precedence>` than the options specified in a configuration file.

For example, ``TT_IPROTO_LISTEN`` and ``TT_IPROTO_LISTEN_DEFAULT`` correspond to the ``iproto.listen`` option.
``TT_SNAPSHOT_DIR`` and ``TT_SNAPSHOT_DIR_DEFAULT`` correspond to the ``snapshot.dir`` option.
To see all the supported environment variables, execute the ``tarantool`` command with the ``--help-env-list`` :ref:`option <configuration_command_options>`.

.. code-block:: console

    $ tarantool --help-env-list

..  NOTE::

    There are also special ``TT_INSTANCE_NAME`` and ``TT_CONFIG`` environment variables that can be used to :ref:`start <configuration_run_instance_tarantool>` the specified Tarantool instance with configuration from the given file.

Below are a few examples that show how to set environment variables of different types, like *string*, *number*, *array*, or *map*.

..  _configuration_environment_variable_string:

String
~~~~~~

In this example, ``TT_LOG_LEVEL`` is used to set a logging level to ``CRITICAL``:

..  code-block:: console

    $ export TT_LOG_LEVEL='crit'


..  _configuration_environment_variable_number:

Number
~~~~~~

In this example, a logging level is set to ``CRITICAL`` using a corresponding numeric value:

..  code-block:: console

    $ export TT_LOG_LEVEL=3

..  _configuration_environment_variable_array:

Array
~~~~~

The examples below show how to set the ``TT_SHARDING_ROLES`` variable that accepts an array value.
Arrays can be passed in two ways: using a *simple* ...

..  code-block:: console

    $ export TT_SHARDING_ROLES=router,storage

... or *JSON* format:

..  code-block:: console

    $ export TT_SHARDING_ROLES='["router", "storage"]'

The *simple* format is applicable only to arrays containing scalar values.


..  _configuration_environment_variable_map:

Map
~~~

To assign map values to environment variables, you can also use *simple* or *JSON* formats.
In the example below, ``TT_LOG_MODULES`` sets different logging levels for different modules using a *simple* format:

..  code-block:: console

    $ export TT_LOG_MODULES=module1=info,module2=error

In the next example, ``TT_ROLES_CFG`` is used to specify the value of a custom configuration for a :ref:`role <configuration_application>` using a *JSON* format:

.. code-block:: console

    $ export TT_ROLES_CFG='{"greeter":{"greeting":"Hello"}}'

The *simple* format is applicable only to maps containing scalar values.


..  _configuration_environment_variable_array_of_maps:

Array of maps
~~~~~~~~~~~~~

In the example below, ``TT_IPROTO_LISTEN`` is used to specify a :ref:`listening host and port <configuration_connections_listen_uri>` values:

..  code-block:: console

    $ export TT_IPROTO_LISTEN=['{"uri":"127.0.0.1:3311"}']

You can also pass several listening addresses:

..  code-block:: console

    $ export TT_IPROTO_LISTEN=['{"uri":"127.0.0.1:3311"}','{"uri":"127.0.0.1:3312"}']






.. _configuration_etcd_overview:

Centralized configuration
-------------------------

..  include:: /concepts/configuration/configuration_etcd.rst
    :start-after: ee_note_centralized_config_start
    :end-before: ee_note_centralized_config_end


Tarantool enables you to store configuration data in one place using a Tarantool or etcd-based storage.
To achieve this, you need to:

1.  Set up a centralized configuration storage.

2.  Publish a cluster's configuration to the storage.

3.  Configure a connection to the storage by providing a local YAML configuration with an endpoint address and key prefix in the ``config`` section:

    ..  literalinclude:: /code_snippets/snippets/centralized_config/instances.enabled/config_etcd/config.yaml
        :language: yaml
        :end-at: prefix: /myapp
        :dedent:

Learn more from the following guide: :ref:`configuration_etcd`.


..  _configuration_precedence:

Configuration precedence
------------------------

Tarantool configuration options are applied from multiple sources with the following precedence, from highest to lowest:

-   `TT_*` :ref:`environment variables <configuration_environment_variable>`.
-   Configuration from a :ref:`local YAML file <configuration_file>`.
-   :ref:`Centralized configuration <configuration_etcd_overview>`.
-   `TT_*_DEFAULT` :ref:`environment variables <configuration_environment_variable>`.

If the same option is defined in two or more locations, the option with the highest precedence is applied.





..  toctree::
    :hidden:

    configuration/configuration_etcd
    configuration/configuration_code
    configuration/configuration_memtx
    configuration/configuration_persistence
    configuration/configuration_connections
    configuration/configuration_credentials
    configuration/configuration_authentication
    .. configuration/configuration_migrating

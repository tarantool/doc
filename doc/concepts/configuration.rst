..  _configuration:

Configuration
=============

Tarantool provides the ability to configure the full topology of a cluster and set parameters specific for concrete instances, such as connection settings, memory used to store data, logging, and snapshot settings.
Each instance uses this configuration during :ref:`startup <configuration_run_instance>` to organize the cluster.

There are two approaches to configuring Tarantool:

*   *Since version 3.0*: In the YAML format.

    YAML configuration allows you to provide the full cluster topology and specify all configuration options.
    You can use local configuration in a YAML file for each instance or store configuration data in one reliable place using :ref:`etcd <configuration_etcd_overview>`.

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


..  _configuration_file:

Configuration in a file
~~~~~~~~~~~~~~~~~~~~~~~

This section provides an overview on how to configure Tarantool in a YAML file.

.. _configuration_instance_basic:

Basic instance configuration
****************************

The example below shows a sample configuration of a single Tarantool instance:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/config.yaml
    :language: yaml
    :dedent:

-   The ``instances`` section includes only one instance named *instance001*.
    The ``iproto.listen`` option sets a port used to listen for incoming requests.
-   The ``replicasets`` section contains one replica set named *replicaset001*.
-   The ``groups`` section contains one group named *group001*.


.. _configuration_scopes:

Configuration scopes
********************

This section shows how to control a scope the specified configuration option is applied to.
Most of the configuration options can be applied to a specific instance, replica set, group, or to all instances globally.

-   *Instance*

    To apply specific configuration options to a concrete instance,
    specify such options for this instance only.
    In the example below, ``iproto.listen`` is applied to *instance001* only.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/instance_scope/config.yaml
        :language: yaml
        :emphasize-lines: 7-8
        :dedent:

-   *Replica set*

    In this example, ``iproto.listen`` is in effect for all instances in *replicaset001*.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/replicaset_scope/config.yaml
        :language: yaml
        :emphasize-lines: 5-6
        :dedent:

-   *Group*

    In this example, ``iproto.listen`` is in effect for all instances in *group001*.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/group_scope/config.yaml
        :language: yaml
        :emphasize-lines: 3-4
        :dedent:

-   *Global*

    In this example, ``iproto.listen`` is applied to all instances of the cluster.

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/global_scope/config.yaml
        :language: yaml
        :emphasize-lines: 1-2
        :dedent:


.. NOTE::

    The :ref:`Configuration reference <configuration_reference>` contains information about scopes to which each configuration option can be applied.


.. _configuration_replica_set_scopes:

Configuration scopes: Replica set example
*****************************************

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
    The ``iproto.advertise.peer`` option specifies a URI used by an instance to connect to another instance as a replica.
    In the example above, the URI includes a user name only.
    A host value is taken from ``iproto.listen`` that is set on the instance level.

-   ``replication``: (*global*)

    The ``replication.failover`` global option sets a manual failover for all replica sets.

-   ``leader``: (*replica set*)

    The ``<replicaset-name>.leader`` option sets a :ref:`master <replication-roles>` instance for *replicaset001*.



.. _configuration_application:

Loading an application
**********************

Using Tarantool as an application server, you can run your own Lua applications.
In the ``app`` section, you can load the application and provide a custom application configuration in the ``cfg`` section.

In the example below, the application is loaded from the ``myapp.lua`` file placed next to the YAML configuration file:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application/config.yaml
    :language: yaml
    :dedent:

To get a value of the custom ``greeting`` property in the application code,
use the ``config:get()`` function provided by the :ref:`config <config-module>` module.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application/myapp.lua
    :language: lua
    :dedent:

As a result of :ref:`starting <configuration_run_instance>` the *instance001*, a log should contain the following line:

.. code-block:: console

    main/103/interactive/myapp I> Hello from app, instance001!

The ``app`` section can be placed in any :ref:`configuration scope <configuration_scopes>`.
As an example use case, you can provide different applications for storages and routers in a sharded cluster:

.. code-block:: yaml

    groups:
      storages:
        app:
          module: storage
          # ...
      routers:
        app:
          module: router
          # ...

Learn more about using Tarantool as the application server from :ref:`Developing applications with Tarantool <how-to-app-server>`.



.. _configuration_predefined_variables:

Predefined variables
********************

In a configuration file, you can use the following predefined variables that are replaced with actual values at runtime:

-   ``instance_name``
-   ``replicaset_name``
-   ``group_name``

To reference these variables in a configuration file, enclose them in double curly braces with whitespaces.
In the example below, ``{{ instance_name }}`` is replaced with *instance001*.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/templating/config.yaml
    :language: yaml
    :dedent:

As a result, the :ref:`paths to snapshots and write-ahead logs <configuration_options_directories>` differ for different instances.



..  _configuration_environment_variable:

Environment variables
~~~~~~~~~~~~~~~~~~~~~

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

Below are a few examples that show how to set environment variables of different types, like *string*, *number*, *array*, or *map*:

*   String. In the example below, ``TT_IPROTO_LISTEN`` is used to specify a :ref:`listening host and port <configuration_options_connection>` values:

    ..  code-block:: console

        $ export TT_IPROTO_LISTEN='127.0.0.1:3311'

    To specify several listening addresses, separate them by a comma without space:

    ..  code-block:: console

        $ export TT_IPROTO_LISTEN='127.0.0.1:3311,127.0.0.1:3312'

*   Number. In this example, ``TT_LOG_LEVEL`` is used to set a logging level to 3 (``CRITICAL``):

    ..  code-block:: console

        $ export TT_LOG_LEVEL=3

*   Array. The examples below show how to set the ``TT_SHARDING_ROLES`` variable that accepts an array value.
    Arrays can be passed in two ways: using a *simple* ...

    ..  code-block:: console

        $ export TT_SHARDING_ROLES=router,storage

    ... or *JSON* format:

    ..  code-block:: console

        $ export TT_SHARDING_ROLES='["router", "storage"]'

    The *simple* format is applicable only to arrays containing scalar values.

*   Map. To assign map values to environment variables, you can also use *simple* or *JSON* formats.
    In the example below, ``TT_LOG_MODULES`` sets different logging levels for different modules using a *simple* format:

    ..  code-block:: console

        $ export TT_LOG_MODULES=module1=info,module2=error

    In the next example, ``TT_APP_CFG`` is used to specify the value of a custom configuration property for a :ref:`loaded application <configuration_application>` using a *JSON* format:

    .. code-block:: console

        $ export TT_APP_CFG='{"greeting":"Hi"}'

    The *simple* format is applicable only to maps containing scalar values.


.. NOTE::

    There are also special ``TT_INSTANCE_NAME`` and ``TT_CONFIG`` environment variables that can be used to :ref:`start <configuration_run_instance_tarantool>` the specified Tarantool instance with configuration from the given file.






.. _configuration_etcd_overview:

Configuration in etcd
~~~~~~~~~~~~~~~~~~~~~

..  include:: /concepts/configuration/configuration_etcd.rst
    :start-after: ee_note_etcd_start
    :end-before: ee_note_etcd_end

Tarantool enables you to store configuration data in one reliable place using `etcd <https://etcd.io/>`_.
To achieve this, you need to:

1.   Provide a local YAML configuration with an etcd endpoint address and key prefix in the ``config`` section:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/etcd/config.yaml
        :language: yaml
        :dedent:

2.   Publish a cluster's configuration to an etcd server.

Learn more from the following guide: :ref:`Storing configuration in etcd <configuration_etcd>`.


..  _configuration_precedence:

Configuration precedence
~~~~~~~~~~~~~~~~~~~~~~~~

Tarantool configuration options are applied from multiple sources with the following precedence, from highest to lowest:

-   `TT_*` :ref:`environment variables <configuration_environment_variable>`.
-   Configuration from a :ref:`local YAML file <configuration_file>`.
-   :ref:`Centralized configuration <configuration_etcd_overview>` stored in etcd.
-   `TT_*_DEFAULT` :ref:`environment variables <configuration_environment_variable>`.

If the same option is defined in two or more locations, the option with the highest precedence is applied.



..  _configuration_options_overview:

Configuration options overview
------------------------------

This section gives an overview of some useful configuration options.
All the available options are documented in the :ref:`Configuration reference <configuration_reference>`.

.. _configuration_options_connection:

Connection settings
~~~~~~~~~~~~~~~~~~~

To configure an address used to listen for incoming requests, use the ``iproto.listen`` option.
Below are a few examples on how to do this:

*   Set a listening port to ``3301``:

    .. code-block:: yaml

        iproto:
          listen: "3301"

*   Set a listening address to ``127.0.0.1:3301``:

    .. code-block:: yaml

        iproto:
          listen: "127.0.0.1:3301"


*   Configure several listening addresses:

    .. code-block:: yaml

        iproto:
          listen: "127.0.0.1:3301,127.0.0.1:3303"

*   Enables :ref:`traffic encryption <enterprise-iproto-encryption>` for a connection using corresponding URI parameters:

    .. code-block:: yaml

        iproto:
          listen: "127.0.0.1:3301?transport=ssl&ssl_key_file=localhost.key&ssl_cert_file=localhost.crt&ssl_ca_file=ca.crt"

    Note that traffic encryption is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


*   Use a Unix domain socket:

    .. code-block:: yaml

        iproto:
          listen: "unix/:./var/run/{{ instance_name }}/tarantool.iproto"


.. _configuration_options_access_control:

Access control
~~~~~~~~~~~~~~

The ``credentials`` section allows you to create users and grant them the specified privileges.
In the example below, there are two users:

*   The *replicator* user is used for replication and has a corresponding role.
*   The *storage* user has the ``super`` role and can perform any action on Tarantool instances.

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster/config.yaml
    :language: yaml
    :start-at: credentials:
    :end-at: roles: [super]
    :dedent:

To learn more, see the :ref:`Access control <authentication>` section.


.. _configuration_options_memory:

Memory
~~~~~~

The ``memtx.memory`` option specifies how much :ref:`memory <engines-memtx>` Tarantool allocates to actually store data.

.. code-block:: yaml

    memtx:
      memory: 100000000

When the limit is reached, ``INSERT`` or ``UPDATE`` requests fail with :ref:`ER_MEMORY_ISSUE <admin-troubleshoot-memory-issues>`.


.. _configuration_options_directories:

Snapshots and write-ahead logs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``snapshot.dir`` and ``wal.dir`` options can be used to configure directories for storing snapshots and write-ahead logs.
For example, you can place snapshots and write-ahead logs on different hard drives for better reliability.

.. code-block:: yaml

    instance001:
      snapshot:
        dir: '/media/drive1/snapshots'
      wal:
        dir: '/media/drive2/wals'

To learn more about the persistence mechanism in Tarantool, see the :ref:`Persistence <concepts-data_model-persistence>` section.


.. _configuration_run_instance:

Starting Tarantool instances
----------------------------

.. _configuration_run_instance_tt:

Starting instances using the tt utility
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`tt <tt-cli>` utility is the recommended way to start Tarantool instances.

Instance files or directories are organized into applications in the ``instances_enabled`` directory.
The example below shows how a :ref:`layout <admin-start_stop_instance-multi-instance-layout>` of the application called ``app`` might look:

.. code-block:: none

    ├── tt.yaml
    └── instances.enabled
        └── app
            ├── config.yaml
            ├── myapp.lua
            └── instances.yml

*   ``config.yaml`` is a :ref:`configuration file <configuration_file>`.
*   ``myapp.lua`` is a Lua script containing an :ref:`application to load <configuration_application>`.
*   ``instances.yml`` specifies :ref:`instances <admin-start_stop_instance-multi-instance>` to run in the current environment.
    This file might look as follows:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/manual_leader/instances.yml
        :language: yaml
        :dedent:

To start all instances, use the ``tt start app`` command:

    .. code-block:: console

        $ tt start app
            • Starting an instance [app:instance001]...
            • Starting an instance [app:instance002]...
            • Starting an instance [app:instance003]...

Then, you can connect to Tarantool instances by its names using the ``tt connect`` command.
You can learn more from the :ref:`Starting and stopping instances <admin-start_stop_instance>` section.



.. _configuration_run_instance_tarantool:

Starting an instance using the tarantool command
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``tarantool`` command provides additional :ref:`options <configuration_command_options>` that might be helpful for development purposes.
Below is the syntax for starting a Tarantool instance configured in a file:

..  code-block:: console

    $ tarantool [OPTION ...] --name INSTANCE_NAME --config CONFIG_FILE_PATH

The command below starts ``instance001`` configured in the ``config.yaml`` file:

.. code-block:: console

    $ tarantool --name instance001 --config config.yaml


.. _configuration_command_options:

Command-line options
********************

Options that can be passed when :ref:`starting a Tarantool instance <configuration_run_instance_tarantool>`:

..  option:: -h, --help

    Print an annotated list of all available options and exit.

..  option:: --help-env-list

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Show a list of :ref:`environment variables <configuration_environment_variable>` that can be used to configure Tarantool.

.. _index-tarantool_version:

..  option:: -v, -V, --version

    Print the product name and version.

    **Example**

    ..  code-block:: console

        % tarantool --version
        Tarantool 3.0.0-entrypoint-746-g36ef3fb43
        Target: Darwin-arm64-Release
        ...

    In this example:

    *   ``3.0.0`` is a Tarantool version.
        Tarantool follows semantic versioning, which is described in the :ref:`Tarantool release policy <release-policy>` section.

    *   ``Target`` is the platform Tarantool is built on.
        Platform-specific details may follow this line.


..  option:: -c, --config PATH

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Set a path to a :ref:`YAML configuration file <configuration_file>`.
    You can also configure this value using the ``TT_CONFIG`` environment variable.

    See also: :ref:`Starting an instance using the tarantool command <configuration_run_instance_tarantool>`

..  option:: -n, --name INSTANCE

    **Since:** :doc:`3.0.0 </release/3.0.0>`.

    Set the name of an instance to run.
    You can also configure this value using the ``TT_INSTANCE_NAME`` environment variable.

    See also: :ref:`Starting an instance using the tarantool command <configuration_run_instance_tarantool>`


..  option:: -i

    Enter an :ref:`interactive mode <interactive_console>`.

    **Example**

    ..  code-block:: console

        % tarantool -i


..  option:: -e EXPR

    Execute the 'EXPR' string. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

    **Example**

    ..  code-block:: console

        % tarantool -e "print('Hello, world!')"
        Hello, world!

..  option:: -l NAME

    Require the 'NAME' library. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.

    **Example**

    ..  code-block:: console

        % tarantool -l luatest.coverage script.lua

..  option:: -j cmd

    Perform a LuaJIT control command. See also: `Command Line Options <https://luajit.org/running.html>`_.

    **Example**

    ..  code-block:: console

        % tarantool -j off app.lua

..  option:: -b ...

    Save or list bytecode. See also: `Command Line Options <https://luajit.org/running.html>`_.

    **Example**

    ..  code-block:: console

        % tarantool -b test.lua test.out

..  option:: -d SCRIPT

    Activate a debugging session for 'SCRIPT'. See also: `luadebug.lua <https://github.com/tarantool/tarantool/blob/master/third_party/lua/README-luadebug.md>`_.

    **Example**

    ..  code-block:: console

        % tarantool -d app.lua


..  option:: --

    Stop handling options. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.


..  option:: -

    Stop handling options and execute the standard input as a file. See also: `lua man page <https://www.lua.org/manual/5.3/lua.html>`_.




..  toctree::
    :hidden:

    configuration/configuration_etcd
    configuration/configuration_code
    configuration/configuration_migrating

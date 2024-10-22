.. _application_roles:

Application roles
=================

An application role is a Lua module that implements specific functions or logic.
You can turn on or off a particular role for certain instances in a :ref:`configuration <configuration>` without restarting these instances.
A role is run when a configuration is loaded or reloaded.

Roles can be divided into the following groups:

-   Tarantool's built-in roles.
    For example, the ``config.storage`` role can be used to make a Tarantool replica set act as a :ref:`configuration storage <centralized_configuration_storage_set_up_tarantool>`.
-   Roles provided by third-party Lua modules.
    For example, the `CRUD <https://github.com/tarantool/crud>`__ module provides the ``roles.crud-storage`` and ``roles.crud-router`` roles that enable CRUD operations in a sharded cluster.
-   Custom roles that are developed as a part of a cluster application.
    For example, you can create a custom role to define a stored procedure or implement a supplementary service, such as an email notifier or a replicator.

This section describes how to develop custom roles.
To learn how to enable and configure roles, see :ref:`configuration_application_roles`.

..  NOTE::

    Don't confuse application roles with other role types:

    -   A role is a container for privileges that can be granted to users. Learn more in :ref:`access_control_concepts_roles`.
    -   A role of a replica set in regard to sharding. Learn more in :ref:`vshard_config_sharding_roles`.


.. _roles_create_custom_role_config:

Providing a role configuration
------------------------------

A custom role can be configured in the same way as roles provided by Tarantool or third-party Lua modules.
You can learn more from :ref:`configuration_application_roles`.

This example shows how to enable and configure the ``greeter`` role, which is implemented in the next section:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/config.yaml
    :language: yaml
    :start-at: instance001
    :dedent:

The role configuration provided in ``roles_cfg`` can be accessed when :ref:`validating <roles_create_custom_role_validate>` and :ref:`applying <roles_create_custom_role_apply>` this configuration.

Tarantool includes the :ref:`experimental.config.utils.schema <config_utils_schema_module>`
built-in module that provides tools for managing user-defined configurations
of applications (``app.cfg``) and roles (``roles_cfg``). The examples below show its
basic usage.

Given that a role is a :ref:`Lua module <app_server-modules>`, a role name is passed to ``require()`` to obtain the module.
When :ref:`developing an application <admin-instance_config-develop-app>`, you can place a file with the role code next to the cluster configuration file.



.. _roles_create_custom_role:

Creating a custom role
----------------------

.. _roles_create_custom_role_overview:

Overview
~~~~~~~~

Creating a custom role includes the following steps:

#.  (Optional) Define the role configuration schema.
#.  Define a function that validates a role configuration.
#.  Define a function that applies a validated configuration.
#.  Define a function that stops a role.
#.  (Optional) Define roles from which this custom role depends on.

As a result, a role module should return an object that has corresponding functions and fields specified:

..  code-block:: lua

    return {
        validate = function() -- ... -- end,
        apply = function() -- ... -- end,
        stop = function() -- ... -- end,
        dependencies = { -- ... -- },
    }

The examples below show how to do this.

..  NOTE::

    Code snippets shown in this section are included from the following application: `application_role_cfg <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/application_role_cfg>`_.

.. _roles_create_custom_role_schema:

Defining the role configuration schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`experimental.config.utils.schema <config_utils_schema_module>` built-in module
provides the :ref:`config-utils-schema_object` class. An object of this class defines
a custom configuration scheme of a role or an application.

This example shows how to define a schema that reflects the role configuration shown above:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/greeter.lua
    :language: lua
    :start-at: local greeter_schema
    :end-before: local function validate
    :dedent:

If you don't use the module, skip this step. In this case, use the ``cfg`` argument
of the role's ``validate()`` and ``apply()`` functions to refer to its configuration
values, for example, ``cfg.greeting``.

.. _roles_create_custom_role_validate:

Validating a role configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To validate a role configuration, you need to define the :ref:`validate([cfg]) <roles_api_reference_validate>` function.
The ``cfg`` argument provides access to the :ref:`role's configuration <roles_create_custom_role_config>` and check its validity.

In the example below, the ``validate()`` function of the role configuration schema
is used to validate the ``greeting`` value:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/greeter.lua
    :language: lua
    :start-at: local function validate
    :end-before: local function apply
    :dedent:

If the configuration is not valid, ``validate()`` reports an unrecoverable error by throwing an error object.


.. _roles_create_custom_role_apply:

Applying a role configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To apply the validated configuration, define the :ref:`apply([cfg]) <roles_api_reference_apply>` function.
As the ``validate()`` function, ``apply()`` provides access to a role's configuration using the ``cfg`` argument.

In the example below, the ``apply()`` function uses the :ref:`log <log-module>` module to write a value from the role configuration to the log:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/greeter.lua
    :language: lua
    :start-at: local function apply
    :end-before: local function stop
    :dedent:



.. _roles_create_custom_role_stop:

Stopping a role
~~~~~~~~~~~~~~~

To stop a role, use the :ref:`stop() <roles_api_reference_stop>` function.

In the example below, the ``stop()`` function uses the :ref:`log <log-module>` module to indicate that a role is stopped:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/greeter.lua
    :language: lua
    :start-at: local function stop
    :end-before: return
    :dedent:

When you've defined all the role functions, you need to return an object that has corresponding functions specified:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/greeter.lua
    :language: lua
    :start-at: return
    :dedent:



.. _roles_create_custom_role_dependencies:

Role dependencies
~~~~~~~~~~~~~~~~~

To define a role's dependencies, use the :ref:`dependencies <roles_api_reference_dependencies>` field.
In this example, the ``byeer`` role has the ``greeter`` role as the dependency:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/byeer.lua
    :language: lua
    :dedent:

A role cannot be started without its dependencies.
This means that all the dependencies of a role should be defined in the ``roles`` configuration parameter:

..  code-block:: yaml

    instance001:
      roles: [ greeter, byeer ]

You can find the full example here: `application_role_cfg <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/application_role_cfg>`_.



.. _roles_create_custom_role_init:

Adding initialization code
~~~~~~~~~~~~~~~~~~~~~~~~~~

You can add initialization code to a role by defining and calling a function with an arbitrary name at the top level of a module, for example:

..  code-block:: lua

    local function init()
        -- ... --
    end

    init()

For example, you can :ref:`create spaces <box_schema-space_create>`, define :ref:`indexes <concepts-data_model_indexes>`, or :ref:`grant privileges <configuration_credentials>` to specific users or roles.

See also: :ref:`roles_create_space`.



.. _roles_create_space:

Specifics of creating spaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create a space in a role, you need to make sure that the target instance is in read-write mode (its :ref:`box.info.ro <box_introspection-box_info>` is ``false``).
You can check an instance state by subscribing to the ``box.status`` event using :ref:`box.watch() <box-watch>`:

..  code-block:: lua

    box.watch('box.status', function()
        -- creating a space
        -- ...
    end)


..  NOTE::

    Given that a role may be enabled when an instance is already in read-write mode,
    you also need to execute schema initialization code from :ref:`apply() <roles_create_custom_role_apply>`.
    To make sure a space is created only once, use the :ref:`if_not_exists <space_opts_if_not_exists>` option.



.. _roles_life_cycle:

Roles life cycle
----------------

A role’s life cycle includes the stages described below.

..  _roles_life_cycle_loading_roles:

1)  *Loading roles*

    On each run, all roles are loaded in the order they are specified in the :ref:`configuration <roles_create_custom_role_config>`.
    This stage takes effect when a role is enabled or an instance with this role is restarted.
    At this stage, a role executes the :ref:`initialization code <roles_create_custom_role_init>`.

    A role cannot be started if it has :ref:`dependencies <roles_create_custom_role_dependencies>` that are not specified in a configuration.

    ..  NOTE::

        Dependencies do not affect the order in which roles are loaded.
        However, the ``validate()``, ``apply()``, and ``stop()`` functions are executed taking dependencies into account.
        Learn more in :ref:`roles_life_cycle_dependencies_specifics`.


..  _roles_life_cycle_stopping_roles:

2)  *Stopping roles*

    This stage takes effect during a configuration reload when a role is removed from the configuration for a given instance.
    Note that all ``stop()`` calls are performed before any ``validate()`` or ``apply()`` calls.
    This means that old roles are stopped first, and only then new roles are started.

.. _roles_life_cycle_validating_role_config:

3)  *Validating a role's configurations*

    At this stage, a configuration for each role is validated using the corresponding :ref:`validate() <roles_api_reference_validate>` function in the same order in which they are specified in the configuration.

.. _roles_life_cycle_applying_role_config:

4)  *Applying a role's configurations*

    At this stage, a configuration for each role is applied using the corresponding :ref:`apply() <roles_api_reference_apply>` function in the same order in which they are specified in the configuration.


All role's functions report an unrecoverable error by throwing an error object.
If an error is thrown in any phase, applying a configuration is stopped.
If starting or stopping a role throws an error, no roles are stopped or started afterward.
An error is caught and shown in :ref:`config:info() <config_api_reference_info>` in the ``alerts`` section.


.. _roles_life_cycle_dependencies_specifics:

Executing functions for dependent roles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For roles that :ref:`depend <roles_create_custom_role_dependencies>` on each other, their ``validate()``,  ``apply()``, and ``stop()`` functions are executed taking into account the dependencies.
Suppose, there are three independent and two dependent roles:

..  code-block:: none

    role1
    role2
    role3
        └─── role4
                 └─── role5

-   ``role1``, ``role2``, and ``role5`` are independent roles.
-   ``role3`` depends on ``role4``, ``role4`` depends on ``role5``.

The roles are enabled in a configuration as follows:

..  code-block:: yaml

    roles: [ role1, role2, role3, role4, role5 ]

In this case, ``validate()`` and ``apply()`` for these roles are executed in the following order:

..  code-block:: none

    role1 -> role2 -> role5 -> role4 -> role3

Roles removed from a configuration are stopped in the order reversed to the order they are specified in a configuration, taking into account the dependencies.
Suppose, all roles except ``role1`` are removed from the configuration above:

..  code-block:: yaml

    roles: [ role1 ]

After reloading a configuration, ``stop()`` functions for the removed roles are executed in the following order:

..  code-block:: none

    role3 -> role4 -> role5 -> role2




.. _roles_example_custom_role:

Example: Role without a configuration
-------------------------------------

The example below shows how to enable the custom ``greeter`` role for ``instance001``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role/config.yaml
    :language: yaml
    :start-at: instance001
    :end-at: greeter
    :dedent:

The implementation of this role looks as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role/greeter.lua
    :language: lua
    :dedent:

Example on GitHub: `application_role <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/application_role>`_



.. _roles_example_custom_role_with_config:

Example: Role with a configuration
----------------------------------

The example below shows how to enable the custom ``greeter`` role for ``instance001`` and specify the configuration for this role:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/config.yaml
    :language: yaml
    :start-at: instance001
    :end-at: greeting
    :dedent:

The implementation of this role looks as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_cfg/greeter.lua
    :language: lua
    :dedent:

Example on GitHub: `application_role_cfg <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/application_role_cfg>`_




.. _roles_example_custom_role_http_api:

Example: HTTP API
-----------------

The example below shows how to enable and configure the ``http-api`` custom role:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_http_api/config.yaml
    :language: yaml
    :start-at: instance001
    :end-at: 8080
    :dedent:

The implementation of this role looks as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/application_role_http_api/http-api.lua
    :language: lua
    :dedent:

Example on GitHub: `application_role_http_api <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/application_role_http_api>`_





.. _roles_api_reference:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Members**
            -

        *   -   :ref:`validate([cfg]) <roles_api_reference_validate>`
            -   Validate a role's configuration.

        *   -   :ref:`apply([cfg]) <roles_api_reference_apply>`
            -   Apply a role's configuration.

        *   -   :ref:`stop() <roles_api_reference_stop>`
            -   Stop a role.

        *   -   :ref:`dependencies <roles_api_reference_dependencies>`
            -   Define a role's dependencies.




.. _roles_api_reference_validate:

..  function:: validate([cfg])

    Validate a role's configuration.
    This function is called on instance startup or when the :ref:`configuration is reloaded <etcd_reloading_configuration>` for the instance with this role.
    Note that the ``validate()`` function is called regardless of whether the role's configuration or any field in a cluster's configuration is changed.

    ``validate()`` should throw an error if the validation fails.

    :param cfg: a role's role configuration to be validated.
                This parameter provides access to configuration options defined in :ref:`roles_cfg.\<role_name\> <configuration_reference_roles_cfg>`.
                To get values of configuration options placed outside ``roles_cfg.<role_name>``, use :ref:`config:get() <config_api_reference_get>`.

    See also: :ref:`roles_create_custom_role_validate`


.. _roles_api_reference_apply:

..  function:: apply([cfg])

    Apply a role's configuration.
    ``apply()`` is called after ``validate()`` is executed for all the enabled roles.
    As the ``validate()`` function, ``apply()`` is called on instance startup or when the configuration is reloaded for the instance with this role.

    ``apply()`` should throw an error if the specified configuration can't be applied.

    ..  NOTE::

        Note that ``apply()`` is not invoked if an instance switches to read-write mode when :ref:`replication.failover <configuration_reference_replication_failover>` is set to ``election`` or ``supervised``.
        You can check an instance state by subscribing to the ``box.status`` event using :ref:`box.watch() <box-watch>`.

    :param cfg: a role's role configuration to be applied.
                This parameter provides access to configuration options defined in :ref:`roles_cfg.\<role_name\> <configuration_reference_roles_cfg>`.
                To get values of configuration options placed outside ``roles_cfg.<role_name>``, use :ref:`config:get() <config_api_reference_get>`.

    See also: :ref:`roles_create_custom_role_apply`


.. _roles_api_reference_stop:

..  function:: stop()

    Stop a role.
    This function is called on configuration reload if the role is removed from ``roles`` for the given instance.

    See also: :ref:`roles_create_custom_role_stop`

.. _roles_api_reference_dependencies:

..  data:: dependencies

    (Optional) Define a role's dependencies.

    :rtype: table

    See also: :ref:`roles_create_custom_role_dependencies`


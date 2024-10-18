..  _config_utils_schema_module:

Submodule experimental.config.utils.schema
==========================================

**Since:** :doc:`3.2.0 </release/3.2.0>`

The ``experimental.config.utils.schema`` module is used to validate and process
parts of cluster configurations that have arbitrary user-defined structures:

-   :ref:`app.cfg <configuration_reference_app_cfg>` for applications loaded using the :ref:`app <configuration_reference_app>` option
-   :ref:`roles_cfg <configuration_reference_roles_cfg>` for :ref:`custom roles <application_roles>` developed as a part of a cluster application

The module provides an API to get and set configuration values, filter and transform configuration data, and so on.

..  important::

    ``experimental.config.utils.schema`` is an experimental submodule and is subject to changes.


.. _config_utils_schema_getting_started:

Getting started with config.utils.schema
----------------------------------------

As an example, consider an :ref:`application role <configuration_application_roles>`
that has a single configuration option - an HTTP endpoint address.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

This is how you can use the ``experimental.config.utils.schema`` module to process
the role configuration:

1.  Load the module:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: config.utils.schema
        :end-at: config.utils.schema
        :dedent:

2.  Define a *schema* -- the root object that stores information about the role's
    configuration -- using :ref:`schema.new() <config-utils-schema-new>`. The example
    below shows a schema that includes a single string option:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local http_api_schema
        :end-before: local function validate
        :dedent:

    Learn more in :ref:`config_utils_schema_definition`.

3.  Use the :ref:`validate() <config-schema_object-validate>` method of the schema object to
    validate configuration values against the schema. In case of a role, call this
    method inside the role's :ref:`validate() <roles_create_custom_role_validate>` function:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local function validate
        :end-before: local function apply
        :dedent:

    Learn more in :ref:`config_utils_schema_validating_configuration`.

4.  Refer to values of configuration options using the :ref:`get() <config-schema_object-get>`
    method inside the role's :ref:`apply() <roles_create_custom_role_apply>` function.
    Learn more in :ref:`config_utils_schema_get_configuration`.



.. _config_utils_schema_definition:

Defining a schema
-----------------

A *configuration schema* stores information about a user-defined configuration structure
that can be passed inside an :ref:`app.cfg <configuration_reference_app_cfg>`
or a :ref:`roles_cfg <configuration_reference_roles_cfg>` section. It includes
option names, types, hierarchy, and other aspects of a configuration.

To create a schema, use the :ref:`schema.new() <config-utils-schema-new>` function.
It has the following arguments:

-   Schema name -- an arbitrary string to use as an identifier.
-   Root schema node -- a table describing the hierarchical schema structure
    starting from the root.
-   (Optional) methods -- user-defined functions that can be called on this schema object.

.. _config_utils_schema_nodes:

Schema nodes
~~~~~~~~~~~~

Schema nodes describe the hierarchy of options within a schema. There are two types of schema nodes:

-   *Scalar* nodes hold a single value of a supported primitive type. For example,
    a string configuration option of a role is a scalar node its schema.
-   *Composite* nodes include multiple values in different forms: *records*, *arrays*, or *maps*.

A node can have *annotations* -- named attributes that enable customization of
its behavior, for example, setting a default value.

.. _config_utils_schema_nodes_scalar:

Scalar nodes
************

Scalar nodes hold a single value of a primitive type, for  example, a string or a number.
For the full list of supported scalar types, see :ref:`config_utils_schema_data_types`.

This configuration has one scalar node of the ``string`` type:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To define a scalar node in a schema, use :ref:`schema.scalar() <config-utils-schema-scalar>`.
The following schema can be used to process the configuration shown above:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
    :language: lua
    :start-at: local http_api_schema
    :end-before: local function validate
    :dedent:

If a scalar node has a limited set of allowed values, you can also define it with
the :ref:`schema.enum() <config-utils-schema-enum>`. Pass the list of allowed values as
its argument:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/http_api.lua
    :language: lua
    :start-at: scheme
    :end-before: host
    :dedent:

.. note::

    Another way to restrict possible option values is the :ref:`allowed_values <config-schema_node_annotation-allowed_values>`
    built-in annotation.

.. _config_utils_schema_data_types:

Data types
^^^^^^^^^^

Scalar nodes can have the following data types:

..  container:: table

    ..  list-table::
        :header-rows: 1

        *   -   Scalar type
            -   Lua type
            -   Comment

        *   -   ``string``
            -   ``string``
            -

        *   -   ``number``
            -   ``number``
            -
        *   -   ``integer``
            -   ``number``
            -   Only integer numbers

        *   -   ``boolean``
            -   ``boolean``
            -   ``true`` or ``false``

        *   -   ``string, number``
                or
                ``number, string``
            -   ``string`` or ``number``
            -

        *   -   ``any``
            -   Arbitrary Lua value
            -   May be used to declare an arbitrary value that doesn't need validation.

.. _config_utils_schema_nodes_record:

Records
*******

*Record* is a composite node that includes a predefined set of other nodes, scalar
or composite. In YAML, a record is represented as a node with nested fields.
For example, the following configuration has a record node ``http_api`` with
three scalar fields:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To define a record node in a schema, use :ref:`schema.record() <config-utils-schema-record>`.
The following schema describes the configuration above:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

Records are also used to define nested schema nodes of non-primitive types. In the example
below, the ``http_api`` node includes another record ``listen_address``.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

The following schema describes this configuration:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:


.. _config_utils_schema_nodes_array:

Arrays
******

*Array* is a composite node type that includes a collection of items of the same
type. The items can be either scalar or composite nodes.

In YAML, array items start with hyphens. For example, the following configuration
includes an array named ``http_api``. Each its item is a record with three fields:
``host``, ``port``, and ``scheme``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_array/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To create an array node in a schema, use :ref:`schema.array() <config-utils-schema-array>`.
The following schema describes this configuration:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_array/http-api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

There is also the :ref:`schema.set() <config-utils-schema-set>` function that enables
creating arrays with a limited set of allowed items.

.. _config_utils_schema_nodes_map:

Maps
****

*Map* is a composite node type that holds an arbitrary number of key-value pairs
of predefined types.

In YAML, a map is represented as a node with nested fields.
For example, the following configuration has the ``endpoints`` node:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_map/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To create a map node in a schema, use :ref:`schema.map() <config-utils-schema-map>`.
If this node is declared as a map as shown below, the ``endpoints`` section can include
any number of options with arbitrary names and boolean values.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_map/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

.. _config_utils_schema_annotation:

Annotations
***********

Node *annotations* are named attributes that define the its various aspects. For example,
scalar nodes have a required annotation ``type`` that defines the node value type.
Other annotations can, for example, set a node's default value and a validation function,
or store arbitrary user-provided data.

Annotations are passed in a table to the node creation function:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: scheme = schema.scalar
    :end-before: host = schema.scalar
    :dedent:

Node annotations fall into three groups:

-   *Built-in annotations* are handled by the module. These are: ``type``, ``validate``, ``allowed_values``, ``default`` and ``apply_default_if``.
    Note that ``validate``, ``allowed_values`` are used for validation only. ``default`` and ``apply_default_if`` can transform the configuration.
-   *User-defined annotations* add named node attributes that can be used in the
    application or role code.
-   *Computed annotations* allow access to annotations of other nodes throughout
    the schema.

.. _config_utils_schema_built_in_annotations:

Built-in annotations
^^^^^^^^^^^^^^^^^^^^

Built-in annotations are interpreted by the module itself. There are the following
built-in annotations:

-   :ref:`type <config-schema_node_annotation-type>` -- the node value type.
    The type must be explicitly specified for scalar nodes, except for those created with ``schema.enum()``.
    For composite nodes and scalar enums, the corresponding constructors ``schema.record()``, ``schema.map()``, ``schema.array()``,
    ``schema.set()``, and ``schema.enum`` set the type automatically.
-   :ref:`allowed_values <config-schema_node_annotation-allowed_values>` -- (optional) a list of possible node values .
-   :ref:`validate <config-schema_node_annotation-validate>` -- (optional) a validation function for the provided node value.
-   :ref:`default <config-schema_node_annotation-default>` -- (optional) a value to use if the option is not specified in the configuration.
-   :ref:`apply_default_if <config-schema_node_annotation-apply_default_if>` -- (optional) a function that defines when to apply the default value.

Consider the following role configuration:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

The following schema uses built-in annotations ``default``, ``allowed_values``, and ``validate``
to define default and allowed option values and validation functions:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

Validation functions can look as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: local function validate_host
    :end-before: local listen_address_schema
    :dedent:


.. _config_utils_schema_user_defined_annotations:

User-defined annotations
^^^^^^^^^^^^^^^^^^^^^^^^

A schema node can have *user-defined annotations* with arbitrary names. Such annotations
are used to implement custom behavior. You can get their names and values from
the schema and use in the role or application code.

Example: the ``env`` user-defined annotation is used to provide names
of environment variables from which the configuration values can be taken.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_fromenv/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function collect_env_cfg
    :dedent:

See the full sample here: :ref:`config_utils_schema_env-vars`.


.. _config_utils_schema_computed_annotations:

Computed annotations
^^^^^^^^^^^^^^^^^^^^

*Computed annotations* enable access from a node to annotations of its ancestor nodes.

In the example below, the ``listen_address`` record validation function refers to the
``protocol`` annotation of its ancestor node:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local listen_address
    :end-before: local http_listen_address_schema
    :dedent:

.. note::

    If there are several ancestor nodes with this annotation, its value is taken
    from the closest one to the current node.

The following schema with ``listen_address`` passes the validation:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local http_listen_address_schema
    :end-before: local iproto_listen_address_schema
    :dedent:

If this record is added to a schema with ``protocol = 'iproto'``, the ``listen_address``
validation fails with an error:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local iproto_listen_address_schema
    :end-before: local function validate
    :dedent:



.. _config_utils_schema_methods:

User-defined methods
~~~~~~~~~~~~~~~~~~~~

A schema can implement custom logic with *methods* -- user-defined functions that can be called on this schema.

For example, this schema has the ``format`` method that returns its fields merged in a URI string:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_methods/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:



.. _config_utils_schema_process_data:

Processing configuration data
-----------------------------

.. _config_utils_schema_validating_configuration:

Validating configuration
~~~~~~~~~~~~~~~~~~~~~~~~

The schema object's :ref:`validate() <config-schema_object-validate>` method performs all the necessary checks
on the provided configuration. It validates the configuration structure, node types, allowed values,
and other aspects of the schema.

When writing roles, call this function inside the :ref:`role validation function <roles_create_custom_role_validate>`:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local function validate
    :end-before: local function apply
    :dedent:


.. _config_utils_schema_get_configuration:

Getting configuration values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get configuration values, use the schema object's :ref:`get() <config-schema_object-get>` method.
It takes the configuration and the full path to the node as arguments:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local function apply
    :end-before: local function stop
    :dedent:


.. _config_utils_schema_transform_configuration:

Transforming configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~

The schema object has methods that transform configuration data based on the schema,
for example, :ref:`apply_default() <config-schema_object-apply_default>`,
:ref:`merge() <config-schema_object-merge>`, :ref:`set() <config-schema_object-set>`.

The following sample shows how to apply default values from the schema to fill
missing configuration fields:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: local function apply
    :end-before: local function stop
    :dedent:


.. _config_utils_schema_env-vars:

Parsing environment variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`schema.fromenv() <config-utils-schema-fromenv>` function allows getting
configuration values from environment variables. The example below shows how to do
this by adding a user-defined annotation ``env``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_fromenv/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

The function also uses schema object methods:

-   :ref:`pairs() <config-schema_object-pairs>` to iterate over the schema nodes.
-   :ref:`set() <config-schema_object-set>` to assign configuration values.


.. _api-reference-config-utils-schema:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 45 55

        *   -   **Functions**
            -

        *   -   :ref:`schema.array() <config-utils-schema-array>`
            -   Create an array node

        *   -   :ref:`schema.enum() <config-utils-schema-enum>`
            -   Create an enum scalar node

        *   -   :ref:`schema.fromenv() <config-utils-schema-fromenv>`
            -   Parse a value from an environment variable

        *   -   :ref:`schema.map() <config-utils-schema-map>`
            -   Create a map node

        *   -   :ref:`schema.new() <config-utils-schema-new>`
            -   Create a schema

        *   -   :ref:`schema.record() <config-utils-schema-record>`
            -   Create a record node

        *   -   :ref:`schema.scalar() <config-utils-schema-scalar>`
            -   Create a scalar node

        *   -   :ref:`schema.set() <config-utils-schema-set>`
            -   Create a set array node

        *   -   **schema_object**
            -

        *   -   :ref:`schema_object:apply_default() <config-schema_object-apply_default>`
            -   Apply default values

        *   -   :ref:`schema_object:filter() <config-schema_object-filter>`
            -   Filter schema nodes

        *   -   :ref:`schema_object:get() <config-schema_object-get>`
            -   Get specified configuration data

        *   -   :ref:`schema_object:map() <config-schema_object-map>`
            -   Transform configuration data

        *   -   :ref:`schema_object:merge() <config-schema_object-merge>`
            -   Merge two configurations

        *   -   :ref:`schema_object:pairs() <config-schema_object-pairs>`
            -   Traverse a configuration

        *   -   :ref:`schema_object:set() <config-schema_object-set>`
            -   Set a configuration value

        *   -   :ref:`schema_object:validate() <config-schema_object-validate>`
            -   Validate a configuration against a schema

        *   -   :ref:`schema_object.methods <config-schema_object-methods>`
            -   User-defined methods

        *   -   :ref:`schema_object.name <config-schema_object-name>`
            -   Schema name

        *   -   :ref:`schema_object.schema <config-schema_object-schema>`
            -   Schema nodes hierarchy

        *   -   **schema_node_annotation**
            -

        *   -   :ref:`allowed_values <config-schema_node_annotation-allowed_values>`
            -   Allowed node values

        *   -   :ref:`apply_default_if <config-schema_node_annotation-apply_default_if>`
            -   Condition to apply defaults

        *   -   :ref:`default <config-schema_node_annotation-default>`
            -   Default node value

        *   -   :ref:`type <config-schema_node_annotation-type>`
            -   Value type

        *   -   :ref:`validate <config-schema_node_annotation-validate>`
            -   Validation function

        *   -   **schema_node_object**
            -

        *   -   :ref:`schema_node_object.allowed_values <config-schema_node_object-allowed_values>`
            -   Allowed node values

        *   -   :ref:`schema_node_object.apply_default_if <config-schema_node_object-apply_default_if>`
            -   Condition to apply defaults

        *   -   :ref:`schema_node_object.computed <config-schema_node_object-computed>`
            -   Computed annotations

        *   -   :ref:`schema_node_object.default <config-schema_node_object-default>`
            -   Default value

        *   -   :ref:`schema_node_object.fields <config-schema_node_object-fields>`
            -   Record node fields

        *   -   :ref:`schema_node_object.items <config-schema_node_object-items>`
            -   Array node items

        *   -   :ref:`schema_node_object.type <config-schema_node_object-type>`
            -   Scalar node type

        *   -   :ref:`schema_node_object.validate <config-schema_node_object-validate>`
            -   Validation function


..  _config-utils-schema_functions:

Functions
~~~~~~~~~

..  module:: config.utils.schema

..  _config-utils-schema-array:

..  function:: schema.array(array_def)

    Create an array node of a configuration schema.

    :param table array_def: a table in the following format:

                            ..  code-block:: text

                                {
                                    items = <schema_node_object>,
                                    <..annotations..>
                                }

                            See also: :ref:`schema_node_object <config-utils-schema_node_object>`, :ref:`schema_node_annotation <config-utils-schema_node_annotation>`.

    :return: the created array node as a table with the following fields:

             -   ``type``: ``array``
             -   ``items``: a table describing an array item as a schema node
             -   annotations, if provided in ``array_def``

    :rtype: table

    **See also:** :ref:`config_utils_schema_nodes_array`

..  _config-utils-schema-enum:

..  function:: schema.enum(allowed_values, annotations)

    A shortcut for creating a string scalar node with a limited set of allowed values.

    :param table allowed_values: a list of enum members -- values allowed for the node
    :param table annotations: annotations (see :ref:`schema_node_annotation <config-utils-schema_node_annotation>`)

    :return: the created scalar node as a table with the following fields:

            -   ``type``: ``string``
            -   ``allowed_values``: allowed node values
            -   annotations, if ``annotations`` is provided

    :rtype: table

    **See also:** :ref:`config_utils_schema_nodes_scalar`

..  _config-utils-schema-fromenv:

..  function:: schema.fromenv(env_var_name, raw_value, schema_node)

    Parse an environment variable as a value of the given schema node.
    The ``env_var_name`` parameter is used only for error messages.
    The value (``raw_value``) should be received using ``os.getenv()`` or ``os.environ()``.

    How the raw value is parsed depends on the ``schema_node`` type:

    -   Scalar:

        -   ``string``: return the value as is
        -   ``number`` or ``integer``: parse the value as a number or an integer
        -   ``string, number``: attempt to parse as a number; in case of a failure
            return the value as is
        -   ``boolean``: accept ``true`` and ``false`` (case-insensitively), or ``1``and ``0``
            for ``true`` and  ``false`` values correspondingly
        -   ``any``: parse the value as a JSON

    -   Map: parse either as JSON (if the raw value starts with ``{``)
        or as a comma-separated string of ``key=value`` pairs: ``key1=value1,key2=value2``
    -   Array: parse either as JSON (if the raw value starts with ``[``)
        or as a comma-separated string of items: ``item1,item2,item3``

    .. note::

        Parsing records from environment variables is not supported.

    :param string env_var_name: environment variable name to use for error messages
    :param string raw_value: environment variable value
    :param schema_node_object schema_node: a schema node (see :ref:`schema_node_object <config-utils-schema_node_object>`)

    :return: the parsed value
    :rtype: table

    **See also:** :ref:`config_utils_schema_env-vars`

..  _config-utils-schema-map:

..  function:: schema.map(map_def)

    Create a map node of a configuration schema.

    :param table map_def: a table in the following format:

                            ..  code-block:: text

                                {
                                    key = <schema_node_object>,
                                    value = <schema_node_object>,
                                    <..annotations..>
                                }

                          See also: :ref:`schema_node_object <config-utils-schema_node_object>`, :ref:`schema_node_annotation <config-utils-schema_node_annotation>`.

    :return: the created map node as a table with the following fields:

            -   ``type``: ``map``
            -   ``key``: map key type
            -   ``value``: map value type
            -   annotations, if provided in ``map_def``

    :rtype: table

    **See also:** :ref:`config_utils_schema_nodes_map`

..  _config-utils-schema-new:

..  function:: schema.new(schema_name, schema_node[, { methods = <...> }])

    Create a schema object.

    :param string schema_name: a name
    :param table schema_node: a root schema node
    :param table methods: methods

    :return: a new schema object (see :ref:`schema_object <config-utils-schema_object>`)
             as a table with the following fields:

                *   ``name``: the schema name
                *   ``schema``: a table with schema nodes
                *   ``methods``: a table with user-provided methods

    :rtype: table

    **See also:** :ref:`config_utils_schema_getting_started`

..  _config-utils-schema-record:

..  function:: schema.record(fields[, annotations])

    Create a record node of a configuration schema.

    :param table fields: a table of fields in the following format:

                         ..  code-block:: text

                             {
                                 [<field_name>] = <schema_node_object>,
                                 <...>
                             }

                         See also: :ref:`schema_node_object <config-utils-schema_node_object>`.

    :param table annotations: annotations (see :ref:`config_utils_schema_annotation`)

    :return: the created record node as a table with the following fields:

            -   ``type``: ``record``
            -   ``fields``: a table describing the record fields
            -   annotations, if provided

    :rtype: table

    **See also:** :ref:`config_utils_schema_nodes_record`

..  _config-utils-schema-scalar:

..  function:: schema.scalar(type[, annotations])

    Create a scalar node of a configuration schema.

    :param string type: data type (see :ref:`config_utils_schema_data_types`)
    :param table annotations: annotations (see :ref:`config_utils_schema_annotation`)

    :return: the created scalar node as a table with the following fields:

            -   ``type``: the node type (see :ref:`config_utils_schema_data_types`)
            -   annotations, if provided

    :rtype: table

    **See also:** :ref:`config_utils_schema_nodes_scalar`

..  _config-utils-schema-set:

..  function:: schema.set(allowed_values, annotations)

    Shortcut for creating an array node of unique string values from the given list of allowed values.

    :param table allowed_values: allowed values of array items
    :param table annotations: annotations (see :ref:`config_utils_schema_annotation`)

    :return: the created array node as a table with the following fields:

             -   ``type``: ``array``
             -   ``items``: a table describing an array item as a schema node
             -   ``validate``: an auto-generated validation function that check
                 that the values don't repeat
             -   annotations, if provided

    :rtype: table

    **See also:** :ref:`config_utils_schema_nodes_array`

..  _config-utils-schema_object:

schema_object
~~~~~~~~~~~~~

..  class:: schema_object

    ..  _config-schema_object-apply_default:

    ..  method:: apply_default(data)

        .. important::

            ``data`` is assumed to be validated against the given schema.

        Apply default values to scalar nodes. The functions takes the ``default``
        built-in annotation values of the scalar nodes and applies them based
        on the ``apply_default_if`` annotation. If there is no ``apply_default_if``
        annotation on a node, the default value is also applied.

        .. note::

            The method works for static defaults. To define a dynamic default value,
            use the :ref:`map() <config-schema_object-map>` method.

        :param any data: configuration data

        :return: configuration data with applied schema defaults

        **See also:** :ref:`default <config-schema_node_annotation-default>`, :ref:`apply_default_if <config-schema_node_annotation-apply_default_if>`

    ..  _config-schema_object-filter:

    ..  method:: filter(data, f)

        .. important::

            ``data`` is assumed to be validated against the given schema.

        Filter data based on the schema annotations. The method returns an iterator
        by configuration nodes for which the given filter function ``f`` returns ``true``.

        The filter function ``f`` receives the following table as the argument:

        .. code-block:: lua

            w = {
                path = <array-like table>,
                schema = <schema node>,
                data = <data at the given path>,
            }

        The filter function returns a boolean value that is interpreted as "accepted" or "not accepted".

        **Example:**

        Calling a function on all schema nodes that have the ``my_annotation``
        annotation defined:

        .. code-block:: lua

            s:filter(function(w)
                return w.schema.my_annotation ~= nil
            end):each(function(w)
                do_something(w.data)
            end)

        :param any data: configuration data
        :param function f: filter function

        :return: a luafun iterator

    ..  _config-schema_object-get:

    ..  method:: get(data, path)

        .. important::

            ``data`` is assumed to be validated against the given schema.

        Get nested configuration values at the given path. The path can be
        either a dot-separated string (``http.scheme``) or an array-like table (``{ 'http', 'scheme'}``).

        **Example:**

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
            :language: lua
            :start-at: local scheme
            :end-before: local host
            :dedent:

        :param any data: configuration data
        :param string/table path: path to the target node as:
                                  -   a string in the dot notation
                                  -   an array-like table


        :return: data at the given path

        **See also**: see :ref:`config_utils_schema_get_configuration`

    ..  _config-schema_object-map:

    ..  method:: map(data, f, f_ctx)

        .. important::

            ``data`` is assumed to be validated against the given schema.

        Transform data by the given function. The ``data`` fields are transformed
        by the function passed in the second argument (``f``), while its structure remains unchanged.

        The transformation function takes three arguments:

        -   ``data`` -- the configuration data
        -   ``w`` -- *walkthrough node* with the following fields:

            -   ``w.schema`` -- schema node
            -   ``w.path`` -- the path to the schema node
            -   ``w.error()`` -- a function for printing human-readable error messages

        -   ``ctx`` -- additional *context* for the transformation function. Can be
            used to provide values for a specific call.

        An example of the transformation function:

        .. code-block:: lua

            local function f(data, w, ctx)
                if w.schema.type == 'string' and data ~= nil then
                    return data:gsub('{{ *foo *}}', ctx.foo)
                end
                return data
            end

        The ``map()`` method traverses all fields of the schema records,
        even if they are ``nil`` or ``box.NULL`` in the provided configuration.
        This allows using this method to set computed default values for missing
        fields. Note that this is not the case for maps and arrays since the schema
        doesn't define their fields to traverse.

        :param any data: configuration data
        :param function f: transformation function
        :param any f_ctx: user-provided context for the transformation function

        :return: transformed configuration data

    ..  _config-schema_object-merge:

    ..  method:: merge(data_a, data_b)

        .. important::

            ``data`` is assumed to be validated against the given schema.

        Merge two configurations. The method merges configurations in a single
        node hierarchy, preferring the latter in case of a collision.

        The following merge rules are used:

        -   any present value is preferred over ``nil`` and ``box.NULL``
        -   ``box.NULL`` is preferred over ``nil``
        -   for scalar and array nodes, the right-hand value is used

            .. note::

                -   Scalars of the ``any`` type are merged the same way as other scalars.
                    They are not deeply merged even if they are tables.
                -   Arrays are not concatenated. Left hand array items are discarded.

        -   records and maps are deeply merged, that is, the merge is performed
            recursively for their nested nodes

        :param any a: configuration data
        :param any b: configuration data

        :return: merged configuration data

    ..  _config-schema_object-pairs:

    ..  method:: pairs()

        Walk over the schema and return scalar, array, and map schema nodes

        .. important::

            The method doesn't return record nodes.

        :return: a luafun iterator

        **Example:**

        .. code-block:: lua

            for _, w in schema:pairs() do
                local path = w.path
                local schema = w.schema
                -- <...>
            end

    ..  _config-schema_object-set:

    ..  method:: set(data, path, value)

        .. important::

            ``data`` is assumed to be validated against the given schema.
            ``value`` is validated by the method before the assignment.

        Set a given value at the given path in a configuration.
        The path can be either a dot-separated string (``http.scheme``) or
        an array-like table (``{ 'http', 'scheme'}``).

        :param any data: configuration data
        :param string/table path: path to the target node as:
                                  -   a string in the dot notation
                                  -   an array-like table
        :param any value: new value

        :return: updated configuration data

        **Example:** see :ref:`config_utils_schema_env-vars`

    ..  _config-schema_object-validate:

    ..  method:: validate(data)

        Validate data against the schema. If the data doesn't adhere to the schema,
        an error is raised.

        The method performs the following checks:

        -   field type checks: field values are checked against the schema node types
        -   allowed values: if a node has the ``allowed_values`` annotations of schema nodes,
            the corresponding data field is checked against the allowed values list
        -   validation functions: if a validation function is defined for a node
            (the ``validate`` annotation), it is executed to check that the provided value is valid.

        :param any data: data

        **Example:** see :ref:`config_utils_schema_annotation` and
        :ref:`config_utils_schema_validating_configuration`

        **See also:** :ref:`allowed_values <config-schema_node_annotation-allowed_values>`,
        :ref:`validate <config-schema_node_annotation-validate>`

    ..  _config-schema_object-methods:

    ..  data:: methods

        User-defined methods in the schema.

        **See also:** :ref:`config_utils_schema_methods`

    ..  _config-schema_object-name:

    ..  data:: name

        Schema name.

    ..  _config-schema_object-schema:

    ..  data:: schema

        Schema nodes hierarchy.

        **See also:** :ref:`config-utils-schema_node_object`


..  _config-utils-schema_node_annotation:

schema_node_annotation
~~~~~~~~~~~~~~~~~~~~~~

The following elements of tables passed as node constructor arguments are
parsed by the modules as :ref:`built-in annotations <config_utils_schema_built_in_annotations>`:

..  _config-schema_node_annotation-allowed_values:

-   ``allowed_values``

    A list of allowed values for a node.

    **See also:** :ref:`schema_object:validate() <config-schema_object-validate>`


..  _config-schema_node_annotation-apply_default_if:

-   ``apply_default_if``

    A boolean function that defines whether to apply the default value specified
    using ``default``. If this function returns ``true`` on a provided configuration data,
    the node receives the default value upon the :ref:`schema_object.apply_default() <config-schema_object-apply_default>`
    method call.

    The function takes two arguments:

    -   ``data`` -- the configuration data
    -   ``w`` -- *walkthrough node* with the following fields:

        -   ``w.schema`` -- schema node
        -   ``w.path`` -- the path to the schema node
        -   ``w.error()`` -- a function for printing human-readable error messages

    **See also:** :ref:`schema_object:apply_default() <config-schema_object-apply_default>`

..  _config-schema_node_annotation-default:

-   ``default``

    A default value to use for a scalar node if it's not specified explicitly.

    **Example:** see :ref:`config_utils_schema_transform_configuration`

    **See also:** :ref:`schema_object:apply_default() <config-schema_object-apply_default>`

..  _config-schema_node_annotation-type:

-   ``type``

    A schema node type.

    **See also:** :ref:`config_utils_schema_data_types`

..  _config-schema_node_annotation-validate:

-   ``validate``

    A function used to validate node data. The function must raise an error to
    fail the check. The function is called upon the :ref:`schema_object:validate() <config-schema_object-validate>`
    function calls.

    The function takes two arguments:

    -   ``data`` -- the configuration data
    -   ``w`` -- *walkthrough node* with the following fields:

        -   ``w.schema`` -- schema node
        -   ``w.path`` -- the path to the schema node
        -   ``w.error()`` -- a function for printing human-readable error messages

    **Example:**

    A function that checks that a string a valid IP address:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
        :language: lua
        :start-at: local function validate_host
        :end-before: local function validate_port
        :dedent:

    **See also:** :ref:`schema_object:validate() <config-schema_object-validate>`

..  _config-utils-schema_node_object:

schema_node_object
~~~~~~~~~~~~~~~~~~

..  class:: schema_node_object

    ..  _config-schema_node_object-allowed_values:

    ..  data:: allowed_values

        A list of values allowed for the node. The values are taken from the
        :ref:`allowed_values <config-schema_node_annotation-allowed_values>` node annotation.

    ..  _config-schema_node_object-apply_default_if:

    ..  data:: apply_default_if

        A function to define when to apply the default node value. The value
        is taken from the :ref:`apply_default_if <config-schema_node_annotation-apply_default_if>` annotation.

    ..  _config-schema_node_object-computed:

    ..  data:: computed

        ``computed.annotations`` stores the node's :ref:`computed annotations <config_utils_schema_computed_annotations>`.

    ..  _config-schema_node_object-default:

    ..  data:: default

        Node's default value. The value
        is taken from the :ref:`default <config-schema_node_annotation-default>` annotation.

    ..  _config-schema_node_object-fields:

    ..  data:: fields

        Child nodes for record nodes.
        See also :ref:`config_utils_schema_nodes_record`.

    ..  _config-schema_node_object-items:

    ..  data:: items

        Node items for array nodes.
        See also :ref:`config_utils_schema_nodes_array`

    ..  _config-schema_node_object-type:

    ..  data:: type

        Node type for scalar nodes. See :ref:`config_utils_schema_data_types`

    ..  _config-schema_node_object-validate:

    ..  data:: validate

        Node value validation function. The value
        is taken from the :ref:`validate <config-schema_node_annotation-validate>` annotation.

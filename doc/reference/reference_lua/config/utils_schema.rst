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

3.  Use the :ref:`schema.validate() <config-utils-schema-validate>` function to
    validate configuration values against the schema. In case of a role, call this
    function inside the role's :ref:`validate() <roles_create_custom_role_validate>` function:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local function validate
        :end-before: local function apply
        :dedent:

4.  Obtain values of configuration options using :ref:`schema.get() <config-utils-schema-get>`.
    In case of a role, call it inside the role's :ref:`apply() <roles_create_custom_role_apply>` function:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local function apply
        :end-before: local function stop
        :dedent:


.. _config_utils_schema_definition:

Defining a schema
-----------------

An application's or a role's *configuration schema* is a core object that stores all
information about a user-defined configuration. To create a schema, use
the :ref:`schema.new() <config-utils-schema-new>` function. It has the following options:

-   schema name -- an arbitrary string
-   schema node -- th

    -   scalar and composite (record, array, map) types
    -   annotations (type, validate, and so on)

-   (optional) methods

.. _config_utils_schema_nodes:

Schema nodes
~~~~~~~~~~~~

Schema nodes can have one of two types: *scalar* or *composite*.
.. _config_utils_schema_scalar_composite_types:

Scalar and composite types
**************************

There are scalar and composite types.

-   Scalar type.
    Can be created using ``schema.scalar()``.
    There is also a shortcut: :ref:`schema.enum() <config-utils-schema-enum>`.
    Learn more about supported data types: :ref:`config_utils_schema_data_types`.
-   Composite data types: record, array, map.
    Can be created using :ref:`schema.record() <config-utils-schema-record>`, :ref:`schema.array() <config-utils-schema-array>`, :ref:`schema.map() <config-utils-schema-map>`.
    There is also a shortcut for arrays: :ref:`schema.set() <config-utils-schema-set>`.


.. _config_utils_schema_nodes_scalar:

Scalar nodes
************

Scalar nodes hold a single value of a primitive type: a string, a number, a boolean value
and so on. For the full list of available scalar types, see :ref:`config_utils_schema_data_types`.

This configuration has one scalar node of the ``string`` type:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To define a scalar node in a schema, use :ref:`schema.scalar() <config-utils-schema-scalar>`:
The following code defines a configuration schema shown above:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
    :language: lua
    :start-at: local http_api_schema
    :end-before: local function validate
    :dedent:

Todo: enum?
allowed?

.. _config_utils_schema_nodes_record:

Records
*******

*Record* is a composite node that includes a predefined set of other nodes, scalar
or composite. The names and types of fields in a record are determined by the schema.

In YAML, a record is represented as a node with nested fields.
For example, the following configuration has a record node ``http_api`` with
three scalar fields:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

The following schema describes this configuration:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

.. note::

    Note the use of the :ref:`schema.enum() <config-utils-schema-enum>` function.
    It defines a scalar node with a limited set of allowed values.

Records are also used to define nested schema nodes of non-primitive types. In the example
below, the ``http_api`` node holds a single composite object -- ``listen_address``.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To create a record node in a schema, use :ref:`schema.record() <config-utils-schema-record>`.
The following schema describes this configuration:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

TODO: This sample can be used in the ``Processing configuration data`` section.


.. _config_utils_schema_nodes_array:

Array
*****

*Array* is a composite node type that includes a collection of items of the same
type. The type can be either primitive or complex.

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
creating arrays with a limited set of item values.

.. _config_utils_schema_nodes_map:

Map
***

*Map* is a composite node type that includes key-value pairs with arbitrary values
of predefined types.

In YAML, a map is represented as a node with nested fields.
For example, the following configuration has a map node ``endpoints`` with
three items:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_map/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

To create a map node in a schema, use :ref:`schema.map() <config-utils-schema-map>`.
The following schema describes this configuration:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_map/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:


.. _config_utils_schema_data_types:

Data types
**********

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

        *   -   ``any``
            -   Arbitrary Lua value
            -   May be used to declare an arbitrary value that doesn't need validation.

        *   -   |``string, number``
                | or
                |``number, string``
            -   ``string`` or ``number``
            -

.. _config_utils_schema_annotation:

Annotations
***********

Each scalar node is defined by a set of *annotations* -- attributes that set its
parameters: type, default value, validation function, etc

Annotations are passed as schema.scalar argument rows

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: host
    :end-before: port
    :dedent:

Node annotations fall into three groups:

-   Built-in annotations handled by the module (``validate``, ``allowed_values``, ``default``, ``apply_default_if``). Note that ``validate``, ``allowed_values`` used for validation only. ``default`` and ``apply_default_if`` can transform the configuration.
-   User-defined annotations
-   Computed annotations

.. _config_utils_schema_built_in_annotations:

Built-in annotations
^^^^^^^^^^^^^^^^^^^^

TODO: check the ``Built-in annotation`` term.

Built-in annotations are interpreted by the module itself. There are the following
built-in annotations:

-

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

In the example below, the user-defined ``env`` annotation is used to provide names
of environment variables that can store values of configuration options:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_fromenv/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function collect_env_cfg
    :dedent:

See the full sample here: :ref:`config_utils_schema_env-vars`.


.. _config_utils_schema_computed_annotations:

Computed annotations
^^^^^^^^^^^^^^^^^^^^

*Computed annotations* enable access to schema data

In the example below, the validate function of the listen_address record
uses computed annotation to access the schema data from outside the record:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local listen_address
    :end-before: local http_listen_address_schema
    :dedent:

The following schema with listen_address passes the validation:
Passes validation:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local http_listen_address_schema
    :end-before: local iproto_listen_address_schema
    :dedent:

If this record is added to a schema with ``protocol = 'iproto'``, an error is raised:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local iproto_listen_address_schema
    :end-before: local function validate
    :dedent:



.. _config_utils_schema_methods:

User-defined methods
~~~~~~~~~~~~~~~~~~~~

In addition to nodes, a schema can include *methods*. Methods are user-defined
functions that can be called on this schema.

For example, this schema has a method that returns its fields merged in a URI string:

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

The schema object's :ref:`validate() <config-schema_object-validate>` function performs all the necessary checks
on the provided configuration. It validates the configuration structure, node types, allowed values,
and other aspects defines in the schema.

When writing roles, call this function inside the :ref:`role validation function <roles_create_custom_role_validate>`:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local function validate
    :end-before: local function apply
    :dedent:


.. _config_utils_schema_get_configuration:

Getting configuration values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get configuration values, use the schema's :ref:`get() <config-schema_object-get>` method.
The function takes the configuration and the full path to the node as arguments:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local function apply
    :end-before: local function stop
    :dedent:



.. _config_utils_schema_transform_configuration:

Transforming configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO: filter, merge, map, apply_default ?

Example with ``apply_default()``:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: local function apply
    :end-before: local function stop
    :dedent:



.. _config_utils_schema_env-vars:

Parsing environment variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The :ref:`schema.fromenv() <config-utils-schema-fromenv>` allows getting configuration
values from environment variables. The example below shows how to do this by
adding a user-defined annotation ``env``:

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
            -   Define an array

        *   -   :ref:`schema.enum() <config-utils-schema-enum>`
            -   Create an enum

        *   -   :ref:`schema.fromenv() <config-utils-schema-fromenv>`
            -   Parse a value from an environment variable

        *   -   :ref:`schema.map() <config-utils-schema-map>`
            -   Create a map

        *   -   :ref:`schema.new() <config-utils-schema-new>`
            -   Create a schema

        *   -   :ref:`schema.record() <config-utils-schema-record>`
            -   Create a record

        *   -   :ref:`schema.scalar() <config-utils-schema-scalar>`
            -   Create a scalar

        *   -   :ref:`schema.set() <config-utils-schema-set>`
            -   Define a set

        *   -   **schema_object**
            -

        *   -   :ref:`schema_object:apply_default() <config-schema_object-apply_default>`
            -   TODO

        *   -   :ref:`schema_object:filter() <config-schema_object-filter>`
            -   TODO

        *   -   :ref:`schema_object:get() <config-schema_object-get>`
            -   TODO

        *   -   :ref:`schema_object:map() <config-schema_object-map>`
            -   TODO

        *   -   :ref:`schema_object:merge() <config-schema_object-merge>`
            -   TODO

        *   -   :ref:`schema_object:pairs() <config-schema_object-pairs>`
            -   TODO

        *   -   :ref:`schema_object:set() <config-schema_object-set>`
            -   TODO

        *   -   :ref:`schema_object:validate() <config-schema_object-validate>`
            -   TODO

        *   -   :ref:`schema_object.methods <config-schema_object-methods>`
            -   TODO

        *   -   :ref:`schema_object.name <config-schema_object-name>`
            -   TODO

        *   -   :ref:`schema_object.schema <config-schema_object-schema>`
            -   TODO

        *   -   **schema_node_annotation**
            -

        *   -   :ref:`allowed_values <config-schema_node_annotation-allowed_values>`
            -   TODO

        *   -   :ref:`apply_default_if <config-schema_node_annotation-apply_default_if>`
            -   TODO

        *   -   :ref:`default <config-schema_node_annotation-default>`
            -   TODO

        *   -   :ref:`type <config-schema_node_annotation-type>`
            -   TODO

        *   -   :ref:`validate <config-schema_node_annotation-validate>`
            -   TODO

        *   -   **schema_node_object**
            -

        *   -   :ref:`schema_node_object.allowed_values <config-schema_node_object-allowed_values>`
            -   TODO

        *   -   :ref:`schema_node_object.apply_default_if <config-schema_node_object-apply_default_if>`
            -   TODO

        *   -   :ref:`schema_node_object.computed <config-schema_node_object-computed>`
            -   TODO

        *   -   :ref:`schema_node_object.default <config-schema_node_object-default>`
            -   TODO

        *   -   :ref:`schema_node_object.fields <config-schema_node_object-fields>`
            -   TODO

        *   -   :ref:`schema_node_object.items <config-schema_node_object-items>`
            -   TODO

        *   -   :ref:`schema_node_object.type <config-schema_node_object-type>`
            -   TODO

        *   -   :ref:`schema_node_object.validate <config-schema_node_object-validate>`
            -   TODO


..  _config-utils-schema_functions:

Functions
~~~~~~~~~

..  module:: config.utils.schema

..  _config-utils-schema-array:

..  function:: schema.array(opts)

    Define an array.

    :param table opts: a table in the following format:

                       ..  code-block:: text

                           { items = <schema_node_object>, <..annotations..> }

                       See also: :ref:`schema_node_object <config-utils-schema_node_object>`, :ref:`schema_node_annotation <config-utils-schema_node_annotation>`.

..  _config-utils-schema-enum:

..  function:: schema.enum(allowed_values, annotations)

    Create an enum.

    :param table allowed_values: allowed values
    :param table annotations: annotations (see :ref:`schema_node_annotation <config-utils-schema_node_annotation>`)

..  _config-utils-schema-fromenv:

..  function:: schema.fromenv(env_var_name, raw_value, schema_node)

    Parse data from an environment variable as a value of the given type.

    :param string env_var_name: env var name
    :param string raw_value: raw value
    :param schema_node_object schema_node: a schema node (see :ref:`schema_node_object <config-utils-schema_node_object>`)


..  _config-utils-schema-map:

..  function:: schema.map(opts)

    Create a map.

    :param table opts: a table in the following format:

                       ..  code-block:: text

                           { key = <schema_node_object>, value = <schema_node_object>, <..annotations..> }

                       See also: :ref:`schema_node_object <config-utils-schema_node_object>`, :ref:`schema_node_annotation <config-utils-schema_node_annotation>`.

    :return: a table that represents the created schema node
    :rtype: table

..  _config-utils-schema-new:

..  function:: schema.new(schema_name, schema_node[, { methods = <...> }])

    Create a schema object.

    :param string schema_name: a name
    :param table schema_node: a node
    :param table methods: methods

    :return: a new schema instance (see :ref:`schema_object <config-utils-schema_object>`)
    :rtype: userdata


..  _config-utils-schema-record:

..  function:: schema.record(fields[, annotations])

    Create a record.

    :param table fields: a table of fields in the following format:

                         ..  code-block:: text

                             { [<field_name>] = <schema_node_object>, <...> }

                         See also: :ref:`schema_node_object <config-utils-schema_node_object>`.

    :param table annotations: annotations (see :ref:`config_utils_schema_annotation`)

    :return: a table that represents the created schema node
    :rtype: table


..  _config-utils-schema-scalar:

..  function:: schema.scalar(type[, annotations])

    Create a scalar.

    :param string type: data type (see :ref:`config_utils_schema_data_types`)
    :param table annotations: annotations (see :ref:`config_utils_schema_annotation`)

    :return: a table that represents the created schema node
    :rtype: table

..  _config-utils-schema-set:

..  function:: schema.set(allowed_values, annotations)

    Shortcut for array of unique string values from the given list of allowed values.

    :param table allowed_values: allowed values
    :param table annotations: annotations (see :ref:`config_utils_schema_annotation`)

    :return: a table that represents the created schema node
    :rtype: table


..  _config-utils-schema_object:

schema_object
~~~~~~~~~~~~~

..  class:: schema_object

    ..  _config-schema_object-apply_default:

    ..  method:: apply_default(data)

        Apply default values.

        :param any data: data

        :return: new data

    ..  _config-schema_object-filter:

    ..  method:: filter(data, f)

        Filter data based on the schema annotations.

        :return: a luafun iterator

    ..  _config-schema_object-get:

    ..  method:: get(data, path)

        Get nested data that is pointed by the given path.

        Example: see :ref:`config_utils_schema_get_configuration`

    ..  _config-schema_object-map:

    ..  method:: map(data, f, f_ctx)

        Transform data by the given function.

        :param any data: value at the given path
        :param any f: walkthrough node, described below
        :param any f_ctx: user-provided context for the transformation function

    ..  _config-schema_object-merge:

    ..  method:: merge(a, b)

        Merge two hierarchical values (prefer the latter).

        :param any a: data
        :param any b: data

        :return: new data

    ..  _config-schema_object-pairs:

    ..  method:: pairs()

        Traverse the schema.

        :return: a luafun iterator

    ..  _config-schema_object-set:

    ..  method:: set()

        TODO

    ..  _config-schema_object-methods:

    ..  _config-schema_object-validate:

    ..  method:: validate(data)

        Validate data against the schema.
        ``validate()`` raises an error if the specified data doesn't adhere this schema.

        :param any data: data

        Example: see :ref:`config_utils_schema_annotation`

    ..  data:: methods

        TODO

    ..  _config-schema_object-name:

    ..  data:: name

        TODO

    ..  _config-schema_object-schema:

    ..  data:: schema

        TODO, see also ``schema_node_object``





..  _config-utils-schema_node_annotation:

schema_node_annotation
~~~~~~~~~~~~~~~~~~~~~~

..  _config-schema_node_annotation-allowed_values:

-   ``allowed_values``

    A list of allowed values.

..  _config-schema_node_annotation-apply_default_if:

-   ``apply_default_if``

    A function that specifies whether to apply the default value specified using ``default``.

..  _config-schema_node_annotation-default:

-   ``default``

    The value to be placed instead of a missed one.

..  _config-schema_node_annotation-type:

-   ``type``

    A value type. See :ref:`config_utils_schema_data_types`.

..  _config-schema_node_annotation-validate:

-   ``validate``

    A function used to validate data.


..  _config-utils-schema_node_object:

schema_node_object
~~~~~~~~~~~~~~~~~~

..  class:: schema_node_object

    ..  _config-schema_node_object-allowed_values:

    ..  data:: allowed_values

        TODO

    ..  _config-schema_node_object-apply_default_if:

    ..  data:: apply_default_if

        TODO

    ..  _config-schema_node_object-computed:

    ..  data:: computed

        TODO (for example, ``computed.annotations``)

    ..  _config-schema_node_object-default:

    ..  data:: default

        TODO

    ..  _config-schema_node_object-fields:

    ..  data:: fields

        TODO

    ..  _config-schema_node_object-items:

    ..  data:: items

        TODO

    ..  _config-schema_node_object-type:

    ..  data:: type

        TODO

    ..  _config-schema_node_object-validate:

    ..  data:: validate

        TODO

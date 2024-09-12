..  _config_utils_schema_module:

Submodule experimental.config.utils.schema
==========================================

**Since:** :doc:`3.2.0 </release/3.2.0>`

Tarantool allows you to provide arbitrary configurations for cluster applications:

-   For applications loaded using the :ref:`app <configuration_reference_app>` option, :ref:`app.cfg <configuration_reference_app_cfg>` is used to provide a configuration.
-   For :ref:`custom roles <application_roles>` developed as a part of a cluster application, :ref:`roles_cfg <configuration_reference_roles_cfg>` is used.

The ``experimental.config.utils.schema`` module can be used to validate such configurations and process their data: get and set configuration values, filter and transform configuration data, and so on.

..  important::

    ``experimental.config.utils.schema`` is an experimental submodule and is subject to changes.




.. _config_utils_schema_getting_started:

Getting started with config.utils.schema
----------------------------------------

Example config - scalar type:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

1.  Load the module:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: config.utils.schema
        :end-at: config.utils.schema
        :dedent:

2.  Define a schema using :ref:`schema.new() <config-utils-schema-new>`.
    Example enum:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local http_api_schema
        :end-before: local function validate
        :dedent:

3.  Validate config values using ``config.utils.schema.validate()``.
    For a role, inside the ``validate()`` func:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local function validate
        :end-before: local function apply
        :dedent:

4.  Get value. For a role, inside the ``apply()`` func:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
        :language: lua
        :start-at: local function apply
        :end-before: local function stop
        :dedent:



.. _config_utils_schema_definition:

Defining a schema
-----------------

Create using :ref:`schema.new() <config-utils-schema-new>`. Options:

-   schema name
-   schema node:

    -   scalar and composite (record, array, map) types
    -   annotations (type, validate, and so on)

-   (optional) methods

.. _config_utils_schema_nodes:

Schema nodes
~~~~~~~~~~~~

.. _config_utils_schema_scalar_composite_types:

Scalar and composite types
**************************

There are scalar and composite types.

-   :ref:`schema.scalar() <config-utils-schema-scalar>`
-   :ref:`schema.record() <config-utils-schema-record>`
-   :ref:`schema.map() <config-utils-schema-map>`
-   :ref:`schema.array() <config-utils-schema-array>`

Shortcuts:

-   :ref:`schema.enum() <config-utils-schema-enum>`
-   :ref:`schema.set() <config-utils-schema-set>`

.. _config_utils_schema_type_system_scalar:

Scalar
^^^^^^

:ref:`schema.scalar() <config-utils-schema-scalar>`

Example config - scalar type:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema definition:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_scalar/http_api.lua
    :language: lua
    :start-at: local http_api_schema
    :end-before: local function validate
    :dedent:

See also: :ref:`config_utils_schema_data_types`.



.. _record:

Record
^^^^^^

Example config:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:


Example config 2 (nested fields inside ``listen_address``):

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

TODO: This sample can be used in the ``Processing configuration data`` section.



.. _array_record:

Array
^^^^^

Also: :ref:`schema.set() <config-utils-schema-set>`

Example config:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_array/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_array/http-api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

.. _record_map:

Map
^^^

Example config:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_map/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_map/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:


.. _config_utils_schema_data_types:

Data types
**********

Supported types:

-   ``string`` -- ``string``
-   ``number`` -- ``number``
-   ``integer``	-- ``number``
-   ``boolean``	-- ``boolean``
-   ``any``	-  any accepts an arbitrary Lua type, including ``table``. A scalar of the ``any`` type may be used to declare an arbitrary value that doesn't need any validation.
-   ``string, number`` -- ``string`` or ``number``
-   ``number, string`` -- ``string`` or ``string``




.. _config_utils_schema_annotation:

Annotations
***********

Example config:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema definition (``validate``, ``allowed_values``, ``default``):

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

Validate functions:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_annotations/http_api.lua
    :language: lua
    :start-at: local function validate_host
    :end-before: local listen_address_schema
    :dedent:




.. _config_utils_schema_user_defined_annotations:

User-defined annotations
^^^^^^^^^^^^^^^^^^^^^^^^

The ``env`` annotation:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_fromenv/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function collect_env_cfg
    :dedent:

See the full sample here: :ref:`config_utils_schema_env-vars`.


.. _config_utils_schema_computed_annotations:

Computed annotations
^^^^^^^^^^^^^^^^^^^^

Schema node:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local listen_address
    :end-before: local http_listen_address_schema
    :dedent:

Passes validation:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local http_listen_address_schema
    :end-before: local iproto_listen_address_schema
    :dedent:

Raises an error:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_computed_annotations/api.lua
    :language: lua
    :start-at: local iproto_listen_address_schema
    :end-before: local function validate
    :dedent:



.. _config_utils_schema_methods:

User-defined methods
~~~~~~~~~~~~~~~~~~~~

Example config:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_methods/config.yaml
    :language: yaml
    :start-at: roles
    :dedent:

Schema:

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

Role -- inside the ``validate()`` function:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_nodes_record_hierarchy/http_api.lua
    :language: lua
    :start-at: local function validate
    :end-before: local function apply
    :dedent:


.. _config_utils_schema_get_configuration:

Getting configuration values
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Using :ref:`schema.fromenv() <config-utils-schema-fromenv>`:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/config_schema_fromenv/http_api.lua
    :language: lua
    :start-at: local listen_address_schema
    :end-before: local function validate
    :dedent:

Other API members:

-   Custom annotation (``env``)
-   ``pairs()``
-   ``set()``



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
            -   TODO

        *   -   :ref:`schema.enum() <config-utils-schema-enum>`
            -   TODO

        *   -   :ref:`schema.fromenv() <config-utils-schema-fromenv>`
            -   TODO

        *   -   :ref:`schema.map() <config-utils-schema-map>`
            -   TODO

        *   -   :ref:`schema.new() <config-utils-schema-new>`
            -   TODO

        *   -   :ref:`schema.record() <config-utils-schema-record>`
            -   TODO

        *   -   :ref:`schema.scalar() <config-utils-schema-scalar>`
            -   TODO

        *   -   :ref:`schema.set() <config-utils-schema-set>`
            -   TODO

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

        *   -   :ref:`schema_node_object.computed.annotations <config-schema_node_object-computed-annotations>`
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

        TODO





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

    ..  _config-schema_node_object-computed-annotations:

    ..  data:: computed.annotations

        TODO

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

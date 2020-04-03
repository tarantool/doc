.. _json-module:

-------------------------------------------------------------------------------
                          Module `json`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``json`` module provides JSON manipulation routines. It is based on the
`Lua-CJSON module by Mark Pulford <http://www.kyne.com.au/~mark/software/lua-cjson.php>`_.
For a complete manual on Lua-CJSON please read
`the official documentation <http://www.kyne.com.au/~mark/software/lua-cjson-manual.html>`_.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``json`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`json.encode()                  | Convert a Lua object to a JSON  |
    | <json-encode>`                       | string                          |
    +--------------------------------------+---------------------------------+
    | :ref:`json.decode()                  | Convert a JSON string to a Lua  |
    | <json-decode>`                       | object                          |
    +--------------------------------------+---------------------------------+
    | :ref:`__serialize parameter          | Output structure specification  |
    | <json-serialize>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`json.cfg()                     | Change configuration            |
    | <json-module_cfg>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`json.NULL                      | Analog of Lua's "nil"           |
    | <json-null>`                         |                                 |
    +--------------------------------------+---------------------------------+

.. module:: json

.. _json-encode:

.. function:: encode(lua-value [, configuration])

    Convert a Lua object to a JSON string.

    :param lua_value: either a scalar value or a Lua table value.
    :param configuration: see :ref:`json.cfg <json-module_cfg>`
    :return: the original value reformatted as a JSON string.
    :rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> json=require('json')
        ---
        ...
        tarantool> json.encode(123)
        ---
        - '123'
        ...
        tarantool> json.encode({123})
        ---
        - '[123]'
        ...
        tarantool> json.encode({123, 234, 345})
        ---
        - '[123,234,345]'
        ...
        tarantool> json.encode({abc = 234, cde = 345})
        ---
        - '{"cde":345,"abc":234}'
        ...
        tarantool> json.encode({hello = {'world'}})
        ---
        - '{"hello":["world"]}'
        ...

.. _json-decode:

.. function:: decode(string [,configuration])

    Convert a JSON string to a Lua object.

    :param string string: a string formatted as JSON.
    :param configuration: see :ref:`json.cfg <json-module_cfg>`
    :return: the original contents formatted as a Lua table.
    :rtype: table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> json = require('json')
        ---
        ...
        tarantool> json.decode('123')
        ---
        - 123
        ...
        tarantool> json.decode('[123, "hello"]')
        ---
        - [123, 'hello']
        ...
        tarantool> json.decode('{"hello": "world"}').hello
        ---
        - world
        ...

    See the tutorial
    :ref:`Sum a JSON field for all tuples <c_lua_tutorial-sum_a_json_field>`
    to see how ``json.decode()`` can fit in an application.

.. _json-serialize:

**__serialize parameter:**

The JSON output structure can be specified with ``__serialize``:

* 'seq', 'sequence', 'array' - table encoded as an array
* 'map', 'mapping' - table encoded as a map
* function - the meta-method called to unpack serializable representation
  of table, cdata or userdata objects

Serializing 'A' and 'B' with different ``__serialize`` values brings different
results:

.. code-block:: tarantoolsession

    tarantool> json.encode(setmetatable({'A', 'B'}, { __serialize="seq"}))
    ---
    - '["A","B"]'
    ...
    tarantool> json.encode(setmetatable({'A', 'B'}, { __serialize="map"}))
    ---
    - '{"1":"A","2":"B"}'
    ...
    tarantool> json.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="map"})})
    ---
    - '[{"f2":"B","f1":"A"}]'
    ...
    tarantool> json.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="seq"})})
    ---
    - '[[]]'
    ...

.. _json-module_cfg:

.. function:: cfg(table)

    Set values that affect the behavior of :ref:`json.encode <json-encode>`
    and :ref:`json.decode <json-decode>`.

    The values are all either integers or boolean ``true``/``false``.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: center-align-column-2
        .. rst-class:: left-align-column-3

        +---------------------------------+---------+--------------------------------------------+
        | Option                          | Default | Use                                        |
        +=================================+=========+============================================+
        | ``cfg.encode_max_depth``        |   128   | Max recursion depth for encoding           |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_deep_as_nil``      |  false  | A flag saying whether to crop tables       |
        |                                 |         | with nesting level deeper than             | 
        |                                 |         | ``cfg.encode_max_depth``.                  |
        |                                 |         | Not-encoded fields are replaced with       |
        |                                 |         | one null. If not set, too deep             |
        |                                 |         | nesting is considered an error.            |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_invalid_numbers``  |  true   | A flag saying whether to enable encoding   |
        |                                 |         | of NaN and Inf numbers                     |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_number_precision`` | 14      | Precision of floating point numbers        |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_load_metatables``  | true    | A flag saying whether the serializer will  |
        |                                 |         | follow :ref:`__serialize <json-serialize>` |
        |                                 |         | metatable field                            |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_use_tostring``     | false   | A flag saying whether to use               |
        |                                 |         | ``tostring()`` for unknown types           |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_invalid_as_nil``   |  false  | A flag saying whether use NULL for         |
        |                                 |         | non-recognized types                       |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_sparse_convert``   | true    | A flag saying whether to handle            |
        |                                 |         | excessively sparse arrays as maps.         |
        |                                 |         | See detailed description                   |
        |                                 |         | :ref:`below <json-module_cfg_sparse>`.     |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_sparse_ratio``     |  2      | 1/``encode_sparse_ratio`` is the           |
        |                                 |         | permissible percentage of missing values   |
        |                                 |         | in a sparse array.                         |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_sparse_safe``      | 10      | A limit ensuring that small Lua arrays     |
        |                                 |         | are always encoded as sparse arrays        |
        |                                 |         | (instead of generating an error or         |
        |                                 |         | encoding as a map)                         |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.decode_invalid_numbers``  |  true   | A flag saying whether to enable decoding   |
        |                                 |         | of NaN and Inf numbers                     |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.decode_save_metatables``  |  true   | A flag saying whether to set metatables    |
        |                                 |         | for all arrays and maps                    |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.decode_max_depth``        |  128    | Max recursion depth for decoding           |
        +---------------------------------+---------+--------------------------------------------+

    .. _json-module_cfg_sparse:

**Sparse arrays features:**

During encoding, the JSON encoder tries to classify a table into one of four kinds:

* map - at least one table index is not unsigned integer
* regular array - all array indexes are available
* sparse array - at least one array index is missing
* excessively sparse array - the number of values missing exceeds the configured ratio

An array is excessively sparse when **all** the following conditions are met:

* ``encode_sparse_ratio`` > 0
* ``max(table)`` > ``encode_sparse_safe``
* ``max(table)`` > ``count(table)`` * ``encode_sparse_ratio``

The JSON encoder will never consider an array to be excessively sparse
when ``encode_sparse_ratio = 0``. The ``encode_sparse_safe`` limit ensures
that small Lua arrays are always encoded as sparse arrays.
By default, attempting to encode an excessively sparse array will
generate an error. If ``encode_sparse_convert`` is set to ``true``,
excessively sparse arrays will be handled as maps.

**json.cfg() example 1:**

The following code will encode 0/0 as NaN ("not a number")
and 1/0 as Inf ("infinity"), rather than returning nil or an error message:

.. code-block:: lua

    json = require('json')
    json.cfg{encode_invalid_numbers = true}
    x = 0/0
    y = 1/0
    json.encode({1, x, y, 2})

The result of the ``json.encode()`` request will look like this:

.. code-block:: tarantoolsession

    tarantool> json.encode({1, x, y, 2})
    ---
    - '[1,nan,inf,2]
    ...

**json.cfg example 2:**

To avoid generating errors on attempts to encode unknown data types as
userdata/cdata, you can use this code:

.. code-block:: tarantoolsession

    tarantool> httpc = require('http.client').new()
    ---
    ...

    tarantool> json.encode(httpc.curl)
    ---
    - error: unsupported Lua type 'userdata'
    ...

    tarantool> json.encode(httpc.curl, {encode_use_tostring=true})
    ---
    - '"userdata: 0x010a4ef2a0"'
    ...

.. NOTE::

    To achieve the same effect for only one call to ``json.encode()`` (i.e.
    without changing the configuration permanently), you can use
    ``json.encode({1, x, y, 2}, {encode_invalid_numbers = true})``.

Similar configuration settings exist for :ref:`MsgPack <msgpack-cfg>`
and :ref:`YAML <yaml-cfg>`.

.. _json-null:

.. data:: NULL

    A value comparable to Lua "nil" which may be useful as a placeholder in a
    tuple.

    **Example:**

    .. code-block:: tarantoolsession

        -- When nil is assigned to a Lua-table field, the field is null
        tarantool> {nil, 'a', 'b'}
        ---
        - - null
          - a
          - b
        ...
        -- When json.NULL is assigned to a Lua-table field, the field is json.NULL
        tarantool> {json.NULL, 'a', 'b'}
        ---
        - - null
          - a
          - b
        ...
        -- When json.NULL is assigned to a JSON field, the field is null
        tarantool> json.encode({field2 = json.NULL, field1 = 'a', field3 = 'c'})
        ---
        - '{"field2":null,"field1":"a","field3":"c"}'
        ...

.. _Lua-CJSON module by Mark Pulford: http://www.kyne.com.au/~mark/software/lua-cjson.php
.. _the official documentation: http://www.kyne.com.au/~mark/software/lua-cjson-manual.html

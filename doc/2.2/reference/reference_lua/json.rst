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
    | :ref:`json.NULL                      | Analog of Lua's "nil"           |
    | <json-null>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`json.cfg()                     | Set global flags                |
    | <json-module_cfg>`                   |                                 |
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

    The JSON output structure can be specified with ``__serialize``:

    * ``__serialize="seq"`` for an array
    * ``__serialize="map"`` for a map

    Serializing 'A' and 'B' with different ``__serialize`` values causes different
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

.. function:: cfg(list of parameter assignments)

    Set values affecting behavior of :ref:`json.encode <json-encode>`
    and :ref:`json.decode <json-decode>`.
    The values are all either integers or boolean ``true``/``false`` values.

    * ``encode_invalid_as_nil`` -- use null for unrecognizable types; default = ``false``
    * ``encode_invalid_numbers`` -- allow nan and inf; default = ``true``
    * ``encode_load_metatables`` -- load metatables; default = ``true``
    * ``encode_max_depth`` -- how deep nesting can be; default = 32
    * ``encode_number_precision`` -- maximum post-decimal digits; default = 14
    * ``encode_sparse_ratio`` -- how sparse an array can be; default = 2
    * ``encode_sparse_safe`` -- how much can safely be sparse; default = 10
    * ``encode_use_tostring`` -- use ``tostring`` for unrecognizable types; default = ``false``
    * ``decode_invalid_numbers`` -- like ``encode_invalid_numbers``; default = ``true``
    * ``decode_max_depth`` -- like ``encode_max_depth``; default = 32
    * ``decode_save_metatables`` -- like ``encode_load_metatables``; default = ``true``
    * ``decode_sparse_convert`` -- like ``encode_sparse_convert``; default = ``true``

    For example, the following code will encode 0/0 as nan ("not a number")
    and 1/0 as inf ("infinity"), rather than returning nil or an error message:

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

    To achieve the same effect for only one call to ``json.encode()`` without
    changing the configuration persistently, one could say
    ``json.encode({1, x, y, 2}, {encode_invalid_numbers = true})``.

    The same configuration settings exist for json, for :ref:`MsgPack
    <msgpack-module>`, and for :ref:`YAML <yaml-module>`.

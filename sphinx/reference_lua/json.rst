.. _json-module:

-------------------------------------------------------------------------------
                          Module `json`
-------------------------------------------------------------------------------

The json module provides JSON manipulation routines. It is based on the
`Lua-CJSON module by Mark Pulford`_. For a complete manual on Lua-CJSON please read
`the official documentation`_.

.. module:: json

.. _json-encode:

.. function:: encode(lua-value)

    Convert a Lua object to a JSON string.

    :param lua_value: either a scalar value or a Lua table value.
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

.. function:: decode(string)

    Convert a JSON string to a Lua object.

    :param string string: a string formatted as JSON.
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

.. _json-null:

.. data:: NULL

    A value comparable to Lua "nil" which may be useful as a placeholder in a tuple.

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
        tarantool> json.encode({field2 = json.NULL, field1 = 'a', field3 = 'c'}
        ---
        - '{"field2":null,"field1":"a","field3":"c"}'
        ...

The JSON output structure can be specified with ``__serialize``:

* ``__serialize="seq"`` for an array
* ``__serialize="map"`` for a map

Serializing 'A' and 'B' with different ``__serialize`` values causes different results:

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

================================================================
                    Configuration settings
================================================================

There are configuration settings which affect the way that Tarantool encodes
invalid numbers or types. They are all boolean ``true``/``false`` values

* ``cfg.encode_invalid_numbers`` - allow nan and inf (default is true)
* ``cfg.encode_use_tostring`` - use tostring for unrecognizable types (default is false)
* ``cfg.encode_invalid_as_nil`` - use null for all unrecognizable types (default is false)
* ``cfg.encode_load_metatables`` - load metatables (default is false)

For example, the following code will interpret 0/0 (which is "not a number")
and 1/0 (which is "infinity") as special values rather than nulls or errors:

.. code-block:: lua

    json = require('json')
    json.cfg{encode_invalid_numbers = true}
    x = 0/0
    y = 1/0
    json.encode({1, x, y, 2})

The result of the json.encode request will look like this:

.. code-block:: tarantoolsession

    tarantool> json.encode({1, x, y, 2})
    ---
    - '[1,nan,inf,2]
    ...

The same configuration settings exist for json, for
:ref:`MsgPack <msgpack-module>`, and for :ref:`YAML <yaml-module>`.
>>>>>>> Fix every NOTE to be highlighted on site + JSON cfg rewritten

.. _Lua-CJSON module by Mark Pulford: http://www.kyne.com.au/~mark/software/lua-cjson.php
.. _the official documentation: http://www.kyne.com.au/~mark/software/lua-cjson-manual.html

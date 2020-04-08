.. _yaml-module:

-------------------------------------------------------------------------------
                            Module `yaml`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``yaml`` module takes strings in YAML_ format and decodes them, or takes a
series of non-YAML values and encodes them.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``yaml`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`yaml.encode()                  | Convert a Lua object to a YAML  |
    | <yaml-encode>`                       | string                          |
    +--------------------------------------+---------------------------------+
    | :ref:`yaml.decode()                  | Convert a YAML string to a Lua  |
    | <yaml-decode>`                       | object                          |
    +--------------------------------------+---------------------------------+
    | :ref:`__serialize parameter          | Output structure specification  |
    | <yaml-serialize>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`yaml.cfg()                     | Change configuration            |
    | <yaml-cfg>`                          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`yaml.NULL                      | Analog of Lua's "nil"           |
    | <yaml-null>`                         |                                 |
    +--------------------------------------+---------------------------------+

.. module:: yaml

.. _yaml-encode:

.. function:: encode(lua_value)

    Convert a Lua object to a YAML string.

    :param lua_value: either a scalar value or a Lua table value.
    :return: the original value reformatted as a YAML string.
    :rtype: string

.. _yaml-decode:

.. function:: decode(string)

    Convert a YAML string to a Lua object.

    :param string: a string formatted as YAML.
    :return: the original contents formatted as a Lua table.
    :rtype: table

.. _yaml-serialize:

**__serialize parameter:**

The YAML output structure can be specified with ``__serialize``:

* 'seq', 'sequence', 'array' - table encoded as an array
* 'map', 'mappping' - table encoded as a map
* function - the meta-method called to unpack serializable representation
  of table, cdata or userdata objects

'seq' or 'map' also enable the flow (compact) mode for the YAML serializer
(flow="[1,2,3]" vs block=" - 1\n - 2\n - 3\n").

Serializing 'A' and 'B' with different ``__serialize`` values brings different
results:

.. code-block:: tarantoolsession

    tarantool> yaml.encode(setmetatable({'A', 'B'}, { __serialize="seq"}))
    ---
    - '["A","B"]'
    ...
    tarantool> yaml.encode(setmetatable({'A', 'B'}, { __serialize="map"}))
    ---
    - '{"1":"A","2":"B"}'
    ...
    tarantool> yaml.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="map"})})
    ---
    - '[{"f2":"B","f1":"A"}]'
    ...
    tarantool> yaml.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="seq"})})
    ---
    - '[[]]'
    ...

.. _yaml-cfg:

.. function:: cfg(table)

    Set values affecting the behavior of encode and decode functions.

    The values are all either integers or boolean ``true``/``false``.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: center-align-column-2
        .. rst-class:: left-align-column-3

        +---------------------------------+---------+--------------------------------------------+
        | Option                          | Default | Use                                        |
        +=================================+=========+============================================+
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
        | ``cfg.encode_invalid_as_nil``   |  false  | A flag saying whether to use NULL for      |
        |                                 |         | non-recognized types                       |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_sparse_convert``   | true    | A flag saying whether to handle            |
        |                                 |         | excessively sparse arrays as maps.         |
        |                                 |         | See detailed description                   |
        |                                 |         | :ref:`below <yaml-cfg_sparse>`             |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_sparse_ratio``     |  2      | 1/``encode_sparse_ratio`` is the           |
        |                                 |         | permissible percentage of missing values   |
        |                                 |         | in a sparse array                          |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.encode_sparse_safe``      | 10      | A limit ensuring that small Lua arrays     |
        |                                 |         | are always encoded as sparse arrays        |
        |                                 |         | (instead of generating an error or         |
        |                                 |         | encoding as map)                           |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.decode_invalid_numbers``  |  true   | A flag saying whether to enable decoding   |
        |                                 |         | of NaN and Inf numbers                     |
        +---------------------------------+---------+--------------------------------------------+
        | ``cfg.decode_save_metatables``  |  true   | A flag saying whether to set metatables    |
        |                                 |         | for all arrays and maps                    |
        +---------------------------------+---------+--------------------------------------------+

    .. _yaml-cfg_sparse:

**Sparse arrays features:**

During encoding, The YAML encoder tries to classify table into one of four kinds:

* map - at least one table index is not unsigned integer
* regular array - all array indexes are available
* sparse array - at least one array index is missing
* excessively sparse array - the number of values missing exceeds the configured ratio

An array is excessively sparse when **all** the following conditions are met:

* ``encode_sparse_ratio`` > 0
* ``max(table)`` > ``encode_sparse_safe``
* ``max(table)`` > ``count(table)`` * ``encode_sparse_ratio``

The YAML encoder will never consider an array to be excessively sparse
when ``encode_sparse_ratio = 0``. The ``encode_sparse_safe`` limit ensures
that small Lua arrays are always encoded as sparse arrays.
By default, attempting to encode an excessively sparse array will
generate an error. If ``encode_sparse_convert`` is set to ``true``,
excessively sparse arrays will be handled as maps.

**yaml.cfg() example 1:**

The following code will encode 0/0 as NaN ("not a number")
and 1/0 as Inf ("infinity"), rather than returning nil or an error message:

.. code-block:: lua

    yaml = require('yaml')
    yaml.cfg{encode_invalid_numbers = true}
    x = 0/0
    y = 1/0
    yaml.encode({1, x, y, 2})

The result of the ``yaml.encode()`` request will look like this:

.. code-block:: tarantoolsession

    tarantool> yaml.encode({1, x, y, 2})
    ---
    - '[1,nan,inf,2]
    ...

**yaml.cfg example 2:**

To avoid generating errors on attempts to encode unknown data types as
userdata/cdata, you can use this code:

.. code-block:: tarantoolsession

    tarantool> httpc = require('http.client').new()
    ---
    ...

    tarantool> yaml.encode(httpc.curl)
    ---
    - error: unsupported Lua type 'userdata'
    ...

    tarantool> yaml.encode(httpc.curl, {encode_use_tostring=true})
    ---
    - '"userdata: 0x010a4ef2a0"'
    ...

.. NOTE::

    To achieve the same effect for only one call to ``yaml.encode()``
    (i.e. without changing the configuration permanently), you can use
    ``yaml.encode({1, x, y, 2}, {encode_invalid_numbers = true})``.

Similar configuration settings exist for :ref:`JSON
<json-module_cfg>` and :ref:`MsgPack <msgpack-cfg>`.

.. _yaml-null:

.. data:: NULL

    A value comparable to Lua "nil" which may be useful as a placeholder in a tuple.

=================================================
                    Example
=================================================

.. code-block:: tarantoolsession

    tarantool> yaml = require('yaml')
    ---
    ...
    tarantool> y = yaml.encode({'a', 1, 'b', 2})
    ---
    ...
    tarantool> z = yaml.decode(y)
    ---
    ...
    tarantool> z[1], z[2], z[3], z[4]
    ---
    - a
    - 1
    - b
    - 2
    ...
    tarantool> if yaml.NULL == nil then print('hi') end
    hi
    ---
    ...

The `YAML collection style <http://yaml.org/spec/1.1/#id930798>`_ can be
specified with ``__serialize``:

* ``__serialize="sequence"`` for a Block Sequence array,
* ``__serialize="seq"`` for a Flow Sequence array,
* ``__serialize="mapping"`` for a Block Mapping map,
* ``__serialize="map"`` for a Flow Mapping map.

Serializing 'A' and 'B' with different ``__serialize`` values causes
different results:

.. code-block:: tarantoolsession

    tarantool> yaml = require('yaml')
    ---
    ...

    tarantool> yaml.encode(setmetatable({'A', 'B'}, { __serialize="sequence"}))
    ---
    - '---

      - A

      - B

      ...

      '
    ...

    tarantool> yaml.encode(setmetatable({'A', 'B'}, { __serialize="seq"}))
    ---
    - '--- [''A'', ''B'']

      ...

      '
    ...

    tarantool> yaml.encode({setmetatable({f1 = 'A', f2 = 'B'}, { __serialize="map"})})
    ---
    - '---

      - {''f2'': ''B'', ''f1'': ''A''}

      ...

      '
    ...


.. _YAML: http://yaml.org/

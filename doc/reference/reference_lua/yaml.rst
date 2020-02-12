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

.. _yaml-cfg:

.. function:: cfg(table)

    Set values affecting behavior of encode and decode functions.

    The values are all either integers or boolean ``true``/``false``.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: center-align-column-2
        .. rst-class:: left-align-column-3

        +---------------------------------+---------+-------------------------------------------+
        | Option                          | Default | Use                                       |
        +=================================+=========+===========================================+
        | ``cfg.encode_invalid_numbers``  |  true   | Enable encoding of NaN and Inf numbers    |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_number_precision`` | 14      | Set point numbers precision               |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_load_metatables``  | true    | Show on ``__serialize`` field in a        |
        |                                 |         | metatable (if exists). See example below  |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_use_tostring``     | false   | Enable ``tostring()`` usage for unknown   |
        |                                 |         | types                                     |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_invalid_as_nil``   |  false  | Use NULL for all unrecognizable types     |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_sparse_convert``   | true    | Handle excessively sparse arrays as maps  |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_sparse_ratio``     |  2      | Permissible number of missing values in   |
        |                                 |         | a sparse array. See example below         |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.encode_sparse_safe``      | 10      | Limit ensuring that small Lua arrays      |
        |                                 |         | are always encoded as sparse arrays       |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.decode_invalid_numbers``  |  true   | Set floating point numbers precision      |
        +---------------------------------+---------+-------------------------------------------+
        | ``cfg.decode_save_metatables``  |  true   | Save ``__serialize`` meta-value for       |
        |                                 |         | decoded arrays and map                    |
        +---------------------------------+---------+-------------------------------------------+

    The same configuration settings exist for :ref:`JSON
    <json-module_cfg>`, and for :ref:`MsgPack <msgpack-cfg>`.

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

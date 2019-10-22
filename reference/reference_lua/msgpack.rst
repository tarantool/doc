.. _msgpack-module:

-------------------------------------------------------------------------------
                                    Module `msgpack`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``msgpack`` module takes strings in MsgPack_ format and decodes them, or
takes a series of non-MsgPack values and encodes them.
Tarantool makes heavy internal use of MsgPack because tuples in Tarantool
are :ref:`stored <index-box_lua-vs-msgpack>` as MsgPack arrays.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``msgpack`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`msgpack.encode()               | Convert a Lua object to an      |
    | <msgpack-encode>`                    | MsgPack string                  |
    +--------------------------------------+---------------------------------+
    | :ref:`msgpack.decode()               | Convert a MsgPack string to a   |
    | <msgpack-decode>`                    | Lua object                      |
    +--------------------------------------+---------------------------------+
    | :ref:`msgpack.decode_unchecked()     | Convert a MsgPack string to a   |
    | <msgpack-decode_unchecked>`          | Lua object                      |
    +--------------------------------------+---------------------------------+
    | :ref:`msgpack.NULL                   | Analog of Lua's "nil"           |
    | <msgpack-null>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`msgpack.cfg                    | Change configuration            |
    | <msgpack-cfg>`                       |                                 |
    +--------------------------------------+---------------------------------+


.. module:: msgpack

.. _msgpack-encode:

.. function:: encode(lua_value)

    Convert a Lua object to a MsgPack string.

    :param lua_value: either a scalar value or a Lua table value.
    :return: the original value reformatted as a MsgPack string.
    :rtype: string

.. _msgpack-decode:

.. function:: decode(msgpack_string [, start_position])

    Convert a MsgPack string to a Lua object.

    :param string msgpack_string: a string formatted as MsgPack.
    :param integer start_position: where to start, minimum = 1,
                                   maximum = string length, default = 1.

    :return:

      * (if ``msgpack_string`` is in valid MsgPack format) the original contents
        of ``msgpack_string``, formatted as a Lua table,
        (otherwise) a scalar value, such as a string or a number;
      * "next_start_position". If ``decode`` stops after parsing as far as
        byte N in ``msgpack_string``, then "next_start_position" will equal N + 1,
        and ``decode(msgpack_string, next_start_position)``
        will continue parsing from where the previous ``decode`` stopped, plus 1.
        Normally ``decode`` parses all of ``msgpack_string``, so
        "next_start_position" will equal ``string.len(msgpack_string)`` + 1.

    :rtype: table and number

.. _msgpack-decode_unchecked:

.. function:: decode_unchecked(string)

    Convert a MsgPack string to a Lua object.
    Because checking is skipped, ``decode_unchecked()``
    can operate with string pointers to
    buffers which ``decode()`` cannot handle.
    For an example see the :ref:`buffer <buffer-module>` module.

    :param string: a string formatted as MsgPack.

    :return:

      * the original contents formatted as a Lua table;
      * the number of bytes that were decoded.

    :rtype: lua object

.. _msgpack-null:

.. data:: NULL

    A value comparable to Lua "nil" which may be useful as a placeholder in a
    tuple.

=================================================
                    Example
=================================================

.. code-block:: tarantoolsession

    tarantool> msgpack = require('msgpack')
    ---
    ...
    tarantool> y = msgpack.encode({'a',1,'b',2})
    ---
    ...
    tarantool> z = msgpack.decode(y)
    ---
    ...
    tarantool> z[1], z[2], z[3], z[4]
    ---
    - a
    - 1
    - b
    - 2
    ...
    tarantool> box.space.tester:insert{20, msgpack.NULL, 20}
    ---
    - [20, null, 20]
    ...

.. _msgpack-serialize:

The MsgPack output structure can be specified with ``__serialize``:

* ``__serialize = "seq" or "sequence"`` for an array
* ``__serialize = "map" or "mapping"`` for a map

Serializing 'A' and 'B' with different ``__serialize`` values causes different
results. To show this, here is a routine which encodes `{'A','B'}` both as an
array and as a map, then displays each result in hexadecimal.

.. code-block:: lua

    function hexdump(bytes)
        local result = ''
        for i = 1, #bytes do
            result = result .. string.format("%x", string.byte(bytes, i)) .. ' '
        end
        return result
    end

    msgpack = require('msgpack')
    m1 = msgpack.encode(setmetatable({'A', 'B'}, {
                                 __serialize = "seq"
                              }))
    m2 = msgpack.encode(setmetatable({'A', 'B'}, {
                                 __serialize = "map"
                              }))
    print('array encoding: ', hexdump(m1))
    print('map encoding: ', hexdump(m2))

**Result:**

.. cssclass:: highlight
.. parsed-literal::

    **array** encoding: 92 a1 41 a1 42
    **map** encoding:   82 01 a1 41 02 a1 42

The MsgPack Specification_ page explains that the first encoding means:

.. cssclass:: highlight
.. parsed-literal::

    fixarray(2), fixstr(1), "A", fixstr(1), "B"

and the second encoding means:

.. cssclass:: highlight
.. parsed-literal::

    fixmap(2), key(1), fixstr(1), "A", key(2), fixstr(2), "B"

Here are examples for all the common types,
with the Lua-table representation on the left,
with the MsgPack format name and encoding on the right.

.. _msgpack-common_types_and_msgpack_encodings:

.. container:: table

    **Common Types and MsgPack Encodings**

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    .. tabularcolumns:: |\Y{0.2}|\Y{0.8}|

    +--------------+-------------------------------------------------+
    | {}           | 'fixmap' if metatable is 'map' = 80             |
    |              | otherwise 'fixarray' = 90                       |
    +--------------+-------------------------------------------------+
    | 'a'          | 'fixstr' = a1 61                                |
    +--------------+-------------------------------------------------+
    | false        | 'false' = c2                                    |
    +--------------+-------------------------------------------------+
    | true         | 'true' = c3                                     |
    +--------------+-------------------------------------------------+
    | 127          | 'positive fixint' = 7f                          |
    +--------------+-------------------------------------------------+
    | 65535        | 'uint 16' = cd ff ff                            |
    +--------------+-------------------------------------------------+
    | 4294967295   | 'uint 32' = ce ff ff ff ff                      |
    +--------------+-------------------------------------------------+
    | nil          | 'nil' = c0                                      |
    +--------------+-------------------------------------------------+
    | msgpack.NULL | same as nil                                     |
    +--------------+-------------------------------------------------+
    | [0] = 5      | 'fixmap(1)' + 'positive fixint' (for the key)   |
    |              | + 'positive fixint' (for the value) = 81 00 05  |
    +--------------+-------------------------------------------------+
    | [0] = nil    | 'fixmap(0)' = 80 -- nil is not stored           |
    |              | when it is a missing map value                  |
    +--------------+-------------------------------------------------+
    | 1.5          | 'float 64' = cb 3f f8 00 00 00 00 00 00         |
    +--------------+-------------------------------------------------+

.. _msgpack-cfg:

.. function:: cfg(table)

    Some MsgPack configuration settings can be changed, in the
    same way that they can be changed for json.
    See :ref:`Module JSON <json-module_cfg>` for a list of some configuration settings.
    (The same configuration settings exist for json, for MsgPack, and for  :ref:`YAML <yaml-module>`.)

    For example, if ``msgpack.cfg.encode_invalid_numbers = true`` (the default),
    then nan and inf are legal values. If that is not desirable, then
    ensure that ``msgpack.encode()`` will not accept them, by saying
    ``msgpack.cfg{encode_invalid_numbers = false}``, thus:

    .. code-block:: none

        tarantool> msgpack = require('msgpack'); msgpack.cfg{encode_invalid_numbers = true}
        ---
        ...
        tarantool> msgpack.decode(msgpack.encode{1, 0 / 0, 1 / 0, false})
        ---
        - [1, -nan, inf, false]
        - 22
        ...
        tarantool> msgpack.cfg{encode_invalid_numbers = false}
       ---
       ...
        tarantool> msgpack.decode(msgpack.encode{1, 0 / 0, 1 / 0, false})
        ---
        - error: ... number must not be NaN or Inf'
       ...


.. _MsgPack: http://msgpack.org/
.. _Specification: http://github.com/msgpack/msgpack/blob/master/spec.md

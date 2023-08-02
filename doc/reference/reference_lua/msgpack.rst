.. _msgpack-module:

Module msgpack
==============

.. _msgpack-module-overview:

Overview
--------

The ``msgpack`` module decodes :ref:`raw MsgPack strings <msgpack-definitions>` by converting them to Lua objects,
and encodes Lua objects by converting them to raw MsgPack strings.
Tarantool makes heavy internal use of MsgPack because tuples in Tarantool
are :ref:`stored <index-box_lua-vs-msgpack>` as MsgPack arrays.

..  _msgpack-object-info:

Besides, starting from version 2.10.0, the ``msgpack`` module enables creating a specific userdata Lua object -- MsgPack object.
The MsgPack object stores arbitrary MsgPack data, and can be created from :ref:`any Lua object <msgpack-object>` including another MsgPack object
and from a :ref:`raw MsgPack string <msgpack-object-from-raw>`. The MsgPack object has its own set of :ref:`methods <msgpack-object-methods>` and :ref:`iterators <msgpack-object-iterator-methods>`.

.. _msgpack-definitions:

.. NOTE::

    *   *MsgPack* is short for `MessagePack <https://msgpack.org/index.html>`_.

    *   A "raw MsgPack string" is a byte array formatted according to the `MsgPack specification <https://github.com/msgpack/msgpack/blob/master/spec.md>`_ including type bytes and sizes.
        The type bytes and sizes can be made displayable with :ref:`string.hex() <string-hex>`,
        or the raw MsgPack strings can be converted to Lua objects by using the ``msgpack`` module methods.


.. _msgpack-module-api-reference:

API Reference
-------------

Below is a list of ``msgpack`` members and related objects.

..  container:: table

    ..  list-table::
        :widths: 50 50
        :header-rows: 1

        *   -   **Members**
            -

        *   -   :ref:`msgpack.encode(lua_value) <msgpack-encode_lua_value>`
            -   Convert a Lua object to a raw MsgPack string

        *   -   :ref:`msgpack.encode(lua_value,ibuf) <msgpack-encode_lua_value_ibuf>`
            -   Convert a Lua object to a raw MsgPack string in an ibuf

        *   -   :ref:`msgpack.decode(msgpack_string) <msgpack-decode_string>`
            -   Convert a raw MsgPack string to a Lua object

        *   -   :ref:`msgpack.decode(C_style_string_pointer) <msgpack-decode_c_style_string_pointer>`
            -   Convert a raw MsgPack string in an ibuf to a Lua object

        *   -   :ref:`msgpack.decode_unchecked(msgpack_string) <msgpack-decode_unchecked_string>`
            -   Convert a raw MsgPack string to a Lua object

        *   -   :ref:`msgpack.decode_unchecked(C_style_string_pointer) <msgpack-decode_unchecked_c_style_string_pointer>`
            -   Convert a raw MsgPack string to a Lua object

        *   -   :ref:`msgpack.decode_array_header(byte-array, size) <msgpack-decode_array_header>`
            -   Call the `MsgPuck <https://rtsisyk.github.io/msgpuck/>`_'s ``mp_decode_array`` function and return the array size and a pointer to the first array component

        *   -   :ref:`msgpack.decode_map_header(byte-array, size) <msgpack-decode_map_header>`
            -   Call the `MsgPuck <https://rtsisyk.github.io/msgpuck/>`_'s ``mp_decode_map`` function and return the map size and a pointer to the first map component

        *   -   :ref:`__serialize <msgpack-serialize>` parameter
            -   Output structure specification

        *   -   :ref:`msgpack.cfg() <msgpack-cfg>`
            -   Change MsgPack configuration settings

        *   -   :ref:`msgpack.NULL <msgpack-null>`
            -   Analog of Lua's ``nil``

        *   -   :ref:`msgpack.object(lua_value) <msgpack-object>`
            -   Create a MsgPack object from a Lua object

        *   -   :ref:`msgpack.object_from_raw(msgpack_string) <msgpack-object-from-raw>`
            -   Create a MsgPack object from a raw MsgPack string

        *   -   :ref:`msgpack.object_from_raw(C_style_string_pointer, size) <msgpack-object-from-raw-pointer>`
            -   Create a MsgPack object from a raw MsgPack string

        *   -   :ref:`msgpack.is_object(some_argument) <msgpack-is-object>`
            -   Check if an argument is a MsgPack object

        *   -   **Related objects**
            -

        *   -   :ref:`msgpack_object <msgpack-object-methods>`
            -   A MsgPack object

        *   -   :ref:`iterator_object <msgpack-object-iterator-methods>`
            -   A MsgPack iterator object


.. module:: msgpack

..  _msgpack-module-api-reference-members:

Members
~~~~~~~

.. _msgpack-encode_lua_value:

.. function:: encode(lua_value)

    Convert a Lua object to a raw MsgPack string.

    :param lua_value: either a scalar value or a Lua table value.

    :return: the original contents formatted as a raw MsgPack string;

    :rtype: raw MsgPack string

.. _msgpack-encode_lua_value_ibuf:

.. function:: encode(lua_value, ibuf)

    Convert a Lua object to a raw MsgPack string in an ibuf,
    which is a buffer such as :ref:`buffer.ibuf() <buffer-ibuf>` creates.
    As with :ref:`encode(lua_value) <msgpack-encode_lua_value>`,
    the result is a raw MsgPack string,
    but it goes to the ``ibuf`` output instead of being returned.

    :param lua-object lua_value: either a scalar value or a Lua table value.
    :param buffer ibuf: (output parameter) where the result raw MsgPack string goes
    :return: number of bytes in the output

    :rtype: raw MsgPack string

    Example using :ref:`buffer.ibuf() <buffer-ibuf>`
    and `ffi.string() <https://luajit.org/ext_ffi_api.html>`_
    and :ref:`string.hex() <string-hex>`:
    The result will be '91a161' because 91 is the MessagePack encoding of "fixarray size 1",
    a1 is the MessagePack encoding of "fixstr size 1",
    and 61 is the UTF-8 encoding of 'a':

    .. code-block:: lua

        ibuf = require('buffer').ibuf()
        msgpack_string_size = require('msgpack').encode({'a'}, ibuf)
        msgpack_string = require('ffi').string(ibuf.rpos, msgpack_string_size)
        string.hex(msgpack_string)

.. _msgpack-decode_string:

.. function:: decode(msgpack_string [, start_position])

    Convert a raw MsgPack string to a Lua object.

    :param string msgpack_string: a raw MsgPack string.
    :param integer start_position: where to start, minimum = 1,
                                   maximum = string length, default = 1.

    :return:

      * (if ``msgpack_string`` is a valid raw MsgPack string) the original contents
        of ``msgpack_string``, formatted as a Lua object, usually a Lua table,
        (otherwise) a scalar value, such as a string or a number;
      * "next_start_position". If ``decode`` stops after parsing as far as
        byte N in ``msgpack_string``, then "next_start_position" will equal N + 1,
        and ``decode(msgpack_string, next_start_position)``
        will continue parsing from where the previous ``decode`` stopped, plus 1.
        Normally ``decode`` parses all of ``msgpack_string``, so
        "next_start_position" will equal ``string.len(msgpack_string)`` + 1.

    :rtype: Lua object and number

    Example: The result will be ['a'] and 4:

    .. code-block:: lua

        msgpack_string = require('msgpack').encode({'a'})
        require('msgpack').decode(msgpack_string, 1)

.. _msgpack-decode_c_style_string_pointer:

.. function:: decode(C_style_string_pointer, size)

    Convert a raw MsgPack string, whose address is supplied as a C-style string pointer
    such as the ``rpos`` pointer which is inside an ibuf such as
    :ref:`buffer.ibuf() <buffer-ibuf>` creates, to a Lua object.
    A C-style string pointer may be described as ``cdata<char *>`` or ``cdata<const char *>``.

    :param buffer C_style_string_pointer: a pointer to a raw MsgPack string.
    :param integer size: number of bytes in the raw MsgPack string

    :return:

      * (if C_style_string_pointer points to a valid raw MsgPack string) the original contents
        of ``msgpack_string``, formatted as a Lua object, usually a Lua table,
        (otherwise) a scalar value, such as a string or a number;
      * returned_pointer = a C-style pointer to the byte after
        what was passed, so that C_style_string_pointer + size = returned_pointer

    :rtype: table and C-style pointer to after what was passed

    Example using :ref:`buffer.ibuf <buffer-ibuf>`
    and pointer arithmetic:
    The result will be ['a'] and 3 and true:

    .. code-block:: lua

        ibuf = require('buffer').ibuf()
        msgpack_string_size = require('msgpack').encode({'a'}, ibuf)
        a, b = require('msgpack').decode(ibuf.rpos, msgpack_string_size)
        a, b - ibuf.rpos, msgpack_string_size == b - ibuf.rpos

.. _msgpack-decode_unchecked_string:

.. function:: decode_unchecked(msgpack_string [, start_position])

    Input and output are the same as for
    :ref:`decode(string) <msgpack-decode_string>`.

.. _msgpack-decode_unchecked_c_style_string_pointer:

.. function:: decode_unchecked(C_style_string_pointer)

    Input and output are the same as for
    :ref:`decode(C_style_string_pointer) <msgpack-decode_c_style_string_pointer>`,
    except that ``size`` is not needed.
    Some checking is skipped, and ``decode_unchecked(C_style_string_pointer)`` can operate with
    string pointers to buffers which ``decode(C_style_string_pointer)`` cannot handle.
    For an example see the :ref:`buffer <buffer-module>` module.

.. _msgpack-decode_array_header:

.. function:: decode_array_header(byte-array, size)

    Call the `MsgPuck <https://rtsisyk.github.io/msgpuck/>`_'s ``mp_decode_array`` function
    and return the array size and a pointer to the first array component.
    A subsequent call to ``msgpack_decode`` can decode the component instead of the whole array.

    :param byte-array: a pointer to a raw MsgPack string.
    :param size: a number greater than or equal to the string's length

    :return:

      * the size of the array;
      * a pointer to after the array header.

    **Example:**

    .. code-block:: lua

        -- Example of decode_array_header
        -- Suppose we have the raw data '\x93\x01\x02\x03'.
        -- \x93 is MsgPack encoding for a header of a three-item array.
        -- We want to skip it and decode the next three items.
        msgpack = require('msgpack');
        ffi = require('ffi');
        x, y = msgpack.decode_array_header(ffi.cast('char*', '\x93\x01\x02\x03'), 4)
        a = msgpack.decode(y, 1);
        b = msgpack.decode(y + 1, 1);
        c = msgpack.decode(y + 2, 1);
        a, b, c
        -- The result is: 1,2,3.

.. _msgpack-decode_map_header:

.. function:: decode_map_header(byte-array, size)

    Call the `MsgPuck <https://rtsisyk.github.io/msgpuck/>`_'s ``mp_decode_map`` function
    and return the map size and a pointer to the first map component.
    A subsequent call to ``msgpack_decode`` can decode the component instead of the whole map.

    :param byte-array: a pointer to a raw MsgPack string.
    :param size: a number greater than or equal to the raw MsgPack string's length

    :return:

      * the size of the map;
      * a pointer to after the map header.

    **Example:**

    .. code-block:: lua

        -- Example of decode_map_header
        -- Suppose we have the raw data '\x81\xa2\x41\x41\xc3'.
        -- '\x81' is MsgPack encoding for a header of a one-item map.
        -- We want to skip it and decode the next map item.
        msgpack = require('msgpack');
        ffi = require('ffi')
        x, y = msgpack.decode_map_header(ffi.cast('char*', '\x81\xa2\x41\x41\xc3'), 5)
        a = msgpack.decode(y, 3);
        b = msgpack.decode(y + 3, 1)
        x, a, b
        -- The result is: 1,"AA", true.

.. _msgpack-serialize:

**__serialize parameter**

The MsgPack output structure can be specified with the ``__serialize`` parameter:

* 'seq', 'sequence', 'array' -- table encoded as an array
* 'map', 'mappping' -- table encoded as a map
* function -- the meta-method called to unpack the serializable representation
  of table, cdata, or userdata objects

Serializing 'A' and 'B' with different ``__serialize`` values brings different
results. To show this, here is a routine which encodes ``{'A','B'}`` both as an
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

.. code-block:: none

    **array** encoding: 92 a1 41 a1 42
    **map** encoding:   82 01 a1 41 02 a1 42

The MsgPack `Specification page <http://github.com/msgpack/msgpack/blob/master/spec.md>`_
explains that the first encoding means:

.. code-block:: none

    fixarray(2), fixstr(1), "A", fixstr(1), "B"

and the second encoding means:

.. code-block:: none

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

    Change MsgPack configuration settings.

    The values are all either integers or boolean ``true``/``false``.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: center-align-column-2
        .. rst-class:: left-align-column-3

        +---------------------------------+---------+-----------------------------------------------+
        | Option                          | Default | Use                                           |
        +=================================+=========+===============================================+
        | ``cfg.encode_max_depth``        |   128   | The maximum recursion depth for encoding      |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_deep_as_nil``      |  false  | Specify whether to crop tables                |
        |                                 |         | with nesting level deeper than                |
        |                                 |         | ``cfg.encode_max_depth``.                     |
        |                                 |         | Not-encoded fields are replaced with          |
        |                                 |         | one null. If not set, too high                |
        |                                 |         | nesting is considered an error.               |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_invalid_numbers``  |  true   | Specify whether to enable encoding of         |
        |                                 |         | NaN and Inf numbers                           |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_load_metatables``  | true    | Specify whether the serializer will           |
        |                                 |         | follow :ref:`__serialize <json-serialize>`    |
        |                                 |         | metatable field                               |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_use_tostring``     | false   | Specify whether to use ``tostring()``         |
        |                                 |         | for unknown types                             |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_invalid_as_nil``   |  false  | Specify whether to use NULL for               |
        |                                 |         | non-recognized types                          |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_sparse_convert``   | true    | Specify whether to handle excessively         |
        |                                 |         | sparse arrays as maps.                        |
        |                                 |         | See detailed description                      |
        |                                 |         | :ref:`below <msgpack-cfg_sparse>`             |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_sparse_ratio``     |  2      | 1/``encode_sparse_ratio`` is the permissible  |
        |                                 |         | percentage of missing values in a sparse      |
        |                                 |         | array                                         |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_sparse_safe``      | 10      | A limit ensuring that small Lua arrays        |
        |                                 |         | are always encoded as sparse arrays           |
        |                                 |         | (instead of generating an error or encoding   |
        |                                 |         | as a map)                                     |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.encode_error_as_ext``     | true    | Specify how error objects                     |
        |                                 |         | (:ref:`box.error.new() <box_error-new>`)      |
        |                                 |         | are encoded in the MsgPack format:            |
        |                                 |         |                                               |
        |                                 |         | *  if ``true``, errors are encoded as the     |
        |                                 |         |    the :ref:`MP_ERROR <msgpack_ext-error>`    |
        |                                 |         |    MsgPack extension.                         |
        |                                 |         | *  if ``false``, the encoding format depends  |
        |                                 |         |    on other configuration options             |
        |                                 |         |    (``encode_load_metatables``,               |
        |                                 |         |    ``encode_use_tostring``,                   |
        |                                 |         |    ``encode_invalid_as_nil``).                |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.decode_invalid_numbers``  |  true   | Specify whether to enable decoding of         |
        |                                 |         | NaN and Inf numbers                           |
        +---------------------------------+---------+-----------------------------------------------+
        | ``cfg.decode_save_metatables``  |  true   | Specify whether to set metatables for         |
        |                                 |         | all arrays and maps                           |
        +---------------------------------+---------+-----------------------------------------------+

    .. _msgpack-cfg_sparse:

**Sparse arrays features**

During encoding, the MsgPack encoder tries to classify tables into one of four kinds:

* map - at least one table index is not unsigned integer
* regular array - all array indexes are available
* sparse array - at least one array index is missing
* excessively sparse array - the number of values missing exceeds the configured ratio

An array is excessively sparse when **all** the following conditions are met:

* ``encode_sparse_ratio`` > 0
* ``max(table)`` > ``encode_sparse_safe``
* ``max(table)`` > ``count(table)`` * ``encode_sparse_ratio``

MsgPack encoder never considers an array to be excessively sparse
when ``encode_sparse_ratio = 0``. The ``encode_sparse_safe`` limit ensures
that small Lua arrays are always encoded as sparse arrays.
By default, attempting to encode an excessively sparse array
generates an error. If ``encode_sparse_convert`` is set to ``true``,
excessively sparse arrays will be handled as maps.

**msgpack.cfg() example 1:**

If ``msgpack.cfg.encode_invalid_numbers = true`` (the default),
then NaN and Inf are legal values. If that is not desirable, then
ensure that ``msgpack.encode()`` does not accept them, by saying
``msgpack.cfg{encode_invalid_numbers = false}``, thus:

.. code-block:: tarantoolsession

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

**msgpack.cfg() example 2:**

To avoid generating errors on attempts to encode unknown data types as
userdata/cdata, you can use this code:

.. code-block:: tarantoolsession

    tarantool> httpc = require('http.client').new()
    ---
    ...

    tarantool> msgpack.encode(httpc.curl)
    ---
    - error: unsupported Lua type 'userdata'
    ...

    tarantool> msgpack.cfg{encode_use_tostring = true}
    ---
    ...

    tarantool> msgpack.encode(httpc.curl)
    ---
    - !!binary tnVzZXJkYXRhOiAweDAxMDU5NDQ2Mzg=
    ...


.. NOTE::

    To achieve the same effect for only one call to ``msgpack.encode()``
    (that is without changing the configuration permanently), you can use
    ``msgpack.new({encode_invalid_numbers = true}).encode({1, 2})``.

Similar configuration settings exist for :ref:`JSON <json-module_cfg>`
and :ref:`YAML <yaml-cfg>`.

.. _msgpack-null:

.. data:: NULL

    A value comparable to Lua "nil" which may be useful as a placeholder in a
    tuple.

    **Example**

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

..  _msgpack-object:

..  function:: object(lua_value)

    **Since:** :doc:`2.10.0 </release/2.10.0>`

    Encode an arbitrary Lua object into the MsgPack format.

    :param lua-object lua_value: a Lua object of any type.

    :return: encoded MsgPack data encapsulated in a MsgPack object.

    :rtype: userdata

    **Example:**

    ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_test.lua
        :language: lua
        :lines: 1-8
        :dedent:

..  _msgpack-object-from-raw:

..  function:: object_from_raw(msgpack_string)

    **Since:** :doc:`2.10.0 </release/2.10.0>`

    Create a MsgPack object from a raw MsgPack string.

    :param string msgpack_string: a raw MsgPack string.

    :return: a MsgPack object

    :rtype: userdata

    **Example:**

    ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_test.lua
        :language: lua
        :lines: 1,9-12
        :dedent:

..  _msgpack-object-from-raw-pointer:

..  function:: object_from_raw(C_style_string_pointer, size)

    **Since:** :doc:`2.10.0 </release/2.10.0>`

    Create a MsgPack object from a raw MsgPack string. The address of the MsgPack string is supplied as a C-style string pointer
    such as the ``rpos`` pointer inside an ``ibuf`` that the :ref:`buffer.ibuf() <buffer-ibuf>` creates.
    A C-style string pointer may be described as ``cdata<char *>`` or ``cdata<const char *>``.

    :param buffer C_style_string_pointer: a pointer to a raw MsgPack string.
    :param integer size: number of bytes in the raw MsgPack string.

    :return: a MsgPack object

    :rtype: userdata

    **Example:**

    ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_test.lua
        :language: lua
        :lines: 1,13-18
        :dedent:

..  _msgpack-is-object:

..  function:: is_object(some_argument)

    **Since:** :doc:`2.10.0 </release/2.10.0>`

    Check if the given argument is a MsgPack object.

    :param some_agrument: any argument.

    :return: ``true`` if the argument is a MsgPack object; otherwise, ``false``

    :rtype: boolean

    **Example:**

    ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_is_object_test.lua
        :language: lua
        :lines: 1-7
        :dedent:


..  _msgpack-module-api-reference-objects:

Related objects
~~~~~~~~~~~~~~~

..  _msgpack-object-methods:

msgpack_object
**************

..  class:: msgpack_object

    A MsgPack object that stores arbitrary MsgPack data.
    To create a MsgPack object from a Lua object or string, use the following methods:

    *   :ref:`msgpack.object <msgpack-object>`
    *   :ref:`msgpack.object_from_raw <msgpack-object-from-raw>`

    If a MsgPack object stores an array, it can be inserted into a database space:

    ..  code-block:: lua

        box.space.bands:insert(msgpack.object({1, 'The Beatles', 1960}))

    ..  method:: decode()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Decode MsgPack data in the MsgPack object.

        :return: a Lua object

        :rtype: Lua object

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_test.lua
            :language: lua
            :lines: 1-2,4-5,19-22
            :dedent:

    ..  method:: iterator()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Create an iterator over the MsgPack data.

        :return: an :ref:`iterator object <msgpack-object-iterator-methods>` over the MsgPack data

        :rtype: userdata


    ..  _msgpack-object-item:

    ..  method:: msgpack_object[key]

        **Since:** :doc:`2.11.0 </release/2.11.0>`

        Get an element of the MsgPack array by the specified index key.
        You can also use the :ref:`get(key) <msgpack-object-get>` method to get an array element.

        The index key used to get the array element might be one of the following:

        *   if a MsgPack object is an array, the ``key`` is an integer value (starting with 1) that specifies the element index.
        *   if a MsgPack object is an associative array, ``key`` is the string value that specifies the element key. In this case, you can also access the array element using dot notation (``msgpack_object.<key>``).

        If the specified key is missing in the array, ``msgpack_object[key]`` returns ``nil``.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_index_test.lua
            :language: lua
            :lines: 1-11
            :dedent:

        .. NOTE::

            Note that if the key for an associative array coincides with any
            ``msgpack_object``'s method name,
            for example, 'iterator', ``mp_from_table['iterator']`` returns
            the ``iterator`` method function instead of a value corresponding to the
            'iterator' key.

    ..  _msgpack-object-get:

    ..  method:: get(key)

        **Since:** :doc:`2.11.0 </release/2.11.0>`

        Get an element of the MsgPack array by the specified index key.
        You can also use the indexed notation (:ref:`msgpack_object[key] <msgpack-object-item>`) to get an array element.

        :param number/string key: the index key used to get the array element, which might be one of the following:

                    *   if a MsgPack object is an array, the ``key`` is an integer value (starting with 1) that specifies the element index.
                    *   if a MsgPack object is an associative array, ``key`` is the string value that specifies the element key.

        :return: an element of the MsgPack array.
                 If the specified key is missing in the array, ``get`` returns ``nil``.



..  _msgpack-object-iterator-methods:

iterator_object
***************

..  class:: iterator_object

    An iterator over a MsgPack array.

    ..  method:: decode_array_header()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Decode a MsgPack array header under the iterator cursor and advance the cursor.
        After calling this function, the iterator points to the first element of the array
        or to the value following the array if the array is empty.

        :return: number of elements in the array

        :rtype: number

        **Possible errors:**  raise an error if the type of the value under the iterator cursor is not ``MP_ARRAY``.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_iterator_test.lua
            :language: lua
            :lines: 1-10
            :dedent:

    ..  method:: decode_map_header()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Decode a MsgPack map header under the iterator cursor and advance the cursor.
        After calling this function, the iterator points to the first key stored in
        the map or to the value following the map if the map is empty.

        :return: number of key-value pairs in the map

        :rtype: number

        **Possible errors:** raise an error if the type of the value under the iterator cursor is not ``MP_MAP``.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_iterator_map_test.lua
            :language: lua
            :lines: 1-8
            :dedent:

    ..  method:: decode()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Decode a MsgPack value under the iterator cursor and advance the cursor.

        :return: a Lua object corresponding to the MsgPack value

        :rtype: Lua object

        **Possible errors:** raise a Lua error if there's no data to decode.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_iterator_test.lua
            :language: lua
            :lines: 1-10
            :dedent:

    ..  method:: take()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Return a MsgPack value under the iterator cursor as a MsgPack object without decoding and advance the cursor.
        The method doesn't copy MsgPack data. Instead, it takes a reference to the original object.

        **Possible errors:** raise a Lua error if there's no data to decode.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_iterator_take_test.lua
            :language: lua
            :lines: 1-10
            :dedent:

    ..  method:: take_array(count)

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Copy the specified number of MsgPack values starting from
        the iterator's cursor position to a new MsgPack array object
        and advance the cursor.

        :param number count: the number of MsgPack values to copy

        :return: a new MsgPack object

        **Possible errors:** raise a Lua error if there aren't enough values to decode.
        In this case, the iterator's cursor position doesn't change.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_iterator_take_array_test.lua
            :language: lua
            :lines: 1-10
            :dedent:

    ..  method:: skip()

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        Advance the iterator cursor by skipping one MsgPack value under the cursor. Returns nothing.

        **Possible errors:** raise a Lua error if there's no data to skip.

        **Example**

        ..  literalinclude:: /code_snippets/test/msgpack/msgpack_object_iterator_test.lua
            :language: lua
            :lines: 1-10
            :dedent:

..  _ulid-module:

Module ulid
===========

Since version 3.6.0.

.. _ulid-module-overview:

Overview
--------

The ``ulid`` module implements ULID (Universally Unique Lexicographically
Sortable Identifier) support in Tarantool. A ULID is a 128-bit identifier
consisting of:

* a 48-bit timestamp in milliseconds since the Unix epoch
* an 80-bit random (entropy) component

ULID strings are encoded using **Crockford Base32**, a compact and
human-friendly alphabet that excludes visually ambiguous characters.

In binary form, ULIDs are represented as 16-byte values in **big-endian**
byte order. This ensures that the lexicographical order of binary ULIDs
matches their chronological order, in accordance with the ULID specification.

ULIDs have several useful properties:

* They are lexicographically sortable by creation time.
* They fit entirely into 26 ASCII characters.
* They avoid visually ambiguous symbols (``I``, ``L``, ``O``, ``U``).
* They have 128 bits of total uniqueness-same as UUID v4.

Tarantool uses a *monotonic* ULID generator. This ensures that multiple ULIDs
created within the same millisecond are strictly increasing and preserve
sort order: for any two ULIDs generated in the same millisecond, the one
created later is greater than the earlier one.

Internally, the monotonic generator keeps the last generated ULID for the
current millisecond and increments the 80-bit random part for each subsequent
ULID. A real overflow of the random part can happen only after generating
``2^80`` ULIDs within the same millisecond, which is practically impossible
on real hardware. However, for strict correctness of the ULID specification
and to avoid silent wrap-around, the implementation detects this overflow
and fails the next generation attempt with a Lua error
(``ULID random component overflow``).

To use this module, run the following command:

..  code-block:: lua

    ulid = require('ulid')

.. _ulid-module-comparison:

Comparison
----------

ULID objects support the full set of Lua comparison operators:

* ``==`` and ``~=`` - equality and inequality;
* ``<`` and ``<=`` - lexicographical comparison;
* ``>`` and ``>=`` - lexicographical comparison.

The comparison is based on the internal 16-byte representation in
big-endian order and is consistent with the ULID specification:
for ULIDs created by the monotonic generator, later ULIDs are greater
than earlier ones, including ULIDs generated within the same millisecond.

Comparison works both between ULID objects and between a ULID object
and a ULID string:

* ``u1 == u2`` compares two ULID objects directly.
* ``u1 == "01..."`` converts the string to ULID and compares values.
* ``u1 < "01..."`` or ``"01..." < u1`` convert the string argument to ULID
  and perform lexicographical comparison.

Examples:

..  code-block:: tarantoolsession

    tarantool> u1 = ulid.new()
    tarantool> u2 = ulid.new()
    tarantool> u1 < u2, u1 <= u2, u1 == u2, u1 ~= u2, u1 > u2, u1 >= u2
    ---
    - true
    - true
    - false
    - true
    - false
    - false
    ...

    tarantool> u = ulid.new()
    tarantool> s = u:str()
    tarantool> u == s, u < s, u > s
    ---
    - true
    - false
    - false
    ...

    tarantool> u == "not-a-valid-ulid"
    ---
    - false
    ...

    tarantool> u < "not-a-valid-ulid"
    ---
    - error: '[string "return u < "not-a-valid-ulid""]:1: incorrect value to convert to
        ulid as 2 argument'
    ...

.. _ulid-module-api-reference:

API Reference
-------------

Below is list of all ``ulid`` functions and members.

..  module:: ulid

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 30 70
        :header-rows: 1

        *   - Name
            - Use

        *  - :ref:`ulid.NULL <ulid-null>`
           - A nil ULID object

        *  - :ref:`ulid.ulid() <ulid-call>` |br|
             :ref:`ulid.bin() <ulid-bin>` |br|
             :ref:`ulid.str() <ulid-str>`
           - Shortcuts to create a new ULID value

        *  - :ref:`ulid.new() <ulid-new>`
           - Create a new ULID object

        *  - :ref:`ulid.fromstr() <ulid-fromstr>` |br|
             :ref:`ulid.frombin() <ulid-frombin>` |br|
             :ref:`ulid_object:bin() <ulid-object_bin>` |br|
             :ref:`ulid_object:str() <ulid-object_str>`
           - Convert between string, binary, and ULID object forms

        *  - :ref:`ulid.is_ulid() <ulid-is_ulid>` |br|
             :ref:`ulid_object:isnil() <ulid-isnil>`
           - Check ULID type or nil value

..  _ulid-null:

..  data:: NULL

    A nil ULID object - a ULID that contains 16 zero bytes.

    :return: the nil ULID value
    :rtype: cdata

    Example:

    ..  code-block:: tarantoolsession

        tarantool> ulid.NULL
        ---
        - 00000000000000000000000000
        ...

..  _ulid-new:

..  function:: new()

    Create a new ULID object.

    This function uses the monotonic generator described in the
    :ref:`overview <ulid-module>`. Multiple ULIDs created within the
    same millisecond are strictly increasing.

    :return: a new ULID object
    :rtype: cdata

    Example:

    ..  code-block:: tarantoolsession

        tarantool> ulid.new()
        ---
        - 06DGE3YNDCM2PPWJT3SKTTRNZR
        ...

..  _ulid-call:

..  function:: ulid()

    Calling the module directly is the same as calling :func:`ulid.new()`.

    In other words, ``ulid()`` is a shortcut for ``ulid.new()``.

    :return: a new ULID object (same as :func:`ulid.new`)
    :rtype: cdata

    Example:

    ..  code-block:: tarantoolsession

        tarantool> ulid()
        ---
        - 06DGE41G63GAZ6F0TV4WRSVCCW
        ...

..  _ulid-str:

..  function:: str()

    Create a new ULID and return its **string** representation.

    This is a shortcut for ``ulid.new():str()``.

    The result is always 26 characters, encoded using Crockford Base32.

    :return: a ULID string
    :rtype: 26-byte string

    Example:

    ..  code-block:: tarantoolsession

        tarantool> ulid.str()
        ---
        - 06DGE480BWZ6H5BKX0KS3Q8S2G
        ...

..  _ulid-bin:

..  function:: bin()

    Create a new ULID and return its **binary** representation
    as a 16-byte string.

    This is a shortcut for ``ulid.new():bin()``.

    :return: a ULID in binary form
    :rtype: 16-byte string

    Example:

    ..  code-block:: tarantoolsession

        tarantool> #ulid.bin()
        ---
        - 16
        ...

..  _ulid-fromstr:

..  function:: fromstr(ulid_string)

    Create a ULID object from a 26-character string.

    The input must be a valid ULID string encoded using Crockford Base32.
    If the string is invalid (wrong length or invalid symbols), ``nil``
    is returned.

    :param string ulid_string: ULID in 26-character string form
    :return: converted ULID or ``nil``
    :rtype: cdata or ``nil``

    Example:

    ..  code-block:: tarantoolsession

        tarantool> u = ulid.fromstr('06DGE4FH80PHA28YZVV5Z473T4')
        tarantool> u
        ---
        - 06DGE4FH80PHA28YZVV5Z473T4
        ...

..  _ulid-frombin:

..  function:: frombin(ulid_bin)

    Create a ULID object from a 16-byte binary string.

    :param string ulid_bin: ULID in 16-byte binary string form
    :return: converted ULID
    :rtype: cdata

    Example:

    ..  code-block:: tarantoolsession

        tarantool> u1 = ulid.new()
        tarantool> b = u1:bin()
        tarantool> u2 = ulid.frombin(b)
        tarantool> u1 == u2
        ---
        - true
        ...

..  _ulid-is_ulid:

..  function:: is_ulid(value)

    Check if the given value is a ULID cdata object.

    :param value: a value of any type
    :return: ``true`` if the value is a ULID, otherwise ``false``
    :rtype: boolean

    Example:

    ..  code-block:: tarantoolsession

        tarantool> ulid.is_ulid(ulid.new())
        ---
        - true
        ...

        tarantool> ulid.is_ulid("string")
        ---
        - false
        ...

ULID object
-----------

A ULID object returned by :func:`ulid.new`, :func:`ulid.fromstr`,
or :func:`ulid.frombin` provides the following methods:

..  _ulid-object_bin:

..  method:: ulid_object:bin()

    Return the ULID as a 16-byte binary string.

    :return: ULID in binary form
    :rtype: 16-byte string

    Example:

    ..  code-block:: tarantoolsession

        tarantool> u = ulid.new()
        tarantool> b = u:bin()
        tarantool> #b, b
        ---
        - 16
        - "\x01\x9B\a\xAD==\x81u۶-\x93hPa\xAE"
        ...

..  _ulid-object_str:

..  method:: ulid_object:str()

    Return the ULID as a 26-character string.

    :return: ULID in string form
    :rtype: 26-byte string

    ULID objects also implement the standard Lua ``__tostring`` metamethod.
    This means that calling ``tostring(u)`` for a ULID object ``u`` returns
    the same value as ``u:str()``, and ULID objects are automatically
    converted to their 26-character string representation when needed
    in string context.

    Example:

    ..  code-block:: tarantoolsession

        tarantool> u = ulid.new()
        tarantool> u:str(), tostring(u)
        ---
        - 06DGFBE3J07B7DB5A3JP4WQ9CM
        - 06DGFBE3J07B7DB5A3JP4WQ9CM
        ...

..  _ulid-isnil:

..  method:: ulid_object:isnil()

    Check if the ULID is the nil ULID (all 16 bytes are zero).

    :return: ``true`` for :data:`ulid.NULL`, otherwise ``false``
    :rtype: boolean

    Example:

    ..  code-block:: tarantoolsession

        tarantool> ulid.NULL:isnil()
        ---
        - true
        ...

        tarantool> ulid.new():isnil()
        ---
        - false
        ...

Examples
--------

Basic usage:

..  code-block:: tarantoolsession

    tarantool> u_obj = ulid.new()
    tarantool> u_str = ulid.str()
    tarantool> u_bin = ulid.bin()

    tarantool> u_obj, u_str, u_bin
    ---
    - 06DGE6SEZDCFFSFEAJFMC9YQAR
    - 06DGE6T0DW0N2N6KMPVZ8SGE4W
    - "\x01\x9B\a\eSz8\xBA\xB3\xC5\xCC\xFE\x18\xBB1\xD6"
    ...

Creating a ULID object and inspecting it:

..  code-block:: tarantoolsession

    tarantool> u = ulid()
    ---
    ...

    tarantool> #u:bin(), #u:str(), type(u), u:isnil()
    ---
    - 16
    - 26
    - cdata
    - false
    ...

    tarantool> tostring(u) == u:str()
    ---
    - true
    ...

Converting between string and binary formats:

..  code-block:: tarantoolsession

    tarantool> s = ulid.str()
    tarantool> s
    ---
    - 06DGE70CPFDV344XX43687N1SM
    ...

    tarantool> u = ulid.fromstr(s)
    tarantool> u:str() == s
    ---
    - true
    ...

    tarantool> b = u:bin()
    tarantool> u2 = ulid.frombin(b)
    tarantool> u2 == u
    ---
    - true
    ...

Working with ``ulid.NULL``:

..  code-block:: tarantoolsession

    tarantool> ulid.NULL
    ---
    - 00000000000000000000000000
    ...

    tarantool> ulid.NULL:isnil()
    ---
    - true
    ...

    tarantool> ulid.new():isnil()
    ---
    - false
    ...

Comparison operators:

..  code-block:: tarantoolsession

    tarantool> u1 = ulid.new()
    tarantool> u2 = ulid.new()
    tarantool> u1 < u2
    ---
    - true
    ...

Checking types:

..  code-block:: tarantoolsession

    tarantool> u = ulid.new()
    tarantool> ulid.is_ulid(u)
    ---
    - true
    ...

    tarantool> ulid.is_ulid("06DGE7RJK8QWJE27X5VVCC5VDW")
    ---
    - false
    ...

Generating many ULIDs:

..  code-block:: tarantoolsession

    tarantool> for i = 1,5 do print(ulid.str()) end
    ---
    06DGE7T8AJD6EDNJ3VQ2ZYB3R4
    06DGE7T8AJD6EDNJ3VQ2ZYB3R8
    06DGE7T8AJD6EDNJ3VQ2ZYB3RC
    06DGE7T8AJD6EDNJ3VQ2ZYB3RG
    06DGE7T8AJD6EDNJ3VQ2ZYB3RM
    ...

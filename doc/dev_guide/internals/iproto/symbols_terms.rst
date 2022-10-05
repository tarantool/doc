..  _box_protocol-notation:

Symbols and terms
=================

This section describes some conventions that will be used throughout the
binary protocol documentation.

MP_* MessagePack types
----------------------

Words that start with **MP_** mean
a `MessagePack <http://MessagePack.org>`_ type or a range of MessagePack types,
including the signal and possibly including a value, with slight modification:

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   **MP_NIL**
            -   nil
        *   -   **MP_UINT**
            -   unsigned integer
        *   -   **MP_INT**
            -   either integer or unsigned integer
        *   -   **MP_STR**
            -   string
        *   -   **MP_BIN**
            -   binary string
        *   -   **MP_ARRAY** 
            -   array
        *   -   **MP_MAP**
            -   map
        *   -   **MP_BOOL**
            -   boolean
        *   -   **MP_FLOAT**
            -   float
        *   -   **MP_DOUBLE**
            -   double
        *   -   **MP_EXT**
            -   :ref:`extension <internals-msgpack_ext>`
        *   -   **MP_OBJECT**
            -   any MessagePack object

Short descriptions are in MessagePack's `"spec" page <https://github.com/msgpack/msgpack/blob/master/spec.md>`_.

Formatting convention
---------------------

To denote message descriptions in this document, we will say ``msgpack(...)`` and within it we will use modified
`YAML <https://en.wikipedia.org/wiki/YAML>`_ so: |br|

:code:`{...}` braces enclose an associative array, also called map, which in MsgPack is MP_MAP.

:samp:`{k}: {v}` is a key-value pair, also called map-item.
In this section, ``k`` is always an unsigned-integer value = one of the IPROTO constants.

:samp:`{italics}` are for replaceable text, which is the convention throughout this manual.

:code:`[...]` is for non-associative arrays.

:code:`#` starts a comment, especially for the beginning of a section.

Everything else is "as is".

Map-items may appear in any order but in examples we usually use the order that ``net_box.c`` happens to use.

All IPROTO constants are unsigned 8-bit integers.

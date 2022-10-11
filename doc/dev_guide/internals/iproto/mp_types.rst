..  _box_protocol-notation:

MP_* MessagePack types
======================

The binary protocol handles data in the MessagePack format, which makes use of MessagePack data types.

This document makes use of words that start with **MP_**. They mean
a `MessagePack <http://MessagePack.org>`_ type or a range of MessagePack types,
including the signal and possibly including a value, with slight modification:

..  container:: table

    ..  list-table::
        :widths: 40 60
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

..  _box_protocol-notation:

MP_* MessagePack types
======================

The binary protocol handles data in the  `MessagePack <http://MessagePack.org>`_ format.
Short descriptions of the basic MessagePack data types 
are on MessagePack's `"spec" page <https://github.com/msgpack/msgpack/blob/master/spec.md>`_.
Tarantool also introduces several MessagePack type :ref:`extensions <internals-msgpack_ext>`.

In this document, MessagePack types are described by words that start with **MP_**.
See this table:


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

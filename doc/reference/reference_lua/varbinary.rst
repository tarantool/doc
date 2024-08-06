..  _varbinary-module:

Module varbinary
================

**Since:** :doc:`3.0.0 </release/3.0.0>`

.. _varbinary-module-overview:

Overview
--------

The ``varbinary`` module provides functions for operating variable-length binary
objects in Lua. It provides functions for creating ``varbinary`` objects, checking their type,
and also defines basic operators on such objects.

For example:

..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
    :language: lua
    :start-at: local
    :end-before: local bin2
    :dedent:

.. _varbinary-module-overview-encode:

Encoding varbinary objects
~~~~~~~~~~~~~~~~~~~~~~~~~~

``varbinary`` objects preserve their binary type when encoded by the built-in :ref:`MsgPack <msgpack-module>`
and :ref:`YAML <yaml-module>` encoders. See the difference with strings:

-   String to MsgPack:

    .. code-block:: tarantoolsession

        tarantool> msgpack.encode('\xFF\xFE')
        ---
        - "\xA2\xFF\xFE"
        ...

-   ``varbinary`` to MsgPack:

    .. code-block:: tarantoolsession

        tarantool> msgpack.encode(varbinary.new('\xFF\xFE'))
        ---
        - "\xC4\x02\xFF\xFE"
        ...

-   String to YAML:

    .. code-block:: tarantoolsession

        tarantool> '\xFF\xFE'
        ---
        - "\xFF\xFE"
        ...

-   ``varbinary`` to YAML:

    .. code-block:: tarantoolsession

        tarantool> varbinary.new('\xFF\xFE')
        ---
        - !!binary //4=
        ...

.. note::

    The JSON format doesn't support the binary type so varbinary objects are encoded
    as plain strings in JSON:

    .. code-block:: tarantoolsession

        tarantool> json.encode('\xFF\xFE')
        ---
        - "\"\xFF\xFE\""
        ...

        tarantool> json.encode(varbinary.new('\xFF\xFE'))
        ---
        - "\"\xFF\xFE\""
        ...

.. _varbinary-module-overview-decode:

Decoding binary data to varbinary objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The built-in decoders also decode binary data fields (fields with the
``binary`` tag in YAML and the ``MP_BIN`` type in MsgPack) to varbinary
objects by default:

.. code-block:: tarantoolsession

    tarantool> varbinary.is(msgpack.decode('\xC4\x02\xFF\xFE'))
    ---
    - true
    ...

    tarantool> varbinary.is(yaml.decode('!!binary //4='))
    ---
    - true
    ...

.. important::

    This behavior is different from what it was before Tarantool 3.0.
    In earlier versions, such fields were decoded to plain strings.
    To return to this behavior, use the ``compat`` option
    :ref:`binary_data_decoding <compat-option-binary-decoding>`.

.. _varbinary-module-api-reference:

API Reference
-------------

Below is a list of ``varbinary`` functions, properties, and related objects.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -
        *   -   :ref:`varbinary.is() <varbinary_is>`
            -   Check that the argument is a ``varbinary`` object

        *   -   :ref:`varbinary.new() <varbinary_new_string>`
            -   Create a ``varbinary`` object

        *   -   **Metamethods**
            -

        *   -   :ref:`varbinary_object.__eq <varbinary_eq>`
            -   Checks the equality of two ``varbinary`` objects

        *   -   :ref:`varbinary_object.__len <varbinary_len>`
            -   Returns the length of the binary data in bytes

        *   -   :ref:`varbinary_object.__tostring <varbinary_tostring>`
            -   Returns the binary data in a plain string


.. module:: varbinary

..  _varbinary-module-api-reference-functions:

Functions
~~~~~~~~~

.. _varbinary_is:

.. function:: is(object)

    Check that the given object is a ``varbinary`` object.

    :param object object: an object to check

    :return: Whether the given object is of ``varbinary`` type
    :rtype: boolean

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: bin = varbinary.new('data')
        :end-at: varbinary.is('data') -- false
        :dedent:

.. _varbinary_new_string:

.. function:: new(string)

    Create a new ``varbinary`` object from a given string.

    :param string string: a string object
    :return: A ``varbinary`` object containing the string data

    :rtype: cdata

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: bin = varbinary.new('data')
        :end-before: varbinary.is(100) -- false
        :dedent:

.. _varbinary_new_ptr:

.. function:: new(ptr, size)

    Create a new ``varbinary`` object from a ``cdata`` pointer and size.

    :param cdata ptr: a ``cdata`` pointer
    :param number size: object size in bytes
    :return: A ``varbinary`` object containing the data

    :rtype: cdata

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: local bin2
        :end-at: print(bin2) -- data
        :dedent:

..  _varbinary-module-api-reference-metamethods:

Metamethods
~~~~~~~~~~~

.. class:: varbinary_object

    .. _varbinary_eq:

    .. method:: __eq(object)

        Checks the equality of two ``varbinary`` objects or a ``varbinary`` object and a string.
        A ``varbinary`` object equals to another ``varbinary`` object or a string if it
        contains the same data.

        Defines the ``==`` and ``~=`` operators for ``varbinary`` objects.

        :rtype: boolean

        **Example:**

        ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
            :language: lua
            :start-at: print(bin == 'data') -- true
            :end-at: print(bin ~= 'data1') -- true
            :dedent:

    .. _varbinary_len:

    .. method:: __len()

        Returns the length of a ``varbinary`` object in bytes.

        Defines the ``#`` operator for ``varbinary`` objects.

        :rtype: number

        **Example:**

        ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
            :language: lua
            :start-at: print(#bin) -- 4
            :end-at: print(#varbinary.new('\xFF\xFE')) -- 2
            :dedent:

    .. _varbinary_tostring:

    .. method:: __tostring()

        Returns a ``varbinary`` object data in a plain string.
        
        Defines the ``tostring()`` function for ``varbinary`` objects.

        :rtype: string

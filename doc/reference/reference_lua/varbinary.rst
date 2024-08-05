..  _varbinary-module:

Module varbinary
================

.. _varbinary-module-overview:

Overview
--------

The ``varbinary`` module provides functions for operating binary objects in Lua.

This module provides functions for creating varbinary objects


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
            -   Check that the argument is a varbinary object

        *   -   :ref:`varbinary.new() <varbinary_new>`
            -   Create a varbinary object

        *   -   **Metamethods**
            -

        *   -   :ref:`varbinary_object.__eq <varbinary_eq>`
            -   Checks the equality of two varbinary ojbects

        *   -   :ref:`varbinary_object.__len <varbinary_len>`
            -   Returns the length of the binary data in bytes

        *   -   :ref:`varbinary_object.__tostring <varbinary_tostring>`
            -   Returns the binary data in a plain string


.. module:: varbinary

..  _varbinary-module-api-reference-functions:

Functions
~~~~~~~~~

.. _varbinary-new:

.. function:: new(data[, size])

    Create a new varbinary object from a given string or a cdata pointer and size.

    **See also:** :ref:`uri.format() <uri-format>`

    :param string data: a string or a cdata pointer
    :param number size: (optional) object size if ``data`` is a cdata pointer
    :return: a varbinary object containing the data

    :rtype: varbinary

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: bin = varbinary.new('data')
        :end-before: print(bin)
        :dedent:


.. _varbinary_is:

.. function:: is(object)

    Check that the given object is a varbinary object.

    :param object object: an object to check

    :return: Whether the given object is a varbinary object
    :rtype: boolean

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: bin = varbinary.new('data')
        :end-at: varbinary.is('data') -- false
        :dedent:

..  _varbinary-module-api-reference-metamethods:

Metamethods
~~~~~~~~~~~

.. _varbinary_eq:

.. function:: __eq (== and ~= operators)

    Checks the equality of two varbinary objects or a varbinary object and a string.
    A varbinary object equals to a another varbinary object of a string if it
    contains the same data.

    Defines the ``==`` and ``~=`` operators for varbinary objects.

    :rtype: boolean

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: bin = varbinary.new('data')
        :end-at: varbinary.is('data') -- false
        :dedent:

.. _varbinary_len:

.. function:: __len (# operator)

    Returns the length of a varbinary object in bytes.

    Defines the ``#`` operator for varbinary objects.

    :rtype: number

    **Example:**

    ..  literalinclude:: /code_snippets/test/varbinary/varbinary_test.lua
        :language: lua
        :start-at: print(#bin) -- 4
        :end-at: print(#varbinary.new('\xFF\xFE')) -- 2
        :dedent:

.. _varbinary_tostring:

.. function:: __tostring

    Returns a varbinary object data in a plain string

    :rtype: string

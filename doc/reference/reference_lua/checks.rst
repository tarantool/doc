..  checks-module:

Module checks
=============

**Since:** :doc:`2.11.0 </release/2.11.0>`

The ``checks`` module provides the ability to check the types of arguments passed to a Lua function.
You need to call the :ref:`checks(type_1, ...) <checks-checks>` function inside the target Lua function and pass :ref:`one or more <checks_number_of_arguments>` type qualifiers to check the corresponding argument types.
There are two types of type qualifiers:

-   A :ref:`string type qualifier <checks_string_type_qualifier>` checks whether a function's argument conforms to the specified type. Example: ``'string'``.
-   A :ref:`table type qualifier <checks_table_type_qualifiers>` checks whether the values of a table passed as an argument conform to the specified types. Example: ``{ 'string', 'number' }``.

.. NOTE::

    For earlier versions, you can install the ``checks`` module from the `Tarantool rocks repository <https://www.tarantool.io/en/download/rocks>`_.

.. _checks_loading:

Loading checks
--------------

In Tarantool :doc:`2.11.0 </release/2.11.0>` and later versions, the :ref:`checks API <checks_api_reference>` is available in a script without loading the module.

For earlier versions, you need to install the ``checks`` module from the Tarantool rocks repository and load the module using the ``require()`` directive:

.. code-block:: lua

    local checks = require('checks')


.. _checks_number_of_arguments:

Number of arguments to check
----------------------------

For each argument to check, you need to specify its own type qualifier in the :ref:`checks(type_1, ...) <checks-checks>` function.

.. _checks_one_argument:

One argument
~~~~~~~~~~~~

In the example below, the ``checks`` function accepts a ``string`` type qualifier to verify that only a string value can be passed to the ``greet`` function.
Otherwise, an error is raised.

..  literalinclude:: /code_snippets/test/checks/checks_string_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:


.. _checks_multiple_arguments:

Multiple arguments
~~~~~~~~~~~~~~~~~~

To check the types of several arguments, you need to pass the corresponding type qualifiers to the ``checks`` function.
In the example below, both arguments should be string values.

..  literalinclude:: /code_snippets/test/checks/checks_string_multiple_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:

To skip checking specific arguments, use the :ref:`? placeholder <checks_any_type>`.


.. _checks_variable_number_of_arguments:

Variable number of arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can check the types of explicitly specified arguments for functions that accept a variable number of arguments.

..  literalinclude:: /code_snippets/test/checks/checks_vararg_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:



.. _checks_string_type_qualifier:

String type qualifier
---------------------

This section describes how to check a specific argument type using a string type qualifier:

- The :ref:`Supported types <checks_string_supported_types>` section describes all the types supported by the ``checks`` module.
- If required, you can make a :ref:`union type <checks_union_type>` to allow an argument to accept several types.
- You can make any of the supported types :ref:`optional <checks_optional_type>`.
- To skip checking specific arguments, use the :ref:`? placeholder <checks_any_type>`.

.. _checks_string_supported_types:

Supported types
~~~~~~~~~~~~~~~

.. _checks_lua_types:

Lua types
*********

A string type qualifier can accept any of the `Lua types <https://www.lua.org/pil/2.html>`_, for example, ``string``, ``number``, ``table``, or ``nil``.
In the example below, the ``checks`` function accepts ``string`` to validate that only a string value can be passed to the ``greet`` function.

..  literalinclude:: /code_snippets/test/checks/checks_string_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:


.. _checks_tarantool_types:

Tarantool types
***************

You can use :ref:`Tarantool-specific types <index_box_field_type_details>` in a string qualifier.
The example below shows how to check that a function argument is a decimal value.

..  literalinclude:: /code_snippets/test/checks/checks_decimal_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:

This table lists all the checks available for Tarantool types:

..  container:: table

    ..  list-table::
        :widths: 30 40 30
        :header-rows: 1

        *   -   Check
            -   Description
            -   See also

        *   -   ``checks('datetime')``
            -   Check whether the specified value is :ref:`datetime_object <datetime_obj>`
            -   :ref:`checkers.datetime(value) <checks-checkers-datetime>`

        *   -   ``checks('decimal')``
            -   Check whether the specified value has the :ref:`decimal <decimal>` type
            -   :ref:`checkers.decimal(value) <checks-checkers-decimal>`

        *   -   ``checks('error')``
            -   Check whether the specified value is :ref:`error_object <box_error-error_object>`
            -   :ref:`checkers.error(value) <checks-checkers-error>`

        *   -   ``checks('int64')``
            -   Check whether the specified value is an ``int64`` value
            -   :ref:`checkers.int64(value) <checks-checkers-int64>`

        *   -   ``checks('interval')``
            -   Check whether the specified value is :ref:`interval_object <interval_obj>`
            -   :ref:`checkers.interval(value) <checks-checkers-interval>`

        *   -   ``checks('tuple')``
            -   Check whether the specified value is a :ref:`tuple <box_tuple-new>`
            -   :ref:`checkers.tuple(value) <checks-checkers-tuple>`

        *   -   ``checks('uint64')``
            -   Check whether the specified value is a ``uint64`` value
            -   :ref:`checkers.uint64(value) <checks-checkers-uint64>`

        *   -   ``checks('uuid')``
            -   Check whether the specified value is :ref:`uuid_object <uuid-module>`
            -   :ref:`checkers.uuid(value) <checks-checkers-uuid>`

        *   -   ``checks('uuid_bin')``
            -   Check whether the specified value is :ref:`uuid <uuid-module>` represented by a 16-byte binary string
            -   :ref:`checkers.uuid_bin(value) <checks-checkers-uuid_bin>`

        *   -   ``checks('uuid_str')``
            -   Check whether the specified value is :ref:`uuid <uuid-module>` represented by a 36-byte hexadecimal string
            -   :ref:`checkers.uuid_str(value) <checks-checkers-uuid_str>`



.. _checks_custom_function:

Custom function
***************

A string type qualifier can accept the name of a custom function that performs arbitrary validations.
To achieve this, create a function returning ``true`` if the value is valid and add this function to the :ref:`checkers <checks-checkers>` table.

The example below shows how to use the ``positive`` function to check that an argument value is a positive number.

..  literalinclude:: /code_snippets/test/checks/checks_function_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:


.. _checks_metatable_type:

Metatable type
**************

A string qualifier can accept a value stored in the ``__type`` field of the argument `metatable <https://www.lua.org/pil/13.html>`_.

..  literalinclude:: /code_snippets/test/checks/checks_metatable_type_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:


.. _checks_union_type:

Union types
~~~~~~~~~~~

To allow an argument to accept several types (a union type), concatenate type names with a pipe (``|``).
In the example below, the argument can be both a ``number`` and ``string`` value.

..  literalinclude:: /code_snippets/test/checks/checks_type_combination_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:



.. _checks_optional_type:

Optional types
~~~~~~~~~~~~~~

To make any of the supported types optional, prefix its name with a question mark (``?``).
In the example below, the ``name`` argument is optional.
This means that the ``greet`` function can accept ``string`` and ``nil`` values.

..  literalinclude:: /code_snippets/test/checks/checks_string_optional_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:

As for a specific type, you can make a :ref:`union type <checks_union_type>` value optional: ``?number|string``.


.. _checks_any_type:

Skipping argument checking
~~~~~~~~~~~~~~~~~~~~~~~~~~

You can skip checking of the specified arguments using the question mark (``?``) placeholder.
In this case, the argument can be any type.

..  literalinclude:: /code_snippets/test/checks/checks_any_optional_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:




.. _checks_table_type_qualifiers:

Table type qualifier
--------------------

A table type qualifier checks whether the values of a table passed as an argument conform to the specified types.
In this case, the following checks are made:

-   The argument is checked to conform to the ``?table`` type, and its content is validated.
-   Table values are validated against the specified :ref:`string type qualifiers <checks_string_type_qualifier>`.
-   Table keys missing in ``checks`` are validated against the ``nil`` type.

The code below checks that the first and second table values have the ``string`` and ``number`` types.

..  literalinclude:: /code_snippets/test/checks/checks_table_indexes_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:

In the next example, the same checks are made for the specified keys.

..  literalinclude:: /code_snippets/test/checks/checks_table_keys_test.lua
    :language: lua
    :end-before: -- Tests
    :dedent:

.. NOTE::

    Table qualifiers can be nested and use tables, too.



.. _checks_api_reference:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Members**
            -

        *   -   :ref:`checks() <checks-checks>`
            -   When called inside a function, checks that the function's arguments conform to the specified types

        *   -   :ref:`checkers <checks-checkers>`
            -   A global variable that provides access to checkers for different types


..  _checks-checks:

checks()
~~~~~~~~

..  function:: checks(type_1, ...)

    When called inside a function, checks that the function's arguments conform to the specified types.

    :param string/table type_1: a :ref:`string <checks_string_type_qualifier>` or :ref:`table <checks_table_type_qualifiers>` type qualifier used to check the argument type
    :param ...: optional type qualifiers used to check the types of :ref:`other arguments <checks_number_of_arguments>`

..  _checks-checkers:

checkers
~~~~~~~~

The ``checkers`` global variable provides access to checkers for different types.
You can use this variable to add a :ref:`custom checker <checks_custom_function>` that performs arbitrary validations.

.. NOTE::

    The ``checkers`` variable also provides access to checkers for Tarantool-specific types.
    These checkers can be used in a custom checker.

.. _checks-checkers-datetime:

.. function:: checkers.datetime(value)

    Check whether the specified value is :ref:`datetime_object <datetime_obj>`.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is ``datetime_object``; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: datetime/interval checkers
        :end-before: is_datetime/is_interval = true

    .. _checks-checkers-decimal:

.. function:: checkers.decimal(value)

    Check whether the specified value has the :ref:`decimal <decimal>` type.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value has the ``decimal`` type; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: decimal checker
        :end-before: is_decimal = true


.. _checks-checkers-error:

.. function:: checkers.error(value)

    Check whether the specified value is :ref:`error_object <box_error-error_object>`.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is ``error_object``; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: error checker
        :end-before: is_error = true


.. _checks-checkers-int64:

.. function:: checkers.int64(value)

    Check whether the specified value is one of the following ``int64`` values:

    *  a Lua number in a range from -2^53+1 to 2^53-1 (inclusive)
    *  Lua cdata ``ctype<uint64_t>`` in a range from 0 to ``LLONG_MAX``
    *  Lua cdata ``ctype<int64_t>``

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is an ``int64`` value; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: int64/uint64 checkers
        :end-before: is_int64/is_uint64 = true


.. _checks-checkers-interval:

.. function:: checkers.interval(value)

    Check whether the specified value is :ref:`interval_object <interval_obj>`.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is ``interval_object``; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: datetime/interval checkers
        :end-before: is_datetime/is_interval = true


.. _checks-checkers-tuple:

.. function:: checkers.tuple(value)

    Check whether the specified value is a :ref:`tuple <box_tuple-new>`.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is a tuple; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: tuple checker
        :end-before: is_tuple = true


.. _checks-checkers-uint64:

.. function:: checkers.uint64(value)

    Check whether the specified value is one of the following ``uint64`` values:

    *  a Lua number in a range from 0 to 2^53-1 (inclusive)
    *  Lua cdata ``ctype<uint64_t>``
    *  Lua cdata ``ctype<int64_t>`` in range from 0 to ``LLONG_MAX``

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is an ``uint64`` value; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: int64/uint64 checkers
        :end-before: is_int64/is_uint64 = true


.. _checks-checkers-uuid:

.. function:: checkers.uuid(value)

    Check whether the specified value is :ref:`uuid_object <uuid-module>`.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is ``uuid_object``; otherwise, ``false``
    :rtype: boolean

    **Example**

    ..  literalinclude:: /code_snippets/test/checks/checkers_test.lua
        :language: lua
        :start-after: uuid checkers
        :end-before: is_uuid/is_uuid_bin/is_uuid_str = true


.. _checks-checkers-uuid_bin:

.. function:: checkers.uuid_bin(value)

    Check whether the specified value is :ref:`uuid <uuid-module>` represented by a 16-byte binary string.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is ``uuid`` represented by a 16-byte binary string; otherwise, ``false``
    :rtype: boolean

    **See also:** :ref:`uuid(value) <checks-checkers-uuid>`


.. _checks-checkers-uuid_str:

.. function:: checkers.uuid_str(value)

    Check whether the specified value is :ref:`uuid <uuid-module>` represented by a 36-byte hexadecimal string.

    :param any value: the value to check the type for

    :return: ``true`` if the specified value is ``uuid`` represented by a 36-byte hexadecimal string; otherwise, ``false``
    :rtype: boolean

    **See also:** :ref:`uuid(value) <checks-checkers-uuid>`

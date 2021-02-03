
================================================================================
Examples and templates
================================================================================

In this document we explain general guidelines for describing Tarantool API and
give some examples and templates.

Use this checklist for documenting a function or a method:

* Base description
* Parameters
* What this function returns (if nothing, write 'none')
* Return type (if exists)
* Possible errors (if exist)
* Complexity factors (if exist)
* Note re storage engine (if exists)
* Example(s)
* Extra information (if needed)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Documenting function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We describe functions of Tarantool modules via Sphinx directives ``.. module::``
and ``.. function::``:

..  code-block:: rst

    ..  module:: fiber

    ..  function:: create(function [, function-arguments])

        Create and start a fiber. The fiber is created and begins to run immediately.

        :param function: the function to be associated with the fiber
        :param function-arguments: what will be passed to function

        :return: created fiber object
        :rtype: userdata

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> fiber = require('fiber')
            ---
            ...
            tarantool> function function_name()
                     >   print("I'm a fiber")
                     > end
            ---
            ...
            tarantool> fiber_object = fiber.create(function_name); print("Fiber started")
            I'm a fiber
            Fiber started
            ---
            ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Documenting class method and data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of documenting a method and a data of a class ``index_object``:

..  code-block:: rst

    ..  class:: index_object

        ..  method:: get(key)

            Search for a tuple via the given index, as described :ref:`here <box_index-note>`.

            :param index_object index_object: an :ref:`object reference
                                              <app_server-object_reference>`.
            :param scalar/table      key: values to be matched against the index key

            :return: the tuple whose index-key fields are equal to the passed key values
            :rtype:  tuple

            **Possible errors:**

            * no such index;
            * wrong type;
            * more than one tuple matches.

            **Complexity factors:** Index size, Index type.
            See also :ref:`space_object:get() <box_space-get>`.

            **Example:**

            ..  code-block:: tarantoolsession

                tarantool> box.space.tester.index.primary:get(2)
                ---
                - [2, 'Music']
                ...

        For documenting a data, a description, a return type and an example will be enough:

        ..  data:: unique

            True if the index is unique, false if the index is not unique.

            :rtype: boolean

            ..  code-block:: tarantoolsession

                tarantool> box.space.tester.index.primary.unique
                ---
                - true
                ...

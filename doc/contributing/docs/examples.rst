
===========================================================
               Examples and templates
===========================================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
               Module and function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of documenting a module (``my_fiber``) and a function
(``my_fiber.create``).

.. module:: my_fiber

.. function:: create(function [, function-arguments])

    Create and start a ``my_fiber`` object. The object is created and begins to
    run immediately.

    :param function: the function to be associated with the ``my_fiber`` object
    :param function-arguments: what will be passed to function

    :return: created ``my_fiber`` object
    :rtype: userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> my_fiber = require('my_fiber')
        ---
        ...
        tarantool> function function_name()
                 >   my_fiber.sleep(1000)
                 > end
        ---
        ...
        tarantool> my_fiber_object = my_fiber.create(function_name)
        ---
        ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
               Module, class and method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of documenting a module (``my_box.index``), a class
(``my_index_object``) and a function (``my_index_object.rename``).

.. module:: my_box.index

.. class:: my_index_object

    .. method:: rename(index-name)

        Rename an index.

        :param index_object: an object reference
        :param index_name: a new name for the index (type = string)

        :return: nil

        Possible errors: index_object does not exist.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:rename('secondary')
            ---
            ...

        Complexity Factors: Index size, Index type, Number of tuples accessed.

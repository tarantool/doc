.. _box_schema-func_drop:

===============================================================================
box.schema.func.drop()
===============================================================================

.. module:: box.schema

.. function:: box.schema.func.drop(func-name [, {options}])

    Drop a function tuple.
    For explanation of how Tarantool maintains function data, see
    reference on :ref:`_func space <box_space-func>`.

    :param string func-name: the name of the function
    :param table options: ``if_exists`` = ``true|false`` (default = ``false``) - boolean;
                          ``true`` means there should be no error if the _func tuple does not exist.

    **Example:**

    .. code-block:: lua

        box.schema.func.drop('calculate')

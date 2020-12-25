.. _box_schema-func_create:

===============================================================================
box.schema.func.create()
===============================================================================

.. module:: box.schema

.. function:: box.schema.func.create(func-name [, {options}])

    Create a function :ref:`tuple <index-box_tuple>`.
    This does not create the function itself -- that is done with Lua --
    but if it is necessary to grant privileges for a function,
    box.schema.func.create must be done first.
    For explanation of how Tarantool maintains function data, see
    reference on :ref:`_func <box_space-func>` space.

    The possible options are:

    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means there should be no error if the ``_func`` tuple already exists.

    * ``setuid`` = ``true|false`` (default = false) - with ``true`` to make Tarantool
      treat the function’s caller as the function’s creator, with full privileges.
      Remember that SETUID works only over
      :ref:`binary ports <admin-security>`.
      SETUID doesn't work if you invoke a function via an
      :ref:`admin console <admin-security>` or inside a Lua script.

    * ``language`` = 'LUA'|'C' (default = ‘LUA’).

    :param string func-name: name of function, which should
                             conform to the :ref:`rules for object names <app_server-names>`
    :param table options: ``if_not_exists``, ``setuid``, ``language``.

    :return: nil

    **Example:**

    .. code-block:: lua

        box.schema.func.create('calculate')
        box.schema.func.create('calculate', {if_not_exists = false})
        box.schema.func.create('calculate', {setuid = false})
        box.schema.func.create('calculate', {language = 'LUA'})

.. _box_schema-func_create:

===============================================================================
box.schema.func.create()
===============================================================================

.. module:: box.schema

.. _box_schema-func_create_with-body:

.. function:: box.schema.func.create(func_name [, function_options])

    Create a function.
    The created function can be used in different usage scenarios,
    for example, in :ref:`field or tuple constraints <index-constraints>` or
    :ref:`functional indexes <box_space-index_func>`.

    Using the :ref:`body <function_options_body>` option, you can make a function *persistent*.
    In this case, the function is "persistent" because its definition is stored in a snapshot (the :ref:`box.space._func <box_space-func>` system space) and can be recovered if the server restarts.

    :param string func_name: a name of the function, which should
                             conform to the :ref:`rules for object names <app_server-names>`
    :param table function_options: see :ref:`function_options <func_create_function_options>`

    :return: nil

    .. NOTE::

        :ref:`box.schema.user.grant() <box_schema-user_grant>` can be used to allow the specified user or
        role to execute the created function.

    **Example 1: a non-persistent Lua function**

    The example below shows how to create a non-persistent Lua function:

    .. code-block:: lua

        box.schema.func.create('calculate')
        box.schema.func.create('calculate', {if_not_exists = false})
        box.schema.func.create('calculate', {setuid = false})
        box.schema.func.create('calculate', {language = 'LUA'})


    **Example 2: a persistent Lua function**

    The example below shows how to create a persistent Lua function,
    show its definition using ``box.func.{func-name}``,
    and call this function using ``box.func.{func-name}:call([parameters])``:

    .. code-block:: tarantoolsession

        tarantool> lua_code = [[function(a, b) return a + b end]]
        tarantool> box.schema.func.create('sum', {body = lua_code})

        tarantool> box.func.sum
        ---
        - is_sandboxed: false
          is_deterministic: false
          id: 2
          setuid: false
          body: function(a, b) return a + b end
          name: sum
          language: LUA
        ...

        tarantool> box.func.sum:call({1, 2})
        ---
        - 3
        ...

    To call functions using ``net.box``, use :ref:`net_box:call() <net_box-call>`.

    .. _box_schema-func_example-sql:

    **Example 3: a persistent SQL expression used in a tuple constraint**

    The code snippet below defines a function that checks a tuple's data using the SQL expression:

    ..  literalinclude:: /code_snippets/test/constraints/constraint_sql_expr_test.lua
        :language: lua
        :start-after: create_constraint_start
        :end-before: create_constraint_end
        :dedent:

    Then, this function is used to create a tuple :ref:`constraint <index-constraints>`:

    ..  literalinclude:: /code_snippets/test/constraints/constraint_sql_expr_test.lua
        :language: lua
        :start-after: configure_space_start
        :end-before: configure_space_end
        :dedent:

    On an attempt to insert a tuple that doesn't meet the required criteria, an error is raised:

    ..  literalinclude:: /code_snippets/test/constraints/constraint_sql_expr_test.lua
        :language: lua
        :start-after: insert_age_error_start
        :end-before: insert_age_error_end
        :dedent:

.. _func_create_function_options:

function_options
~~~~~~~~~~~~~~~~

..  class:: function_options

    A table containing options passed to the :ref:`box.schema.func.create(func-name [, function_options]) <box_schema-func_create_with-body>` function.

    ..  _function_options_if_not_exists:

    .. data:: if_not_exists

        Specify whether there should be no error if the function already exists.

        | Type: boolean
        | Default: ``false``

    ..  _function_options_setuid:

    .. data:: setuid

        Make Tarantool treat the function's caller as the function's creator, with full privileges.
        Note that ``setuid`` works only over :ref:`binary ports <admin-security>`.
        ``setuid`` doesn't work if you invoke a function using the
        :ref:`admin console <admin-security>` or inside a Lua script.

        | Type: boolean
        | Default: ``false``

    ..  _function_options_language:

    .. data:: language

        Specify the function language.
        The possible values are:

        *   ``LUA``: define a Lua function in the :ref:`body <function_options_body>` attribute.
        *   ``SQL_EXPR``: define an :ref:`SQL expression <sql_expressions>` in the :ref:`body <function_options_body>` attribute. An SQL expression can only be used as a field or tuple :ref:`constraint <index-constraints>`.
        *   ``C``: import a C function using its name from a ``.so`` file. Learn how to call C code from Lua in the :ref:`C tutorial <f_c_tutorial-c_stored_procedures>`.

            .. NOTE::

                To reload a C module with all its functions without restarting the server, call :ref:`box.schema.func.reload() <box_schema-func_reload>`.

        | Type: string
        | Default: ``LUA``

    ..  _function_options_is_sandboxed:

    .. data:: is_sandboxed

        Whether the function should be executed in an isolated environment.
        This means that any operation that accesses the world outside the sandbox is forbidden or has no effect.
        Therefore, a sandboxed function can only use modules and functions
        that cannot affect isolation:

        `assert <https://www.lua.org/manual/5.1/manual.html#pdf-assert>`_,
        `assert <https://www.lua.org/manual/5.1/manual.html#pdf-assert>`_,
        `error <https://www.lua.org/manual/5.1/manual.html#pdf-error>`_,
        `ipairs <https://www.lua.org/manual/5.1/manual.html#pdf-ipairs>`_,
        `math.* <https://www.lua.org/manual/5.1/manual.html#5.6>`_,
        `next <https://www.lua.org/manual/5.1/manual.html#pdf-next>`_,
        `pairs <https://www.lua.org/manual/5.1/manual.html#pdf-pairs>`_,
        `pcall <https://www.lua.org/manual/5.1/manual.html#pdf-pcall>`_,
        `print <https://www.lua.org/manual/5.1/manual.html#pdf-print>`_,
        `select <https://www.lua.org/manual/5.1/manual.html#pdf-select>`_,
        `string.* <https://www.lua.org/manual/5.1/manual.html#5.4>`_,
        `table.* <https://www.lua.org/manual/5.1/manual.html#5.5>`_,
        `tonumber <https://www.lua.org/manual/5.1/manual.html#pdf-tonumber>`_,
        `tostring <https://www.lua.org/manual/5.1/manual.html#pdf-tostring>`_,
        `type <https://www.lua.org/manual/5.1/manual.html#pdf-type>`_,
        `unpack <https://www.lua.org/manual/5.1/manual.html#pdf-unpack>`_,
        `xpcall <https://www.lua.org/manual/5.1/manual.html#pdf-xpcall>`_,
        :ref:`utf8.* <utf8-module>`.

        Also, a sandboxed function cannot refer to global variables -- they
        are treated as local variables because the sandbox is established
        with `setfenv <https://www.lua.org/manual/5.1/manual.html#pdf-setfenv>`_.
        So, a sandboxed function is stateless and deterministic.

        | Type: boolean
        | Default: ``false``

    ..  _function_options_is_deterministic:

    .. data:: is_deterministic

        Specify whether a function should be deterministic.

        | Type: boolean
        | Default: ``false``

    ..  _function_options_is_multikey:

    .. data:: is_multikey

        If ``true`` is set in the function definition for a functional index, the function returns multiple keys.
        For details, see the :ref:`example <box_space-index_func_multikey>`.

        | Type: boolean
        | Default: ``false``

    ..  _function_options_body:

    .. data:: body

        Specify a function body.
        You can set a function's language using the :ref:`language <function_options_language>` attribute.

        The code snippet below defines a :ref:`constraint <index-constraints>` function that checks a tuple's data using a Lua function:

        ..  literalinclude:: /code_snippets/test/constraints/constraint_test.lua
            :language: lua
            :lines: 22-26
            :dedent:

        In the following example, an SQL expression is used to check a tuple's data:

        ..  literalinclude:: /code_snippets/test/constraints/constraint_sql_expr_test.lua
            :language: lua
            :start-after: create_constraint_start
            :end-before: create_constraint_end
            :dedent:

        Example: :ref:`A persistent SQL expression used in a tuple constraint <box_schema-func_example-sql>`

        | Type: string
        | Default: ``nil``

    ..  _function_options_takes_raw_args:

    .. data:: takes_raw_args

        **Since:** :doc:`2.10.0 </release/2.10.0>`

        If set to ``true`` for a Lua function and the function is called via ``net.box`` (:ref:`conn:call() <net_box-call>`) or by ``box.func.<func-name>:call()``,
        the function arguments are passed being wrapped in a :ref:`MsgPack object <msgpack-object-info>`:

        ..  code-block:: lua

            local msgpack = require('msgpack')
            box.schema.func.create('my_func', {takes_raw_args = true})
            local my_func = function(mp)
                assert(msgpack.is_object(mp))
                local args = mp:decode() -- array of arguments
            end

        If a function forwards most of its arguments to another Tarantool instance or writes them to a database,
        the usage of this option can improve performance because it skips the MsgPack data decoding in Lua.

        | Type: boolean
        | Default: ``false``


    ..  _function_options_exports:

    .. data:: exports

        Specify the languages that can call the function.

        Example: ``exports = {'LUA', 'SQL'}``

        See also: :ref:`Calling Lua routines from SQL <sql_calling_lua>`

        | Type: table
        | Default: ``{'LUA'}``

    ..  _function_options_param_list:

    .. data:: param_list

        Specify the Lua type names for each parameter of the function.

        Example: ``param_list = {'number', 'number'}``

        See also: :ref:`Calling Lua routines from SQL <sql_calling_lua>`

        | Type: table

    ..  _function_options_returns:

    .. data:: returns

        Specify the Lua type name for a function's return value.

        Example: ``returns = 'number'``

        See also: :ref:`Calling Lua routines from SQL <sql_calling_lua>`

        | Type: string

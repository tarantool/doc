.. _box_schema-func_create:

===============================================================================
box.schema.func.create()
===============================================================================

.. module:: box.schema

.. _box_schema-func_create_without-body:

.. function:: box.schema.func.create(func-name [, {options-without-body}])

    Create a function :ref:`tuple <index-box_tuple>`
    without including the ``body`` option.
    For functions created with the ``body`` option, see
    :ref:`box.schema.func.create(func-name [, {options-with-body}]) <box_schema-func_create_with-body>`.

    This is called a "not persistent" function because functions without bodies are not persistent.
    This does not create the function itself -- that is done with Lua --
    but if it is necessary to grant privileges for a function,
    ``box.schema.func.create`` must be done first.
    For explanation of how Tarantool maintains function data, see the
    reference for the :ref:`box.space._func <box_space-func>` space.

    The possible options are:

    *   ``if_not_exists`` = ``true|false`` (default = ``false``)---
        ``true`` means there should be no error if the ``_func`` tuple already exists.

    *   ``setuid`` = ``true|false`` (default = ``false``)---with ``true`` to make Tarantool
        treat the function's caller as the function's creator, with full privileges.
        Remember that SETUID works only over
        :ref:`binary ports <admin-security>`.
        SETUID doesn't work if you invoke a function via an
        :ref:`admin console <admin-security>` or inside a Lua script.

    *   ``language`` = 'LUA'|'C' (default = 'LUA').

    *   (since version 2.10.0) ``takes_raw_args`` = ``true|false`` (default = ``false``)---
        if set to ``true`` for a Lua function and the function is called via ``net.box`` (:ref:`conn:call() <net_box-call>`) or by ``box.func.<func-name>:call()``,
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

    :param string func-name: name of function, which should
                             conform to the :ref:`rules for object names <app_server-names>`
    :param table options: ``if_not_exists``, ``setuid``, ``language``, ``takes_raw_args``.

    :return: nil

    These functions can be called with :samp:`{function-object}:call({arguments})`; however,
    unlike the case with ordinary functions, array arguments will not be correctly recognized
    unless they are enclosed in braces.

    **Example:**

    .. code-block:: lua

        box.schema.func.create('calculate')
        box.schema.func.create('calculate', {if_not_exists = false})
        box.schema.func.create('calculate', {setuid = false})
        box.schema.func.create('calculate', {language = 'LUA'})

.. _box_schema-func_create_with-body:

.. function:: box.schema.func.create(func-name [, {options-with-body}])

    Create a function :ref:`tuple <index-box_tuple>`.
    including the ``body`` option.
    (For functions created without the ``body`` option, see
    :ref:`box.schema.func.create(func-name [, {options-without-body}]) <box_schema-func_create>`.

    This is called a "persistent" function because only functions with bodies are persistent.
    This does create the function itself, the body is a function definition.
    For explanation of how Tarantool maintains function data, see the
    reference for the :ref:`box.space._func <box_space-func>` space.

    The possible options are:

    * ``if_not_exists`` = ``true|false`` (default = ``false``) - boolean;
      same as for :ref:`box.schema.func.create(func-name [, {options-without-body}]) <box_schema-func_create>`.

    * ``setuid`` = ``true|false`` (default = ``false``) - boolean;
      same as for :ref:`box.schema.func.create(func-name [, {options-without-body}]) <box_schema-func_create>`.

    * ``language`` = 'LUA'|'C' (default = ‘LUA’) - string.
      same as for :ref:`box.schema.func.create(func-name [, {options-without-body}]) <box_schema-func_create>`.

    * ``is_sandboxed`` = ``true|false`` (default = ``false``) - boolean;
      whether the function should be executed in a sandbox.

    * ``is_deterministic`` = ``true|false`` (default = ``false``) - boolean;
      ``true`` means that the function should be deterministic,
      ``false`` means that the function may or may not be deterministic.

    * ``is_multikey`` = ``true|false`` (default = ``false``)---
      if ``true`` is set in the function definition for a functional index, the function returns multiple keys.
      For details, see the :ref:`example <box_space-index_func_multikey>`.

    * ``body`` = function definition (default = nil) - string;
      the function definition.

    * Additional options for SQL = See :ref:`Calling Lua routines from SQL <sql_calling_lua>`.

    * ``takes_raw_args``---see the option description in :ref:`box.schema.func.create(func-name [, {options-with-body}]) <box_schema-func_create_without-body>`.

    :param string func-name: name of function, which should
                             conform to the :ref:`rules for object names <app_server-names>`
    :param table options: ``if_not_exists``, ``setuid``, ``language``,
                          ``is_sandboxed``, ``is_deterministic``, ``body``.

    :return: nil

    C functions are imported from .so files, Lua functions can be defined within ``body``.
    We will only describe Lua functions in this section.

    A function tuple with a body is "persistent" because the tuple is
    stored in a snapshot and is recoverable if the server restarts.
    All of the option values described in this section are visible in the
    :ref:`box.space._func <box_space-func>` system space.

    If ``is_sandboxed`` is true, then the function will be executed
    in an isolated environment: any operation that accesses the world outside
    the sandbox will be forbidden or will have no effect.
    Therefore a sandboxed function can only use modules and functions
    which cannot affect isolation:
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
    :ref:`utf8.* <utf8-module>`,
    `xpcall <https://www.lua.org/manual/5.1/manual.html#pdf-xpcall>`_.
    Also a sandboxed function cannot refer to global variables -- they
    will be treated as local variables because the sandbox is established
    with `setfenv <https://www.lua.org/manual/5.1/manual.html#pdf-setfenv>`_.
    So a sandboxed function will happen to be stateless and deterministic.

    If ``is_deterministic`` is true, there is no immediate effect.
    Tarantool plans to use the is_deterministic value in a future version.
    A function is deterministic if it always returns the same outputs given the same
    inputs. It is the function creator's responsibility to ensure that a
    function is truly deterministic.

    **Using a persistent Lua function**

    After a persistent Lua function is created, it can be found in
    the :ref:`box.space._func <box_space-func>` system space,
    and it can be shown with |br|
    :samp:`box.func.{func-name}` |br|
    and it can be invoked by any user with
    :ref:`authorization <authentication-owners_privileges>`
    to 'execute' it. The syntax for invoking is: |br|
    :samp:`box.func.{func-name}:call([parameters])` |br|
    or, if the connection is remote, the syntax is as in
    :ref:`net_box:call() <net_box-call>`.

    **Example:**

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


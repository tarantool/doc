.. _jit-module:

-------------------------------------------------------------------------------
                            Module `jit`
-------------------------------------------------------------------------------

.. module:: jit

===============================================================================
                                   Overview
===============================================================================

The ``jit`` module has functions for tracing the
`LuaJIT <http://luajit.org>`_ Just-In-Time compiler's
progress, showing the byte-code or assembler output that the compiler produces,
and in general providing information about what LuaJIT does with Lua code.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``jit`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`jit.bc.dump()                  | Print the byte code of          |
    | <jit-bc-dump>`                       | a function                      |
    +--------------------------------------+---------------------------------+
    | :ref:`jit.dis_x86.disass()           | Print the i386 assembler code   |
    | <jit-dis-x86-disass>`                | of a string of bytes            |
    +--------------------------------------+---------------------------------+
    | :ref:`jit.dis_x64.disass()           | Print the x86-64 assembler code |
    | <jit-dis-x64-disass>`                | of a string of bytes            |
    +--------------------------------------+---------------------------------+
    | :ref:`jit.dump.on()                  | Print the intermediate or       |
    | <jit-dump-on>`,                      | machine code of the following   |
    | :ref:`jit.dump.off()                 | Lua code                        |
    | <jit-dump-off>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`jit.v.on()                     | Print a trace of LuaJIT's       |
    | <jit-v-on>`,                         | progress compiling and          |
    | :ref:`jit.v.off()                    | interpreting code               |
    | <jit-v-off>`                         |                                 |
    +--------------------------------------+---------------------------------+

.. _jit-bc-dump:

.. function:: jit.bc.dump(function)

    Prints the byte code of a function.

    **Example:**

    .. code-block:: lua

        function f()
          print("D")
        end
        jit.bc.dump(f)

    For a list of available options, read `the source code of bc.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.6/src/jit/bc.lua>`_.

.. _jit-dis-x86-disass:

.. function:: jit.dis_x86.disass(string)

    Prints the i386 assembler code of a string of bytes.

    **Example:**

    .. code-block:: lua

        -- Disassemble hexadecimal 97 which is the x86 code for xchg eax, edi
        jit.dis_x86.disass('\x97')

    For a list of available options, read `the source code of dis_x86.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.6/src/jit/dis_x86.lua>`_.

.. _jit-dis-x64-disass:

.. function:: jit.dis_x64.disass(string)

    Prints the x86-64 assembler code of a string of bytes.

    **Example:**

    .. code-block:: lua

        -- Disassemble hexadecimal 97 which is the x86-64 code for xchg eax, edi
        jit.dis_x64.disass('\x97')

    For a list of available options, read `the source code of dis_x64.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.6/src/jit/dis_x64.lua>`_.

.. _jit-dump-on:
.. _jit-dump-off:

.. function:: jit.dump.on(option [, output file])
              jit.dump.off()

    Prints the intermediate or machine code of the following Lua code.

    **Example:**

    .. code-block:: lua

        -- Show the machine code of a Lua "for" loop
        jit.dump.on('m')
        local x = 0;
        for i = 1, 1e6 do
          x = x + i
        end
        print(x)
        jit.dump.off()

    For a list of available options, read `the source code of dump.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.6/src/jit/dump.lua>`_.

.. _jit-v-on:
.. _jit-v-off:

.. function:: jit.v.on(option [, output file])
              jit.v.off()

    Prints a trace of LuaJIT's progress compiling and interpreting code.

    **Example:**

    .. code-block:: lua

        -- Show what LuaJIT is doing for a Lua "for" loop
        jit.v.on()
        local x = 0
        for i = 1, 1e6 do
            x = x + i
        end
        print(x)
        jit.v.off()

    For a list of available options, read `the source code of v.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.6/src/jit/v.lua>`_.

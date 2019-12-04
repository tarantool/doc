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

.. NOTE::

     In this document, we will use:
        * ``jit_dis_x64`` for ``require('jit.dis_x64')``,
        * ``jit_v`` for ``require('jit.v')``,
        * ``jit_dump`` for ``require('jit.dump')``.


.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`jit_bc.dump()                  | Print the byte code of          |
    | <jit-bc-dump>`                       | a function                      |
    +--------------------------------------+---------------------------------+
    | :ref:`jit_dis_x86.disass()           | Print the i386 assembler code   |
    | <jit-dis-x86-disass>`                | of a string of bytes            |
    +--------------------------------------+---------------------------------+
    | :ref:`jit_dis_x64.disass()           | Print the x86-64 assembler code |
    | <jit-dis-x64-disass>`                | of a string of bytes            |
    +--------------------------------------+---------------------------------+
    | :ref:`jit_dump.on()                  | Print the intermediate or       |
    | <jit-dump-on>`,                      | machine code of the following   |
    | :ref:`jit_dump.off()                 | Lua code                        |
    | <jit-dump-off>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`jit_v.on()                     | Print a trace of LuaJIT's       |
    | <jit-v-on>`,                         | progress compiling and          |
    | :ref:`jit_v.off()                    | interpreting code               |
    | <jit-v-off>`                         |                                 |
    +--------------------------------------+---------------------------------+

.. _jit-bc-dump:

.. function:: jit_bc.dump(function)

    Prints the byte code of a function.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> jit_bc = require('jit.bc')
        ---
        ...

        tarantool> function f()
                 > print("D")
                 > end
        ---
        ...

        tarantool> jit_bc.dump(f)
        -- BYTECODE -- 0x01113163c8:1-3
        0001    GGET     0   0      ; "print"
        0002    KSTR     2   1      ; "D"
        0003    CALL     0   1   2
        0004    RET0     0   1

        ---
        ...

    .. code-block:: lua

        function f()
          print("D")
        end
        require('jit.bc').dump(f)

    For a list of available options, read `the source code of bc.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/bc.lua>`_.

.. _jit-dis-x86-disass:

.. function:: jit_dis_x86.disass(string)

    Prints the i386 assembler code of a string of bytes.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> -- Disassemble hexadecimal 97 which is the x86 code for xchg eax, edi
        ---
        ...

        tarantool> jit_dis_x86 = require('jit.dis_x86')
        ---
        ...

        tarantool> jit_dis_86.disass('\x97')
        00000000  97                xchg eax, edi
        ---
        ...

    For a list of available options, read `the source code of dis_x86.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/dis_x86.lua>`_.

.. _jit-dis-x64-disass:

.. function:: jit_dis_x64.disass(string)

    Prints the x86-64 assembler code of a string of bytes.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> -- Disassemble hexadecimal 97 which is the x86-64 code for xchg eax, edi
        ---
        ...

        tarantool> jit_dis_x64 = require('jit.dis_x64')
        ---
        ...

        tarantool> jit_dis_64.disass('\x97')
        00000000  97                xchg eax, edi
        ---
        ...

    For a list of available options, read `the source code of dis_x64.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/dis_x64.lua>`_.

.. _jit-dump-on:
.. _jit-dump-off:

.. function:: jit_dump.on(option [, output file])
              jit_dump.off()

    Prints the intermediate or machine code of the following Lua code.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> -- Show the machine code of a Lua "for" loop
        tarantool> jit_dump = require('jit.dump')
        tarantool> jit_dump.on('m')
        tarantool> x = 0;
        tarantool> for i = 1, 1e6 do
                 > x = x + i
                 > end
        ---- TRACE 1 start 0x01047fbc38:1
        ---- TRACE 1 mcode 148
        104c29f6b  mov dword [r14-0xed0], 0x1
        104c29f76  cvttsd2si ebp, [rdx]
        104c29f7a  rorx rbx, [rdx-0x10], 0x2f
        104c29f81  shr rbx, 0x11
        104c29f85  mov rdx, [rbx+0x10]
        104c29f89  cmp dword [rdx+0x34], +0x3f
        104c29f8d  jnz 0x104c1a010  ->0
        104c29f93  mov rcx, [rdx+0x28]
        104c29f97  mov rdi, 0xfffd8001046b3d58
        104c29fa1  cmp rdi, [rcx+0x320]
        104c29fa8  jnz 0x104c1a010  ->0
        104c29fae  lea rax, [rcx+0x318]
        104c29fb5  cmp dword [rax+0x4], 0xfff90000
        104c29fbc  jnb 0x104c1a010  ->0
        104c29fc2  xorps xmm7, xmm7
        104c29fc5  cvtsi2sd xmm7, ebp
        104c29fc9  addsd xmm7, [rax]
        104c29fcd  movsd [rax], xmm7
        104c29fd1  add ebp, +0x01
        104c29fd4  cmp ebp, 0x000f4240
        104c29fda  jg 0x104c1a014   ->1
        ->LOOP:
        104c29fe0  xorps xmm6, xmm6
        104c29fe3  cvtsi2sd xmm6, ebp
        104c29fe7  addsd xmm7, xmm6
        104c29feb  movsd [rax], xmm7
        104c29fef  add ebp, +0x01
        104c29ff2  cmp ebp, 0x000f4240
        104c29ff8  jle 0x104c29fe0  ->LOOP
        104c29ffa  jmp 0x104c1a01c  ->3
        ---- TRACE 1 stop -> loop

        ---
        ...

        tarantool> print(x)
        500000500000
        ---
        ...

        tarantool> jit_dump.off()
        ---
        ...

    For a list of available options, read `the source code of dump.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/dump.lua>`_.

.. _jit-v-on:
.. _jit-v-off:

.. function:: jit_v.on(option [, output file])
              jit_v.off()

    Prints a trace of LuaJIT's progress compiling and interpreting code.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> -- Show what LuaJIT is doing for a Lua "for" loop
        tarantool> jit_v = require('jit.v')
        tarantool> jit_v.on()
        tarantool> l = 0
        tarantool> for i = 1, 1e6 do
                 >     l = l + i
                 > end
        [TRACE   3 "for i = 1, 1e6 do
            l = l + i
        end":1 loop]
        ---
        ...

        tarantool> print(l)
        500000500000
        ---
        ...

        tarantool> jit_v.off()
        ---
        ...

    For a list of available options, read `the source code of v.lua
    <https://github.com/tarantool/luajit/tree/tarantool-1.7/src/jit/v.lua>`_.

.. jit_v = require('jit.v')
.. jit_v.on()
.. l = 0
.. for i = 1, 1e6 do
..     l = l + i
.. end
.. print(l)
.. jit_v.off()

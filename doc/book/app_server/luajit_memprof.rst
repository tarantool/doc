
LuaJIT memory profiler
======================

Starting from version :doc:`2.7.1 </release/2.7.1>`, Tarantool
has the built‑in module called ``misc.memprof`` that implements the LuaJIT memory
profiler (further, *profiler*). The profiler provides
a memory allocation report that helps analyse Lua code and find out the places
that put the most pressure on the Lua garbage collector (GC).

..  contents::
    :local:
    :depth: 2

.. _profiler_usage:

Working with profiler
---------------------

Usage of the profiler is two-fold:

1.  :ref:`Collect <profiler_usage_get>` a binary profile of allocations,
    reallocations, and deallocations in memory related to Lua
    (further, *binary memory profile* or *binary profile* for short).
2.  :ref:`Parse <profiler_usage_parse>` the binary profile collected and get
    a human-readable profiling report.

.. _profiler_usage_get:

Collecting binary profile
~~~~~~~~~~~~~~~~~~~~~~~~~

To collect a binary profile for a particular part of the Lua code,
you need to place this part between two ``misc.memprof`` functions,
namely, ``misc.memprof.start()`` and ``misc.memprof.stop()``, and then execute
the code under Tarantool.

Below is a chunk of simple Lua code named ``test.lua`` to illustrate this.

.. _profiler_usage_example01:

..  code-block:: lua
    :linenos:

    -- Prevent allocations on traces.
    jit.off()
    local str, err = misc.memprof.start("memprof_new.bin")
    -- Lua doesn't create a new frame to call string.rep, and all allocations
    -- are attributed not to the append() function but to the parent scope.
    local function append(str, rep)
        return string.rep(str, rep)
    end

    local t = {}
    for i = 1, 1e5 do
        -- table.insert is the built-in function and all corresponding
        -- allocations are reported in the scope of the main chunk.
        table.insert(t,
            append('q', i)
        )
    end
    local stp, err = misc.memprof.stop()

Starting profiler in Lua code:

..  code-block:: lua

    local str, err = misc.memprof.start(FILENAME)

where ``FILENAME`` is a name of the binary file where profiling events are written.

If it is not possible to open a file for writing or the profiler fails to start,
``misc.memprof.start()`` returns ``nil`` on failure. Also, in this case
the function returns an error message as the second result and
a system-dependent error code as the third result.
Otherwise, it returns ``true``.

Stopping profiler in Lua code:

..  code-block:: lua

    local stp, err = misc.memprof.stop()

If any error occurs at stopping the profiling
(an error when the file descriptor is being closed) or during reporting,
``misc.memprof.stop()`` returns ``nil``. Also, in this case
the function returns an error message as the second result and
a system-dependent error code as the third result.
Otherwise, it returns ``true``.

.. _profiler_usage_generate:

To generate the file with memory profile in binary format
(in the :ref:`example above <profiler_usage_example01>`,
it's ``memprof_new.bin``), execute the code under Tarantool:

..  code-block:: tarantoolconsole

    $ tarantool test.lua

Tarantool collects the allocation events in ``memprof_new.bin``, puts
the file in its :ref:`working directory <cfg_basic-work_dir>`, and closes
the session.

The :ref:`code example <profiler_usage_example01>` above also illustrates the memory
allocation logic in some of the cases that are important to understand for further
:ref:`reading <profiler_usage_parse>` and :ref:`analysing <profiler_analysis>`
a profiling report:

*   Line 2: It is recommended to switch the JIT compilation off by calling ``jit.off()``
    before the profiler start. Refer to the following
    :ref:`explanation <profiler_usage_internal_jitoff>` for more details.

*   Lines 6-8: Tail call optimization doesn't create a new call frame, so all
    allocations inside the function called via the ``CALLT/CALLMT`` `bytecodes <http://wiki.luajit.org/Bytecode-2.0#calls-and-vararg-handling>`_
    are attributed to its caller. See also comments to these lines.

*   Lines 14-16: Usually, the information about allocations inside Lua built‑ins
    are not really
    useful for developers. That's why if a Lua built‑in function is called from
    a Lua function, the profiler attributes all allocations to the Lua function.
    Otherwise, this event is attributed to a C function.
    See also comments to these lines.

.. _profiler_usage_parse:

Parsing binary profile and generating profiling report
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _profiler_usage_parse_command:

After having the memory profile in binary format, the next step is
to parse it to get a human-readable profiling report. You can do this
via Tarantool by using the following command
(mind the hyphen ``-`` prior to the file name):

..  code-block:: tarantoolconsole

    $ tarantool -e 'require("memprof")(arg[1])' - <memprof_new.bin>

where ``memprof_new.bin`` is the binary profile
:ref:`generated earlier <profiler_usage_generate>`.

Tarantool generates a profiling report that is displayed in console and closes
the session:

..  code-block:: console

    ALLOCATIONS
    @test.lua:0, line 15: 1002      531818  0
    @test.lua:0, line 14: 1 24      0
    @test.lua:0, line 10: 1  32      0
    @test.lua:0, line 8: 1  20      0

    REALLOCATIONS
    @test.lua:0, line 14: 9 16424   8248
            Overrides:
                    @test.lua:0, line 14
    @test.lua:0, line 15: 5 1984    992
            Overrides:
                    @test.lua:0, line 15

    DEALLOCATIONS
    INTERNAL: 20    0       1481
    @test.lua:0, line 15: 3 0       7168
            Overrides:
                    @test.lua:0, line 15

..  note::

    On MacOS, a report will be different for the same chunk of code because
    Tarantool and LuaJIT are built with the GC64 mode enabled for MacOS.

Let's examine the report structure. A report has three sections:

* ALLOCATIONS
* RELOCATIONS
* DEALLOCATIONS.

Each section contains event records that are sorted from the most often
to the least ones.

An event record has the following format:

..  code-block:: text

    @<filename>:<function_line>, line <line_number>: <number_of_events> <allocated> <freed>

*   <filename>—a name of the file containing Lua code.
*   <function_line>—the line number where the function generating the event
    is declared. In some of the cases, allocations are attributed not to
    the declared function but to the main chunk. In this case, the <function_line>
    is set to ``0``. See the :ref:`code chunk above<profiler_usage_example01>`
    with the explanation in the comments for some examples.
*   <line_number>—the line number where the event is detected.
*   <number_of_events>—a number of events for this code line.
*   <allocated>—amount of memory allocated during all the events, bytes.
*   <freed>—amount of memory freed during all the events, bytes.

The ``Overrides`` label shows what allocation has been overridden.

.. _profiler_usage_internal_jitoff:

The ``INTERNAL`` label indicates that this event is caused by internal LuaJIT
structures.

..  note::

    Important note regarding the ``INTERNAL`` label and the recommendation
    of switching the JIT compilation off (``jit.off()``): this version of the
    profiler doesn't support verbose reporting for allocations on
    `traces <https://en.wikipedia.org/wiki/Tracing_just-in-time_compilation#Technical_details>`_.
    If memory allocations are made on a trace,
    the profiler can't associate the allocations with the part of Lua code
    that generated the trace. In this case, the profiler labels such allocations
    as ``INTERNAL``.

    So, if the JIT compilation is on,
    new traces will be generated and there will be a mixture of events labeled
    ``INTERNAL`` in the profiling report: some of them are really caused by
    internal LuaJIT structures, but some of them are caused by allocations on
    traces.

    If you want to have more definite report without JIT compiler allocations,
    :ref:`call jit.off() <profiler_usage_example01>` before starting the profiling.
    And if you want to completely exclude the trace allocations from the report,
    remove also the old traces by additionally calling ``jit.flush()`` after
    ``jit.off()``.

    Nevertheless, switching the JIT compilation off before the profiling is not
    "a must". It is rather a recommendation, and in some of the cases,
    for example, on production environment, you may need to keep JIT compilation
    on to see the full picture of all the memory allocations.
    In this case, the majority the ``INTERNAL`` events
    are most probably caused by traces.

As for investigating the Lua code with the help of profiling reports,
it is always code-dependent and there can't be cent per cent definite
recommendations in this regard. Nevertheless, some of the things you can
see in the analysis of :ref:`another code example <profiler_analysis>`.

Also, below is the :ref:`FAQ <profiler_faq>` section with the questions that
most probably can arise while using the profiler.

.. _profiler_faq:

FAQ
---

In this section, some of the profiler-related points are discussed in
a Q&A format.

**Question (Q)**: Is the profiler suitable for C allocations or allocations
inside C code?

**Answer (A)**: The profiler reports only allocation events caused by the Lua
allocator. All Lua-related allocations, like table or string creation
are reported. But the profiler doesn't report allocations made by ``malloc()``
or other non-Lua allocators. You can use ``valgrind`` to debug them.

|

**Q**: Why are there so many ``INTERNAL`` allocations in my profiling report?
What does it mean?

**A**: ``INTERNAL`` means that these allocations/reallocations/deallocations are
related to the internal LuaJIT structures or are made on traces.
Currently, the memory profiler doesn't report verbosely allocations of objects
that are made during trace execution. Try to :ref:`add jit.off() <profiler_usage_internal_jitoff>`
before profiler start.

|

**Q**: Why is there some reallocations/deallocations without the ``Overrides``
section?

**A**: These objects can be created before the profiler starts. Adding
``collectgarbage()`` before the profiler's start enables to collect all
previously allocated objects that are dead when the profiler starts.

|

**Q**: Why some objects are not collected during profiling? Is it
a memory leak?

**A**: LuaJIT uses incremental Garbage Collector (GC). A GC cycle may not be
finished at the moment of the profiler's stop. Add ``collectgarbage()`` before
stopping the profiler to collect all the dead objects for sure.

|

**Q**: Can I profile not just a current chunk but the entire running application?
Can I start the profiler when the application is already running?

**A**: Yes. Here is the example of code that can be inserted in the Tarantool
console for a running instance.

..  code-block:: lua
    :linenos:

    local fiber = require "fiber"
    local log = require "log"

    fiber.create(function()
      fiber.name("memprof")

      collectgarbage() -- Collect all objects already dead
      log.warn("start of profile")

      local st, err = misc.memprof.start(FILENAME)
      if not st then
        log.error("failed to start profiler: %s", err)
      end

      fiber.sleep(TIME)

      collectgarbage()
      st, err = misc.memprof.stop()

      if not st then
        log.error("profiler on stop error: %s", err)
      end

      log.warn("end of profile")
    end)

where

*   ``FILENAME``—a name of the report file in binary format
*   ``TIME``—duration of profiling, seconds.

Also, you can directly call ``misc.memprof.start()`` and ``misc.memprof.stop()``
from a console.

.. _profiler_analysis:

Profiling report analysis example
---------------------------------

In the example below, the following Lua code named ``format_concat.lua`` is
investigated with the help of the memory profiler reports.

.. _profiler_usage_example03:

..  code-block:: lua
    :linenos:

    -- Prevent allocations on new traces.
    jit.off()

    local function concat(a)
      local nstr = a.."a"
      return nstr
    end

    local function format(a)
      local nstr = string.format("%sa", a)
      return nstr
    end

    collectgarbage()

    local binfile = "/tmp/memprof_"..(arg[0]):match("([^/]*).lua")..".bin"

    local st, err = misc.memprof.start(binfile)
    assert(st, err)

    -- Payload.
    for i = 1, 10000 do
      local f = format(i)
      local c = concat(i)
    end
    collectgarbage()

    local st, err = misc.memprof.stop()
    assert(st, err)

    os.exit()

When you run this code :ref:`under Tarantool <profiler_usage_generate>` and
then :ref:`parse <profiler_usage_parse_command>` the binary memory profile,
you will get the following profiling report:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:9, line 10: 19998     624322  0
    INTERNAL: 1     65536   0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 19998 0       558816
            Overrides:
                    @format_concat.lua:9, line 10
    @format_concat.lua:9, line 10: 2 0       98304
            Overrides:
                    @format_concat.lua:9, line 10

The reasonable questions regarding the report can be:

*   Why are there no allocations related to the ``concat()`` function?
*   Why the amount of allocations is not a round number?
*   Why are there approximately 20K allocations instead of 10K?

First of all, LuaJIT doesn't create a new string if the string with the same
payload exists (see details on `lua-users.org/wiki <http://lua-users.org/wiki/ImmutableObjects>`_).
This is called the `string interning <https://en.wikipedia.org/wiki/String_interning>`_.
So, when the string is
created via the ``format()`` function, there is no need to create the same
string via the ``concat()`` function, and LuaJIT just uses the previous one.

That is also the reason why the amount of allocations is not the round number
as can be expected from the cycle operator ``for i = 1, 10000...``:
Tarantool creates some
strings for internal needs and built‑in modules, so some strings already exist.

But why are there so many allocations? It's almost twice as big as the expected
amount. This is because the ``string.format()`` built‑in function creates
another string necessary for the ``%s`` identifier, so there are two allocations
for each iteration: for ``tostring(i)`` and for ``string.format("%sa", string_i_value)``.
You can see the difference in behaviour by adding the
``local _ = tostring(i)`` line between lines 22 and 23.

To profile only the ``concat()`` function, comment line 23, namely,
``local f = format(i)`` and run the profiler.

The profiler's output is the following:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:4, line 5: 10000     284411  0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 10000 0       218905
            Overrides:
                    @format_concat.lua:4, line 5
    @format_concat.lua:4, line 5: 1 0       32768

**Q**: But what will change if the JIT compilation is enabled?

**A**: In the :ref:`code <profiler_usage_example03>`, comment line 2, namely,
``jit.off()`` and run
the profiler . Now, there are only 56 allocations in the report, and all other
allocations are JIT-related (see also the related
`dev issue <https://github.com/tarantool/tarantool/issues/5679>`_):

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:4, line 5: 56        1112    0
    @format_concat.lua:0, line 0: 4 640     0
    INTERNAL: 2     382     0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 58    0       1164
            Overrides:
                    @format_concat.lua:4, line 5
                    INTERNAL

This happens because a trace has been compiled after 56 iterations (the default
value of the ``hotloop`` compiler parameter). Then, the
JIT-compiler removed the unused ``c`` variable  from the trace, and, therefore,
the dead code of the ``concat()`` function is eliminated.

Next, let's profile only the ``format()`` function with JIT enabled.
For that, keep lines 2 and 24 commented (``jit.off()`` and
``local c = concat(i)`` respectively), uncomment line 23
(``local f = format(i)``), and run the profiler.

The profiler's output is the following:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:9, line 10: 19998     624322  0
    INTERNAL: 4     66824   0
    @format_concat.lua:0, line 0: 4 640     0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 19999 0       559072
            Overrides:
                    @format_concat.lua:0, line 0
                    @format_concat.lua:9, line 10
    @format_concat.lua:9, line 10: 2 0       98304
            Overrides:
                    @format_concat.lua:9, line 10

**Q**: Why is there so many allocations in comparison to the ``concat()`` function?

**A**: The answer is simple: the ``string.format()`` function with the ``%s``
identifier is not yet compiled via LuaJIT. So, a trace can't be recorded and
the compiler doesn't perform the corresponding optimizations.

If we change the ``format()`` function in the :ref:`code chunk <profiler_usage_example03>`
in the following way

..  code-block:: lua

    local function format(a)
      local nstr = string.format("%sa", tostring(a))
      return nstr
    end

the profiling report becomes much prettier:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:9, line 10: 110       2131    0
    @format_concat.lua:0, line 0: 4 640     0
    INTERNAL: 3     1148    0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 113   0       2469
            Overrides:
                    @format_concat.lua:0, line 0
                    @format_concat.lua:9, line 10
                    INTERNAL

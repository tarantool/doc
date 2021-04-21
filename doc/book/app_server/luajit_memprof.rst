
LuaJIT memory profiler
======================

Stating from version :doc:`2.7.1 </release/2.7.1>`, Tarantool
has the built-in module called ``memprof`` that implements a LuaJIT memory
profiler and a profile parser. The profiler provides
a memory allocation report that helps analyse Lua code and find out the places
that put the most pressure on the Lua garbage collector.

//?where to put this paragraph//
Usually developers are not interested in information about allocations
inside built-ins. So if a Lua built-in function is called from a Lua function,
all allocations are attributed to this Lua function.
Otherwise, this event is attributed to a C function.

//?where to put this paragraph//
Tail call optimization does not create a new call frame, so all allocations
inside the function called via CALLT/CALLMT bytecodes are attributed to its caller.

.. _profiler_usage:

Working with profiler
---------------------

Usage of the profiler is two-fold:

1.  :ref:`Collect <profiler_usage_get>` a binary profile of allocations,
    reallocations, and deallocations in memory related to Lua VM
    (further, *binary memory profile* or *binary profile* for short).
2.  :ref:`Parse <profiler_usage_parse>` the binary profile collected and get
    a human-readable profiling report.

.. _profiler_usage_get:

Collecting binary profile
~~~~~~~~~~~~~~~~~~~~~~~~~

To collect a binary profile for a particular part of the Lua code,
you need to place this part between two ``memprof`` functions,
namely, ``misc.memprof.start()`` and ``misc.memprof.stop()``, and then execute
the code under Tarantool.

Below is a piece of simple Lua code named ``test.lua`` to illustrate this.

.. _profiler_usage_example01:

..  code-block:: lua
    :linenos:

    jit.off()
    local str, err = misc.memprof.start("memprof_new.bin")
    -- Lua doesn't create a new frame to call string.rep, and all allocations
    -- are attributed not to the append() function but to the parent scope.
    local function append(str, rep)
        return string.rep(str, rep)
    end

    local t = {}
    for _ = 1, 1e5 do
        -- table.insert is the built-in function and all corresponding
        -- allocations are reported in the scope of main chunk.
        table.insert(t,
            append('q', _)
        )
    end
    local stp, err = misc.memprof.stop()

Starting profiler in Lua code:

..  code-block:: lua

    local str, err = misc.memprof.start(FILENAME)

where ``FILENAME`` is a name of the binary file where profile events are written.
The writer for this function performs ``fwrite()`` for each call retrying
in case of ``EINTR``. When the profiling is stopped, ``fclose()`` is called.

If it is not possible to open a file for writing or the profiler fails to start,
``misc.memprof.start()`` returns ``nil`` on failure. Also, in this case
the function returns an error message as the second result and
a system-dependent error code as the third result.
Otherwise, it returns ``true``.

..  note::

    It is recommended to switch the JIT compilation off by calling ``jit.off()``
    before the profiler start. Refer to the following
    :ref:`explanation <profiler_usage_internal_jitoff>` for details.

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

To generate the ``memprof_new.bin`` file with the memory profile in binary format,
execute the code under Tarantool:

..  code-block:: tarantoolconsole

    $ tarantool test.lua

Tarantool collects the allocation events in ``memprof_new.bin``, puts
the file in its :ref:`working directory <cfg_basic-work_dir>`, and closes
the session.

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

Tarantool generates a profiling report and closes the session.

..  code-block:: console

    ALLOCATIONS
    @test.lua:0, line 14: 1002      531818  0
    @test.lua:0, line 13: 1 24      0
    @test.lua:0, line 9: 1  32      0
    @test.lua:0, line 7: 1  20      0

    REALLOCATIONS
    @test.lua:0, line 13: 9 16424   8248
            Overrides:
                    @test.lua:0, line 13

    @test.lua:0, line 14: 5 1984    992
            Overrides:
                    @test.lua:0, line 14


    DEALLOCATIONS
    INTERNAL: 20    0       1481
    @test.lua:0, line 14: 3 0       7168
            Overrides:
                    @test.lua:0, line 14

..  note::

    A report can look differently for the same piece of Lua code depending
    on the OS used. On MacOS, the report data
    //?can be influenced by the LuaJIT GC64 running//.

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
*   <function_line>—a number of the line where the function generating the event
    is declared. Sometimes <function_line> is ``0``. It means that
    the function generating the event is the //?main/entire code of //?file/script itself.
    This is exactly the case in the :ref:`example above <profiler_usage_example01>`.
    Comments in the code explain why it happens for each of the functions.
*   <line_number>—a number of the line where the event is detected.
*   <number_of_events>—a number of events for this code line.
*   <allocated>—bytes allocated in memory during the //?event/events.
*   <freed>—bytes freed in memory during //?event/events.

``Overrides`` shows what allocation has been overridden.

.. _profiler_usage_internal_jitoff:

``INTERNAL`` indicates that this event is caused by internal LuaJIT structures.

//!the note below really needs to be reviewed thoroughly//

..  note::

    Important note regarding the ``INTERNAL`` label and the recommendation
    of switching the JIT compilation off (``jit.off()``): this version of the
    profiler doesn't support verbose reporting for allocations //?on/for
    `traces <https://en.wikipedia.org/wiki/Tracing_just-in-time_compilation#Technical_details>`_.
    If some memory allocations are made //?on/for a trace,
    the profiler can't associate the allocations with the part of Lua code
    that generated the trace. In this case, the profiler labels such allocations
    as ``INTERNAL``.

    So, if the JIT compilation is on,
    new traces will be generated and there will be a mixture of events labeled
    ``INTERNAL`` in the profiling report : some of them are really caused by
    internal LuaJIT structures, but some of them are caused by allocations //?on/for
    traces.

    If you want to have more definite report without new trace allocations,
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

Frequently Asked Questions
--------------------------

In this section, some of the profiler-related points are discussed in
a Q&A format.

**Question (Q)**: Is the profiler suitable for C allocations or allocations
inside C code?

**Answer (A)**: The profiler reports only allocation events caused by the Lua
allocation functions. All Lua-related allocations, like table or string creation
are reported. But the profiler doesn't report allocations made by ``malloc()``
or other non-Lua allocators. You can use ``valgrind`` to debug them.

**Q**: Why is there so many ``INTERNAL`` allocations in my profiling report?
What does it mean?

**A**: ``INTERNAL`` means that these allocations/reallocations/deallocations are
related to the internal LuaJIT structures or are made on JIT traces.
Currently, the memory profiler doesn't report verbosely allocations of objects
that are made during trace execution. Try to :ref:`add jit.off() <profiler_usage_internal_jitoff>`
before profiler start.

**Q**: Why is there some reallocations/deallocations without the ``Overrides``
section?

**A**: These objects can be created before the profiler starts. Adding
``collectgarbage()`` before the profiler's start enables to collect all
previously allocated objects that are dead when the profiler starts.

**Q**: Why some objects are not collected during profiling? Is it
a memory leak?

**A**: LuaJIT uses incremental Garbage Collector (GC). A GC cycle may not be
finished at the moment of the profiler's stop. Add ``collectgarbage()`` before
stopping the profiler to collect all the dead objects for sure.

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

Report analysis example
-----------------------

In the example below, the following Lua code named ``format_concat.lua`` is
investigated with the help of the memory profiler reports.

..  code-block:: lua
    :linenos:

    jit.off() -- More verbose reports.

    local function concat(a)
      local nstr = a.."a"
      return nstr
    end

    local function format(a)
      local nstr = string.format("%sa", a)
      return nstr
    end

    collectgarbage() -- Clean up.

    local binfile = "/tmp/memprof_"..(arg[0]):match("([^/]*).lua")..".bin"

    local st, err = misc.memprof.start(binfile)
    assert(st, err)

    -- Payload.
    for i = 1, 10000 do
      local f = format(i)
      local c = concat(i)
    end
    collectgarbage() -- Clean up.

    local st, err = misc.memprof.stop()
    assert(st, err)

    os.exit()

When you run this code :ref:`under Tarantool <profiler_usage_generate>` and
then :ref:`parse <profiler_usage_parse_command>` the binary memory profile,
you will get the following profiling report:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:8, line 9: 19998     624322  0
    INTERNAL: 1     65536   0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 19998 0       558816
            Overrides:
                    @format_concat.lua:8, line 9

    @format_concat.lua:8, line 9: 2 0       98304
            Overrides:
                    @format_concat.lua:8, line 9

The reasonable questions regarding the report can be:

* Why are there no allocations related to the ``concat()`` function?
* Why the amount of allocations is not a round number?
* Why are there approximately 20K allocations instead of 10K?

First of all, LuaJIT doesn't create a new string if the string with the same
payload exists. It is called the string interning. So, when the string is
created via
the ``format()`` function, there is no need to create the same string via
the ``concat()`` function, and LuaJIT just use the previous one.

This is the reason of //?unpretty amount of allocations: Tarantool creates some
strings for internal needs and built-in modules, so some strings already exist.

But why are there so many allocations? It's almost twice as big as the expected
amount. This is because the ``string.format()`` built-in function creates
another string necessary for the ``%s`` identifier, so there are two allocations
for each iteration: for ``tostring(i)`` and for ``string.format("%sa", string_i_value)``.
You can see the difference in the behaviour by adding the
``local _ = tostring(i)`` line between lines 21 and 22.

Let's comment the 22nd line, namely, ``local f = format(i)``
(by adding ``--`` at the line start) to take a look at the ``concat()`` function.

The profiler's output is the following:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:3, line 4: 10000     284411  0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 10000 0       218905
            Overrides:
                    @format_concat.lua:3, line 4

    @format_concat.lua:3, line 4: 1 0       32768


**Q**: But what will change if JIT compilation is enabled?

**A**: Let's comment the first line of the code, namely, ``jit.off()`` to see what
will happen. Now, there are only 56 allocations in the report, and all other
allocations are JIT-related (see also the related
`dev issue <https://github.com/tarantool/tarantool/issues/5679>`_):

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:3, line 4: 56        1112    0
    @format_concat.lua:0, line 0: 4 640     0
    INTERNAL: 2     382     0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 58    0       1164
            Overrides:
                    @format_concat.lua:3, line 4
                    INTERNAL

This happens because a trace is compiled after 56 iterations, and the
JIT-compiler removed the unused ``c`` variable  from the trace, and, therefore,
the dead code of the ``concat()`` function is eliminated.

Let's now profile only the ``format()`` function with JIT enabled.
The profiler's output is the following:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:8, line 9: 19998     624322  0
    INTERNAL: 4     66824   0
    @format_concat.lua:0, line 0: 4 640     0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 19999 0       559072
            Overrides:
                    @format_concat.lua:0, line 0
                    @format_concat.lua:8, line 9

    @format_concat.lua:8, line 9: 2 0       98304
            Overrides:
                    @format_concat.lua:8, line 9

**Q**: Why is there so many allocations in comparison to the ``concat()`` function?

**A**: The answer is simple: the ``string.format()`` function with the ``%s``
identifier is not yet compiled via LuaJIT. So, a trace can't be recorded and
the compiler doesn't perform the corresponding optimizations.

If we change the ``format()`` function in the following way

..  code-block:: lua

    local function format(a)
      local nstr = string.format("%sa", tostring(a))
      return nstr
    end

the profiling report becomes much prettier:

..  code-block:: console

    ALLOCATIONS
    @format_concat.lua:8, line 9: 110       2131    0
    @format_concat.lua:0, line 0: 4 640     0
    INTERNAL: 3     1148    0

    REALLOCATIONS

    DEALLOCATIONS
    INTERNAL: 113   0       2469
            Overrides:
                    @format_concat.lua:0, line 0
                    @format_concat.lua:8, line 9
                    INTERNAL

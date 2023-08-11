..  _luajit_getmetrics:

LuaJIT getmetrics
=================

Tarantool can return metrics of a current instance via the Lua API or the C API.

..  contents::
    :local:
    :depth: 2

.. _luajit_getmetrics_getmetrics:

misc.getmetrics()
~~~~~~~~~~~~~~~~~

.. function:: getmetrics()

    Get the metrics values into a table.
   
    Parameters: none
     
    :return: table

    Example: ``metrics_table = misc.getmetrics()``  

.. _luajit_getmetrics_tablevalues:

getmetrics table values
~~~~~~~~~~~~~~~~~~~~~~~

The metrics table contains 19 values.
All values have type = 'number' and are the result of a cast to double, so there may be a very slight precision loss.
Values whose names begin with ``gc_`` are associated with the
`LuaJIT garbage collector <http://wiki.luajit.org/New-Garbage-Collector/>`_;
a fuller study of the garbage collector can be found at
`a Lua-users wiki page <http://lua-users.org/wiki/EmergencyGarbageCollector>`_
and
`a slide from the creator of Lua <https://www.lua.org/wshop18/Ierusalimschy.pdf#page=16>`_.
Values whose names begin with ``jit_`` are associated with the
`"phases" <https://en.wikipedia.org/wiki/Tracing_just-in-time_compilation>`_
of the just-in-time compilation process; a fuller study of JIT phases can be found at
`A masters thesis from cern.ch <http://cds.cern.ch/record/2692915/files/CERN-THESIS-2019-152.pdf?version=1>`_.

Values described as "monotonic" are cumulative, that is, they are "totals since
all operations began", rather than "since the last getmetrics() call".
Overflow is possible.

Because many values are monotonic,
a typical analysis involves calling ``getmetrics()``, saving the table,
calling ``getmetrics()`` again and comparing the table to what was saved.
The difference is a "slope curve".
An interesting slope curve is one that shows acceleration,
for example the difference between the latest value and the previous
value keeps increasing.
Some of the table members shown here are used in the examples that come later in this section.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3

    +----------------------+--------------------------------------------------+------------+
    | Name                 | Content                                          | Monotonic? |
    +======================+==================================================+============+
    | gc_allocated         | number of bytes of allocated memory              | yes        |
    +----------------------+--------------------------------------------------+------------+
    | gc_cdatanum          | number of allocated cdata objects                | no         |
    +----------------------+--------------------------------------------------+------------+
    | gc_freed             | number of bytes of freed memory                  | yes        |
    +----------------------+--------------------------------------------------+------------+
    | gc_steps_atomic      | number of steps of garbage collector,            | yes        |
    |                      | atomic phases, incremental                       |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_steps_finalize    | number of steps of garbage collector,            | yes        |
    |                      | finalize                                         |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_steps_pause       | number of steps of garbage collector,            | yes        |
    |                      | pauses                                           |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_steps_propagate   | number of steps of garbage collector,            | yes        |
    |                      | propagate                                        |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_steps_sweep       | number of steps of garbage collector,            | yes        |
    |                      | sweep phases                                     |            | 
    |                      | (see the `Sweep phase description`_)             |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_steps_sweepstring | number of steps of garbage collector,            | yes        |
    |                      | sweep phases for strings                         |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_strnum            | number of allocated string objects               | no         |
    +----------------------+--------------------------------------------------+------------+
    | gc_tabnum            | number of allocated table objects                | no         |
    +----------------------+--------------------------------------------------+------------+
    | gc_total             | number of bytes of currently allocated memory    | no         |
    |                      | (normally equals gc_allocated minus gc_freed)    |            |
    +----------------------+--------------------------------------------------+------------+
    | gc_udatanum          | number of allocated udata objects                | no         |
    +----------------------+--------------------------------------------------+------------+
    | jit_mcode_size       | total size of all allocated machine code areas   | no         |      
    +----------------------+--------------------------------------------------+------------+
    | jit_snap_restore     | overall number of snap restores, based on the    | yes        |
    |                      | number of guard assertions leading to stopping   |            |
    |                      | trace executions (see external `Snap tutorial`_) |            |
    +----------------------+--------------------------------------------------+------------+
    | jit_trace_abort      | overall number of aborted traces                 | yes        |
    +----------------------+--------------------------------------------------+------------+
    | jit_trace_num        | number of JIT traces                             | no         |
    +----------------------+--------------------------------------------------+------------+
    | strhash_hit          | number of strings being interned because, if a   | yes        |
    |                      | string with the same value is found via the      |            |
    |                      | hash, a new one is not created / allocated       |            |
    +----------------------+--------------------------------------------------+------------+
    | strhash_miss         | total number of strings allocations during       | yes        |
    |                      | the platform lifetime                            |            |
    +----------------------+--------------------------------------------------+------------+

.. comment: Links are not inline because they would make the table cells wider.

.. _Sweep phase description: https://ujit.readthedocs.io/en/latest/public/tut-new-gc.html#sweep-phase
.. _Snap tutorial: https://ujit.readthedocs.io/en/latest/public/tut-snap.html

Note: Although value names are similar to value names in
`ujit.getmetrics() <https://ujit.readthedocs.io/en/latest/public/ujit-024.html#ujit-getmetrics>`_
the values are not the same, primarily because many ujit numbers are not monotonic.

Note: Although value names are similar to value names in :ref:`LuaJIT metrics <metrics-reference-luajit>`,
and the values are exactly the same, misc.getmetrics() is slightly easier
because there is no need to ‘require’ the misc module.


.. _luajit_getmetrics_c:

getmetrics C API
~~~~~~~~~~~~~~~~

The Lua ``getmetrics()`` function is a wrapper for the C function ``luaM_metrics()``.

C programs may include a header named ``libmisclib.h``.
The definitions in ``libmisclib.h`` include the following lines:

..  code-block:: c

    struct luam_Metrics { /* the names described earlier for Lua */ }

    LUAMISC_API void luaM_metrics(lua_State *L, struct luam_Metrics *metrics);

The names of ``struct luam_Metrics`` members are the same as Lua's
:ref:`getmetrics table values <luajit_getmetrics_tablevalues>` names.
The data types of ``struct luam_Metrics`` members are all ``size_t``.
The ``luaM_metrics()`` function will fill the ``*metrics`` structure
with the metrics related to the Lua state anchored to the ``L`` coroutine.

**Example with a C program**

Go through the :ref:`C stored procedures <f_c_tutorial-c_stored_procedures>` tutorial.
Replace the easy.c example with

.. code-block:: c

    #include "module.h"
    #include <lmisclib.h>
    
    int easy(box_function_ctx_t *ctx, const char *args, const char *args_end)
    {
      lua_State *ls = luaT_state();
      struct luam_Metrics m;
      luaM_metrics(ls, &m);
      printf("allocated memory = %lu\n", m.gc_allocated);
      return 0;
    }

Now when you go back to the client and execute the requests up to and including the line
``capi_connection:call('easy')``
you will see that the display is something like
"allocated memory = 4431950"
although the number will vary.

.. _luajit_getmetrics_example_1:

Example with gc_strnum, strhash_miss, and strhash_hit
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To track new string object allocations:

.. code-block:: lua

    function f()
      collectgarbage("collect")
      local oldm = misc.getmetrics()
      local table_of_strings = {}
      for i = 3000, 4000 do table.insert(table_of_strings, tostring(i)) end
      for i = 3900, 4100 do table.insert(table_of_strings, tostring(i)) end
      local newm = misc.getmetrics()
      print("gc_strnum diff = " .. newm.gc_strnum - oldm.gc_strnum)
      print("strhash_miss diff = " .. newm.strhash_miss - oldm.strhash_miss)
      print("strhash_hit diff = " .. newm.strhash_hit - oldm.strhash_hit)
    end
    f()

The result will probably be:
"gc_strnum diff = 1100" because we added 1202 strings but 101 were duplicates,
"strhash_miss_diff = 1100" for the same reason,
"strhash_hit_diff = 101" plus some overhead, for the same reason.
(There is always a slight overhead amount for ``strhash_hit``, which can be ignored.)

We say "probably" because there is a chance that the strings were already
allocated somewhere.
It is a good thing if the slope curve of
``strhash_miss`` is less than the slope curve of ``strhash_hit``.

The other ``gc_*num`` values -- ``gc_cdatanum``, ``gc_tabnum``, ``gc_udatanum`` -- can be accessed
in a similar way.
Any of the ``gc_*num`` values can be useful when looking for memory leaks – the total 
number of these objects should not grow nonstop.
A more general way to look for memory leaks is to watch ``gc_total``.
Also ``jit_mcode_size`` can be used to watch the amount of allocated memory for machine code traces.

.. _luajit_getmetrics_example_2:

Example with gc_allocated and gc_freed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To track an application's effect on the garbage collector (less is better):

.. code-block:: lua

    function f()
      for i = 1, 10 do collectgarbage("collect") end
      local oldm = misc.getmetrics()
      local newm = misc.getmetrics()
      oldm = misc.getmetrics()
      collectgarbage("collect")
      newm = misc.getmetrics()
      print("gc_allocated diff = " .. newm.gc_allocated - oldm.gc_allocated)
      print("gc_freed diff = " .. newm.gc_freed - oldm.gc_freed)
    end
    f()

The result will be: ``gc_allocated diff = 800``, ``gc_freed diff = 800``.
This shows that ``local ... = getmetrics()`` itself causes memory allocation
(because it is creating a table and assigning to it),
and shows that when the name of a variable (in this case the ``oldm`` variable)
is used again, that causes freeing.
Ordinarily the freeing would not occur immediately, but
``collectgarbage("collect")`` forces it to happen so we can see the effect.

.. _luajit_getmetrics_example_3:

Example with gc_allocated and a space optimization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To test whether optimizing for space is possible with tables:

.. code-block:: lua

    function f()
      collectgarbage("collect")
      local oldm = misc.getmetrics()
      local t = {}
      for i = 1, 513 do
        t[i] = i
      end
      local newm = misc.getmetrics()
      local diff = newm.gc_allocated - oldm.gc_allocated
      print("diff = " .. diff)
    end
    f()

The result will show that diff equals approximately 18000.

Now see what happens if the table initialization is different:

.. code-block:: lua

    function f()
      local table_new = require "table.new"
      local oldm = misc.getmetrics()
      local t = table_new(513, 0)
      for i = 1, 513 do
        t[i] = i
      end
      local newm = misc.getmetrics()
      local diff = newm.gc_allocated - oldm.gc_allocated
      print("diff = " .. diff)
    end
    f()

The result will show that diff equals approximately 6000.

.. _luajit_getmetrics_example_4:

gc_steps_atomic and gc_steps_propagate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The slope curves of ``gc_steps_*`` items can be used for tracking pressure on
the garbage collector too.
During long-running routines, ``gc_steps_*`` values will increase,
but long times between ``gc_steps_atomic`` increases are a good sign,
And, since ``gc_steps_atomic`` increases only once per garbage-collector cycle,
it shows how many garbage-collector cycles have occurred.

Also, increases in the ``gc_steps_propagate`` number can be used to
estimate indirectly how many objects there are. These values also correlate with the
garbage collector's
`step multiplier <https://www.lua.org/manual/5.4/manual.html#2.5.1>`_.
For example, the number of incremental steps can grow, but according to the
step multiplier configuration, one step can process only a small number of objects.
So these metrics should be considered when configuring the garbage collector.

The following function takes a casual look whether an SQL statement causes much pressure:

.. code-block:: lua

    function f()
      collectgarbage("collect")
      local oldm = misc.getmetrics()
      collectgarbage("collect")
      box.execute([[DROP TABLE _vindex;]])
      local newm = misc.getmetrics()
      print("gc_steps_atomic = " .. newm.gc_steps_atomic - oldm.gc_steps_atomic)
      print("gc_steps_finalize = " .. newm.gc_steps_finalize - oldm.gc_steps_finalize)
      print("gc_steps_pause = " .. newm.gc_steps_pause - oldm.gc_steps_pause)
      print("gc_steps_propagate = " .. newm.gc_steps_propagate - oldm.gc_steps_propagate)
      print("gc_steps_sweep = " .. newm.gc_steps_sweep - oldm.gc_steps_sweep)
    end
    f()

And the display will show that the ``gc_steps_*`` metrics are not significantly
different from what they would be if the ``box.execute()`` was absent.

.. _luajit_getmetrics_example_5:

Example with jit_trace_num and jit_trace_abort
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Just-in-time compilers will "trace" code looking for opportunities to
compile. ``jit_trace_abort`` can show how often there was a failed attempt
(less is better), and ``jit_trace_num`` can show how many traces were
generated since the last flush (usually more is better).

The following function does not contain code that can cause trouble for LuaJIT:

.. code-block:: lua

    function f()
      jit.flush()
      for i = 1, 10 do collectgarbage("collect") end
      local oldm = misc.getmetrics()    
      collectgarbage("collect")
      local sum = 0
      for i = 1, 57 do
        sum = sum + 57
      end
      for i = 1, 10 do collectgarbage("collect") end
      local newm = misc.getmetrics()
      print("trace_num = " .. newm.jit_trace_num - oldm.jit_trace_num)
      print("trace_abort = " .. newm.jit_trace_abort - oldm.jit_trace_abort)
    end
    f()

The result is: trace_num = 1, trace_abort = 0. Fine.

The following function seemingly does contain code that can cause trouble for LuaJIT:

.. code-block:: lua

    jit.opt.start(0, "hotloop=2", "hotexit=2", "minstitch=15")
    _G.globalthing = 5
    function f()
      jit.flush()
      collectgarbage("collect")
      local oldm = misc.getmetrics()
      collectgarbage("collect")
      local sum = 0
      for i = 1, box.space._vindex:count()+ _G.globalthing do
        box.execute([[SELECT RANDOMBLOB(0);]])
        require('buffer').ibuf()
        _G.globalthing = _G.globalthing - 1
      end
      local newm = misc.getmetrics()
      print("trace_num = " .. newm.jit_trace_num - oldm.jit_trace_num)
      print("trace_abort = " .. newm.jit_trace_abort - oldm.jit_trace_abort)
    end
    f()

The result is: trace_num = between 2 and 4, trace_abort = 1.
This means that up to four traces needed to be generated instead of one,
and this means that something made LuaJIT give up in despair.
Tracing more will reveal that the problem is
not the suspicious-looking statements within the function, it
is the ``jit.opt.start`` call.
(A look at a jit.dump file might help in examining the trace compilation process.)

.. _luajit_getmetrics_example_6:

Example with jit_snap_restore and a performance unoptimization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the slope curves of the ``jit_snap_restore`` metric grow after
changes to old code, that can mean LuaJIT is stopping trace
execution more frequently, and that can mean performance is degraded.

Start with this code:

.. code-block:: lua

    function f()
      local function foo(i)
        return i <= 5 and i or tostring(i)
      end
      -- minstitch option needs to emulate nonstitching behaviour
      jit.opt.start(0, "hotloop=2", "hotexit=2", "minstitch=15")
      local sum = 0
      local oldm = misc.getmetrics()
      for i = 1, 10 do
        sum = sum + foo(i)
      end
      local newm = misc.getmetrics()
      local diff = newm.jit_snap_restore - oldm.jit_snap_restore
      print("diff = " .. diff)
    end
    f()

The result will be: diff = 3, because there is one side exit when the loop ends,
and there are two side exits to the interpreter before LuaJIT may decide that
the chunk of code is "hot"
(the default value of the hotloop parameter is 56 according to
`Running LuaJIT  <https://luajit.org/running.html#opt_O>`_).

And now change only one line within function ``local foo``, so now the code is:

.. code-block:: lua

    function f()
      local function foo(i)
        -- math.fmod is not yet compiled!
        return i <= 5 and i or math.fmod(i, 11)
      end
      -- minstitch option needs to emulate nonstitching behaviour
      jit.opt.start(0, "hotloop=2", "hotexit=2", "minstitch=15")
      local sum = 0
      local oldm = misc.getmetrics()
      for i = 1, 10 do
        sum = sum + foo(i)
      end
      local newm = misc.getmetrics()
      local diff = newm.jit_snap_restore - oldm.jit_snap_restore
      print("diff = " .. diff)
    end
    f()

The result will be: diff is larger, because there are more side exits.
So this test indicates that changing the code affected the performance.

.. Comment: There can be a FAQ here but so far there are no frequently-asked questions.

..  _luajit_sysprof:

LuaJIT platform profiler
========================

The default profiling options for LuaJIT are not fine enough to
get an understanding of performance. For example, ``perf`` is only
able to show the host stack, so all the Lua calls are displayed as a single
``pcall()``. Oppositely, the ``jit.p`` module provided with LuaJIT
is not able to give any information about the host stack.

Since version :doc:`2.10.0 </release/2.10.0>`, Tarantool
has a built‑in module called ``misc.sysprof`` that implements a
LuaJIT sampling profiler (further in this section we call it *the profiler*
for short). The profiler can capture both guest and
host stacks simultaneously, along with virtual machine states, so
it can show the whole picture.

Three profiling modes are available:

* **Default**: shows only virtual machine state counters.
* **Leaf**: shows the last frame on the stack.
* **Callchain**: performs a complete stack dump.

The profiler comes with a default parser, which produces output in
a ``flamegraph.pl``-suitable format.

Inside this section:

..  contents::
    :local:
    :depth: 2

.. _profiler_usage:

Working with the profiler
-------------------------

The profiler usage involves two steps:

1.  :ref:`Collecting <profiler_usage_get>` a binary profile of
    stacks (further referred as *binary sampling profile* or *binary profile*
    for short).
2.  :ref:`Parsing <profiler_usage_parse>` the collected binary
    profile to get a human-readable profiling report.

.. _profiler_usage_get:

Collecting a binary profile
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To collect a binary profile for a particular part of the Lua and C code,
you need to place this part between two ``misc.sysprof`` functions --
namely, ``misc.sysprof.start()`` and ``misc.sysprof.stop()`` -- and
then execute the code in Tarantool.

Below is a chunk of Lua code named ``test.lua`` to illustrate this.

.. _profiler_usage_example01:

..  code-block:: lua

    local function payload()
      local function fib(n)
        if n <= 1 then
          return n
        end
        return fib(n - 1) + fib(n - 2)
      end
      return fib(32)
    end

    payload()

    local res, err = misc.sysprof.start({mode = 'C', interval = 1, path = 'sysprof.bin'})
    assert(res, err)

    payload()

    res, err = misc.sysprof.stop()
    assert(res, err)

The Lua code for starting the profiler -- as in line 1 in the
``test.lua`` example above -- is:

..  code-block:: lua

    local str, err = misc.sysprof.start({mode = 'C', interval = 1, path = 'sysprof.bin'})

where:

* ``mode`` is a profiling mode;
* ``interval`` is a sampling interval;
* ``sysprof.bin`` is the name of the binary file where profiling events are written.

If the operation fails, for example if it is not possible to open
a file for writing or if the profiler is already running,
``misc.sysprof.start()`` returns ``nil`` as the first result,
an error-message string as the second result,
and a system-dependent error code number as the third result.

If the operation succeeds, ``misc.sysprof.start()`` returns ``true``.

The Lua code for stopping the profiler -- as in line 15 in the
``test.lua`` example above -- is:

..  code-block:: lua

    local res, err = misc.sysprof.stop()

If the operation fails, for example if there is an error when the
file descriptor is being closed or if there is a failure during
reporting, ``misc.sysprof.stop()`` returns ``nil`` as the first
result, an error-message string as the second result,
and a system-dependent error code number as the third result.

If the operation succeeds, ``misc.sysprof.stop()`` returns ``true``.

.. _profiler_usage_generate:

To generate a file with the memory profile in the binary format
(in the :ref:`test.lua code example above <profiler_usage_example01>`
the file name is ``sysprof.bin``), execute the code in Tarantool:

..  code-block:: console

    $ tarantool test.lua

Tarantool collects allocation events in ``sysprof.bin``, puts
the file in its :ref:`working directory <cfg_basic-work_dir>`,
and closes the session.

.. _profiler_usage_parse:

Parsing a binary profile and generating a profiling report
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _profiler_usage_parse_command:

After getting the platform profile in the binary format, the next step is
to parse it to get a human-readable profiling report. You can do this
via Tarantool with the following command
(mind the hyphen ``-`` before the filename):

..  code-block:: console

    $ tarantool -e 'require("sysprof")(arg)' - sysprof.bin > tmp
    $ curl -O https://raw.githubusercontent.com/brendangregg/FlameGraph/refs/heads/master/flamegraph.pl
    $ perl flamegraph.pl tmp > sysprof.svg

where ``sysprof.bin`` is the binary profile
:ref:`generated earlier <profiler_usage_generate>` by ``tarantool test.lua``.

..  note::

    There is a slight behavior change here: the ``tarantool -e ...`` command
    was slightly different in Tarantool versions prior to Tarantool 2.8.1.
    The resulting SVG image contains a flamegraph with collected stacks
    and can be opened by a modern web-browser for analysis.

As for investigating the Lua code with the help of profiling reports,
it is always code-dependent and there are no definite recommendations
in this regard. Nevertheless, you can see some of the things
in the :ref:`Profiling report analysis example <profiler_analysis>` below.

.. _profiler_lua_api:

Profiler Lua API
----------------

The platform profiler provides a Lua interface:

* ``misc.sysprof.start(opts)``
* ``misc.sysprof.stop()``
* ``misc.sysprof.report()``

The first two functions return boolean ``res`` and ``err``, which is
``nil`` on success and contains an error message on failure.

``misc.sysprof.report`` returns a Lua table containing the
following counters:

..  code-block:: console

    {
      "samples" = int,
      "INTERP" = int,
      "LFUNC" = int,
      "FFUNC" = int,
      "CFUNC" = int,
      "GC" = int,
      "EXIT" = int,
      "RECORD" = int,
      "OPT" = int,
      "ASM" = int,
      "TRACE" = int
   }

The ``opts`` argument of ``misc.sysprof.start`` can contain the
following parameters:

* ``mode`` (required) -- one of the supported profiling modes:

  * ``'D'`` = DEFAULT
  * ``'L'`` = LEAF
  * ``'C'`` = CALLGRAPH

* ``interval`` (optional) -- sampling interval in msec (default is 10 msec).
* ``path`` (optional) -- path to a file to store profile data
  (default is ``sysprof.bin``).

.. _profiler_c_api:

Profiler C API
--------------

The platform profiler provides a low-level C interface:

* ``int luaM_sysprof_set_writer(sp_writer writer)`` -- sets a writer function
  for sysprof.

* ``int luaM_sysprof_set_on_stop(sp_on_stop on_stop)`` -- sets
  an on-stop callback for ``sysprof`` to clear resources.

* ``int luaM_sysprof_set_backtracer(sp_backtracer backtracer)`` -- sets
  a backtracing function. If the ``backtracer`` argument is NULL,
  the default backtracer is set.

..  note::

    There is no need to call the configuration functions multiple times
    if you are starting and stopping the profiler several times
    in a single program.

    Also, it is not necessary to configure ``sysprof`` for the ``Default`` mode.
    However, you MUST configure it for other modes.

* ``int luaM_sysprof_start(lua_State *L, const struct luam_Sysprof_Options *opt)`` --
  see :ref:`Profiler options <profiler_c_options>`.

* ``int luaM_sysprof_stop(lua_State *L)``

* ``int luaM_sysprof_report(struct luam_Sysprof_Counters *counters)`` -- writes
  :ref:`profiling counters <profiler_c_counters>` for each vmstate.

All of the functions return 0 on success and an error code on failure.

.. _profiler_c_config_types:

Configuration C types
~~~~~~~~~~~~~~~~~~~~~

Profiler configuration settings include:

* ``typedef size_t (*sp_writer)(const void **data, size_t len, void *ctx)`` --
  a writer function for profile events.

  Must be async-safe, see also ``man 7 signal-safety``.

  Should return the amount of written bytes on success, or zero in case of error.

  Setting ``*data`` to NULL means end of profiling.
  For details see ``lj_wbuf.h``.

* ``typedef int (*sp_on_stop)(void *ctx, uint8_t *buf)`` -- a callback
  on profiler stopping. Required for a correct cleanup at VM finalization
  when the profiler is still running.

  Returns zero on success.

* ``typedef void (*sp_backtracer)(void *(*frame_writer)(int frame_no, void *addr))`` --
  a backtracing function for the host stack.
  Should call ``frame_writer`` on each frame in the stack, in the order
  from the stack top to the stack bottom.

  The ``frame_writer`` function is implemented inside ``sysprof``
  and will be passed to the ``backtracer`` function.

  If ``frame_writer`` returns NULL, backtracing should be stopped.
  If ``frame_writer`` returns not NULL, the backtracing should be continued
  if there are frames left.

.. _profiler_c_options:

Profiler options
~~~~~~~~~~~~~~~~

The options structure for ``luaM_sysprof_start`` is as follows:

..  code-block:: console

    struct luam_Sysprof_Options {
      /* Profiling mode. */
      uint8_t mode;

      /* Sampling interval in msec. */
      uint64_t interval;

      /* Custom buffer to write data. */
      uint8_t *buf;

      /* The buffer's size. */
      size_t len;

      /* Context for the profile writer and final callback. */
      void *ctx;
    };

.. _profiler_c_modes:

Profiling modes
~~~~~~~~~~~~~~~

The platform profiler supports three profiling modes:

* ``DEFAULT`` mode collects only data for ``luam_sysprof_counters``,
  which is stored in memory and can be collected with ``luaM_sysprof_report``
  after the profiler stops.

* ``LEAF`` mode = ``DEFAULT`` + streams samples with only top frames of the host
  and guests stacks in the format described in ``lj_sysprof.h``.

* ``CALLGRAPH`` mode = DEFAULT + streams samples with full callchains of the host
  and guest stacks in the format described in ``lj_sysprof.h``.

..  code-block:: console

    #define LUAM_SYSPROF_DEFAULT 0
    #define LUAM_SYSPROF_LEAF 1
    #define LUAM_SYSPROF_CALLGRAPH 2

.. _profiler_c_counters:

Profiling counters
~~~~~~~~~~~~~~~~~~

The counters structure for ``luaM_sysprof_report`` is as follows:

..  code-block:: console

   struct luam_Sysprof_Counters {
     uint64_t vmst_interp;
     uint64_t vmst_lfunc;
     uint64_t vmst_ffunc;
     uint64_t vmst_cfunc;
     uint64_t vmst_gc;
     uint64_t vmst_exit;
     uint64_t vmst_record;
     uint64_t vmst_opt;
     uint64_t vmst_asm;
     uint64_t vmst_trace;

     uint64_t samples;
   };

..  note::

    The order of ``vmst_*`` counters is important: it should be the same as
    the order of the vmstates.

.. _profiler_caveats:

Caveats
~~~~~~~

* Providing writers, backtracers and other settings in the ``Default`` mode
  is pointless, since it only collects counters.
* There is NO default configuration for ``sysprof``, so ``luaM_Sysprof_Configure``
  must be called before the first run of ``sysprof``. Mind the async safety.

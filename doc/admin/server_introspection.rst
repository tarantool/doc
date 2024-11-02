.. _admin-server_introspection:

Server introspection
====================

.. _admin-using_tarantool_as_a_client:

Using Tarantool as a client
---------------------------

Tarantool enters the interactive mode if:

* you start Tarantool without an
  :ref:`instance file <admin-instance_file>`, or

* the instance file contains :ref:`console.start() <console-start>`.

Tarantool displays a prompt (e.g. "tarantool>") and you can enter requests.
When used this way, Tarantool can be a client for a remote server.
See basic examples in :ref:`Getting started <getting_started>`.

The interactive mode is used in the ``tt`` utility's :ref:`connect <tt-connect>` command.

.. _admin-executing_code_on_an_instance:

Executing code on an instance
-----------------------------

You can attach to an instance's :ref:`admin console <admin-security>` and
execute some Lua code using ``tt``:

.. code-block:: console

    $ # for local instances:
    $ tt connect my_app
       • Connecting to the instance...
       • Connected to /var/run/tarantool/example.control

    /var/run/tarantool/my_app.control> 1 + 1
    ---
    - 2
    ...
    /var/run/tarantool/my_app.control>

    $ # for local and remote instances:
    $ tt connect username:password@127.0.0.1:3306

You can also use ``tt`` to execute Lua code on an instance without
attaching to its admin console. For example:

.. code-block:: console

    $ # executing commands directly from the command line
    $ <command> | tt connect my_app -f -
    <...>

    $ # - OR -

    $ # executing commands from a script file
    $ tt connect my_app -f script.lua
    <...>

.. NOTE::

    Alternatively, you can use the :ref:`console <console-module>` module or the
    :ref:`net.box <net_box-module>` module from a Tarantool server. Also, you can
    write your client programs with any of the
    :ref:`connectors <index-box_connectors>`. However, most of the examples in
    this manual illustrate usage with either ``tt connect`` or
    :ref:`using the Tarantool server as a client <admin-using_tarantool_as_a_client>`.

.. _admin-health_checks:

Health checks
-------------

To check the instance status, run:

.. code-block:: console

    $ tt status my_app

    $ # - OR -

    $ systemctl status tarantool@my_app

To check the boot log, on systems with ``systemd``, run:

.. code-block:: console

    $ journalctl -u tarantool@my_app -n 5

For more specific checks, use the reports provided by functions in the following submodules:

* :doc:`/reference/reference_lua/box_cfg` (check and specify all
  configuration parameters for the Tarantool server)

* :doc:`/reference/reference_lua/box_slab` (monitor the total use
  and fragmentation of memory allocated for storing data in Tarantool)

* :doc:`/reference/reference_lua/box_info` (introspect Tarantool
  server variables, primarily those related to replication)

* :doc:`/reference/reference_lua/box_stat` (introspect Tarantool
  request and network statistics)

Finally, there is the `metrics <https://github.com/tarantool/metrics>`_
library, which enables collecting metrics (such as memory usage or number
of requests) from Tarantool applications and expose them via various
protocols, including Prometheus. Check :ref:`Monitoring <monitoring>` for more details.

**Example**

A very popular administrator request is
:doc:`/reference/reference_lua/box_slab/slab_info`,
which displays detailed memory usage statistics for a Tarantool instance.

.. code-block:: tarantoolsession

    tarantool> box.slab.info()
    ---
    - items_size: 228128
      items_used_ratio: 1.8%
      quota_size: 1073741824
      quota_used_ratio: 0.8%
      arena_used_ratio: 43.2%
      items_used: 4208
      quota_used: 8388608
      arena_size: 2325176
      arena_used: 1003632
    ...

Tarantool takes memory from the operating system,
for example when a user does many insertions.
You can see how much it has taken by saying (on Linux):

.. code-block:: console

    ps -eo args,%mem | grep "tarantool"

Tarantool almost never releases this memory, even if the user
deletes everything that was inserted, or reduces
fragmentation by calling the Lua garbage collector via the
`collectgarbage function <https://www.lua.org/manual/5.1/manual.html#pdf-collectgarbage>`_.

Ordinarily this does not affect performance.
But, to force Tarantool to release memory, you can
call :doc:`box.snapshot() </reference/reference_lua/box_snapshot>`, stop the server instance,
and restart it.

.. _admin-inspect_traffic:

Inspect traffic
---------------

Inspecting binary traffic is a boring task. We offer a
`Wireshark plugin <https://github.com/tarantool/tarantool-dissector>`_ to
simplify the analysis of Tarantool's traffic.

To enable the plugin, follow the steps below.

Clone the tarantool-dissector repository:

.. code-block:: console

    git clone https://github.com/tarantool/tarantool-dissector.git

Copy or symlink the plugin files into the Wireshark plugin directory:

.. code-block:: console

    mkdir -p ~/.local/lib/wireshark/plugins
    cd ~/.local/lib/wireshark/plugins
    ln -s /path/to/tarantool-dissector/MessagePack.lua ./
    ln -s /path/to/tarantool-dissector/tarantool.dissector.lua ./

(For the location of the plugin directory on macOS and Windows, please refer to
the `Plugin folders <https://www.wireshark.org/docs/wsug_html_chunked/ChPluginFolders.html>`_
chapter in the Wireshark documentation.)

Run the Wireshark GUI and ensure that the plugins are loaded:

* Open :guilabel:`Help` > :guilabel:`About Wireshark` > :guilabel:`Plugins`.
* Find ``MessagePack.lua`` and ``tarantool.dissector.lua`` in the list.

Now you can inspect incoming and outgoing Tarantool packets with user-friendly
annotations.

Visit the project page for details:
`https://github.com/tarantool/tarantool-dissector <https://github.com/tarantool/tarantool-dissector>`_.

.. _admin-profiling_performance_issues:

Profiling performance issues
----------------------------

Tarantool can at times work slower than usual. There can be multiple reasons,
such as disk issues, CPU-intensive Lua scripts or misconfiguration.
Tarantool’s log may lack details in such cases, so the only indications that
something goes wrong are log entries like this: ``W> too long DELETE: 8.546 sec``.
Here are tools and techniques that can help you collect Tarantool’s performance
profile, which is helpful in troubleshooting slowdowns.

.. NOTE::

    Most of these tools -- except ``fiber.info()`` -- are intended for
    generic GNU/Linux distributions, but not FreeBSD or Mac OS.

fiber.info()
~~~~~~~~~~~~

The simplest profiling method is to take advantage of Tarantool’s built-in
functionality. :ref:`fiber.info() <fiber-info>` returns information about all
running fibers with their corresponding C stack traces. You can use this data
to see how many fibers are running and which C functions are executed more often
than others.

First, enter your instance’s interactive administrator console:

.. code-block:: console

    $ tt connect NAME|URI

Once there, load the ``fiber`` module:

.. code-block:: tarantoolsession

    tarantool> fiber = require('fiber')

After that you can get the required information with ``fiber.info()``.

At this point, your console output should look something like this:

.. code-block:: tarantoolsession

    tarantool> fiber = require('fiber')
    ---
    ...
    tarantool> fiber.info()
    ---
    - 360:
        csw: 2098165
        backtrace:
        - '#0 0x4d1b77 in wal_write(journal*, journal_entry*)+487'
        - '#1 0x4bbf68 in txn_commit(txn*)+152'
        - '#2 0x4bd5d8 in process_rw(request*, space*, tuple**)+136'
        - '#3 0x4bed48 in box_process1+104'
        - '#4 0x4d72f8 in lbox_replace+120'
        - '#5 0x50f317 in lj_BC_FUNCC+52'
        fid: 360
        memory:
          total: 61744
          used: 480
        name: main
      129:
        csw: 113
        backtrace: []
        fid: 129
        memory:
          total: 57648
          used: 0
        name: 'console/unix/:'
    ...

We highly recommend to assign meaningful names to fibers you create so that you
can find them in the ``fiber.info()`` list. In the example below, we create a
fiber named ``myworker``:

.. code-block:: tarantoolsession

    tarantool> fiber = require('fiber')
    ---
    ...
    tarantool> f = fiber.create(function() while true do fiber.sleep(0.5) end end)
    ---
    ...
    tarantool> f:name('myworker') <!-- assigning the name to a fiber
    ---
    ...
    tarantool> fiber.info()
    ---
    - 102:
        csw: 14
        backtrace:
        - '#0 0x501a1a in fiber_yield_timeout+90'
        - '#1 0x4f2008 in lbox_fiber_sleep+72'
        - '#2 0x5112a7 in lj_BC_FUNCC+52'
        fid: 102
        memory:
          total: 57656
          used: 0
        name: myworker <!-- newly created background fiber
      101:
        csw: 284
        backtrace: []
        fid: 101
        memory:
          total: 57656
          used: 0
        name: interactive
    ...

You can kill any fiber with :ref:`fiber.kill(fid) <fiber-kill>`:

.. code-block:: tarantoolsession

    tarantool> fiber.kill(102)
    ---
    ...
    tarantool> fiber.info()
    ---
    - 101:
        csw: 324
        backtrace: []
        fid: 101
        memory:
          total: 57656
          used: 0
        name: interactive
    ...

To get a table of all alive fibers you can use :ref:`fiber.top() <fiber-top>`.

If you want to dynamically obtain information with ``fiber.info()``, the shell
script below may come in handy. It connects to a Tarantool instance specified by
``NAME`` every 0.5 seconds, grabs the ``fiber.info()`` output and writes it to
the ``fiber-info.txt`` file:

.. code-block:: console

    $ rm -f fiber.info.txt
    $ watch -n 0.5 "echo 'require(\"fiber\").info()' | tt connect NAME -f - | tee -a fiber-info.txt"

If you can't understand which fiber causes performance issues, collect the
metrics of the ``fiber.info()`` output for 10-15 seconds using the script above
and contact the Tarantool team at support@tarantool.org.

Poor man’s profilers
~~~~~~~~~~~~~~~~~~~~

**pstack <pid>**

To use this tool, first install it with a package manager that comes with your
Linux distribution. This command prints an execution stack trace of a running
process specified by the PID. You might want to run this command several times
in a row to pinpoint the bottleneck that causes the slowdown.

Once installed, say:

.. code-block:: console

    $ pstack $(pidof tarantool INSTANCENAME.lua)

Next, say:

.. code-block:: console

    $ echo $(pidof tarantool INSTANCENAME.lua)

to show the PID of the Tarantool instance that runs the ``INSTANCENAME.lua`` file.

You should get similar output:

.. code-block:: bash

    Thread 19 (Thread 0x7f09d1bff700 (LWP 24173)):
    #0 0x00007f0a1a5423f2 in ?? () from /lib64/libgomp.so.1
    #1 0x00007f0a1a53fdc0 in ?? () from /lib64/libgomp.so.1
    #2 0x00007f0a1ad5adc5 in start_thread () from /lib64/libpthread.so.0
    #3 0x00007f0a1a050ced in clone () from /lib64/libc.so.6
    Thread 18 (Thread 0x7f09d13fe700 (LWP 24174)):
    #0 0x00007f0a1a5423f2 in ?? () from /lib64/libgomp.so.1
    #1 0x00007f0a1a53fdc0 in ?? () from /lib64/libgomp.so.1
    #2 0x00007f0a1ad5adc5 in start_thread () from /lib64/libpthread.so.0
    #3 0x00007f0a1a050ced in clone () from /lib64/libc.so.6
    <...>
    Thread 2 (Thread 0x7f09c8bfe700 (LWP 24191)):
    #0 0x00007f0a1ad5e6d5 in pthread_cond_wait@@GLIBC_2.3.2 () from /lib64/libpthread.so.0
    #1 0x000000000045d901 in wal_writer_pop(wal_writer*) ()
    #2 0x000000000045db01 in wal_writer_f(__va_list_tag*) ()
    #3 0x0000000000429abc in fiber_cxx_invoke(int (*)(__va_list_tag*), __va_list_tag*) ()
    #4 0x00000000004b52a0 in fiber_loop ()
    #5 0x00000000006099cf in coro_init ()
    Thread 1 (Thread 0x7f0a1c47fd80 (LWP 24172)):
    #0 0x00007f0a1a0512c3 in epoll_wait () from /lib64/libc.so.6
    #1 0x00000000006051c8 in epoll_poll ()
    #2 0x0000000000607533 in ev_run ()
    #3 0x0000000000428e13 in main ()

**gdb -ex "bt" -p <pid>**

As with ``pstack``, the GNU debugger (also known as ``gdb``) needs to be installed
before you can start using it. Your Linux package manager can help you with that.

Once the debugger is installed, say:

.. code-block:: console

    $ gdb -ex "set pagination 0" -ex "thread apply all bt" --batch -p $(pidof tarantool INSTANCENAME.lua)

Next, say:

.. code-block:: console

    $ echo $(pidof tarantool INSTANCENAME.lua)

to show the PID of the Tarantool instance that runs the ``INSTANCENAME.lua`` file.

After using the debugger, your console output should look like this:

.. code-block:: bash

    [Thread debugging using libthread_db enabled]
    Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

    [CUT]

    Thread 1 (Thread 0x7f72289ba940 (LWP 20535)):
    #0 _int_malloc (av=av@entry=0x7f7226e0eb20 <main_arena>, bytes=bytes@entry=504) at malloc.c:3697
    #1 0x00007f7226acf21a in __libc_calloc (n=<optimized out>, elem_size=<optimized out>) at malloc.c:3234
    #2 0x00000000004631f8 in vy_merge_iterator_reserve (capacity=3, itr=0x7f72264af9e0) at /usr/src/tarantool/src/box/vinyl.c:7629
    #3 vy_merge_iterator_add (itr=itr@entry=0x7f72264af9e0, is_mutable=is_mutable@entry=true, belong_range=belong_range@entry=false) at /usr/src/tarantool/src/box/vinyl.c:7660
    #4 0x00000000004703df in vy_read_iterator_add_mem (itr=0x7f72264af990) at /usr/src/tarantool/src/box/vinyl.c:8387
    #5 vy_read_iterator_use_range (itr=0x7f72264af990) at /usr/src/tarantool/src/box/vinyl.c:8453
    #6 0x000000000047657d in vy_read_iterator_start (itr=<optimized out>) at /usr/src/tarantool/src/box/vinyl.c:8501
    #7 0x00000000004766b5 in vy_read_iterator_next (itr=itr@entry=0x7f72264af990, result=result@entry=0x7f72264afad8) at /usr/src/tarantool/src/box/vinyl.c:8592
    #8 0x000000000047689d in vy_index_get (tx=tx@entry=0x7f7226468158, index=index@entry=0x2563860, key=<optimized out>, part_count=<optimized out>, result=result@entry=0x7f72264afad8) at /usr/src/tarantool/src/box/vinyl.c:5705
    #9 0x0000000000477601 in vy_replace_impl (request=<optimized out>, request=<optimized out>, stmt=0x7f72265a7150, space=0x2567ea0, tx=0x7f7226468158) at /usr/src/tarantool/src/box/vinyl.c:5920
    #10 vy_replace (tx=0x7f7226468158, stmt=stmt@entry=0x7f72265a7150, space=0x2567ea0, request=<optimized out>) at /usr/src/tarantool/src/box/vinyl.c:6608
    #11 0x00000000004615a9 in VinylSpace::executeReplace (this=<optimized out>, txn=<optimized out>, space=<optimized out>, request=<optimized out>) at /usr/src/tarantool/src/box/vinyl_space.cc:108
    #12 0x00000000004bd723 in process_rw (request=request@entry=0x7f72265a70f8, space=space@entry=0x2567ea0, result=result@entry=0x7f72264afbc8) at /usr/src/tarantool/src/box/box.cc:182
    #13 0x00000000004bed48 in box_process1 (request=0x7f72265a70f8, result=result@entry=0x7f72264afbc8) at /usr/src/tarantool/src/box/box.cc:700
    #14 0x00000000004bf389 in box_replace (space_id=space_id@entry=513, tuple=<optimized out>, tuple_end=<optimized out>, result=result@entry=0x7f72264afbc8) at /usr/src/tarantool/src/box/box.cc:754
    #15 0x00000000004d72f8 in lbox_replace (L=0x413c5780) at /usr/src/tarantool/src/box/lua/index.c:72
    #16 0x000000000050f317 in lj_BC_FUNCC ()
    #17 0x00000000004d37c7 in execute_lua_call (L=0x413c5780) at /usr/src/tarantool/src/box/lua/call.c:282
    #18 0x000000000050f317 in lj_BC_FUNCC ()
    #19 0x0000000000529c7b in lua_cpcall ()
    #20 0x00000000004f6aa3 in luaT_cpcall (L=L@entry=0x413c5780, func=func@entry=0x4d36d0 <execute_lua_call>, ud=ud@entry=0x7f72264afde0) at /usr/src/tarantool/src/lua/utils.c:962
    #21 0x00000000004d3fe7 in box_process_lua (handler=0x4d36d0 <execute_lua_call>, out=out@entry=0x7f7213020600, request=request@entry=0x413c5780) at /usr/src/tarantool/src/box/lua/call.c:382
    #22 box_lua_call (request=request@entry=0x7f72130401d8, out=out@entry=0x7f7213020600) at /usr/src/tarantool/src/box/lua/call.c:405
    #23 0x00000000004c0f27 in box_process_call (request=request@entry=0x7f72130401d8, out=out@entry=0x7f7213020600) at /usr/src/tarantool/src/box/box.cc:1074
    #24 0x000000000041326c in tx_process_misc (m=0x7f7213040170) at /usr/src/tarantool/src/box/iproto.cc:942
    #25 0x0000000000504554 in cmsg_deliver (msg=0x7f7213040170) at /usr/src/tarantool/src/cbus.c:302
    #26 0x0000000000504c2e in fiber_pool_f (ap=<error reading variable: value has been optimized out>) at /usr/src/tarantool/src/fiber_pool.c:64
    #27 0x000000000041122c in fiber_cxx_invoke(fiber_func, typedef __va_list_tag __va_list_tag *) (f=<optimized out>, ap=<optimized out>) at /usr/src/tarantool/src/fiber.h:645
    #28 0x00000000005011a0 in fiber_loop (data=<optimized out>) at /usr/src/tarantool/src/fiber.c:641
    #29 0x0000000000688fbf in coro_init () at /usr/src/tarantool/third_party/coro/coro.c:110

Run the debugger in a loop a few times to collect enough samples for making
conclusions about why Tarantool demonstrates suboptimal performance.
Use the following script:

.. code-block:: console

    $ rm -f stack-trace.txt
    $ watch -n 0.5 "gdb -ex 'set pagination 0' -ex 'thread apply all bt' --batch -p $(pidof tarantool INSTANCENAME.lua) | tee -a stack-trace.txt"

Structurally and functionally, this script is very similar to the one used with
``fiber.info()`` above.

If you have any difficulties troubleshooting, let the script run for 10-15 seconds
and then send the resulting ``stack-trace.txt`` file to the Tarantool team at
support@tarantool.org.

.. WARNING::

    Use the poor man’s profilers with caution: each time they attach to a running
    process, this stops the process execution for about a second, which may leave
    a serious footprint in high-load services.

gperftools
~~~~~~~~~~

To use the CPU profiler from the Google Performance Tools suite with Tarantool,
first take care of the prerequisites:

* For Debian/Ubuntu, run:

.. code-block:: console

    $ apt-get install libgoogle-perftools4

* For RHEL/CentOS/Fedora, run:

.. code-block:: console

    $ yum install gperftools-libs

Once you do this, install Lua bindings:

.. code-block:: console

    $ tt rocks install gperftools

Now you're ready to go. Enter your instance’s interactive administrator console:

.. code-block:: console

    $ tt connect NAME|URI

To start profiling, say:

.. code-block:: tarantoolsession

    tarantool> cpuprof = require('gperftools.cpu')
    tarantool> cpuprof.start('/home/<username>/tarantool-on-production.prof')

It takes at least a couple of minutes for the profiler to gather performance
metrics. After that, save the results to disk (you can do that as many times as
you need):

.. code-block:: tarantoolsession

    tarantool> cpuprof.flush()

To stop profiling, say:

.. code-block:: tarantoolsession

    tarantool> cpuprof.stop()

You can now analyze the output with the ``pprof`` utility that comes with the
``gperftools`` package:

.. code-block:: console

    $ pprof --text /usr/bin/tarantool /home/<username>/tarantool-on-production.prof

.. NOTE::

    On Debian/Ubuntu, the ``pprof`` utility is called ``google-pprof``.

Your output should look similar to this:

.. code-block:: bash

    Total: 598 samples
          83 13.9% 13.9% 83 13.9% epoll_wait
          54 9.0% 22.9% 102 17.1%
    vy_mem_tree_insert.constprop.35
          32 5.4% 28.3% 34 5.7% __write_nocancel
          28 4.7% 32.9% 42 7.0% vy_mem_iterator_start_from
          26 4.3% 37.3% 26 4.3% _IO_str_seekoff
          21 3.5% 40.8% 21 3.5% tuple_compare_field
          19 3.2% 44.0% 19 3.2%
    ::TupleCompareWithKey::compare
          19 3.2% 47.2% 38 6.4% tuple_compare_slowpath
          12 2.0% 49.2% 23 3.8% __libc_calloc
           9 1.5% 50.7% 9 1.5%
    ::TupleCompare::compare@42efc0
           9 1.5% 52.2% 9 1.5% vy_cache_on_write
           9 1.5% 53.7% 57 9.5% vy_merge_iterator_next_key
           8 1.3% 55.0% 8 1.3% __nss_passwd_lookup
           6 1.0% 56.0% 25 4.2% gc_onestep
           6 1.0% 57.0% 6 1.0% lj_tab_next
           5 0.8% 57.9% 5 0.8% lj_alloc_malloc
           5 0.8% 58.7% 131 21.9% vy_prepare

perf
~~~~

This tool for performance monitoring and analysis is installed separately via
your package manager. Try running the ``perf`` command in the terminal and
follow the prompts to install the necessary package(s).

.. NOTE::

    By default, some ``perf`` commands are restricted to **root**, so, to be on
    the safe side, either run all commands as **root** or prepend them with
    ``sudo``.

To start gathering performance statistics, say:

.. code-block:: console

    $ perf record -g -p $(pidof tarantool INSTANCENAME.lua)

This command saves the gathered data to a file named ``perf.data`` inside the
current working directory. To stop this process (usually, after 10-15 seconds),
press **ctrl+C**. In your console, you’ll see:

.. code-block:: console

    ^C[ perf record: Woken up 1 times to write data ]
    [ perf record: Captured and wrote 0.225 MB perf.data (1573 samples) ]

Now run the following command:

.. code-block:: console

    $ perf report -n -g --stdio | tee perf-report.txt

It formats the statistical data in the ``perf.data`` file into a performance
report and writes it to the ``perf-report.txt`` file.

The resulting output should look similar to this:

.. code-block:: bash

    # Samples: 14K of event 'cycles'
    # Event count (approx.): 9927346847
    #
    # Children Self Samples Command Shared Object Symbol
    # ........ ........ ............ ......... .................. .......................................
    #
        35.50% 0.55% 79 tarantool tarantool [.] lj_gc_step
                |
                 --34.95%--lj_gc_step
                           |
                           |--29.26%--gc_onestep
                           | |
                           | |--13.85%--gc_sweep
                           | | |
                           | | |--5.59%--lj_alloc_free
                           | | |
                           | | |--1.33%--lj_tab_free
                           | | | |
                           | | | --1.01%--lj_alloc_free
                           | | |
                           | | --1.17%--lj_cdata_free
                           | |
                           | |--5.41%--gc_finalize
                           | | |
                           | | |--1.06%--lj_obj_equal
                           | | |
                           | | --0.95%--lj_tab_set
                           | |
                           | |--4.97%--rehashtab
                           | | |
                           | | --3.65%--lj_tab_resize
                           | | |
                           | | |--0.74%--lj_tab_set
                           | | |
                           | | --0.72%--lj_tab_newkey
                           | |
                           | |--0.91%--propagatemark
                           | |
                           | --0.67%--lj_cdata_free
                           |
                            --5.43%--propagatemark
                                      |
                                       --0.73%--gc_mark

Unlike the poor man’s profilers, ``gperftools`` and ``perf`` have low overhead
(almost negligible as compared with ``pstack`` and ``gdb``): they don’t result
in long delays when attaching to a process and therefore can be used without
serious consequences.

jit.p
~~~~~


The jit.p profiler comes with the Tarantool application server, to load it one
only needs to say ``require('jit.p')`` or ``require('jit.profile')``.
There are many options for sampling and display, they are described in
the documentation for the LuaJIT Profiler, available from the 2.1 branch of the git
repository in the file: ``doc/ext_profiler.html``.

**Example**

Make a function that calls a function named f1 that
does 500,000 inserts and deletes in a Tarantool space.
Start the profiler, execute the function, stop the
profiler, and show what the profiler sampled.

.. code-block:: lua

    box.space.t:drop()
    box.schema.space.create('t')
    box.space.t:create_index('i')
    function f1() for i = 1,500000 do
      box.space.t:insert{i}
      box.space.t:delete{i}
      end
    return 1
    end
    function f3() f1() end
    jit_p = require("jit.profile")
    sampletable = {}
    jit_p.start("f", function(thread, samples, vmstate)
      local dump=jit_p.dumpstack(thread, "f", 1)
      sampletable[dump] = (sampletable[dump] or 0) + samples
    end)
    f3()
    jit_p.stop()
    for d,v in pairs(sampletable) do print(v, d) end

Typically the result will show that the sampling happened
within f1() many times, but also within internal Tarantool
functions, whose names may change with each new version.


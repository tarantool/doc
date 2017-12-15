.. _admin-daemon_supervision:

================================================================================
Daemon supervision
================================================================================

.. _admin-server_signals:

--------------------------------------------------------------------------------
Server signals
--------------------------------------------------------------------------------

Tarantool processes these signals during the event loop in the transaction
processor thread:

.. container:: table

    .. rst-class:: right-align-column-1
    .. rst-class:: left-align-column-2

    +---------------------+------------------------------------------------------+
    | Signal              | Effect                                               |
    +=====================+======================================================+
    | SIGHUP              | May cause log file rotation. See the                 |
    |                     | :ref:`example <cfg_logging-logging_example>` in      |
    |                     | reference on Tarantool logging parameters.           |
    +---------------------+------------------------------------------------------+
    | SIGUSR1             | May cause a database checkpoint. See                 |
    |                     | :ref:`box.snapshot <box-snapshot>`.                  |
    +---------------------+------------------------------------------------------+
    | SIGTERM             | May cause graceful shutdown (information will be     |
    |                     | saved first).                                        |
    +---------------------+------------------------------------------------------+
    | SIGINT              | May cause graceful shutdown.                         |
    | (also known as      |                                                      |
    | keyboard interrupt) |                                                      |
    +---------------------+------------------------------------------------------+
    | SIGKILL             | Causes an immediate shutdown.                        |
    +---------------------+------------------------------------------------------+

Other signals will result in behavior defined by the operating system. Signals
other than SIGKILL may be ignored, especially if Tarantool is executing a
long-running procedure which prevents return to the event loop in the
transaction processor thread.

.. _admin-automatic_instance_restart:

--------------------------------------------------------------------------------
Automatic instance restart
--------------------------------------------------------------------------------

On ``systemd``-enabled platforms, ``systemd`` automatically restarts all
Tarantool instances in case of failure. To demonstrate it, let’s try to destroy
an instance:

.. code-block:: console

    $ systemctl status tarantool@my_app|grep PID
    Main PID: 5885 (tarantool)
    $ tarantoolctl enter my_app
    /bin/tarantoolctl: Found my_app.lua in /etc/tarantool/instances.available
    /bin/tarantoolctl: Connecting to /var/run/tarantool/my_app.control
    /bin/tarantoolctl: connected to unix/:/var/run/tarantool/my_app.control
    unix/:/var/run/tarantool/my_app.control> os.exit(-1)
    /bin/tarantoolctl: unix/:/var/run/tarantool/my_app.control: Remote host closed connection

Now let’s make sure that ``systemd`` has restarted the instance:

.. code-block:: console

    $ systemctl status tarantool@my_app|grep PID
    Main PID: 5914 (tarantool)

Finally, let’s check the boot logs:

.. code-block:: console

    $ journalctl -u tarantool@my_app -n 8
    -- Logs begin at Fri 2016-01-08 12:21:53 MSK, end at Thu 2016-01-21 21:09:45 MSK. --
    Jan 21 21:09:45 localhost.localdomain systemd[1]: tarantool@my_app.service: Unit entered failed state.
    Jan 21 21:09:45 localhost.localdomain systemd[1]: tarantool@my_app.service: Failed with result 'exit-code'.
    Jan 21 21:09:45 localhost.localdomain systemd[1]: tarantool@my_app.service: Service hold-off time over, scheduling restart.
    Jan 21 21:09:45 localhost.localdomain systemd[1]: Stopped Tarantool Database Server.
    Jan 21 21:09:45 localhost.localdomain systemd[1]: Starting Tarantool Database Server...
    Jan 21 21:09:45 localhost.localdomain tarantoolctl[5910]: /usr/bin/tarantoolctl: Found my_app.lua in /etc/tarantool/instances.available
    Jan 21 21:09:45 localhost.localdomain tarantoolctl[5910]: /usr/bin/tarantoolctl: Starting instance...
    Jan 21 21:09:45 localhost.localdomain systemd[1]: Started Tarantool Database Server.

.. _admin-core_dumps:

--------------------------------------------------------------------------------
Core dumps
--------------------------------------------------------------------------------

Tarantool makes a core dump if it receives any of the following signals: SIGSEGV,
SIGFPE, SIGABRT or SIGQUIT. This is automatic if Tarantool crashes.

On ``systemd``-enabled platforms, ``coredumpctl`` automatically saves core dumps
and stack traces in case of a crash. Here is a general "how to" for how to
enable core dumps on a Unix system:

1. Ensure session limits are configured to enable core dumps, i.e. say
   ``ulimit -c unlimited``. Check  "man 5 core" for other reasons why a core
   dump may not be produced.

2. Set a directory for writing core dumps to, and make sure that the directory
   is writable. On Linux, the directory path is set in a kernel parameter
   configurable via ``/proc/sys/kernel/core_pattern``.

3. Make sure that core dumps include stack trace information. If you use a
   binary Tarantool distribution, this is automatic. If you build Tarantool
   from source, you will not get detailed information if you pass
   ``-DCMAKE_BUILD_TYPE=Release`` to CMake.

To simulate a crash, you can execute an illegal command against a Tarantool
instance:

.. code-block:: console

    $ # !!! please never do this on a production system !!!
    $ tarantoolctl enter my_app
    unix/:/var/run/tarantool/my_app.control> require('ffi').cast('char *', 0)[0] = 48
    /bin/tarantoolctl: unix/:/var/run/tarantool/my_app.control: Remote host closed connection

Alternatively, if you know the process ID of the instance (here we refer to it
as $PID), you can abort a Tarantool instance by running ``gdb`` debugger:

.. code-block:: console

    $ gdb -batch -ex "generate-core-file" -p $PID

or manually sending a SIGABRT signal:

.. code-block:: console

    $ kill -SIGABRT $PID

.. NOTE::

    To find out the process id of the instance ($PID), you can:

    * look it up in the instance's :ref:`box.info.pid <box_introspection-box_info>`,

    * find it with ``ps -A | grep tarantool``, or

    * say ``systemctl status tarantool@my_app|grep PID``.

On a ``systemd-enabled`` system, to see the latest crashes of the Tarantool
daemon, say:

.. code-block:: console

    $ coredumpctl list /usr/bin/tarantool
    MTIME                            PID   UID   GID SIG PRESENT EXE
    Sat 2016-01-23 15:21:24 MSK   20681  1000  1000   6   /usr/bin/tarantool
    Sat 2016-01-23 15:51:56 MSK   21035   995   992   6   /usr/bin/tarantool

To save a core dump into a file, say:

.. code-block:: console

    $ coredumpctl -o filename.core info <pid>

.. _admin-stack_traces:

--------------------------------------------------------------------------------
Stack traces
--------------------------------------------------------------------------------

Since Tarantool stores tuples in memory, core files may be large.
For investigation, you normally don't need the whole file, but only a
"stack trace" or "backtrace".

To save a stack trace into a file, say:

.. code-block:: console

    $ gdb -se "tarantool" -ex "bt full" -ex "thread apply all bt" --batch -c core> /tmp/tarantool_trace.txt

where:

* "tarantool" is the path to the Tarantool executable,
* "core" is the path to the core file, and
* "/tmp/tarantool_trace.txt" is a sample path to a file for saving the stack trace.

.. NOTE::

   Occasionally, you may find that the trace file contains output without debug
   symbols – the lines will contain ”??” instead of names. If this happens,
   check the instructions on these Tarantool wiki pages:
   `How to debug core dump of stripped tarantool <https://github.com/tarantool/tarantool/wiki/How-to-debug-core-dump-of-stripped-tarantool>`_
   and
   `How to debug core from different OS <https://github.com/tarantool/tarantool/wiki/How-to-debug-core-from-different-OS>`_.

To see the stack trace and other useful information in console, say:

.. code-block:: console

    $ coredumpctl info 21035
              PID: 21035 (tarantool)
              UID: 995 (tarantool)
              GID: 992 (tarantool)
           Signal: 6 (ABRT)
        Timestamp: Sat 2016-01-23 15:51:42 MSK (4h 36min ago)
     Command Line: tarantool my_app.lua <running>
       Executable: /usr/bin/tarantool
    Control Group: /system.slice/system-tarantool.slice/tarantool@my_app.service
             Unit: tarantool@my_app.service
            Slice: system-tarantool.slice
          Boot ID: 7c686e2ef4dc4e3ea59122757e3067e2
       Machine ID: a4a878729c654c7093dc6693f6a8e5ee
         Hostname: localhost.localdomain
          Message: Process 21035 (tarantool) of user 995 dumped core.

                   Stack trace of thread 21035:
                   #0  0x00007f84993aa618 raise (libc.so.6)
                   #1  0x00007f84993ac21a abort (libc.so.6)
                   #2  0x0000560d0a9e9233 _ZL12sig_fatal_cbi (tarantool)
                   #3  0x00007f849a211220 __restore_rt (libpthread.so.0)
                   #4  0x0000560d0aaa5d9d lj_cconv_ct_ct (tarantool)
                   #5  0x0000560d0aaa687f lj_cconv_ct_tv (tarantool)
                   #6  0x0000560d0aaabe33 lj_cf_ffi_meta___newindex (tarantool)
                   #7  0x0000560d0aaae2f7 lj_BC_FUNCC (tarantool)
                   #8  0x0000560d0aa9aabd lua_pcall (tarantool)
                   #9  0x0000560d0aa71400 lbox_call (tarantool)
                   #10 0x0000560d0aa6ce36 lua_fiber_run_f (tarantool)
                   #11 0x0000560d0a9e8d0c _ZL16fiber_cxx_invokePFiP13__va_list_tagES0_ (tarantool)
                   #12 0x0000560d0aa7b255 fiber_loop (tarantool)
                   #13 0x0000560d0ab38ed1 coro_init (tarantool)
                   ...

.. _admin-debugger:

--------------------------------------------------------------------------------
Debugger
--------------------------------------------------------------------------------

To start ``gdb`` debugger on the core dump, say:

.. code-block:: console

    $ coredumpctl gdb <pid>

It is highly recommended to install ``tarantool-debuginfo`` package to improve
``gdb`` experience, for example:

.. code-block:: console

    $ dnf debuginfo-install tarantool

``gdb`` also provides information about the debuginfo packages you need to
install:

.. code-block:: console

    $ gdb -p <pid>
    ...
    Missing separate debuginfos, use: dnf debuginfo-install
    glibc-2.22.90-26.fc24.x86_64 krb5-libs-1.14-12.fc24.x86_64
    libgcc-5.3.1-3.fc24.x86_64 libgomp-5.3.1-3.fc24.x86_64
    libselinux-2.4-6.fc24.x86_64 libstdc++-5.3.1-3.fc24.x86_64
    libyaml-0.1.6-7.fc23.x86_64 ncurses-libs-6.0-1.20150810.fc24.x86_64
    openssl-libs-1.0.2e-3.fc24.x86_64

Symbolic names are present in stack traces even if you don’t have
``tarantool-debuginfo`` package installed.

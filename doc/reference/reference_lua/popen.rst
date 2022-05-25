..  _popen-module:

-------------------------------------------------------------------------------
                                   Module popen
-------------------------------------------------------------------------------

..  module:: popen

===============================================================================
                                   Overview
===============================================================================

Since version :doc:`2.4.1 </release/2.4.1>`, Tarantool has the ``popen``
built-in module that supports execution of external programs.
It is similar to Python's
`subprocess() <https://docs.python.org/3.8/library/subprocess.html>`_
or Ruby's `Open3 <https://docs.ruby-lang.org/en/2.0.0/Open3.html>`_.
However, Tarantool's ``popen`` module does not have all the helpers that
those languages provide, it provides only basic functions.
``popen`` uses the
`vfork() <https://pubs.opengroup.org/onlinepubs/009695399/functions/vfork.html>`_
system call to create an object, so the caller thread is
blocked until execution of a child process begins.

The ``popen`` module provides two functions to create the popen
object:

* :ref:`popen.shell <popen-shell>` which is similar to
  the libc `popen <https://www.gnu.org/software/libc/manual/html_node/Pipe-to-a-Subprocess.html>`_
  syscall
* :ref:`popen.new <popen-new>` to create a popen object with more specific options

Either function returns a handle which we will call ``popen_handle`` or ``ph``.
With the handle one can execute methods.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``popen`` functions and handle methods.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`popen.shell()                  | Execute a shell command         |
    | <popen-shell>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`popen.new()                    | Execute a child program in      |
    | <popen-new>`                         | a new process                   |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:read()            | Read data from a child peer     |
    | <popen-read>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:write()           | Write a string to stdin         |
    | <popen-write>`                       | stream of a child process       |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:shutdown()        | Close parent's ends of std* fds |
    | <popen-shutdown>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:terminate()       | Send SIGTERM signal to a child  |
    | <popen-terminate>`                   | process                         |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:kill()            | Send SIGKILL signal to a child  |
    | <popen-kill>`                        | process                         |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:signal()          | Send signal to a child process  |
    | <popen-signal>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:info()            | Return information about the    |
    | <popen-info>`                        | popen handle                    |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:wait()            | Wait until a child process gets |
    | <popen-wait>`                        | exited or signaled              |
    +--------------------------------------+---------------------------------+
    | :ref:`popen_handle:close()           | Close a popen handle            |
    | <popen-close>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`Module constants               | Module constants                |
    | <popen-constants>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`Handle fields                  | Handle fields                   |
    | <popen-handle_fields>`               |                                 |
    +--------------------------------------+---------------------------------+

..  _popen-shell:

..  function:: shell(command [, mode])

    Execute a shell command.

    :param string command: a command to run, mandatory
    :param string mode: communication mode, optional
    :return: (if success) a popen handle, which we will call
             ``popen_handle`` or ``ph``

             (if failure) ``nil, err``

    Possible errors: if a parameter is incorrect, the result is
    IllegalParams: incorrect type or value of a parameter.
    For other possible errors, see :ref:`popen.new() <popen-new>`.

    The possible ``mode`` values are:

    * ``'w'``    which enables :ref:`popen_handle:write() <popen-write>`
    * ``'r'``    which enables :ref:`popen_handle:read() <popen-read>`
    * ``'R'``    which enables :ref:`popen_handle:read({stderr = true}) <popen-read>`
    * ``'nil'``    which means inherit parent's std* file descriptors

    Several mode characters can be set together, for example ``'rw'``, ``'rRw'``.

    The ``shell`` function is just a shortcut for :ref:`popen.new({command}, opts) <popen-new>`
    with ``opts.shell.setsid`` and ``opts.shell.group_signal`` both set to `true`, and with
    ``opts.stdin`` and ``opts.stdout`` and ``opts.stderr`` all set based on the ``mode`` parameter.

    All std* streams are inherited from the parent by default unless it is
    changed using mode: ``'r'`` for stdout, ``'R'`` for stderr, or ``'w'`` for
    stdin.

    **Example:**

    This is the equivalent of the ``sh -c date`` command.
    It starts a process, runs ``'date'``, reads the output,
    and closes the popen object (``ph``).

    ..  code-block:: lua

        local popen = require('popen')
        -- Run the program and save its handle.
        local ph = popen.shell('date', 'r')
        -- Read program's output, strip trailing newline.
        local date = ph:read():rstrip()
        -- Free resources. The process is killed (but 'date'
        -- exits itself anyway).
        ph:close()
        print(date)

    Unix defines a text file as a sequence of lines. Each line
    is terminated by a newline (``\\n``) symbol. The same convention is usually
    applied for text output of a command. So, when it is
    redirected to a file, the file will be correct.

    However, internally an application usually operates on
    strings, which are *not* terminated by newline (for example literals
    for error messages). The newline is usually added just
    before a string is written for the outside world (stdout,
    console or log). That is why the example above contains ``rstrip()``.

..  _popen-new:

..  function:: new(argv [, opts])

    Execute a child program in a new process.

    :param array argv: an array of a program to run with command line options,
                       mandatory; absolute path to the program is required when
                       ``opts.shell`` is false (default)
    :param table opts: table of options, optional
    :return: (if success) a popen handle, which we will call
             ``popen_handle`` or ``ph``

             (if failure) ``nil, err``

    Possible raised errors are:

    * IllegalParams: incorrect type or value of a parameter
    * IllegalParams: group signal is set, while setsid is not

    Possible error reasons when ``nil, err`` is returned are:

    * SystemError: dup(), fcntl(), pipe(), vfork() or close() fails in the
      parent process
    * SystemError: (temporary restriction) the parent process has closed stdin,
      stdout or stderr
    * OutOfMemory: unable to allocate the handle or a temporary buffer

    Possible ``opts`` items are:

    * ``opts.stdin`` (action on STDIN_FILENO)
    * ``opts.stdout`` (action on STDOUT_FILENO)
    * ``opts.stderr`` (action on STDERR_FILENO)

    The ``opts`` table file descriptor actions may be:

    * ``popen.opts.INHERIT`` (== ``'inherit'``) [default] inherit the fd from the parent
    * ``popen.opts.DEVNULL`` (== ``'devnull'``) open /dev/null on the fd
    * ``popen.opts.CLOSE`` (== ``'close'``) close the fd
    * ``popen.opts.PIPE`` (== ``'pipe'``) feed data from fd to parent,
      or from parent to fd, using a pipe

    The ``opts`` table may contain an ``env`` table of environment variables to
    be used inside a process. Each ``opts.env`` item may be a key-value pair
    (key is a variable name, value is a variable value).

    * If ``opts.env`` is not set then the current environment is inherited.
    * If ``opts.env`` is an empty table, then the environment will be dropped.
    * If ``opts.env`` is set to a non-empty table, then the environment will be replaced.

    The ``opts`` table may contain these boolean items:

    ..  container:: table

        ..  rst-class:: left-align-column-1
        ..  rst-class:: left-align-column-2
        ..  rst-class:: left-align-column-3

        +----------------------+----------------+-------------------------------------------+
        | Name                 | Default        | Use                                       |
        +======================+================+===========================================+
        | opts.shell           | false          | If true, then run a child process         |
        |                      |                | via ``sh -c "${opts.argv}"``.             |
        |                      |                | If false, then call the executable        |
        |                      |                | directly.                                 |
        +----------------------+----------------+-------------------------------------------+
        | opts.setsid          | false          | If true, then run the program in a        |
        |                      |                | new session.                              |
        |                      |                | If false, then run the program in         |
        |                      |                | the Tarantool instance's session          |
        |                      |                | and process group.                        |
        +----------------------+----------------+-------------------------------------------+
        | opts.close_fds       | true           | If true, then close all inherited         |
        |                      |                | fds from the parent.                      |
        |                      |                | If false, then do not close all           |
        |                      |                | inherited fds from the parent.            |
        +----------------------+----------------+-------------------------------------------+
        | opts.restore_signals | true           | If true, then reset all signal            |
        |                      |                | actions modified in the parent's          |
        |                      |                | process.                                  |
        |                      |                | If false, then inherit all signal         |
        |                      |                | actions modified in the parent's          |
        |                      |                | process.                                  |
        +----------------------+----------------+-------------------------------------------+
        | opts.group_signal    | false          | If true, then send signal to a            |
        |                      |                | child process group, if and only if       |
        |                      |                | ``opts.setsid`` is enabled.               |
        |                      |                | If false, then send signal to a           |
        |                      |                | child process only.                       |
        +----------------------+----------------+-------------------------------------------+
        | opts.keep_child      | false          | If true, then do not send SIGKILL         |
        |                      |                | to a child process (or to a               |
        |                      |                | process group if ``opts.group_signal``    |
        |                      |                | true).                                    |
        |                      |                | If false, then do send SIGKILL            |
        |                      |                | to a child process (or to a               |
        |                      |                | process group if ``opts.group_signal``    |
        |                      |                | is true) at                               |
        |                      |                | :ref:`popen_handle:close() <popen-close>` |
        |                      |                | or when Lua GC collects the handle.       |
        +----------------------+----------------+-------------------------------------------+


    The returned ``ph`` handle provides a
    :ref:`popen_handle:close() <popen-close>` method for explicitly
    releasing all occupied resources, including the child process
    itself if ``opts.keep_child`` is not set). However, if the ``close()``
    method is not called for a handle during its lifetime, the
    Lua GC will trigger the same freeing actions.

    Tarantool recommends using ``opts.setsid`` plus ``opts.group_signal``
    if a child process may spawn its own children and if they should all
    be killed together.

    A signal will not be sent if the child process is
    already dead. Otherwise we might kill another process that
    occupies the same PID later. This means that if the child
    process dies before its own children die, then the function will not
    send a signal to the process group even when ``opts.setsid`` and
    ``opts.group_signal`` are set.

    Use :ref:`os.environ() <os-environ>` to pass a copy of the current
    environment with several replacements (see example 2 below).

    **Example 1**

    This is the equivalent of the ``sh -c date`` command.
    It starts a process, runs 'date', reads the output,
    and closes the popen object (``ph``).

    .. code-block:: lua

        local popen = require('popen')

        local ph = popen.new({'/bin/date'}, {
            stdout = popen.opts.PIPE,
        })
        local date = ph:read():rstrip()
        ph:close()
        print(date) -- e.g. Thu 16 Apr 2020 01:40:56 AM MSK

    **Example 2**

    Example 2 is quite similar to Example 1, but sets an
    environment variable and uses the shell builtin ``'echo'`` to
    show it.

    ..  code-block:: lua

        local popen = require('popen')
        local env = os.environ()
        env['FOO'] = 'bar'
        local ph = popen.new({'echo "${FOO}"'}, {
            stdout = popen.opts.PIPE,
            shell = true,
            env = env,
        })
        local res = ph:read():rstrip()
        ph:close()
        print(res) -- bar

    **Example 3**

    Example 3 demonstrates how to capture a child's stderr.

    ..  code-block:: lua

        local popen = require('popen')
        local ph = popen.new({'echo hello >&2'}, { -- !!
            stderr = popen.opts.PIPE,              -- !!
            shell = true,
        })
        local res = ph:read({stderr = true}):rstrip()
        ph:close()
        print(res) -- hello

    **Example 4**

    Example 4 demonstrates how to run a stream program (like ``grep``, ``sed``
    and so on), write to its stdin and read from its stdout.

    The example assumes that input data are small enough to fit in
    a pipe buffer (typically 64 KiB, but this depends on the platform
    and its configuration).

    If a process writes lengthy data, it will get stuck in
    :ref:`popen_handle:write() <popen-write>`.
    To handle this case: call :ref:`popen_handle:read() <popen-read>` in a loop in
    another fiber (start it before the first ``:write()``).

    If a process writes lengthy text to stderr, it may get stick in ``write()``
    because the stderr pipe buffer becomes full.
    To handle this case: read stderr in a separate fiber.

    ..  code-block:: lua

        local function call_jq(input, filter)
            -- Start jq process, connect to stdin, stdout and stderr.
            local jq_argv = {'/usr/bin/jq', '-M', '--unbuffered', filter}
            local ph, err = popen.new(jq_argv, {
                stdin = popen.opts.PIPE,
                stdout = popen.opts.PIPE,
                stderr = popen.opts.PIPE,
            })
            if ph == nil then return nil, err end
            -- Write input data to child's stdin and send EOF.
            local ok, err = ph:write(input)
            if not ok then return nil, err end
            ph:shutdown({stdin = true})
            -- Read everything until EOF.
            local chunks = {}
            while true do
                local chunk, err = ph:read()
                if chunk == nil then
                    ph:close()
                    return nil, err
                end
                if chunk == '' then break end -- EOF
                table.insert(chunks, chunk)
            end
            -- Read diagnostics from stderr if any.
            local err = ph:read({stderr = true})
            if err ~= '' then
                ph:close()
                return nil, err
            end
            -- Glue all chunks, strip trailing newline.
            return table.concat(chunks):rstrip()
        end

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                      popen handle methods
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

..  class:: popen_handle

    ..  _popen-read:

    ..  method:: read([opts])

        Read data from a child peer.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :param table opts: options

        Possible errors, raised on incorrect parameters or when the fiber is cancelled:

        * IllegalParams:    incorrect type or value of a parameter
        * IllegalParams:    called on a closed handle
        * IllegalParams:    opts.stdout and opts.stderr are both set
        * IllegalParams:    a requested IO operation is not supported by
          the handle (stdout / stderr is not piped)
        * IllegalParams:    attempt to operate on a closed file descriptor
        * FiberIsCancelled: cancelled by an outside code

        :return: ``true`` on success, ``false`` on error
        :rtype:  (if success) string with read value, empty string if EOF

                 (if failure) ``nil, err``

        Possible ``opts`` items are:

        * ``opts.stdout`` (boolean, default ``true``, if ``true`` then read from stdout)
        * ``opts.stderr`` (boolean, default ``false``, if ``true`` then read from stderr)
        * ``opts.timeout`` (number, default 100 years, time quota in seconds)

        In other words: by default ``read()`` reads from stdout, but reads from
        stderr if one sets ``opts.stderr`` to ``true`` (it is not legal to set both
        ``opts.stdout`` and ``opts.stderr`` to ``true``).



        Possible error reasons when ``nil, err`` is returned are:

        * SocketError: an IO error occurs at read()
        * TimedOut:    exceeded the opts.timeout quota
        * OutOfMemory: no memory space for a buffer to read into
        * LuajitError: ("not enough memory"): no memory space for the Lua string

    ..  _popen-write:

    ..  method:: write(str [, opts])

        Write string ``str`` to stdin stream of a child process.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :param string str: string to write
        :param table opts: options
        :return: ``true`` on success, ``false`` on error
        :rtype:  (if success) boolean = true

                 (if failure) ``nil, err``

        Possible ``opts`` items are:
        ``opts.timeout`` (number, default 100 years, time quota in seconds).

        Possible raised errors are:

        * IllegalParams:    incorrect type or value of a parameter
        * IllegalParams:    called on a closed handle
        * IllegalParams:    string length is greater then SSIZE_MAX
        * IllegalParams:    a requested IO operation is not supported by the
          handle (stdin is not piped)
        * IllegalParams:    attempt to operate on a closed file descriptor
        * FiberIsCancelled: cancelled by an outside code

        Possible error reasons when ``nil, err`` is returned are:

        * SocketError: an IO error occurs at write()
        * TimedOut:    exceeded opts.timeout quota

        ``write()`` may yield forever if the child process does
        not read data from stdin and a pipe buffer becomes full.
        The size of this pipe buffer depends on the platform. Set
        ``opts.timeout`` when unsure.

        When ``opts.timeout`` is not set, the ``write()`` blocks
        (yields the fiber) until all data is written or an error
        happens.

    ..  _popen-shutdown:

    ..  method:: shutdown([opts])

        Close parent's ends of std* fds.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :param table opts: options
        :return: ``true`` on success, ``false`` on error
        :rtype:  (if success) boolean = true

        Possible ``opts`` items are:

        * ``opts.stdin`` (boolean) close parent's end of stdin
        * ``opts.stdout`` (boolean) close parent's end of stdout
        * ``opts.stderr`` (boolean) close parent's end of stderr

        We may use the term std* to mean any one of these items.

        Possible raised errors are:

        * IllegalParams:  an incorrect handle parameter
        * IllegalParams:  called on a closed handle
        * IllegalParams:  neither stdin, stdout nor stderr is chosen
        * IllegalParams:  a requested IO operation is not supported by
          the handle (one of std* is not piped)

        The main reason to use ``shutdown()`` is to send EOF to a
        child's stdin. However the parent's end of stdout / stderr
        may be closed too.

        ``shutdown()`` does not fail on already closed fds (idempotence).
        However, it fails on an attempt to close the end of a pipe that
        never existed. In other words, only those ``std*`` options that
        were set to ``popen.opts.PIPE`` during handle creation may be used
        here (for :ref:`popen.shell() <popen-shell>`: ``'r'`` corresponds to stdout,
        ``'R'`` to stderr and ``'w'`` to stdin).

        ``shutdown()`` does not close any fds on a failure: either all
        requested fds are closed or none of them.

        **Example:**

        ..  code-block:: lua

            local popen = require('popen')
            local ph = popen.shell('sed s/foo/bar/', 'rw')
            ph:write('lorem foo ipsum')
            ph:shutdown({stdin = true})
            local res = ph:read()
            ph:close()
            print(res) -- lorem bar ipsum

    ..  _popen-terminate:

    ..  method:: terminate()

        Send SIGTERM signal to a child process.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :return: see :ref:`popen_handle:signal() <popen-signal>` for errors and
                 return values

        ``terminate()`` only sends a SIGTERM signal.
        It does *not* free any resources (such as popen handle memory and
        file descriptors).

    ..  _popen-kill:

    ..  method:: kill()

        Send SIGKILL signal to a child process.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :return: see :ref:`popen_handle:signal() <popen-signal>` for errors and
                 return values


        ``kill()`` only sends a SIGKILL signal.
        It does *not* free any resources (such as popen handle memory and
        file descriptors).

    ..  _popen-signal:

    ..  method:: signal(signo)

        Send signal to a child process.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :param number signo: signal to send
        :return: (if success) `true` (signal is sent)

                 (if failure) ``nil, err``

        Possible raised errors:

        * IllegalParams:    an incorrect handle parameter
        * IllegalParams:    called on a closed handle

        Possible error values for ``nil, err``:

        * SystemError: a process does not exists any more
          (this may also be returned for a zombie process or when all
          processes in a group are zombies (but see note re Mac OS below)
        * SystemError: invalid signal number
        * SystemError: no permission to send a signal to a process or
          a process group
          (this is returned on Mac OS when a signal is
          sent to a process group, where a group leader
          is a zombie (or when all processes in it
          are zombies, details re uncertain)
          (this may also appear due to other reasons, details are uncertain)

        If ``opts.setsid`` and ``opts.group_signal`` are set for the handle,
        the signal is sent to the process group rather than to the
        process. See :ref:`popen.new() <popen-new>` for details about group
        signaling. Warning: On Mac OS it is possible that a process in the group
        will not receive the signal, particularly if the process has just been
        forked (this may be due to a race condition).

        Note: The module offers ``popen.signal.SIG*`` constants, because
        some signals have different numbers on different platforms.

    ..  _popen-info:

    ..  method:: info()

        Return information about the popen handle.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :param number signo: signal to send
        :return: (if success) formatted result
        :rtype: res

        Possible raised errors are:

        * IllegalParams: an incorrect handle parameter
        * IllegalParams: called on a closed handle

        The result format is:

        ..  code-block:: none

            {
                pid = <number> or <nil>,
                command = <string>,
                opts = <table>,
                status = <table>,
                stdin = one-of(
                    popen.stream.OPEN   (== 'open'),
                    popen.stream.CLOSED (== 'closed'),
                    nil,
                ),
                stdout = one-of(
                    popen.stream.OPEN   (== 'open'),
                    popen.stream.CLOSED (== 'closed'),
                    nil,
                ),
                stderr = one-of(
                    popen.stream.OPEN   (== 'open'),
                    popen.stream.CLOSED (== 'closed'),
                    nil,
                ),
            }

        ``pid`` is a process id of the process when it is alive,
        otherwise ``pid`` is nil.

        ``command`` is a concatenation of space-separated arguments
        that were passed to ``execve()``. Multiword arguments are quoted.
        Quotes inside arguments are not escaped.

        ``opts`` is a table of handle options as in the
        :ref:`popen.new() <popen-new>`
        ``opts`` parameter. ``opts.env`` is not shown here,
        because the environment variables map is not stored in a
        handle.

        ``status`` is a table that represents a process status in the
        following format:

        ..  code-block:: none

            {
                state = one-of(
                    popen.state.ALIVE    (== 'alive'),
                    popen.state.EXITED   (== 'exited'),
                    popen.state.SIGNALED (== 'signaled'),
                )
                -- Present when `state` is 'exited'.
                exit_code = <number>,
                -- Present when `state` is 'signaled'.
                signo = <number>,
                signame = <string>,
            }

        ``stdin``, ``stdout``, and ``stderr`` reflect the status of the parent's end
        of a piped stream. If a stream is not piped, the field is
        not present (``nil``). If it is piped, the status may be
        either ``popen.stream.OPEN`` (== ``'open'``) or ``popen.stream.CLOSED`` (== ``'closed'``).
        The status may be changed from ``'open'`` to ``'closed'``
        by a :ref:`popen_handle:shutdown({std... = true}) <popen-shutdown>` call.

        **Example 1**

        (on Tarantool console)

        ..  code-block:: tarantoolsession

            tarantool> require('popen').new({'/usr/bin/touch', '/tmp/foo'})
            ---
            - command: /usr/bin/touch /tmp/foo
              status:
                state: alive
              opts:
                stdout: inherit
                stdin: inherit
                group_signal: false
                keep_child: false
                close_fds: true
                restore_signals: true
                shell: false
                setsid: false
                stderr: inherit
              pid: 9499
            ...

        **Example 2**

        (on Tarantool console)

        ..  code-block:: tarantoolsession

            tarantool> require('popen').shell('grep foo', 'wrR')
            ---
            - stdout: open
              command: sh -c 'grep foo'
              stderr: open
              status:
                state: alive
              stdin: open
              opts:
                stdout: pipe
                stdin: pipe
                group_signal: true
                keep_child: false
                close_fds: true
                restore_signals: true
                shell: true
                setsid: true
                stderr: pipe
              pid: 10497
            ...

    ..  _popen-wait:

    ..  method:: wait()

        Wait until a child process gets exited or signaled.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :param number signo: signal to send
        :return: (if success) formatted result
        :rtype: res

        Possible raised errors are:

        * IllegalParams: an incorrect handle parameter
        * IllegalParams: called on a closed handle
        * FiberIsCancelled: cancelled by an outside code

        The formatted result is a process status table (the same as the
        ``status`` component of the table returned by
        :ref:`popen_handle:info() <popen-info>`).

    ..  _popen-close:

    ..  method:: close()

        Close a popen handle.

        :param handle ph: handle of a child process created with
                          :ref:`popen.new() <popen-new>` or
                          :ref:`popen.shell() <popen-shell>`
        :return: (if success) true

                 (if failure) ``nil, err``

        Possible raised errors are:

        * IllegalParams: an incorrect handle parameter

        Possible diagnostics when ``nil, err`` is returned
        (do not consider them as errors):

        * SystemError: no permission to send a signal to a process or a process group
          (This diagnostic may appear due to Mac OS behavior on zombies when
          ``opts.group_signal`` is set, see :ref:`popen_handle:signal() <popen-signal>`.
          It may appear for other reasons, details are unclear.)

        The return is always ``true`` when a process is known to be dead (for example,
        after :ref:`popen_handle:wait() <popen-wait>` no signal will be sent, so no 'failure'
        may appear).

        ``close()`` kills a process using SIGKILL and releases all
        resources associated with the popen handle.

        Details about signaling:

        * The signal is sent only when opts.keep_child is not set.
        * The signal is sent only when a process is alive according
          to the information available on current event loop iteration.
          (There is a gap here: a zombie may be signaled; it is
          harmless.)
        * The signal is sent to a process or a process group depending
          on ``opts.group_signal``. (See :ref:`popen.new() <popen-new>`
          for details of group signaling).

        Resources are released regardless whether or not a signal
        sending succeeds: fds are closed, memory is released,
        the handle is marked as closed.

        No operation is possible on a closed handle except
        ``close()``, which is always successful on a closed handle
        (idempotence).

        ``close()`` may return ``true`` or ``nil, err``, but it always
        frees the handle resources. So any return value usually
        means success for a caller. The return values are purely
        informational: they are for logging or some kind of reporting.

    ..  _popen-handle_fields:

    **Handle fields**

    ..  code-block:: none

        popen_handle.pid
        popen_handle.command
        popen_handle.opts
        popen_handle.status
        popen_handle.stdin
        popen_handle.stdout
        popen_handle.stderr

    See :ref:`popen_handle:info() <popen-info>` for details.

    ..  _popen-constants:

    **Module constants**

    ..  code-block:: none

        - popen.opts
          - INHERIT (== 'inherit')
          - DEVNULL (== 'devnull')
          - CLOSE   (== 'close')
          - PIPE    (== 'pipe')

        - popen.signal
          - SIGTERM (== 9)
          - SIGKILL (== 15)
          - ...

        - popen.state
          - ALIVE    (== 'alive')
          - EXITED   (== 'exited')
          - SIGNALED (== 'signaled')

        - popen.stream
          - OPEN    (== 'open')
          - CLOSED  (== 'closed')

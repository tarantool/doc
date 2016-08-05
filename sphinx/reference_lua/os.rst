.. _os-module:

-------------------------------------------------------------------------------
                            Module `os`
-------------------------------------------------------------------------------

.. module:: os

The os module contains the functions
:ref:`execute() <os-execute>`,
:ref:`rename() <os-rename>`,
:ref:`getenv() <os-getenv>`,
:ref:`remove() <os-remove>`,
:ref:`date() <os-date>`,
:ref:`exit() <os-exit>`,
:ref:`time() <os-time>`,
:ref:`clock() <os-clock>`,
:ref:`tmpname() <os-tmpname>`.
Most of these functions are described in the Lua manual
Chapter 22 `The Operating System Library <https://www.lua.org/pil/contents.html#22>`_.

.. _os-execute:

.. function:: execute(shell-command)

    Execute by passing to the shell.

    :param string shell-command: what to execute.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.execute('ls -l /usr')
        total 200
        drwxr-xr-x   2 root root 65536 Apr 22 15:49 bin
        drwxr-xr-x  59 root root 20480 Apr 18 07:58 include
        drwxr-xr-x 210 root root 65536 Apr 18 07:59 lib
        drwxr-xr-x  12 root root  4096 Apr 22 15:49 local
        drwxr-xr-x   2 root root 12288 Jan 31 09:50 sbin
        ---
        ...

.. _os-rename:

.. function:: rename(old-name, new-name)

    Rename a file or directory.

    :param string old-name: name of existing file or directory,
    :param string new-name: changed name of file or directory.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.rename('local','foreign')
        ---
        - null
        - 'local: No such file or directory'
        - 2
        ...

.. _os-getenv:

.. function:: getenv(variable-name)

    Get environment variable.

    Parameters: (string) variable-name = environment variable name.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.getenv('PATH')
        ---
        - /usr/local/sbin:/usr/local/bin:/usr/sbin
        ...

.. _os-remove:

.. function:: remove(name)

    Remove file or directory.

    Parameters: (string) name = name of file or directory which will be removed.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.remove('file')
        ---
        - true
        ...

.. _os-date:

.. function:: date(format-string[, time-since-epoch])

    Return a formatted date.

    Parameters: (string) format-string = instructions; (string) time-since-epoch =
    number of seconds since 1970-01-01. If time-since-epoch is omitted, it is assumed to be the current time.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.date("%A %B %d")
        ---
        - Sunday April 24
        ...

.. _os-exit:

.. function:: exit()

    Exit the program. If this is done on the server, then the server stops.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.exit()
        user@user-shell:~/tarantool_sandbox$

.. _os-time:

.. function:: time()

    Return the number of seconds since the epoch.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.time()
        ---
        - 1461516945
        ...

.. _os-clock:

.. function:: clock()

    Return the number of CPU seconds since the program start.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.clock()
        ---
        - 0.05
        ...

.. _os-tmpname:

.. function:: tmpname()

    Return a name for a temporary file.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.tmpname()
        ---
        - /tmp/lua_7SW1m2
        ...

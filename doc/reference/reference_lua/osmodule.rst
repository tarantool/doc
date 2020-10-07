.. _os-module:

-------------------------------------------------------------------------------
                            Module `os`
-------------------------------------------------------------------------------

.. module:: os

===============================================================================
                                   Overview
===============================================================================

The ``os`` module contains the functions :ref:`execute() <os-execute>`,
:ref:`rename() <os-rename>`, :ref:`getenv() <os-getenv>`,
:ref:`remove() <os-remove>`, :ref:`date() <os-date>`,
:ref:`exit() <os-exit>`, :ref:`time() <os-time>`,
:ref:`clock() <os-clock>`, :ref:`tmpname() <os-tmpname>`,
:ref:`environ() <os-environ>`,
:ref:`setenv() <os-setenv>`,
:ref:`setlocale() <os-setlocale>`,
:ref:`difftime() <os-difftime>`.
Most of these functions are described in the Lua manual
Chapter 22 `The Operating System Library
<https://www.lua.org/pil/contents.html#22>`_.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``os`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`os.execute()                   | Execute by passing to the shell |
    | <os-execute>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.rename()                    | Rename a file or directory      |
    | <os-rename>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.getenv()                    | Get an environment variable     |
    | <os-getenv>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.remove()                    | Remove a file or directory      |
    | <os-remove>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.date()                      | Get a formatted date            |
    | <os-date>`                           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.exit()                      | Exit the program                |
    | <os-exit>`                           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.time()                      | Get the number of seconds since |
    | <os-time>`                           | the epoch                       |
    +--------------------------------------+---------------------------------+
    | :ref:`os.clock()                     | Get the number of CPU seconds   |
    | <os-clock>`                          | since the program start         |
    +--------------------------------------+---------------------------------+
    | :ref:`os.tmpname()                   | Get the name of a temporary     |
    | <os-tmpname>`                        | file                            |
    +--------------------------------------+---------------------------------+
    | :ref:`os.environ()                   | Get a table with all            |
    | <os-environ>`                        | environment variables           |
    +--------------------------------------+---------------------------------+
    | :ref:`os.setenv()                    | Set an environment variable     |
    | <os-setenv>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.setlocale()                 | Change the locale               |
    | <os-setlocale>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`os.difftime()                  | Get the number of seconds       |
    | <os-difftime>`                       | between two times               |
    +--------------------------------------+---------------------------------+

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

    Exit the program. If this is done on a server instance, then the instance stops.

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

.. _os-environ:

.. function:: environ()

    Return a table containing all environment variables.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.environ()['TERM']..os.environ()['SHELL']
        ---
        - xterm/bin/bash
        ...

.. _os-setenv:

.. function:: setenv(variable-name, variable-value)

    Set an environment variable.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.setenv('VERSION','99')
        ---
        -
        ...

.. _os-setlocale:

.. function:: setlocale([new-locale-string])

    Change the locale. If new-locale-string is
    not specified, return the current locale.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> string.sub(os.setlocale(),1,20)
        ---
        - LC_CTYPE=en_US.UTF-8
        ...

.. _os-difftime:

.. function:: difftime(time1, time2)

    Return the number of seconds between two times.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> os.difftime(os.time() - 0)
        ---
        - 1486594859
        ...

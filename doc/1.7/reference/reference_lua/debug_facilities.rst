.. _debug-module:

-------------------------------------------------------------------------------
                            Debug facilities
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

Tarantool users can benefit from built-in debug facilities that are part of:

* Lua (`debug <https://www.lua.org/manual/5.1/manual.html#5.9>`_ library,
  see details below) and
* LuaJit (`debug.* <http://luajit.org/extensions.html>`_ functions).

.. module:: debug

The ``debug`` library provides an interface for debugging Lua programs. All
functions in this library reside in the ``debug`` table. Those functions that
operate on a thread have an optional first parameter that specifies the thread
to operate on. The default is always the current thread.

.. NOTE::

    This library should be used only for debugging and profiling and not as a
    regular programming tool, as the functions provided here can take too long
    to run. Besides, several of these functions can compromise otherwise
    secure code.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``debug`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`debug.debug()                  | Enter an interactive mode       |
    | <debug-debug>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.getfenv()                | Get an object's environment     |
    | <debug-getfenv>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.gethook()                | Get a thread's current hook     |
    | <debug-gethook>`                     | settings                        |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.getinfo()                | Get information about a         |
    | <debug-getinfo>`                     | function                        |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.getlocal()               | Get a local variable's name and |
    | <debug-getlocal>`                    | value                           |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.getmetatable()           | Get an object's metatable       |
    | <debug-getmetatable>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.getregistry()            | Get the registry table          |
    | <debug-getregistry>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.getupvalue()             | Get an upvalue's name and value |
    | <debug-getupvalue>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.setfenv()                | Set an object's environment     |
    | <debug-setfenv>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.sethook()                | Set a given function as a hook  |
    | <debug-sethook>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.setlocal()               | Assign a value to a local       |
    | <debug-setlocal>`                    | variable                        |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.setmetatable()           | Set an object's metatable       |
    | <debug-setmetatable>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.setupvalue()             | Assign a value to an upvalue    |
    | <debug-setupvalue>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`debug.traceback()              | Get a traceback of the call     |
    | <debug-traceback>`                   | stack                           |
    +--------------------------------------+---------------------------------+

.. _debug-debug:

.. function:: debug()

    Enters an interactive mode and runs each string that the user types in. The
    user can, among other things, inspect global and local variables, change
    their values and evaluate expressions.

    Enter ``cont`` to exit this function, so that the caller can continue
    its execution.

    .. NOTE::

        Commands for ``debug.debug()`` are not lexically nested within any
        function and so have no direct access to local variables.

.. _debug-getfenv:

.. function:: getfenv(object)

    :param object: object to get the environment of
    :type object: table, userdata, thread or function

    :return: the environment of the ``object``

.. _debug-gethook:

.. function:: gethook([thread])

    :return: the current hook settings of the ``thread`` as three values:

      * the current hook function
      * the current hook mask
      * the current hook count as set by the ``debug.sethook()`` function

.. _debug-getinfo:

.. function:: getinfo([thread,] function [, what])

    :param function: function to get information on
    :type function: function or number
    :param string what: what information on the ``function`` to return

    :return: a table with information about the ``function``

    You can pass in a ``function`` directly, or you can give a number that
    specifies a function running at level ``function`` of the call stack of
    the given ``thread``: level 0 is the current function (``getinfo()`` itself),
    level 1 is the function that called ``getinfo()``, and so on. If ``function``
    is a number larger than the number of active functions, ``getinfo()`` returns
    ``nil``.

    The default for ``what`` is to get all information available, except the table
    of valid lines. If present, the option ``f`` adds a field named ``func`` with
    the function itself. If present, the option ``L`` adds a field named
    ``activelines`` with the table of valid lines.

.. _debug-getlocal:

.. function:: getlocal([thread,] level, local)

    :param number level: level of the stack
    :param number local: index of the local variable

    :return: the name and the value of the local variable with the index ``local``
             of the function at level ``level`` of the stack or ``nil`` if there
             is no local variable with the given index; raises an error if
             ``level`` is out of range

    .. NOTE::

        You can call ``debug.getinfo()`` to check whether the level is valid.

.. _debug-getmetatable:

.. function:: getmetatable(object)

    :param object: object to get the metatable of
    :type object: table, userdata, thread or function

    :return: a metatable of the ``object`` or ``nil`` if it does not have
             a metatable

.. _debug-getregistry:

.. function:: getregistry()

    :return: the registry table

.. _debug-getupvalue:

.. function:: getupvalue(func, up)

    :param function func: function to get the upvalue of
    :param number up: index of the function upvalue

    :return: the name and the value of the upvalue with the index ``up`` of
             the function ``func`` or ``nil`` if there is no upvalue with
             the given index

.. _debug-setfenv:

.. function:: setfenv(object, table)

    Sets the environment of the ``object`` to the ``table``.

    :param object: object to change the environment of
    :type object: table, userdata, thread or function
    :param table table: table to set the object environment to

    :return: the ``object``

.. _debug-sethook:

.. function:: sethook([thread,] hook, mask [, count])

    Sets the given function as a hook.  When called without arguments,
    turns the hook off.

    :param function hook: function to set as a hook
    :param string mask: describes when the ``hook`` will be called;
      may have the following values:

      * ``c`` - the ``hook`` is called every time Lua calls a function
      * ``r`` - the ``hook`` is called every time Lua returns from a function
      * ``l`` - the ``hook`` is called every time Lua enters a new line of code

    :param number count: describes when the ``hook`` will be called; when
                      different from zero, the ``hook`` is called after
                      every ``count`` instructions.

.. _debug-setlocal:

.. function:: setlocal([thread,] level, local, value)

    Assigns the value ``value`` to the local variable with the index ``local``
    of the function at level ``level`` of the stack.

    :param number level: level of the stack
    :param number local: index of the local variable
    :param value: value to assign to the local variable
    :type value: boolean, number, string or userdata

    :return: the name of the local variable or ``nil`` if there is no local
             variable with the given index; raises an error if ``level`` is
             out of range

    .. NOTE::

        You can call ``debug.getinfo()`` to check whether the level is valid.

.. _debug-setmetatable:

.. function:: setmetatable(object, table)

    Sets the metatable of the ``object`` to the ``table``.

    :param object: object to change the metatable of
    :type object: table, userdata, thread or function
    :param table table: table to set the object metatable to

.. _debug-setupvalue:

.. function:: setupvalue(func, up, value)

    Assigns the value ``value`` to the upvalue with the index ``up``
    of the function ``func``.

    :param function func: function to set the upvalue of
    :param number up: index of the function upvalue
    :param value: value to assign to the function upvalue
    :type value: boolean, number, string or userdata

    :return: the name of the upvalue or ``nil`` if there is no
             upvalue with the given index

.. _debug-traceback:

.. function:: traceback([thread,] [message] [, level])

    :param string message: an optional message prepended to the traceback
    :param number level: specifies at which level to start the traceback
                         (default is 1)

    :return: a string with a traceback of the call stack

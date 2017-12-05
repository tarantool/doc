.. _clock-module:

-------------------------------------------------------------------------------
                            Module `clock`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``clock`` module returns time values derived from the Posix / C
CLOCK_GETTIME_ function or equivalent. Most functions in the module return a
number of seconds; functions whose names end in "64" return a 64-bit number of
nanoseconds.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``clock`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`clock.time()                   |                                 |
    | <clock-time>` |br|                   | Get the wall clock time         |
    | :ref:`clock.realtime()               | in seconds                      |
    | <clock-time>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.time64()                 |                                 |
    | <clock-time>` |br|                   | Get the wall clock time         |
    | :ref:`clock.realtime64()             | in nanoseconds                  |
    | <clock-time>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.monotonic()              | Get the monotonic time          |
    | <clock-monotonic>`                   | in seconds                      |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.monotonic64()            | Get the monotonic time          |
    | <clock-monotonic>`                   | in nanoseconds                  |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.proc()                   | Get the processor time          |
    | <clock-proc>`                        | in seconds                      |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.proc64()                 | Get the processor time          |
    | <clock-proc>`                        | in nanoseconds                  |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.thread()                 | Get the thread time             |
    | <clock-thread>`                      | in seconds                      |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.thread64()               | Get the thread time             |
    | <clock-thread>`                      | in nanoseconds                  |
    +--------------------------------------+---------------------------------+
    | :ref:`clock.bench()                  | Measure the time a function     |
    | <clock-bench>`                       | takes within a processor        |
    +--------------------------------------+---------------------------------+

.. module:: clock

.. _clock-time:

.. function:: time()
              time64()
              realtime()
              realtime64()

    The wall clock time. Derived from C function clock_gettime(CLOCK_REALTIME).
    This is the best function for knowing what the official time is, as
    determined by the system administrator.

    :return: seconds or nanoseconds since epoch (1970-01-01 00:00:00), adjusted.
    :rtype: number or number64

    **Example:**

    .. code-block:: lua

        -- This will print an approximate number of years since 1970.
        clock = require('clock')
        print(clock.time() / (365*24*60*60))

    See also :ref:`fiber.time64 <fiber-time64>` and the standard Lua function
    `os.clock <http://www.lua.org/manual/5.1/manual.html#pdf-os.clock>`_.

.. _clock-monotonic:

.. function:: monotonic()
              monotonic64()

    The monotonic time. Derived from C function clock_gettime(CLOCK_MONOTONIC).
    Monotonic time is similar to wall clock time but is not affected by changes
    to or from daylight saving time, or by changes done by a user.
    This is the best function to use with benchmarks that need to calculate
    elapsed time.

    :return: seconds or nanoseconds since the last time that the computer was booted.
    :rtype: number or number64

    **Example:**

    .. code-block:: lua

        -- This will print nanoseconds since the start.
        clock = require('clock')
        print(clock.monotonic64())

.. _clock-proc:

.. function:: proc()
              proc64()

    The processor time. Derived from C function
    ``clock_gettime(CLOCK_PROCESS_CPUTIME_ID)``. This is the best function to
    use with benchmarks that need to calculate how much time has been spent
    within a CPU.

    :return: seconds or nanoseconds since processor start.
    :rtype: number or number64

    **Example:**

    .. code-block:: lua

        -- This will print nanoseconds in the CPU since the start.
        clock = require('clock')
        print(clock.proc64())

.. _clock-thread:

.. function:: thread()
              thread64()

    The thread time. Derived from C function
    ``clock_gettime(CLOCK_THREAD_CPUTIME_ID)``. This is the best function to use
    with benchmarks that need to calculate how much time has been spent within a
    thread within a CPU.

    :return: seconds or nanoseconds since the transaction processor thread started.
    :rtype: number or number64

    **Example:**

    .. code-block:: lua

        -- This will print seconds in the thread since the start.
        clock = require('clock')
        print(clock.thread64())

.. _clock-bench:

.. function:: bench(function[, ...])

    The time that a function takes within a processor. This function uses
    ``clock.proc()``, therefore it calculates elapsed CPU time. Therefore it is
    not useful for showing actual elapsed time.

    :param function function: function or function reference
    :param               ...: whatever values are required by the function.

    :return: **table**. first element - seconds of CPU time, second element -
             whatever the function returns.

    **Example:**

    .. code-block:: lua

        -- Benchmark a function which sleeps 10 seconds.
        -- NB: bench() will not calculate sleep time.
        -- So the returned value will be {a number less than 10, 88}.
        clock = require('clock')
        fiber = require('fiber')
        function f(param)
          fiber.sleep(param)
          return 88
        end
        clock.bench(f, 10)

.. _CLOCK_GETTIME: http://pubs.opengroup.org/onlinepubs/9699919799/functions/clock_getres.html

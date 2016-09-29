-------------------------------------------------------------------------------
                                 Submodule `fiber-cond`
-------------------------------------------------------------------------------

The ``fiber-cond`` submodule has a synchronization mechanism
for fibers, similar to "Condition Variables" and similar to
operating-system functions such as pthread_cond_wait() plus pthread_cond_signal().

Call ``fiber.cond()`` to create a named condition variable,
which will be called cond for examples in this section.
Call ``cond:wait()`` to make a fiber wait for a signal via a condition variable.
Call ``cond:signal()`` to send a signal to wake up a single fiber that has executed ``cond:wait()``.
Call ``cond:broadcast()`` to send a signal to all fibers that have executed ``cond:wait()``.

.. module:: fiber

.. function:: cond()

    Create a new condition variable.

    :return: new condition variable.
    :rtype:  Lua object

.. class:: cond_object

    .. method:: wait([timeout])

        Make the current fiber go to sleep,
        waiting until until another fiber invokes
        the ``signal()`` or ``broadcast()`` method on the cond object.
        The sleep causes an implicit :ref:`fiber.yield() <fiber-yield>`.

        :param timeout: number of seconds to wait, default = forever.
        :return: If timeout is provided, and a signal doesn't happen for
                the duration of the timeout, ``wait()`` returns false.
                If a signal or broadcast happens, ``wait()`` returns true.
        :rtype:  boolean

    .. method:: signal()

        Wake up a single fiber that has executed ``wait()`` for the same variable.

        :rtype:  nil

    .. method:: broadcast()

        Wake up all fibers that have executed ``wait()`` for the same variable.

        :rtype:  nil


=================================================
                    Example
=================================================

Assume that a tarantool server is running and
listening for connections on localhost port 3301.
Assume that guest users have privileges to connect.
We will use the tarantoolctl utility to start two clients.

On terminal #1, say

.. code-block:: none

    tarantoolctl connect '3301'
    fiber = require('fiber')
    cond = fiber.cond()
    cond:wait()

The job will hang because ``cond:wait()`` -- without
an optional timeout argument -- will go to sleep
until the condition variable changes.

On terminal #2, say

.. code-block:: none

    tarantoolctl connect '3301'
    cond:signal()

Now look again at terminal #1.
It will show that the waiting stopped,
and the ``cond:wait()`` function returned ``true``.

This example depended on the use of a global
conditional variable with the arbitrary name ``cond``.
In real life, programmers would make sure to
use different conditional variable names for
different applications.

-------------------------------------------------------------------------------
                                 Submodule `fiber-ipc`
-------------------------------------------------------------------------------

The ``fiber-ipc`` submodule allows sending and receiving messages between
different processes and has synchronization mechanism for fibers, similar to
"Condition Variables" and similar to operating-system functions such as
``pthread_cond_wait()`` plus ``pthread_cond_signal()``.
The words "different processes" in this context mean different connections,
different sessions, or different fibers.

Call ``fiber.channel()`` to allocate space and get a channel object, which will
be called channel for examples in this section. Call the other ``fiber-ipc``
routines, via channel, to send messages, receive messages, or check ipc status.
Message exchange is synchronous. The channel is garbage collected when no one is
using it, as with any other Lua object. Use object-oriented syntax, for example
``channel:put(message)`` rather than ``fiber.channel.put(message)``.

Call ``fiber.cond()`` to create a named condition variable, which will be called
cond for examples in this section. Call ``cond:wait()`` to make a fiber wait for
a signal via a condition variable. Call ``cond:signal()`` to send a signal to
wake up a single fiber that has executed ``cond:wait()``. Call
``cond:broadcast()`` to send a signal to all fibers that have executed
``cond:wait()``.

.. module:: fiber

.. _fiber_ipc-channel:

=================================================
                    Channel
=================================================

.. function:: channel([capacity])

    Create a new communication channel.

    :param int capacity: positive integer as great as the maximum number of
                         slots (spaces for ``get`` or ``put`` messages)
                         that might be pending at any given time.

    :return: new channel.
    :rtype:  userdata, possibly including the string "channel ...".

.. class:: channel_object

    .. method:: put(message[, timeout])

        Send a message using a channel. If the channel is full,
        ``channel:put()`` blocks until there is a free slot in the channel.

        :param lua_object message: string
        :param timeout: number
        :return: If timeout is provided, and there is no free slot in the
                 channel for the duration of the timeout, ``channel:put()``
                 returns false. Otherwise it returns true.
        :rtype:  boolean

    .. method:: close()

        Close the channel. All waiters in the channel will be woken up. All
        following ``channel:put()`` or ``channel:get()`` operations will return
        an error (``nil``).

    .. method:: get([timeout])

        Fetch a message from a channel. If the channel is empty,
        ``channel:get()`` blocks until there is a message.

        :param timeout: number
        :return: the message placed on the channel by ``channel:put()``. If
                 timeout is provided, and there is no message in the channel
                 for the duration of the timeout, ``channel:get()`` returns nil.
        :rtype:  string

    .. method:: is_empty()

        Check whether the specified channel is empty (has no messages).

        :return: true if the specified channel is empty
        :rtype:  boolean

    .. method:: count()

        Find out how many messages are on the channel. The answer is 0 if the
        channel is empty.

        :return: the number of messages.
        :rtype:  number

    .. method:: is_full()

        Check whether the specified channel is full.

        :return: true if the specified channel is full (has no room for a new
                 message).
        :rtype:  boolean

    .. method:: has_readers()

        Check whether the specified channel is empty and has readers waiting for
        a message (because they have issued ``channel:get()`` and then blocked).

        :return: true if blocked users are waiting. Otherwise false.
        :rtype:  boolean

    .. method:: has_writers()

        Check whether the specified channel is full and has writers waiting
        (because they have issued ``channel:put()`` and then blocked due to lack
        of room).

        :return: true if blocked users are waiting. Otherwise false.
        :rtype:  boolean

    .. method:: is_closed()

        :return: true if the specified channel is already closed. Otherwise
                 false.
        :rtype:  boolean

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This example should give a rough idea of what some functions for fibers should
look like. It's assumed that the functions would be referenced in
:ref:`fiber.create() <fiber-create>`.

.. code-block:: lua

    fiber = require('fiber')
    channel = fiber.channel(10)
    function consumer_fiber()
        while true do
            local task = channel:get()
            ...
        end
    end

    function consumer2_fiber()
        while true do
            -- 10 seconds
            local task = channel:get(10)
            if task ~= nil then
                ...
            else
                -- timeout
            end
        end
    end

    function producer_fiber()
        while true do
            task = box.space...:select{...}
            ...
            if channel:is_empty() then
                -- channel is empty
            end

            if channel:is_full() then
                -- channel is full
            end

            ...
            if channel:has_readers() then
                -- there are some fibers
                -- that are waiting for data
            end
            ...

            if channel:has_writers() then
                -- there are some fibers
                -- that are waiting for readers
            end
            channel:put(task)
        end
    end

    function producer2_fiber()
        while true do
            task = box.space...select{...}
            -- 10 seconds
            if channel:put(task, 10) then
                ...
            else
                -- timeout
            end
        end
    end

=================================================
              Condition variables
=================================================

.. function:: cond()

    Create a new condition variable.

    :return: new condition variable.
    :rtype:  Lua object

.. class:: cond_object

    .. method:: wait([timeout])

        Make the current fiber go to sleep, waiting until until another fiber
        invokes the ``signal()`` or ``broadcast()`` method on the cond object.
        The sleep causes an implicit :ref:`fiber.yield() <fiber-yield>`.

        :param timeout: number of seconds to wait, default = forever.
        :return: If timeout is provided, and a signal doesn't happen for the
                 duration of the timeout, ``wait()`` returns false. If a signal
                 or broadcast happens, ``wait()`` returns true.
        :rtype:  boolean

    .. method:: signal()

        Wake up a single fiber that has executed ``wait()`` for the same
        variable.

        :rtype:  nil

    .. method:: broadcast()

        Wake up all fibers that have executed ``wait()`` for the same variable.

        :rtype:  nil

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Assume that a tarantool server is running and listening for connections on
localhost port 3301. Assume that guest users have privileges to connect. We will
use the tarantoolctl utility to start two clients.

On terminal #1, say

.. code-block:: tarantoolsession

    $ tarantoolctl connect '3301'
    tarantool> fiber = require('fiber')
    tarantool> cond = fiber.cond()
    tarantool> cond:wait()

The job will hang because ``cond:wait()`` -- without an optional timeout
argument -- will go to sleep until the condition variable changes.

On terminal #2, say

.. code-block:: tarantoolsession

    $ tarantoolctl connect '3301'
    tarantool> cond:signal()

Now look again at terminal #1. It will show that the waiting stopped, and the
``cond:wait()`` function returned ``true``.

This example depended on the use of a global conditional variable with the
arbitrary name ``cond``. In real life, programmers would make sure to use
different conditional variable names for different applications.

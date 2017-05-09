-------------------------------------------------------------------------------
                                 Submodule `fiber-ipc`
-------------------------------------------------------------------------------

The ``fiber-ipc`` submodule allows sending and receiving messages between
different processes.
The words "different processes" in this context mean different connections,
different sessions, or different fibers.

Call ``fiber.channel()`` to allocate space and get a channel object, which will
be called channel for examples in this section. Call the other ``fiber-ipc``
routines, via channel, to send messages, receive messages, or check ipc status.
Message exchange is synchronous. The channel is garbage collected when no one is
using it, as with any other Lua object. Use object-oriented syntax, for example
``channel:put(message)`` rather than ``fiber.channel.put(message)``.

.. module:: fiber

.. _fiber_ipc-channel:

=================================================
                    Channel
=================================================

.. function:: channel([capacity])

    Create a new communication channel.

    :param int capacity: the maximum number of slots (spaces for
                         ``channel:put`` messages) that can be in use at once.
                         The default is 0.

    :return: new channel.
    :rtype:  userdata, possibly including the string "channel ...".

.. class:: channel_object

    .. method:: put(message[, timeout])

        Send a message using a channel. If the channel is full,
        ``channel:put()`` waits until there is a free slot in the channel.

        :param lua-value message: what will be sent, usually a string or number or table
        :param number timeout: maximum number of seconds to wait for a slot to become free
        :return: If timeout is specified, and there is no free slot in the
                 channel for the duration of the timeout, then the return value
                 is ``false``. If the channel is closed, then the return value is ``false``.
                 Otherwise, the return value is ``true``, indicating success.
        :rtype:  boolean

    .. method:: close()

        Close the channel. All waiters in the channel will stop waiting. All
        following ``channel:get()`` operations will return ``nil``, and all
        following ``channel:put()`` operations will return ``false``.

    .. method:: get([timeout])

        Fetch and remove a message from a channel. If the channel is empty,
        ``channel:get()`` waits for a message.

        :param number timeout: maximum number of seconds to wait for a message
        :return: If timeout is specified, and there is no message in the
                 channel for the duration of the timeout, then the return
                 value is ``nil``. If the channel is closed, then the
                 return value is ``nil``. Otherwise, the return value is
                 the message placed on the channel by ``channel:put()``.
        :rtype:  usually string or number or table, as determined by ``channel:put``

    .. method:: is_empty()

        Check whether the channel is empty (has no messages).

        :return: ``true`` if the channel is empty. Otherwise ``false``.
        :rtype:  boolean

    .. method:: count()

        Find out how many messages are in the channel.

        :return: the number of messages.
        :rtype:  number

    .. method:: is_full()

        Check whether the channel is full.

        :return: ``true`` if the channel is full (the number of messages
                 in the channel equals the number of slots so there is no room for a new
                 message). Otherwise ``false``.
        :rtype:  boolean

    .. method:: has_readers()

        Check whether readers are waiting for a message because they
        have issued ``channel:get()`` and the channel is empty.

        :return: ``true`` if readers are waiting. Otherwise ``false``.
        :rtype:  boolean

    .. method:: has_writers()

        Check whether writers are waiting
        because they have issued ``channel:put()`` and the channel is full.

        :return: ``true`` if writers are waiting. Otherwise ``false``.
        :rtype:  boolean

    .. method:: is_closed()

        :return: ``true`` if the channel is already closed. Otherwise
                 ``false``.
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

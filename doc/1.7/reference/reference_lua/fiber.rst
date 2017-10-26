.. _fiber-module:

-------------------------------------------------------------------------------
                            Module `fiber`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

With the ``fiber`` module, you can:

* create, run and manage :ref:`fibers <fiber-fibers>`,
* send and receive messages between different processes (i.e. different
  connections, sessions, or fibers) via :ref:`channels <fiber_ipc-channel>`, and
* use a :ref:`synchronization mechanism <fiber_ipc-cond_var>` for fibers,
  similar to "condition variables" and similar to operating-system functions
  such as ``pthread_cond_wait()`` plus ``pthread_cond_signal()``.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``fiber`` functions and members.

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: left-align-column-2

        +--------------------------------------+---------------------------------+
        | Name                                 | Use                             |
        +======================================+=================================+
        | :ref:`fiber.create()                 | Create and start a fiber        |
        | <fiber-create>`                      |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.self()                   | Get a fiber object              |
        | <fiber-self>`                        |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.find()                   | Get a fiber object by ID        |
        | <fiber-find>`                        |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.sleep()                  | Make a fiber go to sleep        |
        | <fiber-sleep>`                       |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.yield()                  | Yield control                   |
        | <fiber-yield>`                       |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.status()                 | Get the current fiber's status  |
        | <fiber-status>`                      |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.info()                   | Get information about all       |
        | <fiber-info>`                        | fibers                          |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.kill()                   | Cancel a fiber                  |
        | <fiber-kill>`                        |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.testcancel()             | Check if the current fiber has  |
        | <fiber-testcancel>`                  | been cancelled                  |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber_object:id()              | Get a fiber's ID                |
        | <fiber_object-id>`                   |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber_object:name()            | Get a fiber's name              |
        | <fiber_object-name_get>`             |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber_object:name(name)        | Set a fiber's name              |
        | <fiber_object-name_set>`             |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber_object:status()          | Get a fiber's status            |
        | <fiber_object-status>`               |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber_object:cancel()          | Cancel a fiber                  |
        | <fiber_object-cancel>`               |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber_object.storage           | Local storage within the fiber  |
        | <fiber_object-storage>`              |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.time()                   | Get the system time in seconds  |
        | <fiber-time>`                        |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.time64()                 | Get the system time in          |
        | <fiber-time64>`                      | microseconds                    |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.channel()                | Create a communication channel  |
        | <fiber-channel>`                     |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:put()           | Send a message via a channel    |
        | <channel_object-put>`                |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:close()         | Close a channel                 |
        | <channel_object-close>`              |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:get()           | Fetch a message from a channel  |
        | <channel_object-get>`                |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:is_empty()      | Check if a channel is empty     |
        | <channel_object-is_empty>`           |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:count()         | Count messages in a channel     |
        | <channel_object-count>`              |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:is_full()       | Check if a channel is full      |
        | <channel_object-is_full>`            |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:has_readers()   | Check if an empty channel has   |
        | <channel_object-has_readers>`        | any readers waiting             |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:has_writers()   | Check if a full channel has any |
        | <channel_object-has_writers>`        | writers waiting                 |
        +--------------------------------------+---------------------------------+
        | :ref:`channel_object:is_closed()     | Check if a channel is closed    |
        | <channel_object-is_closed>`          |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`fiber.cond()                   | Create a condition variable     |
        | <fiber-cond>`                        |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`cond_object:wait()             | Make a fiber go to sleep until  |
        | <cond_object-wait>`                  | woken by another fiber          |
        +--------------------------------------+---------------------------------+
        | :ref:`cond_object:signal()           | Wake up a single fiber          |
        | <cond_object-signal>`                |                                 |
        +--------------------------------------+---------------------------------+
        | :ref:`cond_object:broadcast()        | Wake up all fibers              |
        | <cond_object-broadcast>`             |                                 |
        +--------------------------------------+---------------------------------+

.. _fiber-fibers:

================================================================================
Fibers
================================================================================

A **fiber** is a set of instructions which are executed with cooperative
multitasking. Fibers managed by the fiber module are associated with
a user-supplied function called the *fiber function*.

A fiber has three possible states: **running**, **suspended** or **dead**.
When a fiber is created with :ref:`fiber.create() <fiber-create>`, it is running.
When a fiber yields control with :ref:`fiber.sleep() <fiber-sleep>`, it is suspended.
When a fiber ends (because the fiber function ends), it is dead.

All fibers are part of the fiber registry. This registry can be searched
with :ref:`fiber.find() <fiber-find>` - via fiber id (fid), which is a numeric
identifier.

A runaway fiber can be stopped with :ref:`fiber_object.cancel <fiber_object-cancel>`.
However, :ref:`fiber_object.cancel <fiber_object-cancel>` is advisory — it works
only if the runaway fiber calls :ref:`fiber.testcancel() <fiber-testcancel>`
occasionally. Most ``box.*`` functions, such as
:ref:`box.space...delete() <box_space-delete>` or
:ref:`box.space...update() <box_space-update>`, do call
:ref:`fiber.testcancel() <fiber-testcancel>` but
:ref:`box.space...select{} <box_space-select>` does not. In practice, a runaway
fiber can only become unresponsive if it does many computations and does not
check whether it has been cancelled.

The other potential problem comes from fibers which never get scheduled, because
they are not subscribed to any events, or because no relevant events occur. Such
morphing fibers can be killed with :ref:`fiber.kill() <fiber-kill>` at any time,
since :ref:`fiber.kill() <fiber-kill>` sends an asynchronous wakeup event to the
fiber, and :ref:`fiber.testcancel() <fiber-testcancel>` is checked whenever such
a wakeup event occurs.

Like all Lua objects, dead fibers are garbage collected. The garbage collector
frees pool allocator memory owned by the fiber, resets all fiber data, and
returns the fiber (now called a fiber carcass) to the fiber pool. The carcass
can be reused when another fiber is created.

A fiber has all the features of a Lua coroutine_ and all the programming
concepts that apply for Lua coroutines will apply for fibers as well. However,
Tarantool has made some enhancements for fibers and has used fibers internally.
So, although use of coroutines is possible and supported, use of fibers is
recommended.

.. module:: fiber

.. _fiber-create:

.. function:: create(function [, function-arguments])

    Create and start a fiber. The fiber is created and begins to run immediately.

    :param function: the function to be associated with the fiber
    :param function-arguments: what will be passed to function

    :Return: created fiber object
    :Rtype: userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber = require('fiber')
        ---
        ...
        tarantool> function function_name()
                 >   fiber.sleep(1000)
                 > end
        ---
        ...
        tarantool> fiber_object = fiber.create(function_name)
        ---
        ...


.. _fiber-self:

.. function:: self()

    :Return: fiber object for the currently scheduled fiber.
    :Rtype: userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.self()
        ---
        - status: running
          name: interactive
          id: 101
        ...

.. _fiber-find:

.. function:: find(id)

    :param id: numeric identifier of the fiber.

    :Return: fiber object for the specified fiber.
    :Rtype: userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.find(101)
        ---
        - status: running
          name: interactive
          id: 101
        ...

.. _fiber-sleep:

.. function:: sleep(time)

    Yield control to the scheduler and sleep for the specified number
    of seconds. Only the current fiber can be made to sleep.

    :param time: number of seconds to sleep.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.sleep(1.5)
        ---
        ...

.. _fiber-yield:

.. function:: yield()

    Yield control to the scheduler. Equivalent to :ref:`fiber.sleep(0) <fiber-sleep>`,
    except that `fiber.sleep(0)` depends on a timer, `fiber.yield()` does not.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.yield()
        ---
        ...

.. _fiber-status:

.. function:: status()

    Return the status of the current fiber.

    :Return: the status of ``fiber``. One of: “dead”, “suspended”, or “running”.
    :Rtype: string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.status()
        ---
        - running
        ...

.. _fiber-info:

.. function:: info()

    Return information about all fibers.

    :Return: number of context switches, backtrace, id, total memory, used
             memory, name for each fiber.
    :Rtype: table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.info()
        ---
        - 101:
            csw: 7
            backtrace: []
            fid: 101
            memory:
              total: 65776
              used: 0
            name: interactive
        ...

.. _fiber-kill:

.. function:: kill(id)

    Locate a fiber by its numeric id and cancel it. In other words,
    :ref:`fiber.kill() <fiber-kill>` combines :ref:`fiber.find() <fiber-find>` and
    :ref:`fiber_object:cancel() <fiber_object-cancel>`.

    :param id: the id of the fiber to be cancelled.
    :Exception: the specified fiber does not exist or cancel is not permitted.

    **Example:**

    .. code-block:: tarantoolsession


        tarantool> fiber.kill(fiber.id()) -- kill self, may make program end
        ---
        - error: fiber is cancelled
        ...

.. _fiber-testcancel:

.. function:: testcancel()

    Check if the current fiber has been cancelled
    and throw an exception if this is the case.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.testcancel()
        ---
        - error: fiber is cancelled
        ...

.. class:: fiber_object

    .. _fiber_object-id:

    .. method:: id()

        :param self: fiber object, for example the fiber object returned
                     by :ref:`fiber.create <fiber-create>`
        :Return: id of the fiber.
        :Rtype: number

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber_object = fiber.self()
            ---
            ...
            tarantool> fiber_object:id()
            ---
            - 101
            ...

    .. _fiber_object-name_get:

    .. method:: name()

        :param self: fiber object, for example the fiber object returned
                     by :ref:`fiber.create <fiber-create>`
        :Return: name of the fiber.
        :Rtype: string

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():name()
            ---
            - interactive
            ...

    .. _fiber_object-name_set:

    .. method:: name(name)

        Change the fiber name. By default a Tarantool server's
        interactive-mode fiber is named 'interactive' and new
        fibers created due to :ref:`fiber.create <fiber-create>` are named 'lua'.
        Giving fibers distinct names makes it easier to
        distinguish them when using :ref:`fiber.info <fiber-info>`.

        :param self: fiber object, for example the fiber
                     object returned by :ref:`fiber.create <fiber-create>`
        :param string name: the new name of the fiber.

        :Return: nil

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():name('non-interactive')
            ---
            ...

    .. _fiber_object-status:

    .. method:: status()

        Return the status of the specified fiber.

        :param self: fiber object, for example the fiber object returned by
                     :ref:`fiber.create <fiber-create>`

        :Return: the status of fiber. One of: “dead”, “suspended”, or “running”.
        :Rtype: string

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():status()
            ---
            - running
            ...

    .. _fiber_object-cancel:

    .. method:: cancel()

        Cancel a fiber. Running and suspended fibers can be cancelled.
        After a fiber has been cancelled, attempts to operate on it will
        cause errors, for example :ref:`fiber_object:id() <fiber_object-id>`
        will cause ``error: the fiber is dead``.

        :param self: fiber object, for example the fiber
                     object returned by :ref:`fiber.create <fiber-create>`

        :Return: nil

        Possible errors: cancel is not permitted for the specified fiber object.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():cancel() -- kill self, may make program send
            ---
            - error: fiber is cancelled
            ...

    .. _fiber_object-storage:

    .. data:: storage

        Local storage within the fiber. The storage can contain any number of
        named values, subject to memory limitations. Naming may be done with
        :samp:`{fiber_object}.storage.{name}` or :samp:`{fiber_object}.storage['{name}'].`
        or with a number :samp:`{fiber_object}.storage[{number}]`.
        Values may be either numbers or strings. The storage is garbage-collected
        when :samp:`{fiber_object}:cancel()` happens.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber = require('fiber')
            ---
            ...
            tarantool> function f () fiber.sleep(1000); end
            ---
            ...
            tarantool> fiber_function = fiber:create(f)
            ---
            - error: '[string "fiber_function = fiber:create(f)"]:1: fiber.create(function, ...):
                bad arguments'
            ...
            tarantool> fiber_function = fiber.create(f)
            ---
            ...
            tarantool> fiber_function.storage.str1 = 'string'
            ---
            ...
            tarantool> fiber_function.storage['str1']
            ---
            - string
            ...
            tarantool> fiber_function:cancel()
            ---
            ...
            tarantool> fiber_function.storage['str1']
            ---
            - error: '[string "return fiber_function.storage[''str1'']"]:1: the fiber is dead'
            ...

        See also :ref:`box.session.storage <box_session-storage>`.

.. _fiber-time:

.. function:: time()

    :Return: current system time (in seconds since the epoch) as a Lua
             number. The time is taken from the event loop clock,
             which makes this call very cheap, but still useful for
             constructing artificial tuple keys.
    :Rtype: num

    **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.time(), fiber.time()
            ---
            - 1448466279.2415
            - 1448466279.2415
            ...

.. _fiber-time64:

.. function:: time64()

    :Return: current system time (in microseconds since the epoch)
             as a 64-bit integer. The time is taken from the event
             loop clock.
    :Rtype: num

    **Example:**

    .. code-block:: tarantoolsession

            tarantool> fiber.time(), fiber.time64()
            ---
            - 1448466351.2708
            - 1448466351270762
            ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make the function which will be associated with the fiber. This function
contains an infinite loop (``while 0 == 0`` is always true). Each iteration
of the loop adds 1 to a global variable named gvar, then goes to sleep for
2 seconds. The sleep causes an implicit :ref:`fiber.yield() <fiber-yield>`.

.. code-block:: tarantoolsession

    tarantool> fiber = require('fiber')
    tarantool> function function_x()
             >   gvar = 0
             >   while 0 == 0 do
             >     gvar = gvar + 1
             >     fiber.sleep(2)
             >   end
             > end
    ---
    ...

Make a fiber, associate function_x with the fiber, and start function_x.
It will immediately "detach" so it will be running independently of the caller.

.. code-block:: tarantoolsession

    tarantool> gvar = 0

    tarantool> fiber_of_x = fiber.create(function_x)
    ---
    ...

Get the id of the fiber (fid), to be used in later displays.

.. code-block:: tarantoolsession

    tarantool> fid = fiber_of_x:id()
    ---
    ...

Pause for a while, while the detached function runs. Then ... Display the fiber
id, the fiber status, and gvar (gvar will have gone up a bit depending how long
the pause lasted). The status is suspended because the fiber spends almost all
its time sleeping or yielding.

.. code-block:: tarantoolsession

    tarantool> print('#', fid, '. ', fiber_of_x:status(), '. gvar=', gvar)
    # 102 .  suspended . gvar= 399
    ---
    ...

Pause for a while, while the detached function runs. Then ... Cancel the fiber.
Then, once again ... Display the fiber id, the fiber status, and gvar (gvar
will have gone up a bit more depending how long the pause lasted). This time
the status is dead because the cancel worked.

.. code-block:: tarantoolsession

    tarantool> fiber_of_x:cancel()
    ---
    ...
    tarantool> print('#', fid, '. ', fiber_of_x:status(), '. gvar=', gvar)
    # 102 .  dead . gvar= 421
    ---
    ...

.. _coroutine:  http://www.lua.org/pil/contents.html#9

.. _fiber_ipc-channel:

=================================================
Channels
=================================================

Call ``fiber.channel()`` to allocate space and get a channel object, which will
be called channel for examples in this section.

Call the other routines, via channel, to send messages, receive messages, or
check channel status.

Message exchange is synchronous. The channel is garbage collected when no one is
using it, as with any other Lua object. Use object-oriented syntax, for example
``channel:put(message)`` rather than ``fiber.channel.put(message)``.

.. _fiber-channel:

.. function:: channel([capacity])

    Create a new communication channel.

    :param int capacity: the maximum number of slots (spaces for
                         ``channel:put`` messages) that can be in use at once.
                         The default is 0.

    :return: new channel.
    :rtype:  userdata, possibly including the string "channel ...".

.. class:: channel_object

    .. _channel_object-put:

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

    .. _channel_object-close:

    .. method:: close()

        Close the channel. All waiters in the channel will stop waiting. All
        following ``channel:get()`` operations will return ``nil``, and all
        following ``channel:put()`` operations will return ``false``.

    .. _channel_object-get:

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

    .. _channel_object-is_empty:

    .. method:: is_empty()

        Check whether the channel is empty (has no messages).

        :return: ``true`` if the channel is empty. Otherwise ``false``.
        :rtype:  boolean

    .. _channel_object-count:

    .. method:: count()

        Find out how many messages are in the channel.

        :return: the number of messages.
        :rtype:  number

    .. _channel_object-is_full:

    .. method:: is_full()

        Check whether the channel is full.

        :return: ``true`` if the channel is full (the number of messages
                 in the channel equals the number of slots so there is no room for a new
                 message). Otherwise ``false``.
        :rtype:  boolean

    .. _channel_object-has_readers:

    .. method:: has_readers()

        Check whether readers are waiting for a message because they
        have issued ``channel:get()`` and the channel is empty.

        :return: ``true`` if readers are waiting. Otherwise ``false``.
        :rtype:  boolean

    .. _channel_object-has_writers:

    .. method:: has_writers()

        Check whether writers are waiting
        because they have issued ``channel:put()`` and the channel is full.

        :return: ``true`` if writers are waiting. Otherwise ``false``.
        :rtype:  boolean

    .. _channel_object-is_closed:

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

.. _fiber_ipc-cond_var:

=================================================
Condition variables
=================================================

Call ``fiber.cond()`` to create a named condition variable, which will be called
'cond' for examples in this section.

Call ``cond:wait()`` to make a fiber wait for a signal via a condition variable.

Call ``cond:signal()`` to send a signal to wake up a single fiber that has
executed ``cond:wait()``.

Call ``cond:broadcast()`` to send a signal to all fibers that have executed
``cond:wait()``.

.. _fiber-cond:

.. function:: cond()

    Create a new condition variable.

    :return: new condition variable.
    :rtype:  Lua object

.. class:: cond_object

    .. _cond_object-wait:

    .. method:: wait([timeout])

        Make the current fiber go to sleep, waiting until another fiber
        invokes the ``signal()`` or ``broadcast()`` method on the cond object.
        The sleep causes an implicit :ref:`fiber.yield() <fiber-yield>`.

        :param timeout: number of seconds to wait, default = forever.
        :return: If timeout is provided, and a signal doesn't happen for the
                 duration of the timeout, ``wait()`` returns false. If a signal
                 or broadcast happens, ``wait()`` returns true.
        :rtype:  boolean

    .. _cond_object-signal:

    .. method:: signal()

        Wake up a single fiber that has executed ``wait()`` for the same
        variable.

        :rtype:  nil

    .. _cond_object-broadcast:

    .. method:: broadcast()

        Wake up all fibers that have executed ``wait()`` for the same variable.

        :rtype:  nil

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Assume that a tarantool instance is running and listening for connections on
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

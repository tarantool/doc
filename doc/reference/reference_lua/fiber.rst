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
    | :ref:`fiber.new()                    | Create but do not start a fiber |
    | <fiber-new>`                         |                                 |
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
    | :ref:`fiber_object:set_joinable()    | Make it possible for a new      |
    | <fiber_object-set_joinable>`         | fiber to join                   |
    +--------------------------------------+---------------------------------+
    | :ref:`fiber_object:join()            | Wait for a fiber's state to     |
    | <fiber_object-join>`                 | become 'dead'                   |
    +--------------------------------------+---------------------------------+
    | :ref:`fiber.time()                   | Get the system time in seconds  |
    | <fiber-time>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fiber.time64()                 | Get the system time in          |
    | <fiber-time64>`                      | microseconds                    |
    +--------------------------------------+---------------------------------+
    | :ref:`fiber.clock()                  | Get the monotonic time in       |
    | <fiber-clock>`                       | seconds                         |
    +--------------------------------------+---------------------------------+
    | :ref:`fiber.clock64()                | Get the monotonic time in       |
    | <fiber-clock64>`                     | microseconds                    |
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
When a fiber is created with :ref:`fiber.new() <fiber-new>` or yields control
with :ref:`fiber.sleep() <fiber-sleep>`, it is suspended.
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

Like all Lua objects, dead fibers are garbage collected. The Lua garbage collector
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
                 >   print("I'm a fiber")
                 > end
        ---
        ...
        tarantool> fiber_object = fiber.create(function_name); print("Fiber started")
        I'm a fiber
        Fiber started
        ---
        ...

.. _fiber-new:

.. function:: new(function [, function-arguments])

    Create but do not start a fiber: the fiber is created but does not
    begin to run immediately -- it starts after the fiber creator
    (that is, the job that is calling ``fiber.new()``) yields,
    under :ref:`transaction control <atomic-atomic_execution>`.
    The initial fiber state is 'suspended'.
    Thus ``fiber.new()`` differs slightly from
    :ref:`fiber.create() <fiber-create>`.

    Ordinarily ``fiber.new()`` is used in conjunction with
    :ref:`fiber_object:set_joinable() <fiber_object-set_joinable>`
    and
    :ref:`fiber_object:join() <fiber_object-join>`.

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
                 >   print("I'm a fiber")
                 > end
        ---
        ...
        tarantool> fiber_object = fiber.new(function_name); print("Fiber not started yet")
        Fiber not started yet
        ---
        ...
        tarantool> I'm a fiber
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
    :Exception: see the :ref:`Example of yield failure <fiber-fail>`.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.sleep(1.5)
        ---
        ...

.. _fiber-yield:

.. function:: yield()

    Yield control to the scheduler. Equivalent to :ref:`fiber.sleep(0) <fiber-sleep>`.

    :Exception: see the :ref:`Example of yield failure <fiber-fail>`.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.yield()
        ---
        ...

.. _fiber-status:

.. function:: status([fiber_object])

    Return the status of the current fiber.
    Or, if optional fiber_object is passed, return the status of the
    specified fiber.

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

    .. NOTE::

        Even if you catch the exception, the fiber will remain cancelled.
        Most types of calls will check ``fiber.testcancel()``.
        However, some functions (``id``, ``status``, ``join`` etc.) will return no error.
        We recommend application developers to implement occasional checks with
        :ref:`fiber.testcancel() <fiber-testcancel>` and to end fiber's execution
        as soon as possible in case it has been cancelled.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fiber.testcancel()
        ---
        - error: fiber is cancelled
        ...

.. class:: fiber_object

    .. _fiber_object-id:

    .. method:: id()

        :param fiber_object: generally this is an object referenced in the return
                             from :ref:`fiber.create <fiber-create>`
                             or :ref:`fiber.self <fiber-self>`
                             or :ref:`fiber.find <fiber-find>`
        :Return: id of the fiber.
        :Rtype: number

        ``fiber.self():id()`` can also be expressed as ``fiber.id()``.

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

        :param fiber_object: generally this is an object referenced in the return
                             from :ref:`fiber.create <fiber-create>`
                             or :ref:`fiber.self <fiber-self>`
                             or :ref:`fiber.find <fiber-find>`
        :Return: name of the fiber.
        :Rtype: string

        ``fiber.self():name()`` can also be expressed as ``fiber.name()``.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():name()
            ---
            - interactive
            ...

    .. _fiber_object-name_set:

    .. method:: name(name[, options])

        Change the fiber name. By default a Tarantool server's
        interactive-mode fiber is named 'interactive' and new
        fibers created due to :ref:`fiber.create <fiber-create>` are named 'lua'.
        Giving fibers distinct names makes it easier to
        distinguish them when using :ref:`fiber.info <fiber-info>`.
        Max length is 32.

        :param fiber_object: generally this is an object referenced in the return
                             from :ref:`fiber.create <fiber-create>`
                             or :ref:`fiber.self <fiber-self>`
                             or :ref:`fiber.find <fiber-find>`
        :param string name: the new name of the fiber.
        :param options:

            * ``truncate=true`` -- truncates the name to the max length if it is
              too long. If this option is false (the default),
              ``fiber.name(new_name)`` fails with an exception if a new name is
              too long.

        :Return: nil

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():name('non-interactive')
            ---
            ...

    .. _fiber_object-status:

    .. method:: status()

        Return the status of the specified fiber.

        :param fiber_object: generally this is an object referenced in the return
                             from :ref:`fiber.create <fiber-create>`
                             or :ref:`fiber.self <fiber-self>`
                             or :ref:`fiber.find <fiber-find>`
        :Return: the status of fiber. One of: “dead”, “suspended”, or “running”.
        :Rtype: string

        ``fiber.self():status(`` can also be expressed as ``fiber.status()``.

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
        cause errors, for example :ref:`fiber_object:name() <fiber_object-name_get>`
        will cause ``error: the fiber is dead``. But a dead fiber can still
        report its id and status.

        :param fiber_object: generally this is an object referenced in the return
                             from :ref:`fiber.create <fiber-create>`
                             or :ref:`fiber.self <fiber-self>`
                             or :ref:`fiber.find <fiber-find>`
        :Return: nil

        Possible errors: cancel is not permitted for the specified fiber object.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber.self():cancel() -- kill self, may make program end
            ---
            ...
            tarantool> fiber.self():cancel()
            ---
            - error: fiber is cancelled
            ...
            tarantool> fiber.self:id()
            ---
            - 163
            ...
            tarantool> fiber.self:status()
            ---
            - dead
            ...

    .. _fiber_object-storage:

    .. data:: storage

        Local storage within the fiber. It is a Lua table created when it is
        first accessed. The storage can contain any number of named values,
        subject to memory limitations. Naming may be done with
        :samp:`{fiber_object}.storage.{name}` or
        :samp:`{fiber_object}.storage['{name}'].` or with a number
        :samp:`{fiber_object}.storage[{number}]`.
        Values may be either numbers or strings.

        ``fiber.storage`` is destroyed when the fiber is finished, regardless
        of how is it finished -- via :samp:`{fiber_object}:cancel()`,
        or the fiber's function did 'return'. Moreover, the storage is cleaned
        up even for pooled fibers used to serve IProto requests. Pooled fibers
        never really die, but nonetheless their storage is cleaned up after each
        request. That makes possible to use ``fiber.storage`` as a full featured
        request-local storage.

        This storage may be created for a fiber, no matter how the fiber
        itself was created -- from C or from Lua. For example, a fiber can
        be created in C using ``fiber_new()``, then it can insert into a
        space, which has Lua ``on_replace`` triggers, and one of the triggers
        can create ``fiber.storage``. That storage will be deleted when the
        fiber is stopped.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fiber = require('fiber')
            ---
            ...
            tarantool> function f () fiber.sleep(1000); end
            ---
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

    .. _fiber_object-set_joinable:

    .. method:: set_joinable(true_or_false)

        ``fiber_object:set_joinable(true)`` makes a fiber joinable;
        ``fiber_object:set_joinable(false)`` makes a fiber not joinable;
        the default is false.

        A joinable fiber can be waited for, with
        :ref:`fiber_object:join() <fiber_object-join>`.

        Best practice is to call ``fiber_object:set_joinable()`` before the
        fiber function begins to execute, because otherwise the fiber could
        become 'dead' before ``fiber_object:set_joinable()`` takes effect.
        The usual sequence could be:

        1. Call ``fiber.new()`` instead of ``fiber.create()`` to create a new
           fiber_object.

           Do not yield at this point, because that will cause the fiber
           function to begin.

        2. Call ``fiber_object:set_joinable(true)`` to make the new
           fiber_object joinable.

           Now it is safe to yield.

        3. Call ``fiber_object:join()``.

           Usually ``fiber_object:join()`` should be called, otherwise the
           fiber's status may become 'suspended' when the fiber function ends,
           instead of 'dead'.

        :param true_or_false: the boolean value that changes the ``set_joinable``
                              flag

        :Return: nil

        **Example:**

        The result of the following sequence of requests is:

        * the global variable ``d`` will be 6 (which proves that the function
          was not executed until after ``d`` was set to 1, when
          ``fiber.sleep(1)`` caused a yield);
        * ``fiber.status(fi2)`` will be 'suspended' (which proves that after
          the function was executed the fiber status did not change to 'dead').

        .. code-block:: lua

            fiber=require('fiber')
            d=0
            function fu2() d=d+5 end
            fi2=fiber.new(fu2) fi2:set_joinable(true) d=1 fiber.sleep(1)
            print(d)
            fiber.status(fi2)

    .. _fiber_object-join:

    .. method:: join()

        "Join" a joinable fiber.
        That is, let the fiber's function run and wait
        until the fiber's status is 'dead' (normally a status
        becomes 'dead' when the function execution finishes).
        Joining will cause a yield, therefore, if the fiber is
        currently in a suspended state, execution of its fiber
        function will resume.

        This kind of waiting is more convenient than going into
        a loop and periodically checking the status; however,
        it works only if the fiber was created with
        :ref:`fiber.new() <fiber-new>`
        and was made joinable with
        :ref:`fiber_object:set_joinable() <fiber_object-set_joinable>`.

        :Return: two values. The first value is boolean.
                 If the first value is true, then the join succeeded
                 because the fiber's function ended normally and the
                 second result has the return value from the fiber's function.
                 If the first value is false, then the join succeeded
                 because the fiber's function ended abnormally and the
                 second result has the details about the error, which
                 one can unpack in the same way that one unpacks
                 :ref:`a pcall result <error_handling>`.

        :Rtype: boolean +result type, or boolean + struct error

        **Example:**

        The result of the following sequence of requests is:

        * the first ``fiber.status()`` call returns 'suspended',
        * the ``join()`` call returns true,
        * the elapsed time is usually 5 seconds, and
        * the second ``fiber.status()`` call returns 'dead'.

        This proves that the ``join()`` does not return until
        the function -- which sleeps 5 seconds -- is 'dead'.

        .. code-block:: lua

            fiber=require('fiber')
            function fu2() fiber.sleep(5) end
            fi2=fiber.new(fu2) fi2:set_joinable(true)
            start_time = os.time()
            fiber.status(fi2)
            fi2:join()
            print('elapsed = ' .. os.time() - start_time)
            fiber.status(fi2)

.. _fiber-time:

.. function:: time()

    :Return: current system time (in seconds since the epoch) as a Lua
             number. The time is taken from the event loop clock,
             which makes this call very cheap, but still useful for
             constructing artificial tuple keys.
    :Rtype: number

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
    :Rtype: cdata

    **Example:**

    .. code-block:: tarantoolsession

            tarantool> fiber.time(), fiber.time64()
            ---
            - 1448466351.2708
            - 1448466351270762
            ...

.. _fiber-clock:

.. function:: clock()

    Get the monotonic time in seconds. It is better to use ``fiber.clock()`` for
    calculating timeouts instead of :ref:`fiber.time() <fiber-time>` because
    ``fiber.time()`` reports real time so it is affected by system time changes.

    :Return: a floating-point number of seconds, representing elapsed wall-clock
             time since some time in the past that is guaranteed not to change
             during the life of the process
    :Rtype: number

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> start = fiber.clock()
        ---
        ...
        tarantool> print(start)
        248700.58805
        ---
        ...
        tarantool> print(fiber.time(), fiber.time()-start)
        1600785979.8291 1600537279.241
        ---
        ...

.. _fiber-clock64:

.. function:: clock64()

    Same as :ref:`fiber.clock() <fiber-clock>` but in microseconds.

    :Return: a number of seconds as 64-bit integer, representing
             elapsed wall-clock time since some time in the past that is
             guaranteed not to change during the life of the process
    :Rtype: cdata

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make the function which will be associated with the fiber. This function
contains an infinite loop. Each iteration
of the loop adds 1 to a global variable named gvar, then goes to sleep for
2 seconds. The sleep causes an implicit :ref:`fiber.yield() <fiber-yield>`.

.. code-block:: tarantoolsession

    tarantool> fiber = require('fiber')
    tarantool> function function_x()
             >   gvar = 0
             >   while true do
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

.. _fiber-fail:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example of yield failure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Warning: :ref:`yield() <fiber-yield>` and any function which implicitly yields
(such as :ref:`sleep() <fiber-sleep>`) can fail (raise an exception).

For example, this function has a loop which repeats until :ref:`cancel() <fiber_object-cancel>` happens.
The last thing that it will print is 'before yield', which demonstrates
that ``yield()`` failed, the loop did not continue until :ref:`testcancel() <fiber-testcancel>` failed.

.. code-block:: Lua

    fiber = require('fiber')
    function function_name()
      while true do
        print('before testcancel')
        fiber.testcancel()
        print('before yield')
        fiber.yield()
      end
    end
    fiber_object = fiber.create(function_name)
    fiber.sleep(.1)
    fiber_object:cancel()

.. _fiber_ipc-channel:

=================================================
Channels
=================================================

Call ``fiber.channel()`` to allocate space and get a channel object, which will
be called channel for examples in this section.

Call the other routines, via channel, to send messages, receive messages, or
check channel status.

Message exchange is synchronous. The Lua garbage collector will mark or free the
channel when no one is
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
        variable. Does not yield.

        :rtype:  nil

    .. _cond_object-broadcast:

    .. method:: broadcast()

        Wake up all fibers that have executed ``wait()`` for the same variable.
        Does not yield.

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

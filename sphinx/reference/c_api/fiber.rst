===========================================================
                       Module `fiber`
===========================================================

.. c:type:: struct fiber

    Fiber - contains information about fiber

.. c:function:: struct fiber *fiber_new(const char *name, fiber_func f)

.. c:type:: typedef int (*fuber_func)(va_list)

    Create a new fiber.

    Takes a fiber from fiber cache, if it's not empty. Can fail only if there is
    not enough memory for the fiber structure or fiber stack.

    The created fiber automatically returns itself to the fiber cache when its
    "main" function completes.

    :param const char* name: string with fiber name
    :param fiber_func     f: func for run inside fiber

    See also: :ref:`fiber_start()<c_api-fiber-fiber_start>`

.. c:function:: void fiber_yield(void)

    Return control to another fiber and wait until it'll be woken.

    See also: :ref:`fiber_wakeup()<c_api-fiber-fiber_wakeup>`

.. _c_api-fiber-fiber_start:

.. c:function:: void fiber_start(struct fiber *callee, ...)

    Start execution of created fiber.

    :param struct fiber* callee: fiber to start
    :param                  ...: arguments to start the fiber with

.. _c_api-fiber-fiber_wakeup:

.. c:function:: void fiber_wakeup(struct fiber *f)

    Interrupt a synchronous wait of a fiber

    :param struct fiber* f: fiber to be woken up

.. c:function:: void fiber_cancel(struct fiber *f)

    Cancel the subject fiber (set ``FIBER_IS_CANCELLED`` flag)

    If target fiber's flag ``FIBER_IS_CANCELLABLE`` set, then it would be woken
    up (maybe prematurely). Then current fiber yields until the target fiber is
    dead (or is woken up by :ref:`fiber_wakeup()<c_api-fiber-fiber_wakeup>`).

    :param struct fiber* f: fiber to be cancelled

.. c:function:: bool fiber_set_cancellable(bool yesno)

    Make it possible or not possible to wakeup the current fiber immediately
    when it's cancelled.

    :param struct fiber* f: fiber
    :param bool      yesno: status to set

    :return: previous state

.. _c_api-fiber-fiber_set_joinable:

.. c:function:: void fiber_set_joinable(struct fiber *fiber, bool yesno)

    Set fiber to be joinable (``false`` by default).

    :param struct fiber* f: fiber
    :param bool      yesno: status to set

.. c:function:: void fiber_join(struct fiber *f)

    Wait until the fiber is dead and then move its execution status to the
    caller. The fiber must not be detached.

    :param struct fiber* f: fiber to be woken up

    Before: ``FIBER_IS_JOINABLE`` flag is set.

    See also: :ref:`fiber_set_joinable()<c_api-fiber-fiber_set_joinable>`

.. c:function:: void fiber_sleep(double s)

    Put the current fiber to sleep for at least 's' seconds.

    :param double s: time to sleep

    Note: this is a cancellation point.

    See also: :ref:`fiber_is_cancelled()<c_api-fiber-fiber_is_cancelled>`

.. _c_api-fiber-fiber_is_cancelled:

.. c:function:: bool fiber_is_cancelled()

    Check current fiber for cancellation (it must be checked manually).

.. c:function:: double fiber_time(void)

    Report loop begin time as double (cheap).

.. c:function:: uint64_t fiber_time64(void)

    Report loop begin time as 64-bit int.

.. c:function:: void fiber_reschedule(void)

    Reschedule fiber to end of event loop cycle.

.. c:type:: struct slab_cache

.. c:function:: struct slab_cache *cord_slab_cache(void)

    Return slab_cache suitable to use with ``tarantool/small`` library

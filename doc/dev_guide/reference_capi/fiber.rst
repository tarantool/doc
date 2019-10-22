===========================================================
                       Module `fiber`
===========================================================

.. c:type:: struct fiber

    Fiber - contains information about a :ref:`fiber <atomic-threads_fibers_yields>`.

.. c:type:: typedef int (*fiber_func)(va_list)

    Function to run inside a fiber.

.. c:function:: struct fiber *fiber_new(const char *name, fiber_func f)

    Create a new fiber.

    Takes a fiber from the fiber cache, if it's not empty. Can fail only if there is
    not enough memory for the fiber structure or fiber stack.

    The created fiber automatically returns itself to the fiber cache when its
    "main" function completes.

    :param const char* name: string with fiber name
    :param fiber_func     f: func for run inside fiber

    See also: :ref:`fiber_start()<c_api-fiber-fiber_start>`

.. c:function:: struct fiber *fiber_new_ex(const char *name, const struct fiber_attr *fiber_attr, fiber_func f)

    Create a new fiber with defined attributes.

    Can fail only if there is not enough memory for
    the fiber structure or fiber stack.

    The created fiber automatically returns itself
    to the fiber cache if has a default stack size
    when its "main" function completes.

    :param const char*                    name: string with fiber name
    :param const struct fiber_attr* fiber_attr: fiber attributes container
    :param fiber_func                        f: function to run inside the fiber

    See also: :ref:`fiber_start()<c_api-fiber-fiber_start>`

.. _c_api-fiber-fiber_start:

.. c:function:: void fiber_start(struct fiber *callee, ...)

    Start execution of created fiber.

    :param struct fiber* callee: fiber to start
    :param                  ...: arguments to start the fiber with

.. c:function:: void fiber_yield(void)

    Return control to another fiber and wait until it'll be woken.

    See also: :ref:`fiber_wakeup()<c_api-fiber-fiber_wakeup>`

.. _c_api-fiber-fiber_wakeup:

.. c:function:: void fiber_wakeup(struct fiber *f)

    Interrupt a synchronous wait of a fiber

    :param struct fiber* f: fiber to be woken up

.. _c_api-fiber-fiber_cancel:

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

.. c:function:: bool fiber_is_cancelled(void)

    Check current fiber for cancellation (it must be checked manually).

.. c:function:: double fiber_time(void)

    Report loop begin time as double (cheap).

.. c:function:: uint64_t fiber_time64(void)

    Report loop begin time as 64-bit int.

.. c:function:: void fiber_reschedule(void)

    Reschedule fiber to end of event loop cycle.

.. c:type:: struct slab_cache

.. c:function:: struct slab_cache *cord_slab_cache(void)

    Return ``slab_cache`` suitable to use with ``tarantool/small`` library

.. c:function:: struct fiber *fiber_self(void)

    Return the current fiber.

.. c:type:: struct fiber_attr

.. c:function:: void fiber_attr_new(void)

    Create a new fiber attributes container and initialize it
    with default parameters.

    Can be used for creating many fibers: corresponding fibers
    will not take ownership.

.. c:function:: void fiber_attr_delete(struct fiber_attr *fiber_attr)

    Delete the ``fiber_attr`` and free all allocated resources.
    This is safe when fibers created with this attribute still exist.

    :param struct fiber_attr* fiber_attribute: fiber attributes container

.. c:function:: int fiber_attr_setstacksize(struct fiber_attr *fiber_attr, size_t stack_size)

    Set the fiber's stack size in the fiber attributes container.

    :param struct fiber_attr* fiber_attr: fiber attributes container
    :param size_t             stack_size: stack size for new fibers (in bytes)

    :return: 0 on success
    :return: -1 on failure (if ``stack_size`` is smaller than the minimum
             allowable fiber stack size)

.. c:function:: size_t fiber_attr_getstacksize(struct fiber_attr *fiber_attr)

    Get the fiber's stack size from the fiber attributes container.

    :param struct fiber_attr* fiber_attr: fiber attributes container,
                                          or NULL for default

    :return: stack size (in bytes)

.. _c_api-fiber_cond:

.. c:type:: struct fiber_cond

    A conditional variable: a synchronization primitive that allow fibers in
    Tarantool's :ref:`cooperative multitasking <atomic-cooperative_multitasking>`
    environment to yield until some predicate is satisfied.

    Fiber conditions have two basic operations -- "wait" and "signal", -- where
    "wait" suspends the execution of a fiber (i.e. yields) until "signal" is
    called.

    Unlike ``pthread_cond``, ``fiber_cond`` doesn't require mutex/latch wrapping.

.. c:function:: struct fiber_cond *fiber_cond_new(void)

    Create a new conditional variable.

.. c:function:: void fiber_cond_delete(struct fiber_cond *cond)

    Delete the conditional variable.

    Note: behavior is undefined if there are fibers waiting for the conditional
    variable.

    :param struct fiber_cond* cond: conditional variable to delete

.. _c_api-fiber_cond_signal:

.. c:function:: void fiber_cond_signal(struct fiber_cond *cond);

    Wake up **one** (any) of the fibers waiting for the conditional variable.

    Does nothing if no one is waiting.

    :param struct fiber_cond* cond: conditional variable

.. c:function:: void fiber_cond_broadcast(struct fiber_cond *cond);

    Wake up **all** fibers waiting for the conditional variable.

    Does nothing if no one is waiting.

    :param struct fiber_cond* cond: conditional variable

.. _c_api-fiber_cond_wait_timeout:

.. c:function:: int fiber_cond_wait_timeout(struct fiber_cond *cond, double timeout)

    Suspend the execution of the current fiber (i.e. yield) until
    :ref:`fiber_cond_signal() <c_api-fiber_cond_signal>` is called.

    Like ``pthread_cond``, ``fiber_cond`` can issue spurious wake ups caused by
    explicit :ref:`fiber_wakeup()<c_api-fiber-fiber_wakeup>` or
    :ref:`fiber_cancel()<c_api-fiber-fiber_cancel>` calls. It is highly
    recommended to wrap calls to this function into a loop and check the actual
    predicate and :ref:`fiber_is_cancelled()<c_api-fiber-fiber_is_cancelled>`
    on every iteration.

    :param struct fiber_cond* cond: conditional variable
    :param struct double timeout: timeout in seconds

    :return: 0 on :ref:`fiber_cond_signal() <c_api-fiber_cond_signal>` call or a
             spurious wake up
    :return: -1 on timeout, and the error code is set to 'TimedOut'

.. c:function:: int fiber_cond_wait(struct fiber_cond *cond)

    Shortcut for :ref:`fiber_cond_wait_timeout() <c_api-fiber_cond_wait_timeout>`.

===========================================================
                        Function on_shutdown
===========================================================

..  _c_api-on_shutdown:
    
.. c:function:: int box_on_shutdown(void *arg, int (*new_handler)(void *), int (*old_handler)(void *))

    Register and/or deregister an on_shutdown function.

    :param void* arg: Pointer to an area that the new handler can use
    :param function* new_handler: Pointer to a function which will be registered, or NULL
    :param function* old_handler: Pointer to a function which will be deregistered, or NULL

    :return: status of operation. 0 - success, -1 - failure
    :rtype:  int

    A function which is registered will be called when the Tarantool instance shuts down.
    This is functionally similar to what :ref:`box.ctl.on_shutdown <box_ctl-on_shutdown>` does.

    If there are several on_shutdown functions, the Tarantool instance will call them
    in reverse order of registration, that is, it will call the last-registered function first.
    
    Typically a module developer will register an on_shutdown function that does whatever
    cleanup work the module requires, and then returns control to the Tarantool instance.
    Such an on_shutdown function should be fast, or should use an
    asynchronous waiting mechanism (for example :ref:`coio_wait <c_api-coio-coio_wait>`).

    Possible errors:
    old_handler does not exist (errno = EINVAL),
    new_handler and old_handler are both NULL (errno = EINVAL),
    memory allocation fails (errno = ENOMEM).
    
    Example: if the C API .c program contains a function
    ``int on_shutdown_function(void *arg) {printf("Bye!\n");return 0; }``
    and later, in the function which the instance calls, contains a line
    ``box_on_shutdown(NULL, on_shutdown_function, NULL);``
    then, if all goes well, when the instance shuts down, it will display "Bye!".

    Added in version :doc:`2.8.1 </release/2.8.1>`.

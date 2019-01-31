.. _box_ctl:

-------------------------------------------------------------------------------
                                Submodule `box.ctl`
-------------------------------------------------------------------------------

.. module:: box.ctl

The ``box.ctl`` submodule contains two wait functions: ``wait_ro``
(wait until read-only)
and ``wait_rw`` (wait until read-write).
The wait functions are useful during initialization of a server.

A particular use is for :ref:`box_once() <box-once>`.
For example, when a replica is initializing, it may call
a ``box.once()`` function while the server is still in
read-only mode, and fail to make changes that are necessary
only once before the replica is fully initialized.
This could cause conflicts between a master and a replica
if the master is in read-write mode and the replica is in
read-only mode.
Waiting until "read only mode = false" solves this problem.

To see whether a function is already in read-only or
read-write mode, check :ref:`box.info.ro <box_introspection-box_info>`.

.. _ctl-wait_ro:

.. function:: wait_ro([timeout])

    Wait until ``box.info.ro`` is true.

    :param number timeout: maximum number of seconds to wait
    :return: nil, or error (errors may be due to timeout or fiber cancellation)

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.info().ro
        ---
        - false
        ...

        tarantool> n = box.ctl.wait_ro(0.1)
        ---
        - error: timed out
        ...

.. _ctl-wait_rw:

.. function:: wait_rw([timeout])

    Wait until box.info.ro is false.

    :param number timeout: maximum number of seconds to wait
    :return: nil, or error (errors may be due to timeout or fiber cancellation)


    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.ctl.wait_rw(0.1)
        ---
        ...



.. _box_ctl-on_shutdown:


The ``box.ctl`` submodule also contains one function for :ref:`trigger <triggers>` definition: ``on_shutdown``.

.. function:: on_shutdown(trigger-function [, old-trigger-function])

     Create a "shutdown :ref:`trigger <triggers>`".
     The ``trigger-function`` will be executed
     whenever   :ref:`os.exit() <os-exit>` happens, or when the server is
     shut down after receiving a SIGTERM or SIGINT or SIGHUP signal
     (but not after SIGSEGV or SIGABORT or any signal that causes
     immediate program termination).
        
     :param function     trigger-function: function which will become the
                                           trigger function
     :param function old-trigger-function: existing trigger function which
                                           will be replaced by
                                           trigger-function
     :return: nil or function pointer

     If the parameters are (nil, old-trigger-function), then the old
     trigger is deleted.

     Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.





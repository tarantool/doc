.. _box_ctl:

-------------------------------------------------------------------------------
                                Submodule `box.ctl`
-------------------------------------------------------------------------------

.. module:: box.ctl

The ``box.ctl`` submodule contains two functions: ``wait_ro``
(wait until read-only)
and ``wait_rw`` (wait until read-write).
The functions are useful during initialization of a server.

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
    :return: nil, or error may be thrown due to timeout or fiber cancellation

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
    :return: nil, or error may be thrown due to timeout or fiber cancellation


    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.ctl.wait_rw(0.1)
        ---
        ...

.. _box_ctl-on_shutdown:

The ``box.ctl`` submodule also contains two functions for the two
:ref:`server trigger <triggers>` definitions: ``on_shutdown`` and ``on_schema_init``.
Please, learn the mechanism of trigger functions before using them.

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

.. _box_ctl-on_schema_init:

.. function:: on_schema_init(trigger-function [, old-trigger-function])

    Create a "schema_init :ref:`trigger <triggers>`".
    The ``trigger-function`` will be executed
    when :ref:`box.cfg{} <index-book_cfg>` happens for the first time.
    That is, the ``schema_init`` trigger is called before the server's
    configuration and recovery begins, and therefore ``box.ctl.on_schema_init``
    must be called before ``box.cfg`` is called.

    :param function     trigger-function: function which will become the
                                           trigger function
    :param function old-trigger-function: existing trigger function which
                                          will be replaced by
                                          trigger-function
    :return: nil or function pointer

    If the parameters are (nil, old-trigger-function), then the old
    trigger is deleted.

    A common use is: make a ``schema_init`` trigger function which creates
    a ``before_replace`` trigger function on a system space. Thus, since
    system spaces are created when the server starts, the ``before_replace``
    triggers will be activated for each tuple in each system space.
    For example, such a trigger could change the storage engine of a
    given space, or make a given space replica-local while a replica
    is being bootstrapped. Making such a change after ``box.cfg`` is
    not reliable because other connections might use the database before
    the change can be made.

    Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

    **Example:**

    Suppose that, before the server is fully up and ready
    for connections, you want to make sure that the engine of
    space ``space_name`` is vinyl. So you want to make a trigger
    that will be activated when a tuple is inserted in the
    ``_space`` system space. In this case you could end up with
    a master that has space-name with ``engine='memtx'`` and a
    replica that has space_name with ``engine='vinyl'``, with
    the same contents.

    .. code-block:: lua

        function function_for_before_replace(old, new)
          if new[3] == 'space_name' and new[4] ~= 'vinyl' then
            return new:update{{'=', 4, 'vinyl'}}
          end
        end

        box.ctl.on_schema_init(function()
          box.space._space:before_replace(function_for_before_replace)
        end)

        box.cfg{replication='master_uri', ...}

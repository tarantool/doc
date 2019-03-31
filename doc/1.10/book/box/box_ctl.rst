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



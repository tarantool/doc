.. _ctl-wait_rw:

===============================================================================
box.ctl.wait_rw()
===============================================================================

.. module:: box.ctl

.. function:: wait_rw([timeout])

    Wait until ``box.info.ro`` is false.

    :param number timeout: maximum number of seconds to wait
    :return: nil, or error may be thrown due to timeout or fiber cancellation


    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.ctl.wait_rw(0.1)
        ---
        ...
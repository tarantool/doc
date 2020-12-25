.. _ctl-wait_ro:

===============================================================================
box.ctl.wait_ro()
===============================================================================

.. module:: box.ctl

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

box.stat.net()
==============================

.. module:: box.stat

.. function:: net()

    Shows network activity: the number of bytes sent
    and received, the number of connections, and the number of active requests
    (current, average, and total).

    :return: in the tables that ``box.stat.net()`` returns:

        * ``SENT.rps`` and ``RECEIVED.rps`` -- average number of bytes sent/received per
          second in the last 5 seconds
        * ``SENT.total`` and ``RECEIVED.total`` -- total number of bytes sent/received
          since the server started
        * ``CONNECTIONS.rps`` -- number of connections opened per second in the last 5 seconds
        * ``CONNECTIONS.total`` -- total number of connections opened since the server started
        * ``REQUESTS.current`` -- number of requests in progress, which can be
          limited by :ref:`box.cfg.net_msg_max <cfg_networking-net_msg_max>`
        * ``REQUESTS.rps`` -- number of requests processed per second in the last 5 seconds
        * ``REQUESTS.total`` -- total number of requests processed since startup

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.stat.net() -- 4 tables
        ---
        - SENT:
            total: 0
            rps: 0
          CONNECTIONS:
            current: 0
            rps: 0
            total: 0
          REQUESTS:
            current: 0
            rps: 0
            total: 0
          RECEIVED:
            total: 0
            rps: 0
        ...
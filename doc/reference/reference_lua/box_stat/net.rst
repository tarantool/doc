box.stat.net()
==============

.. module:: box.stat

.. function:: net()

    Shows network activity: the number of bytes sent
    and received, the number of connections, streams, and requests
    (current, average, and total).

    :return: in the tables that ``box.stat.net()`` returns:

        * ``SENT.rps`` and ``RECEIVED.rps`` -- average number of bytes sent/received per
          second in the last 5 seconds
        * ``SENT.total`` and ``RECEIVED.total`` -- total number of bytes sent/received
          since the server started
        * ``CONNECTIONS.current`` -- number of open connections
        * ``CONNECTIONS.rps`` -- number of connections opened per second in the last 5 seconds
        * ``CONNECTIONS.total`` -- total number of connections opened since the server started
        * ``REQUESTS.current`` -- number of requests in progress, which can be
          limited by :ref:`box.cfg.net_msg_max <cfg_networking-net_msg_max>`
        * ``REQUESTS.rps`` -- number of requests processed per second in the last 5 seconds
        * ``REQUESTS.total`` -- total number of requests processed since startup
        * ``STREAMS.current`` -- number of active :doc:`streams </book/box/stream>`
        * ``STREAMS.rps`` -- number of streams opened per second in the last 5 seconds
        * ``STREAMS.total`` -- total number of streams opened since the server started

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.stat.net() -- 5 tables
        ---
        - CONNECTIONS:
            current: 0
            rps: 0
            total: 0
          REQUESTS:
            current: 0
            rps: 0
            total: 0
          SENT:
            total: 0
            rps: 0
          STREAMS:
            current: 0
            rps: 0
            total: 0
          RECEIVED:
            total: 0
            rps: 0
        ...
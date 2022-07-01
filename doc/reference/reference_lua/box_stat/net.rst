.. _box_introspection-box_stat_net:

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
        * ``CONNECTIONS.rps`` -- average number of connections opened per second in the last 5 seconds
        * ``CONNECTIONS.total`` -- total number of connections opened since the server started
        * ``REQUESTS.current`` -- number of requests in progress, which can be
          limited by :ref:`box.cfg.net_msg_max <cfg_networking-net_msg_max>`
        * ``REQUESTS.rps`` -- average number of requests processed per second in the last 5 seconds
        * ``REQUESTS.total`` -- total number of requests processed since the server started
        * ``REQUESTS_IN_PROGRESS.current`` -- number of requests being currently processed by the :ref:`TX thread <memtx-memory>`
        * ``REQUESTS_IN_PROGRESS.rps`` -- average number of requests processed by the TX thread per second in the last 5 seconds
        * ``REQUESTS_IN_PROGRESS.total`` -- total number of requests processed by the TX thread since the server started
        * ``STREAMS.current`` -- number of active :ref:`streams <txn_mode_stream-interactive-transactions>`
        * ``STREAMS.rps`` -- average number of streams opened per second in the last 5 seconds
        * ``STREAMS.total`` -- total number of streams opened since the server started
        * ``REQUESTS_IN_STREAM_QUEUE.current`` -- number of requests waiting in stream queues
        * ``REQUESTS_IN_STREAM_QUEUE.rps`` -- average number of requests in stream queues per second in the last 5 seconds
        * ``REQUESTS_IN_STREAM_QUEUE.total`` -- total number of requests placed in stream queues since the server started


    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.stat.net() -- 5 tables
        ---
        - CONNECTIONS:
            current: 1
            rps: 0
            total: 1
          REQUESTS:
            current: 0
            rps: 0
            total: 8
          REQUESTS_IN_PROGRESS:
            current: 0
            rps: 0
            total: 7
          SENT:
            total: 19579
            rps: 0
          REQUESTS_IN_STREAM_QUEUE:
            current: 0
            rps: 0
            total: 0
          STREAMS:
            current: 0
            rps: 0
            total: 0
          RECEIVED:
            total: 197
            rps
        ...


.. module:: box.stat

.. function:: net.thread()

    Shows network activity per :ref:`network thread <thread_model>`:
    the number of bytes sent and received, the number of connections, streams,
    and requests (current, average, and total).

    When called with an index (``box.stat.net.thread[1]``), shows network statistics for
    a single network thread.

    :return: Same network activity metrics as :ref:`box.stat.net() <box_introspection-box_stat_net>`
        for each network thread

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> box.stat.net.thread() -- iproto_threads = 2
        - - CONNECTIONS:
              current: 0
              rps: 0
              total: 0
            REQUESTS:
              current: 0
              rps: 0
              total: 0
            REQUESTS_IN_PROGRESS:
              current: 0
              rps: 0
              total: 0
            SENT:
              total: 0
              rps: 0
            REQUESTS_IN_STREAM_QUEUE:
              current: 0
              rps: 0
              total: 0
            STREAMS:
              current: 0
              rps: 0
              total: 0
            RECEIVED:
              total: 0
              rps: 0
          - CONNECTIONS:
              current: 1
              rps: 0
              total: 1
            REQUESTS:
              current: 0
              rps: 0
              total: 8
            REQUESTS_IN_PROGRESS:
              current: 0
              rps: 0
              total: 7
            SENT:
              total: 19579
              rps: 0
            REQUESTS_IN_STREAM_QUEUE:
              current: 0
              rps: 0
              total: 0
            STREAMS:
              current: 0
              rps: 0
              total: 0
            RECEIVED:
              total: 197
              rps: 0
        ...

    ..  code-block:: tarantoolsession

        tarantool> box.stat.net.thread[1] -- first network thread
        - - CONNECTIONS:
              current: 1
              rps: 0
              total: 1
            REQUESTS:
              current: 0
              rps: 0
              total: 8
            REQUESTS_IN_PROGRESS:
              current: 0
              rps: 0
              total: 7
            SENT:
              total: 19579
              rps: 0
            REQUESTS_IN_STREAM_QUEUE:
              current: 0
              rps: 0
              total: 0
            STREAMS:
              current: 0
              rps: 0
              total: 0
            RECEIVED:
              total: 197
              rps: 0
        ...

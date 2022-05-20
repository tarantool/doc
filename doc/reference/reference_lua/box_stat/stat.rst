==============================
box.stat()
==============================

..  function:: box.stat()

    Shows the total number of requests since startup and
    the average number of requests per second,
    broken down by request type.

    :return:    in the tables that ``box.stat()`` returns:

                * ``total``: total number of requests processed per second since the server started
                * ``rps``: average number of requests per second in the last 5 seconds.

    ``ERROR`` is the count of requests that resulted in an error.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> box.stat() -- return 11 tables
        ---
        - DELETE:
            total: 1873949
            rps: 123
          SELECT:
            total: 1237723
            rps: 4099
          INSERT:
            total: 0
            rps: 0
          EVAL:
            total: 0
            rps: 0
          CALL:
            total: 0
            rps: 0
          REPLACE:
            total: 1239123
            rps: 7849
          UPSERT:
            total: 0
            rps: 0
          AUTH:
            total: 0
            rps: 0
          ERROR:
            total: 0
            rps: 0
          EXECUTE:
            total: 0
            rps: 0
          UPDATE:
            total: 0
            rps: 0
        ...

        tarantool> box.stat().DELETE -- total + requests per second from one table
        ---
        - total: 0
          rps: 0
        ...
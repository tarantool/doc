box.stat()
==========

..  module:: box

..  function:: stat()

    Shows the total number of requests since startup and
    the average number of requests per second,
    broken down by request type.

    :return: in the tables that ``box.stat()`` returns:

        * ``total``: total number of requests processed per second since the server started
        * ``rps``: average number of requests per second in the last 5 seconds.

        ``ERROR`` is the count of requests that resulted in an error.

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> box.stat() -- return 15 tables
        ---
        - DELETE:
            total: 0
            rps: 0
          COMMIT:
            total: 0
            rps: 0
          SELECT:
            total: 12
            rps: 0
          ROLLBACK:
            total: 0
            rps: 0
          INSERT:
            total: 6
            rps: 0
          EVAL:
            total: 0
            rps: 0
          ERROR:
            total: 0
            rps: 0
          CALL:
            total: 0
            rps: 0
          BEGIN:
            total: 0
            rps: 0
          PREPARE:
            total: 0
            rps: 0
          REPLACE:
            total: 0
            rps: 0
          UPSERT:
            total: 0
            rps: 0
          AUTH:
            total: 0
            rps: 0
          EXECUTE:
            total: 0
            rps: 0
          UPDATE:
            total: 2
            rps: 0
        ...

        tarantool> box.stat().DELETE -- total + requests per second from one table
        ---
        - total: 0
          rps: 0
        ...
* :ref:`io_collect_interval <cfg_networking-io_collect_interval>`,
* :ref:`readahead <cfg_networking-readahead>`

.. _cfg_networking-io_collect_interval:

.. confval:: io_collect_interval

    The instance will sleep for io_collect_interval seconds between iterations
    of the event loop. Can be used to reduce CPU load in deployments in which
    the number of client connections is large, but requests are not so frequent
    (for example, each connection issues just a handful of requests per second).

    | Type: float
    | Default: null
    | Dynamic: **yes**

.. _cfg_networking-readahead:

.. confval:: readahead

    The size of the read-ahead buffer associated with a client connection. The
    larger the buffer, the more memory an active connection consumes and the
    more requests can be read from the operating system buffer in a single
    system call. The rule of thumb is to make sure the buffer can contain at
    least a few dozen requests. Therefore, if a typical tuple in a request is
    large, e.g. a few kilobytes or even megabytes, the read-ahead buffer size
    should be increased. If batched request processing is not used, it’s prudent
    to leave this setting at its default.

    | Type: integer
    | Default: 16320
    | Dynamic: **yes**

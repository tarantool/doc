.. _cfg_flight_recorder:

..  admonition:: Enterprise Edition
    :class: fact

    The flight recorder is available in the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

* :ref:`flightrec_enabled <cfg_flightrec_enabled>`
* :ref:`flightrec_logs_size <cfg_flightrec_logs_size>`
* :ref:`flightrec_logs_max_msg_size <cfg_flightrec_logs_max_msg_size>`
* :ref:`flightrec_logs_log_level <cfg_flightrec_logs_log_level>`
* :ref:`flightrec_metrics_period <cfg_flightrec_metrics_period>`
* :ref:`flightrec_metrics_interval <cfg_flightrec_metrics_interval>`
* :ref:`flightrec_requests_size <cfg_flightrec_requests_size>`
* :ref:`flightrec_requests_max_req_size <cfg_flightrec_requests_max_req_size>`
* :ref:`flightrec_requests_max_res_size <cfg_flightrec_requests_max_res_size>`


.. _cfg_flightrec_enabled:

.. confval:: flightrec_enabled

    Since :doc:`2.11.0 </release/2.11.0>`.

    Enable the :ref:`flight recorder <enterprise-flight-recorder>`.

    | Type: boolean
    | Default: false
    | Environment variable: TT_FLIGHTREC_ENABLED
    | Dynamic: yes


.. _cfg_flightrec_logs_size:

.. confval:: flightrec_logs_size

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the size (in bytes) of the log storage.
    You can set this option to ``0`` to disable the log storage.

    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_LOGS_SIZE


.. _cfg_flightrec_logs_max_msg_size:

.. confval:: flightrec_logs_max_msg_size

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the maximum size (in bytes) of the log message.
    The log message is truncated if its size exceeds this limit.

    | Type: integer
    | Default: 4096
    | Maximum: 16384
    | Environment variable: TT_FLIGHTREC_LOGS_MAX_MSG_SIZE


.. _cfg_flightrec_logs_log_level:

.. confval:: flightrec_logs_log_level

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the level of detail the log has.
    You can learn more about log levels from the :ref:`log_level <cfg_logging-log_level>`
    option description.
    Note that the ``flightrec_logs_log_level`` value might differ from ``log_level``.

    | Type: integer
    | Default: 6
    | Environment variable: TT_FLIGHTREC_LOGS_LOG_LEVEL


.. _cfg_flightrec_metrics_period:

.. confval:: flightrec_metrics_period

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the time period (in seconds) that defines how long metrics are stored from the moment of dump.
    So, this value defines how much historical metrics data is collected up to the moment of crash.
    The frequency of metric dumps is defined by :ref:`flightrec_metrics_interval <cfg_flightrec_metrics_interval>`.

    | Type: integer
    | Default: 180
    | Environment variable: TT_FLIGHTREC_METRICS_PERIOD


.. _cfg_flightrec_metrics_interval:

.. confval:: flightrec_metrics_interval

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the time interval (in seconds) that defines the frequency of dumping metrics.
    This value shouldn't exceed :ref:`flightrec_metrics_period <cfg_flightrec_metrics_period>`.

    .. NOTE::

        Given that the average size of a metrics entry is 2 kB,
        you can estimate the size of the metrics storage as follows:

        .. code-block:: console

            (flightrec_metrics_period / flightrec_metrics_interval) * 2 kB

    | Type: number
    | Default: 1.0
    | Minimum: 0.001
    | Environment variable: TT_FLIGHTREC_METRICS_INTERVAL


.. _cfg_flightrec_requests_size:

.. confval:: flightrec_requests_size

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the size (in bytes) of storage for the request and response data.
    You can set this parameter to ``0`` to disable a storage of requests and responses.

    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_REQUESTS_SIZE



.. _cfg_flightrec_requests_max_req_size:

.. confval:: flightrec_requests_max_req_size

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the maximum size (in bytes) of a request entry.
    A request entry is truncated if this size is exceeded.

    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_REQ_SIZE


.. _cfg_flightrec_requests_max_res_size:

.. confval:: flightrec_requests_max_res_size

    Since :doc:`2.11.0 </release/2.11.0>`.

    Specifies the maximum size (in bytes) of a response entry.
    A response entry is truncated if this size is exceeded.

    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_RES_SIZE

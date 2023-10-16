.. _enterprise-flight-recorder:

Flight recorder
===============

The flight recorder available in the Enterprise Edition is an event collection tool that
gathers various information about a working Tarantool instance, such as:

*   logs

*   metrics

*   requests and responses

This information helps you investigate incidents related
to :ref:`crashing <admin-disaster_recovery>` a Tarantool instance.


.. _enable:

Enabling the flight recorder
----------------------------

The flight recorder is disabled by default and can be enabled and configured for
a specific Tarantool instance.
To enable the flight recorder, set the ``flightrec_enabled``
:doc:`configuration option </reference/configuration/index>` to ``true``.
This option is :ref:`dynamic <box_cfg_params>` and can be changed at runtime by calling ``box.cfg{}``:

.. code-block:: lua

    box.cfg{ flightrec_enabled = true }

After ``flightrec_enabled`` is set to ``true``, the flight recorder starts collecting data in the flight recording file  ``current.ttfr``.
This file is stored in the :ref:`memtx_dir <cfg_basic-memtx_dir>` directory.
If the instance crashes and reboots, Tarantool rotates the flight recording:
``current.ttfr`` is renamed to ``<timestamp>.ttfr`` (for example, ``20230411T050721.ttfr``)
and the new ``current.ttfr`` file is created for collecting data.
In the case of correct shutdown (for example, using ``os.exit()``),
Tarantool continues writing to the existing ``current.ttfr`` file after restart.

.. NOTE::

    Note that old flight recordings should be removed manually.



.. _config:

Configuration
-------------

This section describes options related to the flight recorder configuration.
Note that all options are :ref:`dynamic <box_cfg_params>` and can be changed at runtime.

.. TODO not implemented yet
    .. _config-directory:

    Flight recording directory
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

    .. _cfg_flightrec_dir:

    .. confval:: flightrec_dir

        Specifies the directory used to store flight recordings (``*.ttfr`` files).

        | Type: string
        | Default: :ref:`memtx_dir <cfg_basic-memtx_dir>`
        | Environment variable: TT_FLIGHTREC_DIR



.. _config-logs:

Logs
~~~~

This section describes the flight recorder settings related to :ref:`logging <cfg_logging-log>`.
For example, you can configure a more detailed logging level in the flight recorder for deeper analysis.

* :ref:`flightrec_logs_size <cfg_flightrec_logs_size>`
* :ref:`flightrec_logs_max_msg_size <cfg_flightrec_logs_max_msg_size>`
* :ref:`flightrec_logs_log_level <cfg_flightrec_logs_log_level>`

.. _cfg_flightrec_logs_size:

.. confval:: flightrec_logs_size

    Specifies the size (in bytes) of the log storage.
    You can set this option to ``0`` to disable the log storage.

    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_LOGS_SIZE


.. _cfg_flightrec_logs_max_msg_size:

.. confval:: flightrec_logs_max_msg_size

    Specifies the maximum size (in bytes) of the log message.
    The log message is truncated if its size exceeds this limit.

    | Type: integer
    | Default: 4096
    | Maximum: 16384
    | Environment variable: TT_FLIGHTREC_LOGS_MAX_MSG_SIZE


.. _cfg_flightrec_logs_log_level:

.. confval:: flightrec_logs_log_level

    Specifies the level of detail the log has.
    You can learn more about log levels from the :ref:`log_level <cfg_logging-log_level>`
    option description.
    Note that the ``flightrec_logs_log_level`` value might differ from ``log_level``.

    | Type: integer
    | Default: 6
    | Environment variable: TT_FLIGHTREC_LOGS_LOG_LEVEL


.. _config-metrics:

Metrics
~~~~~~~

This section describes the flight recorder settings related to collecting
:ref:`metrics <metrics-reference>`.

* :ref:`flightrec_metrics_period <cfg_flightrec_metrics_period>`
* :ref:`flightrec_metrics_interval <cfg_flightrec_metrics_interval>`

.. _cfg_flightrec_metrics_period:

.. confval:: flightrec_metrics_period

    Specifies the time period (in seconds) that defines how long metrics are stored from the moment of dump.
    So, this value defines how much historical metrics data is collected up to the moment of crash.
    The frequency of metric dumps is defined by :ref:`flightrec_metrics_interval <cfg_flightrec_metrics_interval>`.

    | Type: integer
    | Default: 180
    | Environment variable: TT_FLIGHTREC_METRICS_PERIOD


.. _cfg_flightrec_metrics_interval:

.. confval:: flightrec_metrics_interval

    Specifies the time interval (in seconds) that defines the frequency of dumping metrics.
    This value shouldn't exceed :ref:`flightrec_metrics_period <cfg_flightrec_metrics_period>`.

    | Type: number
    | Default: 1.0
    | Minimum: 0.001
    | Environment variable: TT_FLIGHTREC_METRICS_INTERVAL

.. NOTE::

    Given that the average size of a metrics entry is 2 kB,
    you can estimate the size of the metrics storage as follows:

    .. code-block:: console

        (flightrec_metrics_period / flightrec_metrics_interval) * 2 kB



.. _config-requests:

Requests
~~~~~~~~

This section lists the flight recorder settings related to
storing the :ref:`request and response <internals-requests_responses>` data.

* :ref:`flightrec_requests_size <cfg_flightrec_requests_size>`
* :ref:`flightrec_requests_max_req_size <cfg_flightrec_requests_max_req_size>`
* :ref:`flightrec_requests_max_res_size <cfg_flightrec_requests_max_res_size>`

.. _cfg_flightrec_requests_size:

.. confval:: flightrec_requests_size

    Specifies the size (in bytes) of storage for the request and response data.
    You can set this parameter to ``0`` to disable a storage of requests and responses.

    | Type: integer
    | Default: 10485760
    | Environment variable: TT_FLIGHTREC_REQUESTS_SIZE



.. _cfg_flightrec_requests_max_req_size:

.. confval:: flightrec_requests_max_req_size

    Specifies the maximum size (in bytes) of a request entry.
    A request entry is truncated if this size is exceeded.

    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_REQ_SIZE


.. _cfg_flightrec_requests_max_res_size:

.. confval:: flightrec_requests_max_res_size

    Specifies the maximum size (in bytes) of a response entry.
    A response entry is truncated if this size is exceeded.

    | Type: integer
    | Default: 16384
    | Environment variable: TT_FLIGHTREC_REQUESTS_MAX_RES_SIZE

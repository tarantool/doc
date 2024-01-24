..  _enterprise-flight-recorder:

Flight recorder
===============

**Example on GitHub**: `flightrec <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/flightrec>`_

The flight recorder available in the Enterprise Edition is an event collection tool that
gathers various information about a working Tarantool instance, such as:

*   logs
*   metrics
*   requests and responses

This information helps you investigate incidents related
to :ref:`crashing <admin-disaster_recovery>` a Tarantool instance.

.. _enterprise-flight-recorder_enable:

Enabling the flight recorder
----------------------------

The flight recorder is disabled by default and can be enabled and configured for
a specific Tarantool instance.
To enable the flight recorder, set the :ref:`flightrec.enabled <configuration_reference_flightrec_enabled>`
configuration option to ``true``.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/flightrec/config.yaml
    :language: yaml
    :start-at: flightrec:
    :end-at: enabled: true
    :dedent:


After ``flightrec_enabled`` is set to ``true``, the flight recorder starts collecting data in the flight recording file  ``current.ttfr``.
This file is stored in the ``snapshot.dir`` directory.
By default, the directory is ``var/lib/{{ instance_name }}/<file_name>.ttfr``.

If the instance crashes and reboots, Tarantool rotates the flight recording:
``current.ttfr`` is renamed to ``<timestamp>.ttfr`` (for example, ``20230411T050721.ttfr``)
and the new ``current.ttfr`` file is created for collecting data.
In the case of correct shutdown (for example, using ``os.exit()``),
Tarantool continues writing to the existing ``current.ttfr`` file after restart.

..  NOTE::

    Note that old flight recordings should be removed manually.


.. _enterprise-flight-recorder_configure:

Configuring a flight recorder
-----------------------------

When the flight recorder is enabled, you can set the options related to :ref:`logging <cfg_logging-log>`,
:ref:`metrics <metrics-reference>`, and storing the :ref:`request and response <internals-requests_responses>` data.

The ``flightrec`` configuration might look as follows:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/flightrec/config.yaml
    :language: yaml
    :start-at: flightrec:
    :end-at: 10485780
    :dedent:

In the example, the following options are set:

*   :ref:`flightrec.logs_size <configuration_reference_flightrec_logs_size>` -- a log storage size in bytes.
*   :ref:`flightrec.logs_log_level <configuration_reference_flightrec_logs_log_level>` -- a :ref:`log_level <cfg_logging-log_level>`.
*   :ref:`flightrec.metrics_period <configuration_reference_flightrec_metrics_period>` -- the number of seconds to store metrics after the dump.
*   :ref:`flightrec.metrics_interval <configuration_reference_flightrec_metrics_interval>` -- the frequency of metrics dumps in seconds.
*   :ref:`flightrec.requests_size <configuration_reference_flightrec_requests_size>` -- a storage size for the request and response data in bytes.

Read more: :ref:`Flight recorder configuration options <configuration_reference_flightrec>`.

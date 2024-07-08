..  _metrics-api_reference:

Module metrics
==============

**Since:** `2.11.1 <https://github.com/tarantool/tarantool/releases/tag/2.11.1>`__

The ``metrics`` module provides the ability to collect and expose :ref:`Tarantool metrics <monitoring>`.

..  NOTE::

    If you use a Tarantool version below `2.11.1 <https://github.com/tarantool/tarantool/releases/tag/2.11.1>`__,
    it is necessary to install the latest version of `metrics <https://github.com/tarantool/metrics>`__ first.
    For Tarantool 2.11.1 and above, you can also use the external ``metrics`` module.
    In this case, the external ``metrics`` module takes priority over the built-in one.


..  _metrics-api_reference_overview:

Overview
--------

.. _metrics-api_reference-collectors:

Collectors
~~~~~~~~~~

Tarantool provides the following metric collectors:

..  contents::
    :local:
    :depth: 1

A collector is a representation of one or more observations that change over time.


..  _metrics-api_reference-counter:

counter
*******

A counter is a cumulative metric that denotes a single monotonically increasing counter. Its value might only
increase or be reset to zero on restart. For example, you can use the counter to represent the number of requests
served, tasks completed, or errors.

The design is based on the `Prometheus counter <https://prometheus.io/docs/concepts/metric_types/#counter>`__.


.. _metrics-api_reference-gauge:

gauge
*****

A gauge is a metric that denotes a single numerical value that can arbitrarily increase and decrease.

The gauge type is typically used for measured values like temperature or current memory usage.
It could also be used for values that can increase or decrease, such as the number of concurrent requests.

The design is based on the `Prometheus gauge <https://prometheus.io/docs/concepts/metric_types/#gauge>`__.




..  _metrics-api_reference-histogram:

histogram
*********

A histogram metric is used to collect and analyze
statistical data about the distribution of values within the application.
Unlike metrics that track the average value or quantity of events, a histogram provides detailed visibility into the distribution of values and can uncover hidden dependencies.

The design is based on the `Prometheus histogram <https://prometheus.io/docs/concepts/metric_types/#histogram>`__.



..  _metrics-api_reference-summary:

summary
*******

A summary metric is used to collect statistical data
about the distribution of values within the application.

Each summary provides several measurements:

*   total count of measurements
*   sum of measured values
*   values at specific quantiles

Similar to histograms, the summary also operates with value ranges. However, unlike histograms,
it uses quantiles (defined by a number between 0 and 1) for this purpose. In this case,
it is not required to define fixed boundaries. For summary type, the ranges depend
on the measured values and the number of measurements.

The design is based on the `Prometheus summary <https://prometheus.io/docs/concepts/metric_types/#summary>`__.



..  _metrics-api_reference-labels:

Labels
~~~~~~

A label is a piece of metainfo that you associate with a metric in the key-value format.
For details, see `labels in Prometheus <https://prometheus.io/docs/practices/naming/#labels>`_ and `tags in Graphite <https://graphite.readthedocs.io/en/latest/tags.html>`_.

Labels are used to differentiate between the characteristics of a thing being
measured. For example, in a metric associated with the total number of HTTP
requests, you can represent methods and statuses as label pairs:

..  code-block:: lua

    http_requests_total_counter:inc(1, { method = 'POST', status = '200' })

The example above allows extracting the following time series:

#.  The total number of requests over time with ``method = "POST"`` (and any status).
#.  The total number of requests over time with ``status = 500`` (and any method).



..  _metrics-api_reference_configuring:

Configuring metrics
-------------------

To configure metrics, use :ref:`metrics.cfg() <metrics_cfg>`.
This function can be used to turn on or off the specified metrics or to configure labels applied to all collectors.
Moreover, you can use the following shortcut functions to set-up metrics or labels:

-   :ref:`metrics.enable_default_metrics() <metrics_enable_default_metrics>`
-   :ref:`metrics.set_global_labels() <metrics_set_global_labels>`

..  NOTE::

    Starting from version 3.0, metrics can be configured using a :ref:`configuration file <configuration_file>` in the :ref:`metrics <configuration_reference_metrics>` section.



..  _metrics-api_reference_custom_metrics:

Custom metrics
--------------

..  _metrics-api_reference_create_custom_metrics:

Creating custom metrics
~~~~~~~~~~~~~~~~~~~~~~~

To create a custom metric, follow the steps below:

1.  **Create a metric**

    To create a new metric, you need to call a function corresponding to the desired :ref:`collector type <metrics-api_reference-collectors>`. For example, call :ref:`metrics.counter() <metrics_counter>` or :ref:`metrics.gauge() <metrics_gauge>` to create a new counter or gauge, respectively.
    In the example below, a new counter is created:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_custom/examples/collect_custom_replace_count.lua
        :start-at: local metrics
        :end-at: local bands_replace_count
        :language: lua
        :dedent:

    This counter is intended to collect the number of data operations performed on the specified space.

    In the next example, a gauge is created:

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_custom/examples/collect_custom_waste_size.lua
        :start-at: local metrics
        :end-at: local bands_waste_size
        :language: lua
        :dedent:

2.  **Take a measurement**

    You can take a measurement in two ways:

    -   At the appropriate place, for example, in an API request handler or :ref:`trigger <triggers>`.
        In this example below, the counter value is increased any time a data operation is performed on the ``bands`` space.
        To increase a counter value, :ref:`counter_obj:inc() <metrics-api_reference-counter_inc>` is called.

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_custom/examples/collect_custom_replace_count.lua
            :start-after: -- Collect a custom metric
            :end-before: -- End
            :language: lua
            :dedent:

    -   At the time of requesting the data collected by metrics.
        In this case, you need to collect the required metric inside :ref:`metrics.register_callback() <metrics_register_callback>`.
        The example below shows how to use a gauge collector to measure the size of memory wasted due to internal fragmentation:

        ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_custom/examples/collect_custom_waste_size.lua
            :start-after: -- Collect a custom metric
            :end-before: -- End
            :language: lua
            :dedent:

        To set a gauge value, :ref:`gauge_obj:set() <metrics_gauge_obj_set>` is called.

You can find the full example on GitHub: `metrics_collect_custom <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/metrics_collect_custom>`_.




..  _monitoring-getting_started-warning:

Possible limitations
~~~~~~~~~~~~~~~~~~~~

The module allows to add your own metrics, but there are some subtleties when working with specific tools.

When adding your custom metric, it's important to ensure that the number of label value combinations is kept to a minimum.
Otherwise, combinatorial explosion may happen in the timeseries database with metrics values stored.
Examples of data labels:

*   `Labels <https://prometheus.io/docs/concepts/data_model/#metric-names-and-labels>`__ in Prometheus
*   `Tags <https://docs.influxdata.com/influxdb/v1/concepts/glossary/#tag>`__ in InfluxDB

For example, if your company uses InfluxDB for metric collection, you can potentially disrupt the entire
monitoring setup, both for your application and for all other systems within the company. As a result,
monitoring data is likely to be lost.

Example:

..  code-block:: lua

    local some_metric = metrics.counter('some', 'Some metric')

    -- THIS IS POSSIBLE
    local function on_value_update(instance_alias)
       some_metric:inc(1, { alias = instance_alias })
    end

    -- THIS IS NOT ALLOWED
    local function on_value_update(customer_id)
       some_metric:inc(1, { customer_id = customer_id })
    end

In the example, there are two versions of the function ``on_value_update``. The top version labels
the data with the cluster instance's alias. Since there's a relatively small number of nodes, using
them as labels is feasible. In the second case, an identifier of a record is used. If there are many
records, it's recommended to avoid such situations.

The same principle applies to URLs. Using the entire URL with parameters is not recommended.
Use a URL template or the name of the command instead.

In essence, when designing custom metrics and selecting labels or tags, it's crucial to opt for a minimal
set of values that can uniquely identify the data without introducing unnecessary complexity or potential
conflicts with existing metrics and systems.



..  _metrics-api_reference-collecting_http_statistics:

Collecting HTTP metrics
-----------------------

The ``metrics`` module provides middleware for monitoring HTTP latency statistics for endpoints that are created using the `http <https://github.com/tarantool/http>`_ module.
The latency collector observes both latency information and the number of invocations.
The metrics collected by HTTP middleware are separated by a set of :ref:`labels <metrics-api_reference-labels>`:

*   a route (``path``)
*   a method (``method``)
*   an HTTP status code (``status``)

For each route that you want to track, you must specify the middleware explicitly.
The example below shows how to collect statistics for requests made to the ``/metrics/hello`` endpoint.

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_http/collect_http_metrics.lua
    :start-after: Collect HTTP metrics
    :end-at: httpd:start()
    :language: lua
    :dedent:

..  NOTE::

    The middleware does not cover the 404 errors.


..  _metrics-plugins-available:
..  _metrics-api_reference_collecting_using_plugins:

Collecting metrics using plugins
--------------------------------

The ``metrics`` module provides a set of plugins that let you collect metrics through a unified interface:

-   :ref:`metrics-prometheus-api_reference`
-   :ref:`metrics-json-api_reference`
-   :ref:`metrics-graphite-api_reference`


For example, you can obtain an HTTP response object containing metrics in the Prometheus format by calling the ``metrics.plugins.prometheus.collect_http()`` function:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_plugins/examples/expose_prometheus_metrics.lua
    :start-at: local prometheus_plugin
    :end-at: local prometheus_metrics
    :language: lua
    :dedent:

To expose the collected metrics, you can use the `http <https://github.com/tarantool/http>`_ module:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_plugins/examples/expose_prometheus_metrics.lua
    :start-after: Expose Prometheus metrics
    :end-at: httpd:start()
    :language: lua
    :dedent:

Example on GitHub: `metrics_plugins <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/metrics_plugins>`_




..  _metrics-plugins-plugin-specific_api:
..  _metrics-plugins-custom:

Creating custom plugins
~~~~~~~~~~~~~~~~~~~~~~~

Use the following API to create custom plugins:

-   :ref:`metrics.invoke_callbacks() <metrics_invoke_callbacks>`
-   :ref:`metrics.collectors() <metrics_collectors>`
-   :ref:`collector_object <metrics_collector_object>`

To create a plugin, you need to include the following in your main export function:

..  code-block:: lua

    -- Invoke all callbacks registered via `metrics.register_callback(<callback-function>)`
    metrics.invoke_callbacks()

    -- Loop over collectors
    for _, c in pairs(metrics.collectors()) do
        ...

        -- Loop over instant observations in the collector
        for _, obs in pairs(c:collect()) do
            -- Export observation `obs`
            ...
        end
    end

See the source code of built-in plugins in the `metrics GitHub repository <https://github.com/tarantool/metrics/tree/master/metrics/plugins>`_.





.. _metrics-module-api-reference:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 50 50

        *   -   **metrics API**
            -

        *   -   :ref:`metrics.cfg() <metrics_cfg>`
            -   Entrypoint to setup the module

        *   -   :ref:`metrics.collect() <metrics_collect>`
            -   Collect observations from each collector

        *   -   :ref:`metrics.collectors() <metrics_collectors>`
            -   List all collectors in the registry

        *   -   :ref:`metrics.counter() <metrics_counter>`
            -   Register a new counter

        *   -   :ref:`metrics.enable_default_metrics() <metrics_enable_default_metrics>`
            -   Same as ``metrics.cfg{ include = include, exclude = exclude }``

        *   -   :ref:`metrics.gauge() <metrics_gauge>`
            -   Register a new gauge

        *   -   :ref:`metrics.histogram() <metrics_histogram>`
            -   Register a new histogram

        *   -   :ref:`metrics.invoke_callbacks() <metrics_invoke_callbacks>`
            -   Invoke all registered callbacks

        *   -   :ref:`metrics.register_callback() <metrics_register_callback>`
            -   Register a function named ``callback``

        *   -   :ref:`metrics.set_global_labels() <metrics_set_global_labels>`
            -   Same as ``metrics.cfg{ labels = label_pairs }``

        *   -   :ref:`metrics.summary() <metrics_summary>`
            -   Register a new summary

        *   -   :ref:`metrics.unregister_callback() <metrics_unregister_callback>`
            -   Unregister a function named ``callback``

        *   -   **metrics.http_middleware API**
            -

        *   -   :ref:`metrics.http_middleware.build_default_collector() <metrics_http_middleware_build_default_collector>`
            -   Register and return a collector for the middleware

        *   -   :ref:`metrics.http_middleware.configure_default_collector() <metrics_http_middleware_configure_default_collector>`
            -   Register a collector for the middleware and set it as default

        *   -   :ref:`metrics.http_middleware.get_default_collector() <metrics_http_middleware_get_default_collector>`
            -   Get the default collector

        *   -   :ref:`metrics.http_middleware.set_default_collector() <metrics_http_middleware_set_default_collector>`
            -   Set the default collector

        *   -   :ref:`metrics.http_middleware.v1() <metrics_http_middleware_v1>`
            -   Latency measuring wrap-up

        *   -   **Related objects**
            -

        *   -   :ref:`collector_object <metrics_collector_object>`
            -   A collector object

        *   -   :ref:`counter_obj <metrics_counter_obj>`
            -   A counter object

        *   -   :ref:`gauge_obj <metrics_gauge_obj>`
            -   A gauge object

        *   -   :ref:`histogram_obj <metrics_histogram_obj>`
            -   A histogram object

        *   -   :ref:`registry <metrics_registry>`
            -   A metrics registry

        *   -   :ref:`summary_obj <metrics_summary_obj>`
            -   A summary object



..  _metrics-api_reference-functions:

metrics API
~~~~~~~~~~~

..  module:: metrics

..  _metrics_cfg:

..  function:: cfg([config])

    Entrypoint to setup the module.

    :param table config: module configuration options:

      * ``cfg.include`` (string/table, default ``all``): ``all`` to enable all
        supported default metrics, ``none`` to disable all default metrics,
        table with names of the default metrics to enable a specific set of metrics.
      * ``cfg.exclude`` (table, default ``{}``): a table containing the names of
        the default metrics that you want to disable. Has higher priority
        than ``cfg.include``.
      * ``cfg.labels`` (table, default ``{}``): a table containing label names as
        string keys, label values as values. See also: :ref:`metrics-api_reference-labels`.

    You can work with ``metrics.cfg`` as a table to read values, but you must call
    ``metrics.cfg{}`` as a function to update them.

    Supported default metric names (for ``cfg.include`` and ``cfg.exclude`` tables):

    *   ``all`` (metasection including all metrics)
    *   ``network``
    *   ``operations``
    *   ``system``
    *   ``replicas``
    *   ``info``
    *   ``slab``
    *   ``runtime``
    *   ``memory``
    *   ``spaces``
    *   ``fibers``
    *   ``cpu``
    *   ``vinyl``
    *   ``memtx``
    *   ``luajit``
    *   ``clock``
    *   ``event_loop``

    See :ref:`metrics reference <metrics-reference>` for details.
    All metric collectors from the collection have ``metainfo.default = true``.

    ``cfg.labels`` are the global labels to be added to every observation.

    Global labels are applied only to metric collection. They have no effect
    on how observations are stored.

    Global labels can be changed on the fly.

    ``label_pairs`` from observation objects have priority over global labels.
    If you pass ``label_pairs`` to an observation method with the same key as
    some global label, the method argument value will be used.

    Note that both label names and values in ``label_pairs`` are treated as strings.




..  _metrics_collect:

..  function:: collect([opts])

    Collect observations from each collector.

    :param table opts: table of collect options:

      * ``invoke_callbacks`` -- if ``true``, :ref:`invoke_callbacks() <metrics_invoke_callbacks>` is triggered before actual collect.
      * ``default_only`` -- if ``true``, observations contain only default metrics (``metainfo.default = true``).



..  _metrics_collectors:

..  function:: collectors()

    List all collectors in the registry. Designed to be used in exporters.

    :return: A list of created collectors (see :ref:`collector_object <metrics_collector_object>`).

    See also: :ref:`metrics-plugins-custom`



..  _metrics_counter:

..  function:: counter(name [, help, metainfo])

    Register a new counter.

    :param string name: collector name. Must be unique.
    :param string help: collector description.
    :param table metainfo: collector metainfo.
    :return: A counter object (see :ref:`counter_obj <metrics_counter_obj>`).
    :rtype: counter_obj

    See also: :ref:`metrics-api_reference_create_custom_metrics`




..  _metrics_enable_default_metrics:

..  function:: enable_default_metrics([include, exclude])

    Same as ``metrics.cfg{include=include, exclude=exclude}``, but ``include={}`` is
    treated as ``include='all'`` for backward compatibility.



..  _metrics_gauge:

..  function:: gauge(name [, help, metainfo])

    Register a new gauge.

    :param string name: collector name. Must be unique.
    :param string help: collector description.
    :param table metainfo: collector metainfo.

    :return: A gauge object (see :ref:`gauge_obj <metrics_gauge_obj>`).

    :rtype: gauge_obj

    See also: :ref:`metrics-api_reference_create_custom_metrics`



..  _metrics_histogram:

..  function:: histogram(name [, help, buckets, metainfo])

    Register a new histogram.

    :param string   name: collector name. Must be unique.
    :param string   help: collector description.
    :param table buckets: histogram buckets (an array of sorted positive numbers).
                          The infinity bucket (``INF``) is appended automatically.
                          Default: ``{.005, .01, .025, .05, .075, .1, .25, .5, .75, 1.0, 2.5, 5.0, 7.5, 10.0, INF}``.
    :param table metainfo: collector metainfo.

    :return: A histogram object (see :ref:`histogram_obj <metrics_histogram_obj>`).

    :rtype: histogram_obj

    See also: :ref:`metrics-api_reference_create_custom_metrics`

    ..  note::

        A histogram is basically a set of collectors:

        *   ``name .. "_sum"`` -- a counter holding the sum of added observations.
        *   ``name .. "_count"`` -- a counter holding the number of added observations.
        *   ``name .. "_bucket"`` -- a counter holding all bucket sizes under the label
            ``le`` (less or equal). To access a specific bucket -- ``x`` (where ``x`` is a number),
            specify the value ``x`` for the label ``le``.






..  _metrics_invoke_callbacks:

..  function:: invoke_callbacks()

    Invoke all registered callbacks. Has to be called before each :ref:`collect() <metrics_collect>`.
    You can also use ``collect{invoke_callbacks = true}`` instead.
    If you're using one of the default exporters,
    ``invoke_callbacks()`` will be called by the exporter.

    See also: :ref:`metrics-plugins-custom`


..  _metrics_register_callback:

..  function:: register_callback(callback)

    Register a function named ``callback``, which will be called right before metric
    collection on plugin export.

    :param function callback: a function that takes no parameters.

    This method is most often used for gauge metrics updates.

    **Example:**

    ..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_custom/examples/collect_custom_waste_size.lua
        :start-after: -- Collect a custom metric
        :end-before: -- End
        :language: lua
        :dedent:

    See also: :ref:`metrics-api_reference_custom_metrics`





..  _metrics_set_global_labels:

..  function:: set_global_labels(label_pairs)

    Same as ``metrics.cfg{ labels = label_pairs }``.
    Learn more in :ref:`metrics.cfg() <metrics_cfg>`.





..  _metrics_summary:

..  function:: summary(name [, help, objectives, params, metainfo])

    Register a new summary. Quantile computation is based on the
    `"Effective computation of biased quantiles over data streams" <https://ieeexplore.ieee.org/document/1410103>`_
    algorithm.

    :param string   name: collector name. Must be unique.
    :param string   help: collector description.
    :param table objectives: a list of "targeted" φ-quantiles in the ``{quantile = error, ... }`` form.
        Example: ``{[0.5]=0.01, [0.9]=0.01, [0.99]=0.01}``.
        The targeted φ-quantile is specified in the form of a φ-quantile and the tolerated
        error. For example, ``{[0.5] = 0.1}`` means that the median (= 50th
        percentile) is to be returned with a 10-percent error. Note that
        percentiles and quantiles are the same concept, except that percentiles are
        expressed as percentages. The φ-quantile must be in the interval ``[0, 1]``.
        A lower tolerated error for a φ-quantile results in higher memory and CPU
        usage during summary calculation.

    :param table params: table of the summary parameters used to configuring the sliding
        time window. This window consists of several buckets to store observations.
        New observations are added to each bucket. After a time period, the head bucket
        (from which observations are collected) is reset, and the next bucket becomes the
        new head. This way, each bucket stores observations for
        ``max_age_time * age_buckets_count`` seconds before it is reset.
        ``max_age_time`` sets the duration of each bucket's lifetime -- that is, how
        many seconds the observations are kept before they are discarded.
        ``age_buckets_count`` sets the number of buckets in the sliding time window.
        This variable determines the number of buckets used to exclude observations
        older than ``max_age_time`` from the summary. The value is
        a trade-off between resources (memory and CPU for maintaining the bucket)
        and how smooth the time window moves.
        Default value: ``{max_age_time = math.huge, age_buckets_count = 1}``.

    :param table metainfo: collector metainfo.

    :return: A summary object (see :ref:`summary_obj <metrics_summary_obj>`).

    :rtype: summary_obj

    See also: :ref:`metrics-api_reference_create_custom_metrics`

    ..  note::

        A summary represents a set of collectors:

        *   ``name .. "_sum"`` -- a counter holding the sum of added observations.
        *   ``name .. "_count"`` -- a counter holding the number of added observations.
        *   ``name`` holds all the quantiles under observation that find themselves
            under the label ``quantile`` (less or equal).
            To access bucket ``x`` (where ``x`` is a number),
            specify the value ``x`` for the label ``quantile``.



..  _metrics_unregister_callback:

..  function:: unregister_callback(callback)

    Unregister a function named ``callback`` that is called right before metric
    collection on plugin export.

    :param function callback: a function that takes no parameters.

    **Example:**

    ..  code-block:: lua

        local cpu_callback = function()
            local cpu_metrics = require('metrics.psutils.cpu')
            cpu_metrics.update()
        end

        metrics.register_callback(cpu_callback)

        -- after a while, we don't need that callback function anymore

        metrics.unregister_callback(cpu_callback)



..  _metrics-http_middleware-api_reference-functions:

metrics.http_middleware API
~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  module:: metrics.http_middleware

..  _metrics_http_middleware_build_default_collector:

..  function:: build_default_collector(type_name, name [, help])

    Register and return a collector for the middleware.

    :param string type_name: collector type: ``histogram`` or ``summary``. The default is ``histogram``.
    :param string      name: collector name. The default is ``http_server_request_latency``.
    :param string      help: collector description. The default is ``HTTP Server Request Latency``.

    :return: A collector object

    **Possible errors:**

    *   A collector with the same type and name already exists in the registry.



..  _metrics_http_middleware_configure_default_collector:

..  function:: configure_default_collector(type_name, name, help)

    Register a collector for the middleware and set it as default.

    :param string type_name: collector type: ``histogram`` or ``summary``. The default is ``histogram``.
    :param string      name: collector name. The default is ``http_server_request_latency``.
    :param string      help: collector description. The default is ``HTTP Server Request Latency``.

    **Possible errors:**

    *   A collector with the same type and name already exists in the registry.


..  _metrics_http_middleware_get_default_collector:

..  function:: get_default_collector()

    Return the default collector.
    If the default collector hasn't been set yet, register it
    (with default :ref:`http_middleware.build_default_collector() <metrics_http_middleware_build_default_collector>` parameters)
    and set it as default.

    :return: A collector object


..  _metrics_http_middleware_set_default_collector:

..  function:: set_default_collector(collector)

    Set the default collector.

    :param collector: middleware collector object



..  _metrics_http_middleware_v1:

..  function:: v1(handler, collector)

    Latency measuring wrap-up for the HTTP ver. ``1.x.x`` handler. Returns a wrapped handler.

    Learn more in :ref:`metrics-api_reference-collecting_http_statistics`.

    :param function handler: handler function.
    :param collector: middleware collector object.
                      If not set, the default collector is used
                      (like in :ref:`http_middleware.get_default_collector() <metrics_http_middleware_get_default_collector>`).

    **Usage:**

    ..  code-block:: lua

        httpd:route(route, http_middleware.v1(request_handler, collector))

    See also: :ref:`metrics-api_reference-collecting_http_statistics`





..  _metrics-module-api-reference-objects:

Related objects
~~~~~~~~~~~~~~~

..  _metrics_collector_object:

..  class:: collector_object

    A collector object.

    See also: :ref:`metrics-plugins-custom`

    ..  method:: collect()

        Collect observations from this collector.
        To collect observations from each collector, use :ref:`metrics.collectors() <metrics_collectors>`.

        ``collector_object:collect()`` is equivalent to the following code:

        ..  code-block:: lua

            for _, c in pairs(metrics.collectors()) do
                for _, obs in ipairs(c:collect()) do
                    ...  -- handle observation
                end
            end

        :return: A concatenation of ``observation`` objects across all created collectors.

            ..  code-block:: lua

                {
                    label_pairs: table,         -- `label_pairs` key-value table
                    timestamp: ctype<uint64_t>, -- current system time (in microseconds)
                    value: number,              -- current value
                    metric_name: string,        -- collector
                }

        :rtype: table



..  _metrics_counter_obj:

..  class:: counter_obj

    A counter object.

    ..  _metrics-api_reference-counter_inc:

    ..  method:: inc(num, label_pairs)

        Increment the observation for ``label_pairs``.
        If ``label_pairs`` doesn't exist, the method creates it.

        See also: :ref:`metrics-api_reference-labels`

        :param number        num: increment value.
        :param table label_pairs: table containing label names as keys,
                                  label values as values. Note that both
                                  label names and values in ``label_pairs``
                                  are treated as strings.

    ..  _metrics-api_reference-counter_collect:

    ..  method:: collect()

        :return: Array of ``observation`` objects for a given counter.

        ..  code-block:: lua

            {
                label_pairs: table,          -- `label_pairs` key-value table
                timestamp: ctype<uint64_t>,  -- current system time (in microseconds)
                value: number,               -- current value
                metric_name: string,         -- collector
            }

        :rtype: table

    ..  _metrics-api_reference-counter_remove:

    ..  method:: remove(label_pairs)

        Remove the observation for :ref:`label_pairs <metrics-api_reference-labels>`.

    ..  _metrics-api_reference-counter_reset:

    ..  method:: reset(label_pairs)

        Set the observation for :ref:`label_pairs <metrics-api_reference-labels>` to 0.

        :param table label_pairs: table containing label names as keys,
                                  label values as values. Note that both
                                  label names and values in ``label_pairs``
                                  are treated as strings.



..  _metrics_gauge_obj:

..  class:: gauge_obj

    ..  _metrics_gauge_obj_inc:

    ..  method:: inc(num, label_pairs)

        Increment the observation for :ref:`label_pairs <metrics-api_reference-labels>`.
        If ``label_pairs`` doesn't exist, the method creates it.

    ..  _metrics_gauge_obj_dec:

    ..  method:: dec(num, label_pairs)

        Decrement the observation for :ref:`label_pairs <metrics-api_reference-labels>`.

    ..  _metrics_gauge_obj_set:

    ..  method:: set(num, label_pairs)

        Set the observation for :ref:`label_pairs <metrics-api_reference-labels>` to ``num``.

    ..  _metrics_gauge_obj_collect:

    ..  method:: collect()

        Get an array of ``observation`` objects for a given gauge.
        For the description of ``observation``, see
        :ref:`counter_obj:collect() <metrics-api_reference-counter_collect>`.

    ..  _metrics_gauge_obj_remove:

    ..  method:: remove(label_pairs)

        Remove the observation for :ref:`label_pairs <metrics-api_reference-labels>`.



..  _metrics_histogram_obj:

..  class:: histogram_obj

    ..  _metrics_histogram_obj_observe:

    ..  method:: observe(num, label_pairs)

        Record a new value in a histogram.
        This increments all bucket sizes under the labels ``le`` >= ``num``
        and the labels that match ``label_pairs``.

        :param number        num: value to put in the histogram.
        :param table label_pairs: table containing label names as keys,
                                  label values as values.
                                  All internal counters that have these labels specified
                                  observe new counter values.
                                  Note that both label names and values in ``label_pairs``
                                  are treated as strings.
                                  See also: :ref:`metrics-api_reference-labels`.

    ..  _metrics_histogram_obj_collect:

    ..  method:: collect()

        Return a concatenation of ``counter_obj:collect()`` across all internal
        counters of ``histogram_obj``. For the description of ``observation``,
        see :ref:`counter_obj:collect() <metrics-api_reference-counter_collect>`.

    ..  _metrics_histogram_obj_remove:

    ..  method:: remove(label_pairs)

        Works like the ``remove()`` function
        of a :ref:`counter <metrics-api_reference-counter_remove>`.




..  _metrics_registry:

..  class:: registry

    ..  _metrics_registry_unregister:

    ..  method:: unregister(collector)

        Remove a collector from the registry.

        :param collector_obj collector: the collector to be removed.

    **Example:**

    ..  code-block:: lua

        local collector = metrics.gauge('some-gauge')

        -- after a while, we don't need it anymore

        metrics.registry:unregister(collector)

    ..  _metrics_registry_find:

    ..  method:: find(kind, name)

        Find a collector in the registry.

        :param string kind: collector kind (``counter``, ``gauge``, ``histogram``, or ``summary``).
        :param string name: collector name.

        :return: A collector object or ``nil``.

        :rtype: collector_obj

    **Example:**

    ..  code-block:: lua

        local collector = metrics.gauge('some-gauge')

        collector = metrics.registry:find('gauge', 'some-gauge')



..  _metrics_summary_obj:

..  class:: summary_obj

    ..  _metrics_summary_obj_observe:

    ..  method:: observe(num, label_pairs)

        Record a new value in a summary.

        :param number        num: value to put in the data stream.
        :param table label_pairs: a table containing label names as keys,
                                  label values as values.
                                  All internal counters that have these labels specified
                                  observe new counter values.
                                  You can't add the ``"quantile"`` label to a summary.
                                  It is added automatically.
                                  If ``max_age_time`` and ``age_buckets_count`` are set,
                                  the observed value is added to each bucket.
                                  Note that both label names and values in ``label_pairs``
                                  are treated as strings.
                                  See also: :ref:`metrics-api_reference-labels`.

    ..  _metrics_summary_obj_collect:

    ..  method:: collect()

        Return a concatenation of ``counter_obj:collect()`` across all internal
        counters of ``summary_obj``. For the description of ``observation``,
        see :ref:`counter_obj:collect() <metrics-api_reference-counter_collect>`.
        If ``max_age_time`` and ``age_buckets_count`` are set, quantile observations
        are collected only from the head bucket in the sliding time window,
        not from every bucket. If no observations were recorded,
        the method will return ``NaN`` in the values.

    ..  _metrics_summary_obj_remove:

    ..  method:: remove(label_pairs)

        Works like the ``remove()`` function
        of a :ref:`counter <metrics-api_reference-counter_remove>`.





..  toctree::
    :hidden:

    metrics/prometheus
    metrics/graphite
    metrics/json

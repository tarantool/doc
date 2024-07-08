..  _metrics-prometheus-api_reference:

metrics.plugins.prometheus
==========================

..  module:: metrics.plugins.prometheus

..  function:: collect_http()

    Get an HTTP response object containing metrics in the Prometheus format.

    :return: a table containing the following fields:

             * ``status``: set to ``200``
             * ``headers``: response headers
             * ``body``: metrics in the Prometheus format

    :rtype: table

**Example**

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_plugins/examples/expose_prometheus_metrics.lua
    :start-at: local prometheus_plugin
    :end-at: local prometheus_metrics
    :language: lua
    :dedent:

Example on GitHub: `metrics_plugins <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/config/instances.enabled/metrics_plugins>`_

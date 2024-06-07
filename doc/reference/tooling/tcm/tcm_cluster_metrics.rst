..  _tcm_cluster_metrics:

Viewing cluster metrics
=======================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

In |tcm_full_name|, you can view metrics of connected clusters in real time on the
**Cluster** > **Cluster metrics** page. The list of metrics that Tarantool exposes
is provided in the :ref:`metrics-reference`.

Metrics are displayed one by one. To view a metric, select it in the drop-down list
at the top of the page. Then, choose a way to visualize it:

- **Chart**: a time series chart with the metric values are displayed as lines.
- **Table**: a table where the metric values are displayed as numbers in table cells.

Once you select a metric, |tcm| starts visualizing its current values, updating it
once per second. To pause the visualization, click the button on the left from
the metrics selector. To stop the visualization, clear the metric selection.


..  _tcm_cluster_metrics_prometheus:

Monitoring metrics with Prometheus
----------------------------------

- Prometherus?
- Generate API token
- Configure prometheus job

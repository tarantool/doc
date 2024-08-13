..  _tcm_cluster_metrics:

Viewing cluster metrics
=======================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

In |tcm_full_name|, you can view metrics of connected clusters in real time on the
**Cluster** > **Cluster metrics** page. The list of metrics that Tarantool exposes
is provided in the :ref:`metrics-reference`.

Metrics are displayed one by one. To view a metric, select it in the drop-down list
at the top of the page. Then, choose a way to visualize it:

- **Chart**: a time series chart with the metric values displayed as lines.
- **Table**: a table where the metric values are displayed as numbers in table cells.

Once you select a metric, |tcm| starts visualizing its current values, updating them
once per second. To pause the visualization, click the button on the left from
the metrics selector. To stop the visualization, clear the metric selection.


..  _tcm_cluster_metrics_instance:

Viewing instance metrics
------------------------

To view metrics of a specific instance, find this instance on the **Stateboard**,
click its name, and go to the **Metrics** tab of the instance page.


..  _tcm_cluster_metrics_prometheus:

Monitoring metrics with Prometheus
----------------------------------

To allow collecting cluster metrics with external systems, such as Prometheus,
|tcm| provides HTTP endpoints at ``/api/metrics/<clusterId>``.

.. note::

    Cluster IDs are shown in the cluster selection dialog that opens when you click
    **Cluster** at the top of the left navigation pane.

To access such an endpoint, a request must be authorized with an :ref:`API token <tcm_access_control_api_tokens>`
that has a ``cluster.metrics`` permission on the target cluster.

Below is an example of a Prometheus scrape configuration that collects metrics of
a Tarantool cluster from |tcm|:

.. code-block:: yaml

    - job_name: "tarantool"
        static_configs:
          - targets: ["127.0.0.1:8080"]
        metrics_path: "/api/metrics/00000000-0000-0000-0000-000000000000"
        bearer_token: QgMPZ22JZ3uw7n0QTbqYGAQDmNDs1JnTkhaC1OlQzWM3utmpV78b23GG97zp8YE3

..  _monitoring-getting_started:

Getting started with monitoring
===============================

Example on GitHub: `sharded_cluster_crud_metrics <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics>`_

Tarantool allows you to configure and expose its :ref:`metrics <metrics-reference>` using a :ref:`YAML configuration <configuration>`.
You can also use the built-in :ref:`metrics <metrics-api_reference>` module to create and collect custom metrics.




.. _monitoring_configuring_metrics:

Configuring metrics
-------------------

To configure metrics, use the :ref:`metrics <configuration_reference_metrics>` section in a cluster configuration.
The configuration below enables all metrics excluding :ref:`vinyl <metrics-reference-vinyl>`-specific ones:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics/config.yaml
    :start-at: metrics:
    :end-at: instance_name
    :language: yaml
    :dedent:

The ``metrics.labels`` option accepts the predefined :ref:`{{ instance_name }} <configuration_predefined_variables>` variable.
This adds an instance name as a :ref:`label <metrics-api_reference-labels>` to every observation.

Third-party Lua modules, like `crud <https://github.com/tarantool/crud>`_ or `expirationd <https://github.com/tarantool/expirationd>`_, offer their own metrics.
You can enable these metrics by :ref:`configuring the corresponding role <configuration_application_roles_configure>`.
The example below shows how to enable statistics on called operations by providing the ``roles.crud-router`` role's configuration:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics/config.yaml
    :language: yaml
    :start-after: routers:
    :end-at: stats_quantiles
    :dedent:

``expirationd`` metrics can be enabled as follows:

..  code-block:: yaml

    expirationd:
      cfg:
        metrics: true



..  _monitoring_exposing_metrics:

Exposing metrics
----------------

To expose metrics in different formats, you can use a third-party `metrics-export-role <https://github.com/tarantool/metrics-export-role>`__ role.
In the following example, the metrics of ``storage-a-001`` are provided on two endpoints:

-   ``/metrics/prometheus``: exposes metrics in the Prometheus format.
-   ``/metrics/json``: exposes metrics in the JSON format.

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics/config.yaml
    :start-at: storage-a-001:
    :end-at: format: json
    :language: yaml
    :dedent:

Example on GitHub: `sharded_cluster_crud_metrics <https://github.com/tarantool/doc/tree/latest/doc/code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics>`_

..  NOTE::

    The ``metrics`` module provides a set of plugins that can be used to collect and expose metrics in different formats. Learn more in :ref:`metrics-api_reference_collecting_using_plugins`.



.. _monitoring_create_metrics:

Creating custom metrics
-----------------------

The ``metrics`` module allows you to create and collect custom metrics.
The example below shows how to collect the number of data operations performed on the specified space by increasing a ``counter`` value inside the :ref:`on_replace() <box_space-on_replace>` trigger function:

..  literalinclude:: /code_snippets/snippets/config/instances.enabled/metrics_collect_custom/examples/collect_custom_replace_count.lua
    :start-after: -- Collect a custom metric
    :end-before: -- End
    :language: lua
    :dedent:

Learn more in :ref:`metrics-api_reference_custom_metrics`.



..  _monitoring_collecting_metrics:

Collecting metrics
------------------

When metrics are configured and exposed, you can use the desired third-party tool to collect them.
Below is the example of a Prometheus scrape configuration that collects metrics of multiple Tarantool instances:

..  literalinclude:: /code_snippets/snippets/sharding/instances.enabled/sharded_cluster_crud_metrics/prometheus/prometheus.yml
    :language: yaml
    :dedent:

For more information on collecting and visualizing metrics, refer to :ref:`monitoring-grafana_dashboard-page`.

..  NOTE::

    |tcm_full_name| allows you to view metrics of connected clusters in real time.
    Learn more in :ref:`tcm_cluster_metrics`.

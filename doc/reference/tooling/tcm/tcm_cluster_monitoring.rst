..  _tcm_cluster_monitoring:

Cluster monitoring
==================

|tcm_full_name| provides means for monitoring various aspects of connected clusters,
such as:

*   topology
*   instance state
*   memory usage
*   data distribution
*   Tarantool versions

Cluster monitoring tools are available on the **Cluster** > **Stateboard** page.

..  _tcm_cluster_monitoring_topology:

Cluster topology
----------------

The cluster topology is displayed on the **Stateboard** page in one of two forms:
a list or a graph.

..  _tcm_cluster_monitoring_topology_list:

List view
~~~~~~~~~

The list view of the cluster topology is used by default. In this view, each row contains
the general information about the instance: its current state, memory usage and limit,
and other parameters.

In the list view, |tcm| additionally displays the Tarantool version information
and instance states on circle diagrams. You can click the sectors of these diagrams
to filter the instances with the selected versions and states.

To switch to the list view, click the list button on the right of the search bar on the **Stateboard** page.

..  _tcm_cluster_monitoring_topology_graph:

Graph view
~~~~~~~~~~

In the graph view, the instance state is shown by its color.
You can move the graph vertexes to arrange them as you like, and zoom in and out,
which is helpful for bigger clusters.

To switch to the graph view, click the graph button on the right of the search bar on the **Stateboard** page.

..  _tcm_cluster_monitoring_topology_group:

Instance grouping
~~~~~~~~~~~~~~~~~

By default, the cluster topology is shown hierarchically as it's defined in the configuration:
instances are grouped by their replica set, and replica sets are grouped by
their configuration group.

For better navigation across the cluster, you can adjust the instance grouping.
For example, you can group instances by their roles or custom tags defined in the configuration.
A typical case for such tags is adding a geographical markers to instances. In this case,
you see if issues happen in a specific data center or server.

To change the instance grouping, click **Group by** in the **Actions** menu on the **Stateboard** page.
Then add or remove grouping criteria.

..  _tcm_cluster_monitoring_topology_filters:

Filtering
~~~~~~~~~

You can filter the instances shown on the **Stateboard** page using the search bar
at the top. It has predefined filters that select:

*   instances with errors or warnings
*   leader or read-only instances
*   instances with no issues
*   stale instances

To display all instances, delete the filter applied in the search bar.

..  _tcm_cluster_monitoring_instance_details:

Instance details
----------------

The general information about the state of cluster instances is shown in the
list view of the cluster topology. Each row contains the information about the instance
status, used and available memory, read-only status, and virtual buckets for sharded
clusters.

To view the detailed information about an instance or connect to it, click the corresponding
row in the instances list or vertex of the graph. On the instance page, you can
find its configuration overview, current state (with warning and error messages if any),
and the detailed Tarantool information returned by the instance introspection functions
from :ref:`box_introspection-box_info`, :ref:`box_introspection-box_stat`, and other
built-in modules.

Additionally, on the instance details page there is a terminal that enables running
arbitrary Lua code on the instance.

..  _tcm_cluster_monitoring_urls:

Additional monitoring services
------------------------------

When you :ref:`connect a cluster <tcm_connect_clusters>` to |tcm|, you can specify
URLs of external services linked to this cluster. For example, this can be a Grafana
server that monitors the cluster metrics.

All the URLs added for a cluster are available in the **Actions** menu on the
**Stateboard** page.
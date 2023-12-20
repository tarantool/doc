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
a list or a graph. The list view is used by default. In this view, each row contains
the general information about the instance: its current state, memory usage and limit,
and other parameters. In the graph view, the instance state is shown by its color.
You can move the graph vertexes to arrange them as you like, and zoom in and out,
which is helpful for bigger clusters. To switch between the list
and the graph view, use the buttons on the right of the search bar on the **Stateboard** page.

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

..  _tcm_cluster_monitoring_versions:

Tarantool versions
------------------

The **Stateboard** page displays common information about Tarantool versions running on
the cluster nodes: the version and the number of instances that run this version.
The versions information

To view the Tarantool version running on an specific instance, click its name in
the instances list or graph and open the **Details** tab.

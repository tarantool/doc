.. _vshard-summary:

===============================================================================
Summary
===============================================================================

Scaling databases in a growing project is often considered one of the most
challenging issue. Once a single server cannot withstand the load, scaling
methods should be applied.

Sharding is a database architecture that allows for `horizontal scaling <https://en.wikipedia.org/wiki/Scalability#Horizontal_and_vertical_scaling>`_.

.. NOTE::

    *Horizontal scaling* implies that a dataset is partitioned and distributed over
    multiple servers.

With ``vshard``, the tuples of a dataset are distributed across
multiple nodes, with a Tarantool database server instance on each node. Each instance
handles only a subset of the total data, so larger loads can be handled by simply
adding more servers. The initial dataset is partitioned into multiple parts, so each
part is stored on a separate server. The dataset is partitioned using sharding keys.

The ``vshard`` module is based on the concept of
:ref:`virtual buckets <vshard-vbuckets>`, where a tuple
set is partitioned into a large number of abstract virtual nodes (virtual buckets,
or buckets) rather than into a smaller number of physical nodes.

Hashing a sharding key into a large number of virtual buckets allows seamlessly
changing the number of servers in the cluster. The rebalancing mechanism distributes
buckets evenly among all shards in case some servers were added or removed.

The buckets have states, so it is easy to monitor the server states. For example,
a server instance is active and available for all types of requests, or a failover
occurred and the instance accepts only read requests.

The ``vshard`` module provides analogs of the data-manipulation functions of the
Tarantool ``box`` library (select, insert, replace, update, delete) for
sharding-aware applications.

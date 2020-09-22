.. _vshard-summary:

Scaling databases in a growing project is often considered one of the most
challenging issues. Once a single server cannot withstand the load, scaling
methods should be applied.

**Sharding** is a database architecture that allows for
`horizontal scaling <https://en.wikipedia.org/wiki/Scalability#Horizontal_and_vertical_scaling>`_,
which implies that a dataset is partitioned and distributed over multiple servers.

With Tarantool's `vshard <https://github.com/tarantool/vshard>`_ module,
the tuples of a dataset are distributed across
multiple nodes, with a Tarantool database server instance on each node. Each instance
handles only a subset of the total data, so larger loads can be handled by simply
adding more servers. The initial dataset is partitioned into multiple parts, so each
part is stored on a separate server.

The ``vshard`` module is based on the concept of
:ref:`virtual buckets <vshard-vbuckets>`, where a tuple
set is partitioned into a large number of abstract virtual nodes (**virtual buckets**,
further just **buckets**) rather than into a smaller number of physical nodes.

The dataset is partitioned using **sharding keys** (bucket id numbers).
Hashing a sharding key into a large number of buckets allows seamlessly
changing the number of servers in the cluster. The **rebalancing mechanism** distributes
buckets evenly among all shards in case some servers were added or removed.

The buckets have **states**, so it is easy to monitor the server states. For example,
a server instance is active and available for all types of requests, or a failover
occurred and the instance accepts only read requests.

The ``vshard`` module provides router and storage API (public and internal) for sharding-aware applications.

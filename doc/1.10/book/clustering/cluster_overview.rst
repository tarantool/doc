.. _cluster_overview:

================================================================================
Overview of Tarantool clustering
================================================================================

A Tarantool cluster is a collection of Tarantool instances acting in concert.
While a single Tarantool instance can leverage the performance of a single server
and is vulnerable to failure, the cluster spans multiple servers, utilizes their
cumulative CPU power, and is fault-tolerant.

To fully utilize the capabilities of a Tarantool cluster, you need to
develop applications keeping in mind they are to run in a cluster environment.

Cluster-aware application development is not a trivial task, so you are welcome
to try `Tarantool Cartridge <https://github.com/tarantool/cartridge/>`_,
a new framework for developing and managing Tarantool-based cluster applications.

As a software development kit (SDK), Tarantool Cartridge provides you with
utilities and templates to help:

* easily set up a development environment for your applications;
* plug the necessary Lua modules;
* pack the applications in an environment-independent way: together with
  module binaries and Tarantool executables.

The resulting package can be installed and started on one or multiple servers
as one or multiple instantiated services, independent or organized into a cluster.

Further on, Tarantool Cartridge provides your cluster-aware applications with
the following key benefits:

* horizontal scalability and load balancing via built-in automatic sharding;
* asynchronous replication;
* automatic failover;
* centralized cluster control via GUI or API;
* automatic configuration synchronization;
* instance functionality segregation.

A Tarantool Cartridge cluster can segregate functionality between instances via
built-in and custom (user-defined) **cluster roles**. You can toggle instances
on and off on the fly during cluster operation. This allows you to put
different types of workloads (e.g., compute- and transaction-intensive ones) on
different physical servers with dedicated hardware.

..  _enterprise_deprecated_features:

Deprecated features
===================

The ZooKeeper along with ``orchestrator`` are no longer supported. However, they
still can be used, if necessary.

The following sections describe the corresponding functionality.

..  _manage-sharding-api:

Controlling the cluster via API
-------------------------------

To control the cluster, use the ``orchestrator`` included in the delivery package.
The ``orchestrator`` uses ZooKeeper to store and distribute the configuration.
The ``orchestrator`` provides the REST API for controlling the cluster.
Configurations in the ZooKeeper are changed as a result of calling the ``orchestrator``'s
API-functions, which in turn leads to changes in configurations of the Tarantool
nodes.

We recommend using a **curl** command line interface to call the API-functions
of the ``orchestrator``.

The following example shows how to register a new availability zone (DC):

..  code-block:: kconfig

    $ curl -X POST http://HOST:PORT/api/v1/zone \
        -d '{
      "name": "Caucasian Boulevard"
      }'

To check whether the DC registration was successful, try the following instruction.
It retrieves the list of all registered nodes in the JSON format:

..  code-block:: console

    $ curl http://HOST:PORT/api/v1/zone| python -m json.tool

To apply the new configuration directly on the Tarantool nodes, increase the
configuration version number after calling the API function. To do this, use the
POST request to ``/api/v1/version``:

..  code-block:: console

    $ curl -X POST http://HOST:PORT/api/v1/version

Altogether, to update the cluster configuration:

1.  Call the ``POST/PUT`` method of the ``orchestrator``.
    As a result, the ZooKeeper nodes are updated, and a subsequent update of the
    Tarantool nodes is initiated.
2.  Update the configuration version using the ``POST`` request to ``/api/v1/version``.
    As a result, the configuration is applied to the Tarantool nodes.

See the :ref:`Orchestrator API reference <enterprise_orchestrator_api>` for the detailed orchestrator API.

..  _geo-redundancy-setup:

Setting up geo redundancy
-------------------------

Logically, cluster nodes can belong to some availability zone. Physically, an
availability zone is a separate DC, or a rack inside a DC. You can specify a matrix
of weights (distances) for the availability zones.

New zones are added by calling a corresponding API method of the orchestrator.

By default, the matrix of weights (distances) for the zones is not configured,
and geo-redundancy for such configurations works as follows:

* Data is always written to the master.
* If the master is available, then it is used for reading.
* If the master is unavailable, then any available replica is used for reading.

When you define a matrix of weights (distances) by calling ``/api/v1/zones/weights``,
the automatic scale-out system of the Tarantool DBMS finds a replica which is the
closest to the specified router in terms of weights, and starts using this replica
for reading. If this replica is not available, then the next nearest replica is
selected, taking into account the distances specified in the configuration.


..  toctree::
    :hidden:

    deprecated/orchestrator_api

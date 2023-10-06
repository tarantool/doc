..  _enterprise_orchestrator_api:

Orchestrator API reference
==========================

..  _orchestrator-configure-zones:

Configuring the zones
---------------------

*   :ref:`POST /api/v1/zone <orchestrator_api-post_zone>`
*   :ref:`GET /api/v1/zone/ <orchestrator_api-get_zone>`
*   :ref:`PUT /api/v1/zone/ <orchestrator_api-put_zone>`
*   :ref:`DELETE /api/v1/zone/ <orchestrator_api-delete_zone>`

..  _orchestrator_api-post_zone:

..  function:: POST /api/v1/zone

    Create a new zone.

    **Request**

    .. code-block:: kconfig

        {
        "name": "zone 1"
        }

    **Response**

    .. code-block:: kconfig

        {
        "error": {
            "code": 0,
            "message": "ok"
        },
        "data": {
            "id": 2,
            "name": "zone 2"
        },
        "status": true
        }

    **Potential errors**

    *   ``zone_exists`` - the specified zone already exists

..  _orchestrator_api-get_zone:

..  function:: GET /api/v1/zone/{zone_id: optional}

    Return information on the specified zone or on all the zones.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": [
                {
                    "id": 1,
                    "name": "zone 11"
                },
                {
                    "id": 2,
                    "name": "zone 2"
                }
            ],
            "status": true
        }

    **Potential errors**

    *   ``zone_not_found`` - the specified zone is not found

.. _orchestrator_api-put_zone:

..  function:: PUT /api/v1/zone/{zone_id}

    Update information on the zone.

    **Body**

    ..  code-block:: kconfig

        {
            "name": "zone 22"
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``zone_not_found`` - the specified zone is not found

..  _orchestrator_api-delete_zone:

..  function:: DELETE /api/v1/zone/{zone_id}

    Delete a zone if it doesn’t store any nodes.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``zone_not_found`` - the specified zone is not found
    *   ``zone_in_use`` - the specified zone stores at least one node

..  _orchestrator-configure-zone-weights:

Configuring the zone weights
----------------------------

*   :ref:`GET /api/v1/zones/weights <orchestrator_api-get_weights>`
*   :ref:`POST /api/v1/zones/weights <orchestrator_api-post_weights>`

..  _orchestrator_api-post_weights:

..  function:: POST /api/v1/zones/weights

    Set the zone weights configuration.

    **Body**

    ..  code-block:: kconfig

        {
            "weights": {
                "1": {
                    "2": 10,
                    "3": 11
                },
                "2": {
                    "1": 10,
                    "3": 12
                },
                "3": {
                    "1": 11,
                    "2": 12
                }
            }
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``zones_weights_error`` - configuration error

..  _orchestrator_api-get_weights:

..  function:: GET /api/v1/zones/weights

    Return the zone weights configuration.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {
                "1": {
                    "2": 10,
                    "3": 11
                },
                "2": {
                    "1": 10,
                    "3": 12
                },
                "3": {
                    "1": 11,
                    "2": 12
                }
            },
            "status": true
        }

    **Potential errors**

    *   ``zone_not_found`` - the specified zone is not found

..  _orchestrator-configure-registry:

Configuring registry
--------------------

*   :ref:`GET /api/v1/registry/nodes/new <orchestrator_api-get_new>`
*   :ref:`POST /api/v1/registry/node <orchestrator_api-post_registry_node>`
*   :ref:`PUT /api/v1/registry/node/ <orchestrator_api-put_node>`
*   :ref:`GET /api/v1/registry/node/ <orchestrator_api-get_node>`
*   :ref:`DELETE /api/v1/registry/node/ <orchestrator_api-delete_node>`

..  _orchestrator_api-get_new:

..  function:: GET /api/v1/registry/nodes/new

    Return all the detected nodes.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": [
                {
                    "uuid": "uuid-2",
                    "hostname": "tnt2.public.i",
                    "name": "tnt2"
                }
            ],
            "status": true
        }

..  _orchestrator_api-post_registry_node:

..  function:: POST /api/v1/registry/node

    Register the detected node.

    **Body**

    ..  code-block:: kconfig

        {
            "zone_id": 1,
            "uuid": "uuid-2",
            "uri": "tnt2.public.i:3301",
            "user": "user1:pass1",
            "repl_user": "repl_user1:repl_pass1",
            "cfg": {
                "listen": "0.0.0.0:3301"
            }
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``node_already_registered`` - the specified node is already registered
    *   ``zone_not_found`` - the specified zone is not found
    *   ``node_not_discovered`` - the specified node is not detected

..  _orchestrator_api-put_node:

..  function:: PUT /api/v1/registry/node/{node_uuid}

    Update the registered node parameters.

    **Body**

    Pass only those parameters that need to be updated.

    ..  code-block:: kconfig

        {
            "zone_id": 1,
            "repl_user": "repl_user2:repl_pass2",
            "cfg": {
                "listen": "0.0.0.0:3301",
                "memtx_memory": 100000
            }
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``node_not_registered`` - the specified node is not registered

..  _orchestrator_api-get_node:

..  function:: GET /api/v1/registry/node/{node_uuid: optional}

    Return information on the nodes in a cluster. If ``node_uuid`` is passed,
    information on this node only is returned.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {
                "uuid-1": {
                    "user": "user1:pass1",
                    "hostname": "tnt1.public.i",
                    "repl_user": "repl_user2:repl_pass2",
                    "uri": "tnt1.public.i:3301",
                    "zone_id": 1,
                    "name": "tnt1",
                    "cfg": {
                        "listen": "0.0.0.0:3301",
                        "memtx_memory": 100000
                    },
                    "zone": 1
                },
                "uuid-2": {
                    "user": "user1:pass1",
                    "hostname": "tnt2.public.i",
                    "name": "tnt2",
                    "uri": "tnt2.public.i:3301",
                    "repl_user": "repl_user1:repl_pass1",
                    "cfg": {
                        "listen": "0.0.0.0:3301"
                    },
                    "zone": 1
                }
            },
            "status": true
        }

    **Potential errors**

    *   ``node_not_registered`` - the specified node is not registered

..  _orchestrator_api-delete_node:

..  function:: DELETE /api/v1/registry/node/{node_uuid}

    Delete the node if it doesn’t belong to any replica set.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    * ``node_not_registered`` - the specified node is not registered
    * ``node_in_use`` - the specified node is in use by a replica set

.. _orchestrator-router-api:

Routers API
-----------

*   :ref:`GET /api/v1/routers <orchestrator_api-get_routers>`
*   :ref:`POST /api/v1/routers <orchestrator_api-post_routers>`
*   :ref:`DELETE /api/v1/routers/{uuid} <orchestrator_api-delete_routers>`

..  _orchestrator_api-get_routers:

..  function:: GET /api/v1/routers

    Return the list of all nodes that constitute the router.

    **Response**

    ..  code-block:: kconfig

        {
            "data": [
                "uuid-1"
            ],
            "status": true,
            "error": {
                "code": 0,
                "message": "ok"
            }
        }

..  _orchestrator_api-post_routers:

..  function:: POST /api/v1/routers

    Assign the router role to the node.

    **Body**

    ..  code-block:: kconfig

        {
            "uuid": "uuid-1"
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``node_not_registered`` - the specified node is not registered

..  _orchestrator_api-delete_routers:

..  function:: DELETE /api/v1/routers/{uuid}

    Release the router role from the node.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

..  _orchestrator_api-replica_set_cfg:

Configuring replica sets
------------------------

*   :ref:`POST /api/v1/replicaset <orchestrator_api-post_replicaset>`
*   :ref:`PUT /api/v1/replicaset/ <orchestrator_api-put_replicaset>`
*   :ref:`GET /api/v1/replicaset/ <orchestrator_api-get_replicaset>`
*   :ref:`DELETE /api/v1/replicaset/ <orchestrator_api-delete_replicaset>`
*   :ref:`POST /api/v1/replicaset/{replicaset_uuid}/master <orchestrator_api-post_master>`
*   :ref:`POST /api/v1/replicaset/{replicaset_uuid}/node <orchestrator_api-post_replicaset_node>`
*   :ref:`DELETE /api/v1/zone/ <orchestrator_api-delete_zone>`

..  _orchestrator_api-post_replicaset:

..  function:: POST /api/v1/replicaset

    Create a replica set containing all the registered nodes.

    **Body**

    ..  code-block:: kconfig

        {
            "uuid": "optional-uuid",
            "replicaset": [
                {
                    "uuid": "uuid-1",
                    "master": true
                }
            ]
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {
                "replicaset_uuid": "cc6568a2-63ca-413d-8e39-704b20adb7ae"
            },
            "status": true
        }

    **Potential errors**

    *   ``replicaset_exists`` – the specified replica set already exists
    *   ``replicaset_empty`` – the specified replica set doesn’t contain any nodes
    *   ``node_not_registered`` – the specified node is not registered
    *   ``node_in_use`` – the specified node is in use by another replica set

..  _orchestrator_api-put_replicaset:

..  function:: PUT /api/v1/replicaset/{replicaset_uuid}

    Update the replica set parameters.

    **Body**

    ..  code-block:: kconfig

        {
            "replicaset": [
                {
                    "uuid": "uuid-1",
                    "master": true
                },
                {
                    "uuid": "uuid-2",
                    "master": false,
                    "off": true
                }
            ]
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``replicaset_empty`` – the specified replica set doesn’t contain any nodes
    *   ``replicaset_not_found`` – the specified replica set is not found
    *   ``node_not_registered`` – the specified node is not registered
    *   ``node_in_use`` – the specified node is in use by another replica set

..  _orchestrator_api-get_replicaset:

..  function:: GET /api/v1/replicaset/{replicaset_uuid: optional}

    Return information on all the cluster components. If ``replicaset_uuid`` is
    passed, information on this replica set only is returned.

    **Body**

    ..  code-block:: kconfig

        {
            "name": "zone 22"
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {
                "cc6568a2-63ca-413d-8e39-704b20adb7ae": {
                    "uuid-1": {
                        "hostname": "tnt1.public.i",
                        "off": false,
                        "repl_user": "repl_user2:repl_pass2",
                        "uri": "tnt1.public.i:3301",
                        "master": true,
                        "name": "tnt1",
                        "user": "user1:pass1",
                        "zone_id": 1,
                        "zone": 1
                    },
                    "uuid-2": {
                        "hostname": "tnt2.public.i",
                        "off": true,
                        "repl_user": "repl_user1:repl_pass1",
                        "uri": "tnt2.public.i:3301",
                        "master": false,
                        "name": "tnt2",
                        "user": "user1:pass1",
                        "zone": 1
                    }
                }
            },
            "status": true
        }

    **Potential errors**

    *   ``replicaset_not_found`` – the specified replica set is not found

..  _orchestrator_api-delete_replicaset:

..  function:: DELETE /api/v1/replicaset/{replicaset_uuid}

    Delete a replica set.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``replicaset_not_found`` - the specified replica set is not found

..  _orchestrator_api-post_master:

..  function:: POST /api/v1/replicaset/{replicaset_uuid}/master

    Switch the master in the replica set.

    **Body**

    ..  code-block:: kconfig

        {
            "instance_uuid": "uuid-1",
            "hostname_name": "hostname:instance_name"
        }

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Potential errors**

    *   ``replicaset_not_found`` – the specified replica set is not found
    *   ``node_not_registered`` – the specified node is not registered
    *   ``node_not_in_replicaset`` – the specified node is not in the specified replica set

..  _orchestrator_api-post_replicaset_node:

..  function:: POST /api/v1/replicaset/{replicaset_uuid}/node

    Add a node to the replica set.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {},
            "status": true
        }

    **Body**

    ..  code-block:: kconfig

        {
            "instance_uuid": "uuid-1",
            "hostname_name": "hostname:instance_name",
            "master": false,
            "off": false
        }

    **Potential errors**

*   ``replicaset_not_found`` – the specified replica set is not found
*   ``node_not_registered`` – the specified node is not registered
*   ``node_in_use`` – the specified node is in use by another replica set

..  _orchestrator_api-get_status:

..  function:: GET /api/v1/replicaset/status

    Return statistics on the cluster.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "data": {
                "cluster": {
                    "routers": [
                        {
                            "zone": 1,
                            "name": "tnt1",
                            "repl_user": "repl_user1:repl_pass1",
                            "hostname": "tnt1.public.i",
                            "status": null,
                            "uri": "tnt1.public.i:3301",
                            "user": "user1:pass1",
                            "uuid": "uuid-1",
                            "total_rps": null
                        }
                    ],
                    "storages": [
                        {
                            "hostname": "tnt1.public.i",
                            "repl_user": "repl_user2:repl_pass2",
                            "uri": "tnt1.public.i:3301",
                            "name": "tnt1",
                            "total_rps": null,
                            "status": 'online',
                            "replicas": [
                                {
                                    "user": "user1:pass1",
                                    "hostname": "tnt2.public.i",
                                    "replication_info": null,
                                    "repl_user": "repl_user1:repl_pass1",
                                    "uri": "tnt2.public.i:3301",
                                    "uuid": "uuid-2",
                                    "status": 'online',
                                    "name": "tnt2",
                                    "total_rps": null,
                                    "zone": 1
                                }
                            ],
                            "user": "user1:pass1",
                            "zone_id": 1,
                            "uuid": "uuid-1",
                            "replicaset_uuid": "cc6568a2-63ca-413d-8e39-704b20adb7ae",
                            "zone": 1
                        }
                    ]
                }
            },
            "status": true
        }

    **Potential errors**

    *   ``zone_not_found`` - the specified zone is not found
    *   ``zone_in_use`` - the specified zone stores at least one node

..  _orchestrator-setup-config-versions:

Setting up configuration versions
---------------------------------

*   :ref:`POST /api/v1/version <orchestrator_api-post_version>`
*   :ref:`GET /api/v1/version <orchestrator_api-get_version>`

..  _orchestrator_api-post_version:

..  function:: POST /api/v1/version

    Set the configuration version.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "status": true,
            "data": {
                "version": 2
            }
        }

    **Potential errors**

    *   ``cfg_error`` - configuration error

..  _orchestrator_api-get_version:

..  function:: GET /api/v1/version

    Return the configuration version.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "status": true,
            "data": {
                "version": 2
            }
        }

.. _orchestrator-config-shards:

Configuring sharding
--------------------

*   :ref:`POST /api/v1/sharding/cfg <orchestrator_api-post_cfg>`
*   :ref:`GET /api/v1/sharding/cfg <orchestrator_api-get_cfg>`

..  _orchestrator_api-post_cfg:

..  function:: POST /api/v1/sharding/cfg

    Add a new sharding configuration.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "status": true,
            "data": {}
        }

..  _orchestrator_api-get_cfg:

..  function:: GET /api/v1/sharding/cfg

    Return the current sharding configuration.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "status": true,
            "data": {}
        }

.. _orchestrator-reset-cluster-config:

Resetting cluster configuration
-------------------------------

*   :ref:`POST /api/v1/clean/cfg <orchestrator_api-post_clean_cfg>`
*   :ref:`POST /api/v1/clean/all <orchestrator_api-post_clean_all>`

..  _orchestrator_api-post_clean_cfg:

..  function:: POST /api/v1/clean/cfg

    Reset the cluster configuration.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "status": true,
            "data": {}
        }

..  _orchestrator_api-post_clean_all:

..  function:: POST /api/v1/clean/all

    Reset the cluster configuration and delete information on the cluster nodes
    from the ZooKeeper catalogues.

    **Response**

    ..  code-block:: kconfig

        {
            "error": {
                "code": 0,
                "message": "ok"
            },
            "status": true,
            "data": {}
        }

.. _compat-option-box-info-cluster:

Meaning of box.info.cluster
===========================

Option: ``box_info_cluster_meaning``

Starting from version 3.0, the :ref:`box_info_cluster` table stores the information
about the entire cluster. In earlier versions, it stored only the current replica set
information. The ``box_info_cluster_meaning`` compat option allows to define the
the scope of ``box.info.cluster``: the entire cluster or a single replica set.

Old and new behavior
--------------------

New behavior: ``box.info.cluster`` displays information about the entire
cluster with all its replica sets.

..  code-block:: tarantoolsession

    tarantool> compat.box_info_cluster_meaning = 'new'
    ---
    ...

    tarantool> box.info.cluster
    ---
    - <cluster information>
    ...

    tarantool> box.info.replicaset
    ---
    - uuid: <replicaset uuid>
    - <... other attributes of the replicaset>
    ...

.. note::

    In the new behavior, :ref:`box_info_replicaset` is equivalent to the old ``box.info.cluster``.

Old behavior: ``box.info.cluster`` displays information about the current replica set.

..  code-block:: tarantoolsession

    tarantool> compat.box_info_cluster_meaning = 'old'
    ---
    ...

    tarantool> box.info.cluster
    ---
    - uuid: <replicaset uuid>
    - <... other attributes of the replicaset>
    ...

    tarantool> box.info.replicaset
    ---
    - uuid: <replicaset uuid>
    - <... other attributes of the replicaset>
    ...

Known compatibility issues
--------------------------

``vshard`` versions earlier than 0.1.24 do not support the new behavior.


Detecting issues in your codebase
---------------------------------

Look for all usages of ``box.info.cluster``, ``info.cluster``, and
``.cluster``, ``['cluster']``, ``["cluster"]`` in the application code
written before the change. To make it work the same way on Tarantool 3.0 or later,
replace the ``cluster`` key with ``replicaset``.
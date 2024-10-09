.. _compat-option-box-info-cluster:

Meaning of box.info.cluster
===========================

Option: ``box_info_cluster_meaning``

Starting from version 3.0, the :ref:`box_info_cluster` table stores the information
about the entire cluster. In earlier versions, it stored only the current replica set
information. The ``box_info_cluster_meaning`` compat option in Tarantool 3.0 or later
allows to rollback to the old meaning of ``box.info.cluster`` - display information
about a single replica set.

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
    - name: my_cluster
    ...

    tarantool> box.info.replicaset
    ---
    - uuid: 0a3ff0c7-9075-441c-b0f5-b93a24be07cb
      name: router-001
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
    - uuid: 0a3ff0c7-9075-441c-b0f5-b93a24be07cb
      name: router-001
    ...

    tarantool> box.info.replicaset
    ---
    - uuid: 0a3ff0c7-9075-441c-b0f5-b93a24be07cb
      name: router-001
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

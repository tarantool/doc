.. _box_introspection-box_info:

-------------------------------------------------------------------------------
Submodule box.info
-------------------------------------------------------------------------------

.. module:: box.info

The ``box.info`` submodule provides access to information about server instance
variables.

* **cluster.uuid** is the UUID of the replica set.
  Every instance in a replica set will have the same ``cluster.uuid`` value.
  This value is also stored in :ref:`box.space._schema <box_space-schema>`
  system space.
* **gc()** returns the state of the
  :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`
  including the checkpoints and their consumers (users); see details
  :doc:`here </reference/reference_lua/box_info/gc>`.
* **id** corresponds to :samp:`replication[{n}].id`
  (see :doc:`here </reference/reference_lua/box_info/replication>`).
* **lsn** corresponds to :samp:`replication[{n}].lsn`
  (see :doc:`here </reference/reference_lua/box_info/replication>`).
* **listen** returns a real address to which an instance was bound
  (see :doc:`here </reference/reference_lua/box_info/listen>`).
* **memory()** returns the statistics about memory
  (see :doc:`here </reference/reference_lua/box_info/memory>`).
* **pid** is the process ID. This value is also shown by
  :ref:`tarantool <tarantool-build>` module
  and by the Linux command ``ps -A``.
* **ro** is ``true`` if the instance is in "read-only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in ``box.cfg{}``),
  or if status is 'orphan'.
* **signature** is the sum of all ``lsn`` values from each :ref:`vector clock <replication-vector>`
  (**vclock**) for all instances in the replica set.
* **sql().cache.size** is the number of bytes in the SQL prepared statement cache.
* **sql().cache.stmt_count** is the number of statements in the SQL prepared statement cache.
* **status** is the current state of the instance. It can be:

  * ``running`` -- the instance is loaded,
  * ``loading`` -- the instance is either recovering xlogs/snapshots or bootstrapping,
  * ``orphan`` --  the instance has not (yet) succeeded in joining the required
    number of masters (see :ref:`orphan status <replication-orphan_status>`),
  * ``hot_standby`` -- the instance is :ref:`standing by <index-hot_standby>` another instance.
* **uptime** is the number of seconds since the instance started.
  This value can also be retrieved with
  :ref:`tarantool.uptime() <tarantool-build>`.
* **uuid** corresponds to :samp:`replication[{n}].uuid`
  (see :doc:`here </reference/reference_lua/box_info/replication>`).
* **vclock** is a table with the vclock values of all instances in a replica set which have made data changes.
* **version** is the Tarantool version. This value is also shown by
  :ref:`tarantool -V <index-tarantool_version>`.
* **vinyl()** returns runtime statistics for the vinyl storage engine.
  This function is deprecated, use
  :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>` instead.
* **election** shows the current state of a replica set node regarding leader
  election (see :doc:`here </reference/reference_lua/box_info/election>`).

Below is a list of all ``box.info`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_info/info`
           - Return all keys and values provided in the submodule

        *  - :doc:`./box_info/gc`
           - Return info about garbage collector

        *  - :doc:`./box_info/memory`
           - Return info about memory usage

        *  - :doc:`./box_info/replication_anon`
           - List all the anonymous replicas following the instance

        *  - :doc:`./box_info/replication`
           - Return statistics for all instances in the replica set

        *  - :doc:`./box_info/listen`
           - Return a real address to which an instance was bound

        *  - :doc:`./box_info/election`
           - Show the current state of a replica set node
             in regards to leader election

..  toctree::
    :hidden:

    box_info/info
    box_info/gc
    box_info/memory
    box_info/replication_anon
    box_info/replication
    box_info/listen
    box_info/election

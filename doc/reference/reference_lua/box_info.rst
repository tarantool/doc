.. _box_introspection-box_info:

-------------------------------------------------------------------------------
Submodule `box.info`
-------------------------------------------------------------------------------

===============================================================================
                                  Overview
===============================================================================

The ``box.info`` submodule provides access to information about server instance
variables.

* **cluster.uuid** is the UUID of the replica set.
  Every instance in a replica set will have the same ``cluster.uuid`` value.
  This value is also stored in :ref:`box.space._schema <box_space-schema>`
  system space.
* **gc()** returns the state of the
  :ref:`Tarantool garbage collector <cfg_checkpoint_daemon-garbage-collector>`
  including the checkpoints and their consumers (users); see details
  :ref:`below <box_info_gc>`.
* **id** corresponds to **replication.id**
  (see :ref:`below <box_info_replication>`).
* **lsn** corresponds to **replication.lsn**
  (see :ref:`below <box_info_replication>`).
* **memory()** returns the statistics about memory
  (see :ref:`below <box_info_memory>`).
* **pid** is the process ID. This value is also shown by
  :ref:`tarantool <tarantool-build>` module
  and by the Linux command ``ps -A``.
* **ro** is ``true`` if the instance is in "read-only" mode
  (same as :ref:`read_only <cfg_basic-read_only>` in ``box.cfg{}``),
  or if status is 'orphan'.
* **signature** is the sum of all **lsn** values from the vector clocks
  (**vclock**) of all instances in the replica set.
* **status** is the current state of the instance. It can be:

  * ``running`` -- the instance is loaded,
  * ``loading`` -- the instance is either recovering xlogs/snapshots or bootstrapping,
  * ``orphan`` --  the instance has not (yet) succeeded in joining the required
    number of masters (see :ref:`orphan status <replication-orphan_status>`),
  * ``hot_standby`` -- the instance is :ref:`standing by <index-hot_standby>` another instance.
* **uptime** is the number of seconds since the instance started.
  This value can also be retrieved with
  :ref:`tarantool.uptime() <tarantool-build>`.
* **uuid** corresponds to **replication.uuid**
  (see :ref:`below <box_info_replication>`).
* **vclock** corresponds to **replication.downstream.vclock**
  (see :ref:`below <box_info_replication>`).
* **version** is the Tarantool version. This value is also shown by
  :ref:`tarantool -V <index-tarantool_version>`.
* **vinyl()** returns runtime statistics for the vinyl storage engine.
  This function is deprecated, use
  :ref:`box.stat.vinyl() <box_introspection-box_stat_vinyl>` instead.

===============================================================================
                                  Contents
===============================================================================


.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.info() <box_info_info>`    | Return all keys and values      |
    |                                      | provided in the submodule       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.info.gc() <box_info_gc>`   | Return info about garbage       |
    |                                      | collector                       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.info.memory()              | Return info about memory usage  |
    | <box_info_memory>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.info.replication           | Return statistics for all       |
    | <box_info_replication>`              | instances in the replica set    |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_info/box_info_info
    box_info/box_info_gc
    box_info/box_info_memory
    box_info/box_info_replication

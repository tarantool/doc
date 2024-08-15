.. _box_info_lsn:

================================================================================
box.info.lsn
================================================================================

.. module:: box.info

.. data:: lsn

    A :ref:`log sequence number <replication-mechanism>` (LSN) for the latest entry in the instance's :ref:`write-ahead log <index-box_persistence>` (WAL).
    This value corresponds to ```replication[{n}].lsn``.
    Learn more in :ref:`box_info_replication`.

    :rtype: number

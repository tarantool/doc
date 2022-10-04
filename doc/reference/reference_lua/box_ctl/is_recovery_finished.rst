.. _box_ctl-is_recovery_finished:

==============================
box.ctl.is_recovery_finished()
==============================

.. module:: box.ctl

.. function:: is_recovery_finished()

     Since version :doc:`2.5.3 </release/2.5.3>`.

     Check whether the :ref:`recovery process <internals-recovery_process>` has finished.
     Until it has finished, space changes such as ``insert`` or ``update`` are not possible.

     :return: ``true`` if recovery has finished, otherwise ``false``
     :rtype: boolean






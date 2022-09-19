.. _box_ctl-promote:

box.ctl.promote()
=================

.. function:: promote()

    Wait, then choose new replication leader.

    For :ref:`synchronous transactions <how-to-repl_sync>` it is
    possible that a new leader will be chosen but the transactions
    of the old leader have not been completed. Therefore to
    finalize the transaction, the function ``box.ctl.promote()``
    should be called, as mentioned in the notes for
    :ref:`leader election <repl_leader_elect_important>`.    
    The old name for this function is ``box.ctl.clear_synchro_queue()``.
    
    The :ref:`election state <box_info_election>` should change to ``leader``.
    
    Parameters: none
     
    :return: nil or function pointer

    Added in release :doc:`2.6.2 </release/2.6.2>`. Renamed in release :doc:`2.6.3 </release/2.6.3>`.

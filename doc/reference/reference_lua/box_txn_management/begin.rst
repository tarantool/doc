.. _box-begin:

================================================================================
box.begin()
================================================================================

.. function:: box.begin()

    Begin the transaction. Disable :ref:`implicit yields <app-implicit-yields>`
    until the transaction ends.
    Signal that writes to the :ref:`write-ahead log <internals-wal>` will be
    deferred until the transaction ends.
    In effect the fiber which executes ``box.begin()`` is starting an "active
    multi-request transaction", blocking all other fibers.

    **Possible errors:**

    * error if this operation is not permitted because there is already an active transaction.
    * error if for some reason memory cannot be allocated.
.. _box-begin:

box.begin()
===========

.. function:: box.begin([opts])

    Begin the transaction. Disable :ref:`implicit yields <app-implicit-yields>`
    until the transaction ends.
    Signal that writes to the :ref:`write-ahead log <internals-wal>` will be
    deferred until the transaction ends.
    In effect the fiber which executes ``box.begin()`` is starting an "active
    multi-request transaction", blocking all other fibers.

    :param table opts: (optional) transaction options:

                       *   ``txn_isolation`` -- the :ref:`transaction isolation level <txn_mode_mvcc-options>`
                       *   ``timeout`` -- a timeout (in seconds), after which the transaction is rolled back

    **Possible errors:**

    * error if this operation is not permitted because there is already an active transaction.
    * error if for some reason memory cannot be allocated.
    * error and abort the transaction if the timeout is exceeded.

    **Example**

    ..  literalinclude:: /code_snippets/test/transactions/box_commit_test.lua
        :language: lua
        :lines: 29-44
        :dedent:

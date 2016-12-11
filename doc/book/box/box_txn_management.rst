.. _box-txn_management:

--------------------------------------------------------------------------------
Functions for transaction management
--------------------------------------------------------------------------------

For general information and examples, see section
:ref:`Transaction control <atomic-atomic_execution>`.

Observe the following rules when working with transactions:

.. admonition:: Rule #1
    :class: FACT

    The requests in a transaction must be sent to the server as a single block.
    It is not enough to enclose them between begin and commit or rollback.
    To ensure they are sent as a single block: put them in a function, or put
    them all on one line, or use a delimiter so that multi-line requests
    are handled together.

.. admonition:: Rule #2
    :class: FACT

    All database operations in a transaction should use the same storage engine.
    It is not safe to access tuple sets that are defined with ``{engine='vinyl'}``
    and also access tuple sets that are defined with ``{engine='memtx'}``,
    in the same transaction.

.. _box-begin:
 
.. function:: box.begin()

    Begin the transaction. Disable implicit yields until the transaction ends.
    Signal that writes to the write-ahead log will be deferred until the transaction ends.
    In effect the fiber which executes ``box.begin()`` is starting an "active
    multi-request transaction", blocking all other fibers.

.. _box-commit:

.. function:: box.commit()

    End the transaction, and make all its data-change operations permanent.

.. _box-rollback:

.. function:: box.rollback()

    End the transaction, but cancel all its data-change operations.
    An explicit call to functions outside ``box.space`` that always
    yield, such as :ref:`fiber.sleep() <fiber-sleep>` or
    :ref:`fiber.yield() <fiber-yield>`, will have the same effect.

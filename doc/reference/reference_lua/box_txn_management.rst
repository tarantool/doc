.. _box-txn_management:

--------------------------------------------------------------------------------
Functions for transaction management
--------------------------------------------------------------------------------

For general information and examples, see section
:ref:`Transactions <atomic-atomic_execution>`.

Observe the following rules when working with transactions:

.. admonition:: Rule #1
    :class: FACT

    The requests in a transaction must be sent to a server as a single block.
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

.. admonition:: Rule #3
    :class: FACT

    Requests which cause changes to the data definition
    -- create, alter, drop, truncate -- are only allowed with
    Tarantool version 2.1 or later.
    Data-definition requests which change an index
    or change a format, such as
    :doc:`space_object:create_index()
    </reference/reference_lua/box_schema_sequence/create_index>` and
    :ref:`space_object:format() <box_space-format>`,
    are not allowed inside transactions except as the first request
    after ``box.begin()``.

Below is a list of all functions for transaction management.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_txn_management/begin`
           - Begin the transaction

        *  - :doc:`./box_txn_management/commit`
           - End the transaction and save all changes

        *  - :doc:`./box_txn_management/rollback`
           - End the transaction and discard all changes

        *  - :doc:`./box_txn_management/savepoint`
           - Get a savepoint descriptor

        *  - :doc:`./box_txn_management/rollback_to_savepoint`
           - Do not end the transaction and discard all changes made after a
             savepoint

        *  - :doc:`./box_txn_management/atomic`
           - Execute a function, treating it as a transaction

        *  - :doc:`./box_txn_management/on_commit`
           - Define a trigger that will be activated by ``box.commit``

        *  - :doc:`./box_txn_management/on_rollback`
           - Define a trigger that will be activated by ``box.rollback``

        *  - :doc:`./box_txn_management/is_in_txn`
           - State whether a transaction is in progress

.. toctree::
    :hidden:

    box_txn_management/begin
    box_txn_management/commit
    box_txn_management/rollback
    box_txn_management/savepoint
    box_txn_management/rollback_to_savepoint
    box_txn_management/atomic
    box_txn_management/on_commit
    box_txn_management/on_rollback
    box_txn_management/is_in_txn
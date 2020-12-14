.. _box-txn_management:

--------------------------------------------------------------------------------
Functions for transaction management
--------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

For general information and examples, see section
:ref:`Transaction control <atomic-atomic_execution>`.

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
    -- create, alter, drop, truncate -- must not be used.

===============================================================================
                                 Contents
===============================================================================

Below is a list of all functions for transaction management.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    .. tabularcolumns:: |\Y{0.4}|\Y{0.6}|

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.begin()                    | Begin the transaction           |
    | <box-begin>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.commit()                   | End the transaction and save    |
    | <box-commit>`                        | all changes                     |
    +--------------------------------------+---------------------------------+
    | :ref:`box.rollback()                 | End the transaction and discard |
    | <box-rollback>`                      | all changes                     |
    +--------------------------------------+---------------------------------+
    | :ref:`box.savepoint()                | Get a savepoint descriptor      |
    | <box-savepoint>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.rollback_to_savepoint()    | Do not end the transaction and  |
    | <box-rollback_to_savepoint>`         | discard all changes made after  |
    |                                      | a savepoint                     |
    +--------------------------------------+---------------------------------+
    | :ref:`box.atomic()                   | Execute a function, treating it |
    | <box-atomic>`                        | as a transaction                |
    +--------------------------------------+---------------------------------+
    | :ref:`box.on_commit()                | Define a trigger that will be   |
    | <box-on_commit>`                     | activated by ``box.commit``     |
    +--------------------------------------+---------------------------------+
    | :ref:`box.on_rollback()              | Define a trigger that will be   |
    | <box-on_rollback>`                   | activated by ``box.rollback``   |
    +--------------------------------------+---------------------------------+
    | :ref:`box.is_in_txn()                | State whether a transaction is  |
    | <box-is_in_txn>`                     | in progress                     |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_txn_management/box_begin
    box_txn_management/box_commit
    box_txn_management/box_rollback
    box_txn_management/box_savepoint
    box_txn_management/box_rollback_to_savepoint
    box_txn_management/box_atomic
    box_txn_management/box_on_commit
    box_txn_management/box_on_rollback
    box_txn_management/box_is_in_txn
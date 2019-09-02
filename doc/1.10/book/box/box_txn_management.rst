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
                                    Index
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

.. _box-begin:

.. function:: box.begin()

    Begin the transaction. Disable :ref:`implicit yields <atomic-implicit-yields>`
    until the transaction ends.
    Signal that writes to the :ref:`write-ahead log <internals-wal>` will be
    deferred until the transaction ends.
    In effect the fiber which executes ``box.begin()`` is starting an "active
    multi-request transaction", blocking all other fibers.

    **Possible errors:** error if this operation is not permitted because there
                         is already an active transaction. error if for some
                         reason memory cannot be allocated.

.. _box-commit:

.. function:: box.commit()

    End the transaction, and make all its data-change operations permanent.

    **Possible errors:**  error and abort the transaction in case of a conflict.
                          error if the operation fails to write to disk.
                          error if for some reason memory cannot be allocated.

.. _box-rollback:

.. function:: box.rollback()

    End the transaction, but cancel all its data-change operations.
    An explicit call to functions outside ``box.space`` that always
    yield, such as :ref:`fiber.sleep() <fiber-sleep>` or
    :ref:`fiber.yield() <fiber-yield>`, will have the same effect.

.. _box-savepoint:

.. function:: box.savepoint()

    Return a descriptor of a savepoint (type = table), which can be used later
    by :ref:`box.rollback_to_savepoint(savepoint) <box-rollback_to_savepoint>`.
    Savepoints can only be created while a transaction is active, and they are
    destroyed when a transaction ends.

    :return: savepoint table
    :rtype:  Lua object

    :return: error if the savepoint cannot be set in absence of active
             transaction.

    **Possible errors:** error if for some reason memory cannot be allocated.

.. _box-rollback_to_savepoint:

.. function:: box.rollback_to_savepoint(savepoint)

    Do not end the transaction, but cancel all its data-change
    and :ref:`box.savepoint() <box-savepoint>` operations that were done after
    the specified savepoint.

    :return: error if the savepoint cannot be set in absence of active
             transaction.

    **Possible errors:** error if the savepoint does not exist.

    **Example:**

    .. code-block:: lua

        function f()
          box.begin()           -- start transaction
          box.space.t:insert{1} -- this will not be rolled back
          local s = box.savepoint()
          box.space.t:insert{2} -- this will be rolled back
          box.rollback_to_savepoint(s)
          box.commit()          -- end transaction
        end

.. _box-atomic:

.. function:: box.atomic(tx-function [, function-arguments])

    Execute a function, acting as if the function starts with an implicit
    :ref:`box.begin() <box-begin>` and ends with an implicit
    :ref:`box.commit() <box-commit>` if successful, or ends with an implicit
    :ref:`box.rollback() <box-rollback>` if there is an error.

    :return: the result of the function passed to ``atomic()`` as an argument.

    **Possible errors:** any error that :ref:`box.begin() <box-begin>` and
                        :ref:`box.commit() <box-commit>` can return.

.. _box-on_commit:

.. function:: box.on_commit(trigger-function [, old-trigger-function])

    Define a trigger for execution when a transaction ends due to an event
    such as :ref:`box.commit <box-commit>`.

    The trigger function may take an iterator parameter, as described in an
    example for this section.

    The trigger function should not access any database spaces.

    If the trigger execution fails and raises an error, the effect is severe
    and should be avoided -- use Lua's ``pcall()`` mechanism around code that
    might fail.

    ``box.on_commit()`` must be invoked within a transaction,
    and the trigger ceases to exist when the transaction ends.

    :param function trigger-function: function which will become the trigger
                                      function
    :param function old-trigger-function: existing trigger function which will
                                          be replaced by trigger-function
    :return: nil or function pointer

    If the parameters are ``(nil, old-trigger-function)``, then the old trigger
    is deleted.

    Details about trigger characteristics are in the
    :ref:`triggers <triggers-box_triggers>` section.

    **Simple and useless example:** this will display 'commit happened':

    .. code-block:: lua

        function f()
        function f() print('commit happened') end
        box.begin() box.on_commit(f) box.commit()

    But of course there is more to it: the function parameter can be an ITERATOR.

    The iterator goes through the effects of every request that changed a space
    during the transaction.

    The iterator will have:

    * an ordinal request number,
    * the old value of the tuple before the request
      (this will be nil for an insert request),
    * the new value of the tuple after the request
      (this will be nil for a delete request),
    * and the id of the space.

    **Less simple more useful example:** this will display the effects of two
    replace requests:

    .. code-block:: lua

        box.space.test:drop()
        s = box.schema.space.create('test')
        i = box.space.test:create_index('i')
        function f(iterator)
          for request_number, old_tuple, new_tuple, space_id in iterator() do
            print('request_number ' .. tostring(request_number))
            print('  old_tuple ' .. tostring(old_tuple[1]) .. ' ' .. old_tuple[2])
            print('  new_tuple ' .. tostring(new_tuple[1]) .. ' ' .. new_tuple[2])
            print('  space_id ' .. tostring(space_id))
          end
        end
        s:insert{1,'-'}
        box.begin() s:replace{1,'x'} s:replace{1,'y'} box.on_commit(f) box.commit()

    The result will look like this:

    .. code-block:: tarantoolsession

        tarantool> box.begin() s:replace{1,'x'} s:replace{1,'y'} box.on_commit(f) box.commit()
        request_number 1
          old_tuple 1 -
          new_tuple 1 x
          space_id 517
        request_number 2
          old_tuple 1 x
          new_tuple 1 y
          space_id 517

.. _box-on_rollback:

.. function:: box.on_rollback(trigger-function [, old-trigger-function])

    Define a trigger for execution when a transaction ends due to an event
    such as :ref:`box.rollback <box-rollback>`.

    The parameters and warnings are exactly the same as for
    :ref:`box.on-commit <box-on_commit>`.

.. _box-is_in_txn:

.. function:: box.is_in_txn()

    If a transaction is in progress (for example the user has called
    :ref:`box.begin <box-begin>` and has not yet called either
    :ref:`box.commit <box-commit>` or :ref:`box.rollback <box-rollback>`,
    return ``true``. Otherwise return ``false``.

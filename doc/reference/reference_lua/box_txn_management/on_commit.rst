.. _box-on_commit:

================================================================================
box.on_commit()
================================================================================

.. function:: box.on_commit(trigger-function [, old-trigger-function])

    Define a trigger for execution when a transaction ends due to an event
    such as :doc:`/reference/reference_lua/box_txn_management/commit`.

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

    **Example 1**

    ..  literalinclude:: /code_snippets/test/transactions/box_on_commit_test.lua
        :language: lua
        :lines: 29-43
        :dedent:

    **Example 2**

    The function parameter can be an iterator.
    The iterator goes through the effects of every request that changed a space
    during the transaction.

    The iterator has:

    * an ordinal request number
    * the old value of the tuple before the request
      (``nil`` for an ``insert`` request)
    * the new value of the tuple after the request
      (``nil`` for a ``delete`` request)
    * the ID of the space

    The example below displays the effects of two ``replace`` requests:

    ..  literalinclude:: /code_snippets/test/transactions/box_on_commit_iterator_test.lua
        :language: lua
        :lines: 29-49
        :dedent:

    The output might look like this:

    .. code-block:: console

        request_number: 1
        old_tuple: [1, 'Roxette', 1986]
        new_tuple: [1, 'The Beatles', 1960]
        space_id: 512
        request_number: 2
        old_tuple: [2, 'Scorpions', 1965]
        new_tuple: [2, 'The Rolling Stones', 1965]
        space_id: 512

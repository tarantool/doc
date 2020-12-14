.. _box-on_commit:

================================================================================
box.on_commit()
================================================================================

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
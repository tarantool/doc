..  _box_space-on_replace:

===============================================================================
space_object:on_replace()
===============================================================================

..  class:: space_object

    ..  method:: on_replace([trigger-function [, old-trigger-function]])

        Create a "replace :ref:`trigger <triggers>`".
        The ``trigger-function`` will be executed
        whenever a ``replace()`` or ``insert()`` or ``update()`` or ``upsert()``
        or ``delete()`` happens to a tuple in ``<space-name>``.

        :param function     trigger-function: function which will become the
                                              trigger function; see Example 2
                                              below for details about
                                              trigger function parameters
        :param function old-trigger-function: existing trigger function which
                                              will be replaced by
                                              ``trigger-function``
        :return: nil or function pointer

        If the parameters are ``(nil, old-trigger-function)``, then the old
        trigger is deleted.

        If both parameters are omitted, then the response is a list of existing
        trigger functions.

        If it is necessary to know whether the trigger activation
        happened due to replication or on a specific connection type,
        the function can refer to :doc:`/reference/reference_lua/box_session/type`.

        Details about trigger characteristics are in the
        :ref:`triggers <triggers-box_triggers>` section.

        See also :doc:`/reference/reference_lua/box_space/before_replace`.

        **Example 1:**

        ..  code-block:: tarantoolsession

            tarantool> x = 0
                     > function f ()
                     >   x = x + 1
                     > end
            tarantool> box.space.my_space_name:on_replace(f)

        **Example 2:**

        The ``trigger-function`` can have up to four parameters:

        * (tuple) old value which has the contents before the request started,
        * (tuple) new value which has the contents after the request ended,
        * (string) space name,
        * (string) type of request which is ``INSERT``, ``DELETE``, ``UPDATE``,
          or ``REPLACE``.

        For example, the following code causes ``nil`` and ``INSERT``
        to be printed when the insert request is processed and causes
        ``[1, 'Hi']`` and ``DELETE`` to be printed when the delete request
        is processed:

        ..  code-block:: lua

            box.schema.space.create('space_1')
            box.space.space_1:create_index('space_1_index',{})
            function on_replace_function (old, new, s, op) print(old) print(op) end
            box.space.space_1:on_replace(on_replace_function)
            box.space.space_1:insert{1,'Hi'}
            box.space.space_1:delete{1}

        **Example 3:**

        The following series of requests will create a space, create an index,
        create a function which increments a counter, create a trigger, do two
        inserts, drop the space, and display the counter value - which is 2,
        because the function is executed once after each insert.

        ..  code-block:: tarantoolsession

            tarantool> s = box.schema.space.create('space53')
            tarantool> s:create_index('primary', {parts = {{field = 1, type = 'unsigned'}}})
            tarantool> function replace_trigger()
                     >   replace_counter = replace_counter + 1
                     > end
            tarantool> s:on_replace(replace_trigger)
            tarantool> replace_counter = 0
            tarantool> t = s:insert{1, 'First replace'}
            tarantool> t = s:insert{2, 'Second replace'}
            tarantool> s:drop()
            tarantool> replace_counter

        ..  NOTE::

            As everything executed inside triggers is already in a transaction,
            you shouldn't use in trigger-functions for ``on_replace`` and
            ``before_replace``

            * transactions,
            * yield-operations (:ref:`explicit <app-yields>` or not),
            * actions that are not allowed to be used in transactions
              (see :ref:`rule #2 <box-txn_management>`).



          **Example:**

        ..  code-block:: tarantoolsession

            tarantool> box.space.test:on_replace(fiber.yield)
            tarantool> box.space.test:replace{1, 2, 3}
            2020-02-02 21:22:03.073 [73185] main/102/init.lua txn.c:532 E> ER_TRANSACTION_YIELD: Transaction has been aborted by a fiber yield
            ---
            - error: Transaction has been aborted by a fiber yield
            ...

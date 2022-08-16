.. _box_space-truncate:

===============================================================================
space_object:truncate()
===============================================================================

.. class:: space_object

    .. method:: truncate()

        Deletes all tuples. The method is performed in background and doesn't
        block consequent requests.

        :param space_object space_object: an :ref:`object reference
                                          <app_server-object_reference>`

        **Complexity factors:** Index size, Index type, Number of tuples accessed.

        :return: nil

        The ``truncate`` method can only be called by the user who created
        the space, or from within a ``setuid`` function created by the user
        who created the space.
        Read more about `setuid` functions in the reference for
        :doc:`/reference/reference_lua/box_schema/func_create`.

        ..  note::

            Do not call this method within a transaction in
            Tarantool older than :tarantool-release:`2.10.0`. See :tarantool-issue:`6123` for details.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:truncate()
            ---
            ...
            tarantool> box.space.tester:len()
            ---
            - 0
            ...

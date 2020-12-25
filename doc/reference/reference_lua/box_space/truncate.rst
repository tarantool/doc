.. _box_space-truncate:

===============================================================================
space_object:truncate()
===============================================================================

.. module:: box.space

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
        :ref:`box.schema.func.create() <box_schema-func_create>`.

        The ``truncate`` method cannot be called from within a transaction.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.tester:truncate()
            ---
            ...
            tarantool> box.space.tester:len()
            ---
            - 0
            ...

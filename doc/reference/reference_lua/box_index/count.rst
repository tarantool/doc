.. _box_index-count:

===============================================================================
index_object:count()
===============================================================================

.. class:: index_object

    .. method:: count([key], [iterator])

        Iterate over an index, counting the number of
        tuples which match the key-value.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key
        :param         iterator: comparison method

        :return: the number of matching tuples.
        :rtype:  number

        **Example:**

        Below are few examples of using ``count``.
        To try out these examples, you need to bootstrap a Tarantool database
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        ..  literalinclude:: /code_snippets/test/indexes/index_aggr_functions_test.lua
            :language: lua
            :lines: 42-68
            :dedent:

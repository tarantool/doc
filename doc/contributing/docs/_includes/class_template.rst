..  class:: index_object

    ..  method:: get(key)

        Search for a tuple :ref:`via the given index <box_index-note>`.

        :param index_object index_object: :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table      key: values to be matched against the index key

        :return: the tuple whose index-key fields are equal to the passed key values
        :rtype:  tuple

        **Possible errors:**

        * No such index
        * Wrong type
        * More than one tuple matches

        **Complexity factors:** index size, index type.
        See also :ref:`space_object:get() <box_space-get>`.

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary:get(2)
            ---
            - [2, 'Music']
            ...

    ..  data:: unique

        True if the index is unique, false if the index is not unique.

        :rtype: boolean

        ..  code-block:: tarantoolsession

            tarantool> box.space.tester.index.primary.unique
            ---
            - true
            ...

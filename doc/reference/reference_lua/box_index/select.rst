.. _box_index-select:

===============================================================================
index_object:select()
===============================================================================

..  class:: index_object

    ..  method:: select(search-key, options)

        Search for a tuple or a set of tuples by the current index.
        To search by the primary index in the specified space, use the :ref:`box_space-select` method.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table          key: a value to be matched against the index key, which may be multi-part.
        :param table/nil         options: none, any, or all of the following parameters:

                                          * ``iterator`` -- the :ref:`iterator type <box_index-iterator-types>`. The default iterator type is 'EQ'.
                                          * ``limit`` -- the maximum number of tuples.
                                          * ``offset`` -- the number of tuples to skip (use this parameter carefully when scanning :ref:`large data sets <offset-warning>`).
                                          * ``options.after`` -- a tuple or the position of a tuple (:ref:`tuple_pos <box_index-tuple_pos>`) after which ``select`` starts the search. You can pass an empty string or :ref:`box.NULL <box-null>` to this option to start the search from the first tuple.
                                          * ``options.fetch_pos`` -- if **true**, the ``select`` method returns the position of the last selected tuple as the second value.

                                            .. NOTE::

                                                The ``after`` and ``fetch_pos`` options are supported for the ``TREE`` :ref:`index <index-types>` only.



        :return:

            This function might return one or two values:

            *   The tuples whose fields are equal to the fields of the passed key.
                If the number of passed fields is less than the
                number of fields in the current key, then only the passed
                fields are compared, so ``select{1,2}`` matches a tuple
                whose primary key is ``{1,2,3}``.
            *   (Optionally) If ``options.fetch_pos`` is set to **true**, returns a base64-encoded string representing the position of the last selected tuple as the second value.
                If no tuples are fetched, returns ``nil``.

        :rtype:

            *   array of tuples
            *   (Optionally) string

        .. _offset-warning:

        ..  WARNING::

            Use the ``offset`` option carefully when scanning
            large data sets as it linearly increases the number
            of scanned tuples and leads to a full space scan.
            Instead, you can use the ``after`` and ``fetch_pos`` options.


        **Examples:**

        Below are few examples of using ``select`` with different parameters.
        To try out these examples, you need to bootstrap a Tarantool database
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        ..  literalinclude:: /code_snippets/test/indexes/index_select_test.lua
            :language: lua
            :lines: 42-128
            :dedent:

        ..  _box_index-note:

        ..  NOTE::

            :samp:`box.space.{space-name}.index.{index-name}:select(...)[1]`. can be
            replaced by :samp:`box.space.{space-name}.index.{index-name}:get(...)`.
            That is, ``get`` can be used as a convenient shorthand to get the first
            tuple in the tuple set that would be returned by ``select``. However,
            if there is more than one tuple in the tuple set, then ``get`` throws
            an error.

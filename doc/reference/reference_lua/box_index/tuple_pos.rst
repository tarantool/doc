.. _box_index-tuple_pos:

===============================================================================
index_object:tuple_pos()
===============================================================================

.. class:: index_object

    .. method:: tuple_pos(tuple)

        Return a tuple's position for an index.
        This value can be passed to the ``after`` option of the ``select`` and ``pairs`` methods:

            *   :ref:`index_object:select <box_index-select>`/:ref:`space_object:select <box_space-select>`
            *   :ref:`index_object:pairs <box_index-pairs>`/:ref:`space_object:pairs <box_space-pairs>`

        Note that ``tuple_pos`` does not work with :ref:`functional <box_space-index_func>` and multikey indexes.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`
        :param scalar/table        tuple: a tuple whose position should be found

        :return: a tuple's position in a space
        :rtype:  base64-encoded string


        **Example:**

        To try out this example, you need to bootstrap a Tarantool instance
        as described in :ref:`Using data operations <box_space-operations-detailed-examples>`.

        .. code-block:: tarantoolsession

            -- Insert test data --
            tarantool> bands:insert{1, 'Roxette', 1986}
                       bands:insert{2, 'Scorpions', 1965}
                       bands:insert{3, 'Ace of Base', 1987}
                       bands:insert{4, 'The Beatles', 1960}
                       bands:insert{5, 'Pink Floyd', 1965}
                       bands:insert{6, 'The Rolling Stones', 1962}
            ---
            ...

            -- Get a tuple's position --
            tarantool> position = bands.index.primary:tuple_pos({3, 'Ace of Base', 1987})
            ---
            ...
            -- Pass the tuple's position as the 'after' parameter --
            tarantool> bands:select({}, {limit = 3, after = position})
            ---
            - - [4, 'The Beatles', 1960]
              - [5, 'Pink Floyd', 1965]
              - [6, 'The Rolling Stones', 1962]
            ...

.. _box_schema-sequence_create_index:

===============================================================================
space_object:create_index()
===============================================================================

.. module:: box.schema

.. function:: space_object:create_index(... [sequence='...' option] ...)

    You can use the :samp:`sequence={sequence-name}`
    (or :samp:`sequence={sequence-id}` or :samp:`sequence=true`)
    option when :ref:`creating <box_space-create_index>` or
    :ref:`altering <box_index-alter>` a primary-key index.
    The sequence becomes associated with the index, so that the next
    ``insert()`` will put the next generated number into the primary-key
    field, if the field would otherwise be nil.

    For example, if 'Q' is a sequence and 'T' is a new space, then this will
    work:

    .. code-block:: tarantoolsession

        tarantool> box.space.T:create_index('Q',{sequence='Q'})
        ---
        - unique: true
          parts:
          - type: unsigned
            is_nullable: false
            fieldno: 1
          sequence_id: 8
          id: 0
          space_id: 514
          name: Q
          type: TREE
        ...

    (Notice that the index now has a ``sequence_id`` field.)

    And this will work:

    .. code-block:: tarantoolsession

        tarantool> box.space.T:insert{box.NULL,0}
        ---
        - [1, 0]
        ...

    .. NOTE::

        If you are using negative numbers for the sequence options,
        make sure that the index key type is 'integer'. Otherwise
        the index key type may be either 'integer' or 'unsigned'.

        A sequence cannot be dropped if it is associated with an index.
        However, :ref:`index_object:alter() <box_index-alter>`
        can be used to say that a sequence
        is not associated with an index, for example
        ``box.space.T.index.I:alter({sequence=false})``.

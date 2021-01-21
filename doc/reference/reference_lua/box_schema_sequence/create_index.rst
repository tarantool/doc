.. _box_schema-sequence_create_index:

===============================================================================
specifying a sequence in create_index()
===============================================================================

..  class:: space_object

  ..  method::  space_object:create_index(... [sequence='...' option] ...)

    You can use the :samp:`sequence={sequence-name}`
    (or :samp:`sequence={sequence-id}` or :samp:`sequence=true`)
    option when :ref:`creating <box_space-create_index>` or
    :doc:`altering </reference/reference_lua/box_index/alter>` a primary-key index.
    The sequence becomes associated with the index, so that the next
    ``insert()`` will put the next generated number into the primary-key
    field, if the field would otherwise be nil.

    The syntax may be any of: |br|
    :samp:`sequence = {sequence identifier}` |br|
    or
    :code:`sequence = {id =` :samp:`{sequence identifier}` :code:`}` |br|
    or
    :code:`sequence = {field =` :samp:`{field number}` :code:`}` |br|
    or
    :code:`sequence = {id =` :samp:`{sequence identifier}` :code:`, field =` :samp:`{field number}` :code:`}` |br|
    or
    :code:`sequence = true` |br|
    or
    :code:`sequence = {}`. |br|
    The sequence identifier may be either a number
    (the sequence id) or a string (the sequence name).
    The field number may be the ordinal number of any field
    in the index; default = 1.
    Examples of all possibilities:
    ``sequence = 1`` or
    ``sequence = 'sequence_name'`` or
    ``sequence = {id = 1}`` or
    ``sequence = {id = 'sequence_name'}`` or
    ``sequence = {id = 1, field = 1}`` or
    ``sequence = {id = 'sequence_name', field = 1}`` or
    ``sequence = {field = 1}`` or
    ``sequence = true`` or
    ``sequence = {}``.
    Notice that the sequence identifier can be omitted,
    if it is omitted then a new sequence is created
    automatically with default name = :samp:`{space-name}_seq`.
    Notice that the field number does not have to be 1,
    that is, the sequence can be associated with any
    field in the primary-key index.


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

        The index key type may be either 'integer' or 'unsigned'.
        If any of the sequence options is a negative number, then
        the index key type should be 'integer'.

        Users should not insert a value greater than 9223372036854775807,
        which is 2^63 - 1, in the indexed field. The sequence generator
        will ignore it.

        A sequence cannot be dropped if it is associated with an index.
        However, :ref:`index_object:alter() <box_index-alter>`
        can be used to say that a sequence
        is not associated with an index, for example
        ``box.space.T.index.I:alter({sequence=false})``.

        If a sequence was created automatically because the
        sequence identifier was omitted, then it will be dropped
        automatically if the index is altered so that ``sequence=false``,
        or if the index is dropped.

        ``index_object:alter()`` can also be used to associate a
        sequence with an existing index, with the same syntax for options.

        When a sequence is used with an index based on a JSON path,
        inserted tuples must have all components of the path preceding
        the autoincrement field, and the autoincrement field.
        To achieve that use ``box.NULL`` rather than ``nil``. Example:

        .. code-block:: lua

            s = box.schema.space.create('test')
            s:create_index('pk', {parts = {{'[1].a.b[1]', 'unsigned'}}, sequence = true})
            s:replace{} -- error
            s:replace{{c = {}}} -- error
            s:replace{{a = {c = {}}}} -- error
            s:replace{{a = {b = {}}}} -- error
            s:replace{{a = {b = {nil}}}} -- error
            s:replace{{a = {b = {box.NULL}}}} -- ok

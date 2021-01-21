.. _box_schema-sequence_current:

===============================================================================
sequence_object:current()
===============================================================================

..  class:: sequence_object

  ..  method:: current()

    Return the last retrieved value of the specified sequence or throw an error
    if no value has been generated yet (``next()`` has not been called yet, or ``current()`` is called right
    after ``reset()`` is called).

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> sq = box.schema.sequence.create('test')
      ---
      ...
      tarantool> sq:current()
      ---
      - error: Sequence 'test' is not started
      ...
      tarantool> sq:next()
      ---
      - 1
      ...
      tarantool> sq:current()
      ---
      - 1
      ...
      tarantool> sq:set(42)
      ---
      ...
      tarantool> sq:current()
      ---
      - 42
      ...
      tarantool> sq:reset()
      ---
      ...
      tarantool> sq:current()  -- error
      ---
      - error: Sequence 'test' is not started
      ...
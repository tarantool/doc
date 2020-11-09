.. _box_space-schema:

===============================================================================
box.space._schema
===============================================================================

.. module:: box.space

.. data:: _schema

    ``_schema`` is a system space.

    This space contains the following tuples:

    * ``version`` tuple with version information for this Tarantool instance,
    * ``cluster`` tuple with the instance's replica set ID,
    * ``max_id`` tuple with the maximal space ID,
    * ``once...`` tuples that correspond to specific
      :ref:`box.once() <box-once>` blocks from the instance's
      :ref:`initialization file <index-init_label>`.
      The first field in these tuples contains the ``key`` value from the
      corresponding ``box.once()`` block prefixed with 'once' (e.g. `oncehello`),
      so you can easily find a tuple that corresponds to a specific
      ``box.once()`` block.

    **Example:**

    Here is what ``_schema`` contains in a typical installation (notice the
    tuples for two ``box.once()`` blocks, ``'oncebye'`` and ``'oncehello'``):

    .. code-block:: tarantoolsession

       tarantool> box.space._schema:select{}
       ---
       - - ['cluster', 'b4e15788-d962-4442-892e-d6c1dd5d13f2']
         - ['max_id', 512]
         - ['oncebye']
         - ['oncehello']
         - ['version', 1, 7, 2]

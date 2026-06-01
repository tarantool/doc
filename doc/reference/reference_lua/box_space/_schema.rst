.. _box_space-schema:

===============================================================================
box.space._schema
===============================================================================

.. module:: box.space

.. data:: _schema

    ``_schema`` is a system space.

    This space contains the following tuples:

    * ``version``: version information for this Tarantool instance.
    * ``cluster``: the instance's replica set ID.
    * ``max_id`` (deprecated since `2.11.1 <https://github.com/tarantool/tarantool/releases/tag/2.11.1>`__): the maximal space ID.
      Use the :ref:`box.space._space.index[0]:max() <box_index-max>` function instead.
    * ``once...``: tuples that correspond to specific
      :ref:`box.once() <box-once>` blocks from the instance's
      :ref:`initialization file <index-init_label>`.
      The first field in these tuples contains the ``key`` value from the
      corresponding ``box.once()`` block prefixed with 'once' (e.g. `oncehello`),
      so you can easily find a tuple that corresponds to a specific
      ``box.once()`` block.

    **Example:**

    In the example, the ``_schema`` space contains two ``box.once`` objects -- ``oncebye`` and ``oncehello``.

    .. code-block:: tarantoolsession

       tarantool> box.space._schema:select{}
       ---
       - - ['cluster', 'b4e15788-d962-4442-892e-d6c1dd5d13f2']
         - ['max_id', 512]
         - ['oncebye']
         - ['oncehello']
         - ['version', 1, 7, 2]

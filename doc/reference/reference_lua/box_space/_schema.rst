.. _box_space-schema:

box.space._schema
=================

.. module:: box.space

.. data:: _schema

    ``_schema`` is a system space.

    This space contains the following tuples:

    * ``version``: version information for this Tarantool instance.
    * ``replicaset_name`` (since :doc:`3.0.0 <release/3.0.0>`): the name of a replica set to which this instance belongs.
    * ``replicaset_uuid`` (since :doc:`3.0.0 <release/3.0.0>`): the instance's replica set UUID. In version :doc:`3.0.0 <release/3.0.0>`,
      the field was renamed from ``cluster`` to ``replicaset_uuid``.
    * ``max_id`` (deprecated since :doc:`2.11.1 <https://github.com/tarantool/tarantool/releases/tag/2.11.1>`__): the maximal space ID.
      Use the :ref:`box.space._space.index[0]:max() <box_index-max>` function instead.
    * ``once...``: tuples that correspond to specific
      :ref:`box.once() <box-once>` blocks from the instance's
      :ref:`initialization file <index-init_label>`.
      The first field in these tuples contains the ``key`` value from the
      corresponding ``box.once()`` block prefixed with 'once' (for example, ``oncehello``),
      so you can easily find a tuple that corresponds to a specific
      ``box.once()`` block.

    **Example:**

    In the example, the ``_schema`` space contains two ``box.once`` objects -- ``oncebye`` and ``oncehello``.

    ..  code-block:: tarantoolsession

        app:instance001> box.space._schema:select{}
        ---
        - - ['oncebye']
          - ['oncehello']
          - ['replicaset_name', 'replicaset001']
          - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
          - ['version', 3, 1, 0]
        ...


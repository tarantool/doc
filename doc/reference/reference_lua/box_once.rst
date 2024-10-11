.. _box-once:

Function box.once
=================

.. function:: box.once(key, function[, ...])

    Execute a function, provided it has not been executed before. A passed value
    is checked to see whether the function has already been executed. If it has
    been executed before, nothing happens. If it has not been executed before,
    the function is invoked.

    See an example of using ``box.once()`` in :ref:`vshard-quick-start-storage-code`.

    **Warning:** If an error occurs inside ``box.once()`` when initializing a
    database, you can re-execute the failed ``box.once()`` block without
    stopping the database. The solution is to delete the ``once`` object from
    the system space :ref:`_schema <box_space-schema>`.
    Say ``box.space._schema:select{}``, find your ``once`` object there and
    delete it.

    When ``box.once()`` is used for initialization, it may be useful to
    wait until the database is in an appropriate state (read-only or read-write).
    In that case, see the functions in the :doc:`/reference/reference_lua/box_ctl`.

    :param string        key: a value that will be checked
    :param function function: a function
    :param               ...: arguments that must be passed to function

    ..  NOTE::

        The parameter ``key`` will be stored in the :ref:`_schema <box_space-schema>`
        system space after ``box.once()`` is called in order to prevent a double
        run. These keys are global per replica set. So a simultaneous call of
        ``box.once()`` with the same key on two instances of the same replica set
        may succeed on both of them, but it'll lead to a transaction conflict.


    **Example**

    The example shows how to re-execute the ``box.once()`` block that contains the ``hello`` key.

    First, check the ``_schema`` system space.
    The ``_schema`` space in the example contains two ``box.once`` objects -- ``oncebye`` and ``oncehello``:

    ..  code-block:: tarantoolsession

        app:instance001> box.space._schema:select{}
        ---
        - - ['oncebye']
          - ['oncehello']
          - ['replicaset_name', 'replicaset001']
          - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
          - ['version', 3, 1, 0]

    Delete the ``oncehello`` object:

    ..  code-block:: tarantoolsession

        app:instance001> box.space._schema:delete('oncehello')
        ---
        - ['oncehello']
        ...

    After that, check the ``_schema`` space again:

    ..  code-block:: tarantoolsession

        app:instance001> box.space._schema:select{}
        ---
        - - ['oncebye']
          - ['replicaset_name', 'replicaset001']
          - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
          - ['version', 3, 1, 0]
        ...

    To re-execute the function, call the ``box.once()`` method again:

    ..  code-block:: tarantoolsession

        app:instance001> box.once('hello', function() end)
        ---
        ...

        app:instance001> box.space._schema:select{}
        ---
        - - ['oncebye']
          - ['oncehello']
          - ['replicaset_name', 'replicaset001']
          - ['replicaset_uuid', '72d2d9bf-5d9f-48c4-ba80-9d657e128fee']
          - ['version', 3, 1, 0]
        ...


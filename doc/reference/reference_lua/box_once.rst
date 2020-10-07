.. _box-once:

-------------------------------------------------------------------------------
                             Function `box.once`
-------------------------------------------------------------------------------

.. function:: box.once(key, function[, ...])

    Execute a function, provided it has not been executed before. A passed value
    is checked to see whether the function has already been executed. If it has
    been executed before, nothing happens. If it has not been executed before,
    the function is invoked.

    See an example of using ``box.once()`` while
    :ref:`bootstrapping a replica set <replication-bootstrap>`.

    **Warning:** If an error occurs inside ``box.once()`` when initializing a
    database, you can re-execute the failed ``box.once()`` block without
    stopping the database. The solution is to delete the ``once`` object from
    the system space :ref:`_schema <box_space-schema>`.
    Say ``box.space._schema:select{}``, find your ``once`` object there and
    delete it. For example, re-executing a block with ``key='hello'`` :

    When ``box.once()`` is used for initialization, it may be useful to
    wait until the database is in an appropriate state (read-only or read-write).
    In that case, see the functions in the :ref:`box.ctl submodule <box_ctl>`.

    .. code-block:: tarantoolsession

        tarantool> box.space._schema:select{}
        ---
        - - ['cluster', 'b4e15788-d962-4442-892e-d6c1dd5d13f2']
          - ['max_id', 512]
          - ['oncebye']
          - ['oncehello']
          - ['version', 1, 7, 2]
        ...

        tarantool> box.space._schema:delete('oncehello')
        ---
        - ['oncehello']
        ...

        tarantool> box.once('hello', function() end)
        ---
        ...

    :param string        key: a value that will be checked
    :param function function: a function
    :param               ...: arguments that must be passed to function

    .. NOTE::

        The parameter ``key`` will be stored in the :ref:`_schema <box_space-schema>`
        system space after ``box.once()`` is called in order to prevent a double
        run. These keys are global per replica set. So a simultaneous call of
        ``box.once()`` with the same key on two instances of the same replica set
        may succeed on both of them, but it'll lead to a transaction conflict.

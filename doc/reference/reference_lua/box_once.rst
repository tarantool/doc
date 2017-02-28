.. _box-once:

-------------------------------------------------------------------------------
                             Function `box.once`
-------------------------------------------------------------------------------

.. function:: box.once(key, function[, ...])

    Execute a function, provided it has not been executed before. A passed value
    is checked to see whether the function has already been executed. If it has
    been executed before, nothing happens. If it has not been executed before,
    the function is invoked. For an explanation why ``box.once`` is useful, see
    the section :ref:`Preventing Duplicate Actions
    <index-preventing_duplicate_actions>`.

    If an error occurs inside box.once when initializing a database,
    you can re-execute the failed box.once block without stopping the database.
    The solution is to delete the "once" object from the system space "_schema".
    Say box.space._schema:select{}, find your once object there and delete it.

    :param string        key: a value that will be checked
    :param function function: a function
    :param               ...: arguments, that must be passed to function

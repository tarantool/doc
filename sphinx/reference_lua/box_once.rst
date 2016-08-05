.. _box-once:

-------------------------------------------------------------------------------
                             Function `box.once`
-------------------------------------------------------------------------------

.. function:: box.once(key, function[, ...])

    Execute a function, provided it has not been executed before. A passed value
    is checked to see whether the function has already been executed. If it has
    been executed before, nothing happens. If it has not been executed before,
    the function is invoked. For an explanation why ``box.once`` is useful, see
    the section :ref:`Preventing Duplicate Actions <index-preventing_duplicate_actions>`.

    :param string        key: a value that will be checked
    :param function function: a function
    :param               ...: arguments, that must be passed to function


.. _box_tuple-pairs:

================================================================================
tuple_object:pairs(), tuple_object:ipairs()
================================================================================

.. module:: box.tuple

.. class:: tuple_object

    .. method:: pairs()
                ipairs()

        In Lua, `lua-table-value:pairs() <https://www.lua.org/pil/7.3.html>`_
        is a method which returns:
        ``function``, ``lua-table-value``, ``nil``. Tarantool has extended
        this so that ``tuple-value:pairs()`` returns: ``function``,
        ``tuple-value``, ``nil``. It is useful for Lua iterators, because Lua
        iterators traverse a value's components until an end marker is reached.

        ``tuple_object:ipairs()`` is the same as ``pairs()``, because tuple
        fields are always integers.

        :return: function, tuple-value, nil
        :rtype:  function, lua-value, nil

        In the following example, a tuple named ``t`` is created and then all
        its fields are selected using a Lua for-end loop.

        .. code-block:: tarantoolsession

            tarantool> t = box.tuple.new{'Fld#1', 'Fld#2', 'Fld#3', 'Fld#4', 'Fld#5'}
            ---
            ...
            tarantool> tmp = ''
            ---
            ...
            tarantool> for k, v in t:pairs() do
                     >   tmp = tmp .. v
                     > end
            ---
            ...
            tarantool> tmp
            ---
            - Fld#1Fld#2Fld#3Fld#4Fld#5
            ...
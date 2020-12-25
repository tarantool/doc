.. _box_space-space_index:

===============================================================================
space_object:index
===============================================================================

.. module:: box.space

.. class:: space_object

.. data:: index

    A container for all defined indexes. There is a Lua object of type
    :ref:`box.index <box_index>` with methods to search tuples and iterate
    over them in predefined order.

    To reset, use :ref:`box.stat.reset() <box_introspection-box_stat_reset>`.

    :rtype: table

    **Example:**

    .. code-block:: tarantoolsession

        -- checking the number of indexes for space 'tester'
        tarantool> local counter=0; for i=0,#box.space.tester.index do
          if box.space.tester.index[i]~=nil then counter=counter+1 end
          end; print(counter)
        1
        ---
        ...
        -- checking the type of index 'primary'
        tarantool> box.space.tester.index.primary.type
        ---
        - TREE
        ...

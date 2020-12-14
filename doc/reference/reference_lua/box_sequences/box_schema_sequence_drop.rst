.. _box_schema-sequence_drop:

===============================================================================
sequence_object:drop()
===============================================================================

.. module:: box.schema

.. function:: sequence_object:drop()

    Drop an existing sequence.

    **Example:**

    Here is an example showing all sequence options and operations:

    .. code-block:: lua

        s = box.schema.sequence.create(
                       'S2',
                       {start=100,
                       min=100,
                       max=200,
                       cache=100000,
                       cycle=false,
                       step=100
                       })
        s:alter({step=6})
        s:next()
        s:reset()
        s:set(150)
        s:drop()

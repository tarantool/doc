.. _box_schema-sequence_reset:

===============================================================================
sequence_object:reset()
===============================================================================

.. module:: box.schema

.. function:: sequence_object:reset()

    Set the sequence back to its original state.
    The effect is that a subsequent ``next()`` will return the ``start`` value.
    This function requires a :ref:`'write' privilege <box_schema-user_grant>`
    on the sequence.

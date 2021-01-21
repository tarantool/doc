.. _box_schema-sequence_reset:

===============================================================================
sequence_object:reset()
===============================================================================

..  class:: sequence_object

  ..  method:: sequence_object:reset()

    Set the sequence back to its original state.
    The effect is that a subsequent ``next()`` will return the ``start`` value.
    This function requires a
    :doc:`'write' privilege </reference/reference_lua/box_schema/user_grant>`
    on the sequence.

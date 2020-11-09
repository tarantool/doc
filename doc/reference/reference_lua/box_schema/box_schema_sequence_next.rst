.. _box_schema-sequence_next:

===============================================================================
sequence_object:next()
===============================================================================

.. module:: box.schema

.. function:: sequence_object:next()

    Generate the next value and return it.

    The generation algorithm is simple:

    * If this is the first time, then return the STARTS WITH value.
    * If the previous value plus the INCREMENT value is less than the
      MINIMUM value or greater than the MAXIMUM value, that is "overflow",
      so either raise an error (if ``cycle`` = ``false``) or return the
      MAXIMUM value (if ``cycle`` = ``true`` and ``step`` < 0)
      or return the MINIMUM value (if ``cycle`` = ``true`` and ``step`` > 0).

    If there was no error, then save the returned result, it is now
    the "previous value".

    For example, suppose sequence 'S' has:

    * ``min`` == -6,
    * ``max`` == -1,
    * ``step`` == -3,
    * ``start`` = -2,
    * ``cycle`` = true,
    * previous value = -2.

    Then ``box.sequence.S:next()`` returns -5 because -2 + (-3) == -5.

    Then ``box.sequence.S:next()`` again returns -1 because -5 + (-3) < -6,
    which is overflow, causing cycle, and ``max`` == -1.

    This function requires a :ref:`'write' privilege <box_schema-user_grant>`
    on the sequence.

    .. NOTE::

        This function should not be used in "cross-engine" transactions
        (transactions which use both the memtx and the vinyl storage engines).

        To see what the previous value was, without changing it, you can
        select from the :ref:`_sequence_data <box_space-sequence_data>`
        system space.

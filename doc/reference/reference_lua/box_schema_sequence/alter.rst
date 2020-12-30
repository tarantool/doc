.. _box_schema-sequence_alter:

===============================================================================
sequence_object:alter()
===============================================================================

.. module:: box.schema

.. function:: sequence_object:alter(options)

    The ``alter()`` function can be used to change any of the sequence's
    options. Requirements and restrictions are the same as for
    :doc:`/reference/reference_lua/box_schema_sequence/create`.

    Options:

    * ``start`` -- the STARTS WITH value. Type = integer, Default = 1.

    * ``min`` -- the MINIMUM value. Type = integer, Default = 1.

    * ``max`` - the MAXIMUM value. Type = integer, Default = 9223372036854775807.

      There is a rule: ``min`` <= ``start`` <= ``max``.
      For example it is illegal to say ``{start=0}`` because then the
      specified start value (0) would be less than the default min value (1).

      There is a rule: ``min`` <= next-value <= ``max``.
      For example, if the next generated value would be 1000,
      but the maximum value is 999, then that would be considered
      "overflow".

    * ``cycle`` -- the CYCLE value. Type = bool. Default = false.

      If the sequence generator's next value is an overflow number,
      it causes an error return -- unless ``cycle == true``.

      But if ``cycle == true``, the count is started again, at the
      MINIMUM value or at the MAXIMUM value (not the STARTS WITH value).

    * ``cache`` -- the CACHE value. Type = unsigned integer. Default = 0.

      Currently Tarantool ignores this value, it is reserved for future use.

    * ``step`` -- the INCREMENT BY value. Type = integer. Default = 1.

      Ordinarily this is what is added to the previous value.
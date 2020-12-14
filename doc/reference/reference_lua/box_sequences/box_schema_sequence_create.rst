.. _box_schema-sequence_create:

===============================================================================
box.schema.sequence.create()
===============================================================================

.. module:: box.schema

.. function:: box.schema.sequence.create(name[, options])

    Create a new sequence generator.

    :param string name: the name of the sequence

    :param table options: see a quick overview in the
                          "Options for ``box.schema.sequence.create()``"
                          :ref:`chart <index-box_sequence-options>`
                          (in the :ref:`Sequences <index-box_sequence>`
                          section of the "Data model" chapter),
                          and see more details below.

    :return: a reference to a new sequence object.

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

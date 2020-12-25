.. _box_space-sequence_data:

===============================================================================
box.space._sequence_data
===============================================================================

.. module:: box.space

.. data:: _sequence_data

    ``_sequence_data`` is a system space
    for support of the :ref:`sequence feature <index-box_sequence>`.

    Each tuple in ``_sequence_data`` contains two fields:

    * the id of the sequence, and
    * the last value that the sequence generator returned
      (non-persistent information).

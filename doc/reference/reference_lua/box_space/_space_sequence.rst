.. _box_space-space-sequence:

box.space._space_sequence
=========================

.. module:: box.space

.. data:: _space_sequence

    ``_space_sequence`` is a system space. It contains connections between spaces
    and sequences.

    Tuples in this space contain the following fields:

    *   ``id`` (``unsigned``) -- space id
    *   ``sequence_id`` (``unsigned``) -- id of the attached sequence
    *   ``is_generated`` (``boolean``) -- ``true`` if the sequence was created automatically
        via a ``space:create_index('pk', {sequence = true})`` call
    *   ``field`` (``unsigned``) -- id of the space field to which the sequence is attached.
    *   ``path`` (``string``) -- path to the data within the field that is set
        using the attached sequence.

    The :ref:`system space view <box_space-sysviews>` for ``_space_sequence`` is
    ``_vspace_sequence``.


    **Example**

    ..  literalinclude:: /code_snippets/test/sequence/sequence_test.lua
        :language: lua
        :lines: 44-48,73-86
        :dedent:
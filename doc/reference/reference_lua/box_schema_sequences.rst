.. _box_schema-sequence:

--------------------------------------------------------------------------------
Sequences
--------------------------------------------------------------------------------

================================================================================
                                  Overview
================================================================================

An introduction to sequences is in the :ref:`Sequences <index-box_sequence>`
section of the "Data model" chapter.
Here are the details for each function and option.

All functions related to sequences require appropriate
:ref:`privileges <authentication-owners_privileges>`.

================================================================================
                                  Contents
================================================================================

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.schema.sequence.create()   | Create a new sequence generator |
    | <box_schema-sequence_create>`        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:next()         | Generate and return the next    |
    | <box_schema-sequence_next>`          | value                           |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:alter()        | Change sequence options         |
    | <box_schema-sequence_alter>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:reset()        | Reset sequence state            |
    | <box_schema-sequence_reset>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:set()          | Set the new value               |
    | <box_schema-sequence_set>`           |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`sequence_object:drop()         | Drop the sequence               |
    | <box_schema-sequence_drop>`          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`space_object:create_index()    | Create an index with a sequence |
    | <box_schema-sequence_create_index>`  | option                          |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_sequences/box_schema_sequence_create
    box_sequences/box_schema_sequence_next
    box_sequences/box_schema_sequence_alter
    box_sequences/box_schema_sequence_reset
    box_sequences/box_schema_sequence_set
    box_sequences/box_schema_sequence_drop
    box_sequences/box_schema_sequence_create_index

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
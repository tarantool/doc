.. _box_schema-sequence:

--------------------------------------------------------------------------------
Sequences
--------------------------------------------------------------------------------

An introduction to sequences is in the :ref:`Sequences <index-box_sequence>`
section of the "Data model" chapter.
Here are the details for each function and option.

All functions related to sequences require appropriate
:ref:`privileges <authentication-owners_privileges>`.

Below is a list of all ``box.schema.sequence`` functions.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_schema_sequence/create`
           - Create a new sequence generator

        *  - :doc:`./box_schema_sequence/next`
           - Generate and return the next value

        *  - :doc:`./box_schema_sequence/alter`
           - Change sequence options

        *  - :doc:`./box_schema_sequence/reset`
           - Reset sequence state

        *  - :doc:`./box_schema_sequence/set`
           - Set the new value

        *  - :doc:`./box_schema_sequence/drop`
           - Drop the sequence

        *  - :doc:`./box_schema_sequence/set`
           - Set the new value

        *  - :doc:`./box_schema_sequence/create_index`
           - Create an index with a sequence option

.. toctree::
    :hidden:

    box_schema_sequence/create
    box_schema_sequence/next
    box_schema_sequence/alter
    box_schema_sequence/reset
    box_schema_sequence/set
    box_schema_sequence/drop
    box_schema_sequence/create_index

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
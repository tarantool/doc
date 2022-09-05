..  _index-box_sequence:

Using sequences
===============

A **sequence** is a generator of ordered integer values.

As with spaces and indexes, you should specify the sequence **name** and let
Tarantool generate a unique numeric identifier (sequence ID).

As well, you can specify several options when creating a new sequence.
The options determine what value will be generated whenever the sequence is used.

..  _index-box_sequence-options:

Options for box.schema.sequence.create()
----------------------------------------

..  container:: table

    ..  list-table::
        :widths: 20 40 15 25
        :header-rows: 1

        *   -   Option name
            -   Type and meaning
            -   Default
            -   Examples
        *   -   ``start``
            -   Integer. The value to generate the first time a sequence is used
            -   1
            -   ``start=0``
        *   -   ``min``
            -   Integer. Values smaller than this cannot be generated
            -   1
            -   ``min=-1000``
        *   -   ``max``
            -   Integer. Values larger than this cannot be generated
            -   9223372036854775807
            -   ``max=0``
        *   -   ``cycle``
            -   Boolean. Whether to start again when values cannot be generated
            -   false
            -   ``cycle=true``
        *   -   ``cache``
            -   Integer. The number of values to store in a cache
            -   0
            -   ``cache=0``
        *   -   ``step``
            -   Integer. What to add to the previous generated value, when generating a new value
            -   1
            -   ``step=-1``
        *   -   ``if_not_exists``
            -   Boolean. If this is true and a sequence with this name exists already,
                ignore other options and use the existing values
            -   ``false``
            -   ``if_not_exists=true``


Once a sequence exists, it can be altered, dropped, reset, forced to generate
the next value, or associated with an index.

Associating a sequence with an index
------------------------------------

For an initial example, we generate a sequence named 'S'.

..  code-block:: tarantoolsession

    tarantool> box.schema.sequence.create('S',{min=5, start=5})
    ---
    - step: 1
      id: 5
      min: 5
      cache: 0
      uid: 1
      max: 9223372036854775807
      cycle: false
      name: S
      start: 5
    ...

The result shows that the new sequence has all default values,
except for the two that were specified, ``min`` and ``start``.

Then we get the next value, with the ``next()`` function.

..  code-block:: tarantoolsession

    tarantool> box.sequence.S:next()
    ---
    - 5
    ...

The result is the same as the start value. If we called ``next()``
again, we would get 6 (because the previous value plus the
step value is 6), and so on.

Then we create a new table and specify that its primary key should be
generated from the sequence.

..  code-block:: tarantoolsession

    tarantool> s=box.schema.space.create('T')
    ---
    ...
    tarantool> s:create_index('I',{sequence='S'})
    ---
    - parts:
      - type: unsigned
        is_nullable: false
        fieldno: 1
      sequence_id: 1
      id: 0
      space_id: 520
      unique: true
      type: TREE
      sequence_fieldno: 1
      name: I
    ...
    ---
    ...

Then we insert a tuple without specifying a value for the primary key.

..  code-block:: tarantoolsession

     tarantool> box.space.T:insert{nil,'other stuff'}
     ---
     - [6, 'other stuff']
     ...

The result is a new tuple where the first field has a value of 6.
This arrangement, where the system automatically generates the
values for a primary key, is sometimes called "auto-incrementing"
or "identity".

For syntax and implementation details, see the reference for
:doc:`box.schema.sequence </reference/reference_lua/box_schema_sequence>`.

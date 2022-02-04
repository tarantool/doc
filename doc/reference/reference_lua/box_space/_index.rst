.. _box_space-index:

===============================================================================
box.space._index
===============================================================================

.. module:: box.space

.. data:: _index

    ``_index`` is a system space.

    Tuples in this space contain the following fields:

    * ``id`` (= id of space),
    * ``iid`` (= index number within space),
    * ``name``,
    * ``type``,
    * ``opts`` (e.g. unique option), [``tuple-field-no``, ``tuple-field-type`` ...].

    Here is what ``_index`` contains in a typical installation:

    .. code-block:: tarantoolsession

       tarantool> box.space._index:select{}
       ---
       - - [272, 0, 'primary', 'tree', {'unique': true}, [[0, 'string']]]
         - [280, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned']]]
         - [280, 1, 'owner', 'tree', {'unique': false}, [[1, 'unsigned']]]
         - [280, 2, 'name', 'tree', {'unique': true}, [[2, 'string']]]
         - [281, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned']]]
         - [281, 1, 'owner', 'tree', {'unique': false}, [[1, 'unsigned']]]
         - [281, 2, 'name', 'tree', {'unique': true}, [[2, 'string']]]
         - [288, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned'], [1, 'unsigned']]]
         - [288, 2, 'name', 'tree', {'unique': true}, [[0, 'unsigned'], [2, 'string']]]
         - [289, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned'], [1, 'unsigned']]]
         - [289, 2, 'name', 'tree', {'unique': true}, [[0, 'unsigned'], [2, 'string']]]
         - [296, 0, 'primary', 'tree', {'unique': true}, [[0, 'unsigned']]]
         - [296, 1, 'owner', 'tree', {'unique': false}, [[1, 'unsigned']]]
         - [296, 2, 'name', 'tree', {'unique': true}, [[2, 'string']]]
       ---
       ...

    The :ref:`system space view <box_space-sysviews>` for ``_index`` is ``_vindex``.


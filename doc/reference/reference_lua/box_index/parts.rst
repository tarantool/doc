.. _box_index-parts:

===============================================================================
index_object.parts
===============================================================================

.. class:: index_object

    .. data:: parts

    The index's key parts. 
    Since version :doc:`3.0.0 </release/3.0.0>`, the ``index_object.parts`` can operate methods
    :ref:`extract_key() <key_def-extract_key>`,
    :ref:`compare() <key_def-compare>`,
    :ref:`compare_with_key() <key_def-compare_with_key>`,
    :ref:`merge() <key_def-merge>`.

    Since version :doc:`3.1.0 </release/3.1.0>`, the ``index_object.parts`` can operate methods
    :ref:`validate_key() <key_validate_key>`,
    :ref:`validate_full_key() <key_validate_full_key>`,
    :ref:`validate_tuple() <key_validate_tuple>`,
    :ref:`compare_keys() <key_compare_keys>`.

    **``index_object.parts`` example**

    ..  code-block:: lua

            box.schema.space.create('T')
            i = box.space.T:create_index('I', {parts={3, 'string', 1, 'unsigned'}})
            box.space.T:insert{1, 99.5, 'X', nil, 99.5}
            i.parts:extract_key(box.space.T:get({'X', 1}))

    **``key_def`` equivalent**

        ..  code-block:: lua

            key_def = require('key_def')
            box.schema.space.create('T')
            i = box.space.T:create_index('I', {parts={3, 'string', 1, 'unsigned'}})
            box.space.T:insert{1, 99.5, 'X', nil, 99.5}
            k = key_def.new(i.parts)
            k:extract_key(box.space.T:get({'X', 1}))

    The outcome of the methods calling is described in :ref:`key_def_object <key_def_object>`.

        :rtype: table

        **See also:** :ref:`index_opts.parts <index_opts_parts>`

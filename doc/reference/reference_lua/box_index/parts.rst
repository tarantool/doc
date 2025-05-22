.. _box_index-parts:

===============================================================================
index_object:parts
===============================================================================

.. class:: index_object

    .. data:: parts

    The index's key parts. 
    Since version :doc:`3.0.0 </release/3.0.0>`, the ``index_object:parts`` can operate methods
    :ref:`extract_key() <key_def-extract_key>`,
    :ref:`compare() <key_def-compare>`,
    :ref:`compare_with_key() <key_def-compare_with_key>`,
    :ref:`merge() <key_def-merge>`,
    :ref:`totable() <key_def-totable>`.

    The outcome of the methods calling is described in :ref:`key_def_object <key_def_object>`.

        :rtype: table

        **See also:** :ref:`index_opts.parts <index_opts_parts>`

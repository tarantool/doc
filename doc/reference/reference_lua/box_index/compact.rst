.. _box_index-compact:

===============================================================================
index_object:compact()
===============================================================================

.. module:: box.index

.. class:: index_object

    .. method:: compact()

        Remove unused index space. For the memtx storage engine this
        method does nothing; ``index_object:compact()`` is only for the
        vinyl storage engine. For example, with vinyl, if a tuple is
        deleted, the space is not immediately reclaimed. There is a
        scheduler for reclaiming space automatically based on factors
        such as lsm shape and amplification as discussed in the section
        :ref:`Storing data with vinyl <engines-vinyl>`,
        so calling ``index_object:compact()`` manually is not always necessary.

        :return: nil (Tarantool returns without waiting for compaction to complete)

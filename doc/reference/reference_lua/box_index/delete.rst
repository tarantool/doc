.. _box_index-delete:

===============================================================================
index_object:delete()
===============================================================================

.. class:: index_object

    .. method:: delete(key)

        Delete a tuple identified by a key.

        Same as :ref:`box.space...delete() <box_space-delete>`, but key is
        searched in this index instead of in the primary-key index. This index
        ought to be unique.

        :param index_object index_object: an :ref:`object reference
                                          <app_server-object_reference>`.
        :param scalar/table key: values to be matched against the index key

        :return: the deleted tuple.
        :rtype:  tuple

        **Note regarding storage engine:**
        vinyl will return `nil`, rather than the deleted tuple.

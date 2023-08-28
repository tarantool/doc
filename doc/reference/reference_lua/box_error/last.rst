.. _box_error-last:

===============================================================================
box.error.last()
===============================================================================

.. function:: box.error.last()

    Get the last raised error.

    :return: an :ref:`error_object <box_error-error_object>` representing the last error

    **Example**

    ..  literalinclude:: /code_snippets/test/errors/unpack_clear_error_test.lua
        :language: lua
        :start-after: Get the last error: start
        :end-before: Get the last error: end
        :dedent:

    **See also:** :ref:`error_object:unpack() <box_error-unpack>`

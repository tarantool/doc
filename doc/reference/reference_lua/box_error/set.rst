.. _box_error-set:

===============================================================================
box.error.set()
===============================================================================

.. function:: box.error.set(error_object)

    **Since:** :doc:`2.4.1 </release/2.4.1>`

    Set the specified error as the last system error explicitly.
    This error is returned by :doc:`/reference/reference_lua/box_error/last`.

    :param error_object error_object: an error object

    **Example**

    ..  literalinclude:: /code_snippets/test/errors/set_error_test.lua
        :language: lua
        :start-after: snippet_start
        :end-before: snippet_end
        :dedent:

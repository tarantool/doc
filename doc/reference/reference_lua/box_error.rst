-------------------------------------------------------------------------------
                            Submodule box.error
-------------------------------------------------------------------------------

The ``box.error`` function is for raising an error. The difference between this
function and Lua's built-in `error <https://www.lua.org/pil/8.3.html>`_ function
is that when the error reaches the client, its error code is preserved.
In contrast, a Lua error would always be presented to the client as
:errcode:`ER_PROC_LUA`.

Below is a list of all ``box.error`` functions.

.. container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *   - :doc:`./box_error/error`
            - Throw an error

        *   - :doc:`./box_error/last`
            - Get a description of the last error

        *   - :doc:`./box_error/clear`
            - Clear the record of errors

        *   - :doc:`./box_error/new`
            - Create an error but do not throw

        *   - :doc:`./box_error/set`
            - Set an error as ``box.error.last()``

        *   - :doc:`./box_error/error_object`
            - Error object methods

        *   - :doc:`./box_error/custom_type`
            - Create a custom error type

..  toctree::
    :hidden:

    box_error/error
    box_error/last
    box_error/clear
    box_error/new
    box_error/set
    box_error/error_object
    box_error/custom_type
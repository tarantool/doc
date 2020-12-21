-------------------------------------------------------------------------------
                            Submodule `box.error`
-------------------------------------------------------------------------------

The ``box.error`` function is for raising an error. The difference between this
function and Lua's built-in `error <https://www.lua.org/pil/8.3.html>`_ function
is that when the error reaches the client, its error code is preserved.
In contrast, a Lua error would always be presented to the client as
``ER_PROC_LUA``.

Below is a list of all ``box.error`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.error()                    | Throw an error                  |
    | <box_error-error>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.last()               | Get a description of the        |
    | <box_error-last>`                    | last error                      |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.clear()              | Clear the record of errors      |
    | <box_error-clear>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.error.new()                | Create an error but do not      |
    | <box_error-new>`                     | throw                           |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_error/box_error_error
    box_error/box_error_last
    box_error/box_error_clear
    box_error/box_error_new
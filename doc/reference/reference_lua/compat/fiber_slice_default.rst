.. _compat-option-fiber-slice:

Default value for max fiber slice
=================================

The max fiber slice specifies the max fiber execution time without yield before a warning is logged or an error is raised.
It is set with the :ref:`fiber.set_max_slice() <fiber-set_max_slice>` function.
The new ``compat`` option – ``fiber_slice_default`` – controls the default value of the max fiber slice.

Old and new behavior
--------------------

The old default value for the max fiber slice is infinity (no warnings or errors). The new default value is ``{warn = 0.5, err = 1.0}``.
To use the new behavior, set ``fiber_slice_default`` to ``new`` as follows:

..  code-block:: lua

    compat = require('compat')
    compat.fiber_slice_default = 'new'

Known compatibility issues
--------------------------

At this point, no incompatible modules are known.

Detecting issues in you codebase
--------------------------------

If you see a warning like this in the log:

``fiber has not yielded for more than 0.500 seconds``,

or the following error is raised unexpectedly by a ``box`` function

``error: fiber slice is exceeded``,

then your application has a fiber that may exceed its slice and fail.

First, make sure that :ref:`fiber.yield() <fibers_yield_control>` is used for this fiber to transfer control to another fiber.
You can also extend the fiber slice with the :ref:`fiber.extend_slice(slice) <fiber-extend_slice>` function.

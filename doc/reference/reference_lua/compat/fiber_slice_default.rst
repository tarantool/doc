.. _compat-option-fiber-slice:

Default value for max fiber slice
=================================

Max fiber slice specifies the max fiber execution time without yield before a warning is logged or an error is raised.
It is set with the ``fiber.set_max_slice()`` function.
The new ``compat`` option – ``fiber_slice_default`` – controls the default value of the max fiber slice.

Old and new behavior
--------------------

The old default value for the max fiber slice is infinity (no warnings or errors). The new default value is ``{warn = 0.5, err = 1.0}``.

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

To fix this you need to reset the fiber slice with the ``fiber.set_max_slice()`` function.

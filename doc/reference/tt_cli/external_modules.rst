Extending the tt functionality
==============================

The ``tt`` utility implements the modular architecture: its :doc:`commands <commands>`
are implemented in separate modules. When you run ``tt`` with a command, the
corresponding module is executed with the given arguments.

Modular architecture enables the option to extend the ``tt`` functionality with
**external modules** (as opposed to **internal modules** that implement built-in
commands). Simply said, you can write any code you want to execute
from ``tt``, pack it into an executable, and run it with a command like this:

..  code-block:: bash

    tt my-module-name my-args

External modules: requirements
------------------------------

An executable can be an external ``tt`` module if it satisfies two requirements:

*   Handles mandatory flags:
    -   ``--description`` -- print a short description of the module.
    -   ``--help`` -- display help.

*   Is located in the modules directory specified in the :ref:`configuration file <tt-config_file>`.

Overloading internal modules
----------------------------

External modules can overload external modules.
If you want to change the behavior of a built-in ``tt`` command, create an external
modules with the same name and your own implementation.

When ``tt`` sees two modules -- an external and an internal one -- with the same name,
it will use the external module by default.

You can force the use of the internal module by running ``tt`` with the ``--internal`` or ``-I``
:doc:`argument <arguments>:

..  code-block:: bash

    tt version -I
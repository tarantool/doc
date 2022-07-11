Extending the tt functionality
==============================

The ``tt`` utility implements the modular architecture: its :doc:`commands <commands>`
are implemented in separate modules. When you run ``tt`` with a command, the
corresponding module is executed with the given arguments.

Modular architecture enables the option to extend the ``tt`` functionality with
**external modules** (as opposed to **internal modules** that implement built-in
commands). Simply said, you can write any code you want to execute
from ``tt``, pack it into an executable, and run it with a ``tt`` command:

..  code-block:: bash

    tt my-module-name my-args

The command that executes a module is the same as the name of its executable.


Mandaroty flags
---------------

To be an external ``tt`` module, an executable must be able to handle two flags:

-   ``--description`` -- print a short description of the module. It is shown alongside
    the command in the ``tt`` help.
-   ``--help`` -- display help. It is shown when ``tt <module-name> help`` is called.


Location
--------

External modules must be located in the modules directory specified in the
:ref:`configuration file <tt-config_file>`:

    ..  code:: yaml

        tt:
            modules:
                directory: path/to/modules/dir

To check if a module is available in ``tt``, call ``tt help``.
It will show available external modules in the ``EXTERNAL COMMANDS`` section together
with their descriptions.


Overloading built-in commands
-----------------------------

External modules can overload built-in ``tt`` commands.
If you want to change the behavior of a built-in command, create an external
modules with the same name and your own implementation.

When ``tt`` sees two modules -- an external and an internal one -- with the same name,
it will use the external module by default.

For example, if you want get the information about your Tarantool application
from ``tt``, write the corresponding external module ``version``. The ``tt version``
call will execute your implementation.

You can force the use of the internal module by running ``tt`` with the ``--internal`` or ``-I``
:doc:`argument <arguments>`. The following call will execute the built-in ``version`` command
even if there is an external module ``version``:

..  code-block:: bash

    tt version -I
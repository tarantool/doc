.. _tt-binaries:

Managing binaries in the current environment
============================================

..  code-block:: console

    $ tt binaries COMMAND [PROGRAM_NAME] [VERSION]

``tt binaries`` manages Tarantool and ``tt`` binaries installed in the current environment.

``COMMAND`` is one of the following:

-   :ref:`list <tt-binaries-list>`
-   :ref:`switch <tt-binaries-switch>`


.. _tt-binaries-list:

list
----

..  code-block:: console

    $ tt binaries list

``tt binaries list`` shows a list of installed binaries and their versions.

To show a list of installed Tarantool versions:

..  code-block:: console

    $ tt binaries list
    List of installed binaries:
       • tarantool:
            3.1.0 [active]
            2.11.2
       • tt:
            2.3.0
            2.2.1 [active]

.. _tt-binaries-switch:

switch
------

..  code-block:: console

    $ tt binaries switch [PROGRAM_NAME] [VERSION]

``tt binaries switch`` switches binaries used in the current environment.
The possible values of ``PROGRAM_NAME`` are:

*   ``tarantool``: Tarantool Community Edition.
*   ``tarantool-ee``: Tarantool Enterprise Edition.
*   ``tt``: the ``tt`` command-line utility.

When called without arguments, the command lets you choose the program and
version interactively:

..  code-block:: console

    $ tt binaries switch
    Use the arrow keys to navigate: ↓ ↑ → ←
    ? Select program:
      ▸ tarantool
        tarantool-ee
        tt

You can also specify the program name and version in the call.

To view ``tt`` versions installed in the current environment and switch
between them:

..  code-block:: console

    $ tt binaries switch tt
    Use the arrow keys to navigate: ↓ ↑ → ←
    ? Select version:
      ▸ 2.2.1
        2.3.0 [active]

To switch to a specific Tarantool EE version installed in the current environment:

..  code-block:: console

    $ tt binaries switch tarantool-ee 3.1.0


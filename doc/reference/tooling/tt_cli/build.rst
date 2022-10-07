.. _tt-build:

Build an application
====================

..  code-block:: bash

    tt build [PATH] [flags]


``tt build `` builds a Tarantool application locally.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``--spec``
            -   Path to a ``.rockspec`` file to use for the current build


Details
-------

The ``PATH`` argument should contain the path to the application directory
(that is, to the build source). The default path is ``.`` (current directory).

The application directory must contain a ``.rockspec`` file to use for the build.
If there are more than one ``.rockspec`` files in the application directory, specify
the one to use in the ``--spec`` argument.

``tt build`` runs

.. pre build?
post build?

In result

.. result?

Examples
--------

*   Build the application ``app1`` from its directory:

    ..  code-block:: bash

        tt build

*   Build the application ``app1`` from the ``simple_app`` directory inside the current directory:

    ..  code-block:: bash

        tt build simple_app

*   Build the application ``app1`` from its directory explicitly specifying the rockspec file to use:

    ..  code-block:: bash

        tt build --spec app1-scm-1.rockspec
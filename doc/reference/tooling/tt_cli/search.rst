.. _tt-search:

Listing available Tarantool versions
====================================

..  code-block:: bash

    tt search PROGRAM_NAME [flags]

``tt search`` lists versions of Tarantool and ``tt`` that are available for
installation. The possible values of ``PROGRAM_NAME`` are:

*   ``tarantool``
*   ``tarantool-ee``
*   ``tt``

.. note::

    For ``tarantool-ee``, account credentials are required. Specify them in a file
    (see the :ref:`ee section <tt-config_file_ee>` of the configuration file) or
    provide interactively.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 0

        *   -   ``--debug``
            -   (``tarantool-ee`` only) Search for debug builds of Tarantool Enterprise SDK
        *   -   ``--local-repo``
            -   Search in the local repository, which is specified in the
                :ref:`repo section <tt-config_file_repo>` of the ``tt``
                configuration file
        *   -   ``--version``
            -   (``tarantool-ee`` only) Tarantool Enterprise version

Example
--------

*   List available Tarantool versions:

    ..  code-block:: bash

        tt search tarantool

*   List available ``tt`` versions from the local repository:

    ..  code-block:: bash

        tt search tt --local-repo
.. _tt-search:

Listing available Tarantool versions
====================================

..  code-block:: console

    $ tt search PROGRAM_NAME [OPTION ...]

``tt search`` lists versions of Tarantool and ``tt`` that are available for
installation. The possible values of ``PROGRAM_NAME`` are:

*   ``tarantool``
*   ``tarantool-ee``
*   ``tt``

.. note::

    For ``tarantool-ee``, account credentials are required. Specify them in a file
    (see the :ref:`ee section <tt-config_file_ee>` of the configuration file) or
    provide interactively.

Options
-------

.. option:: --debug

    **Applicable to:** ``taranttol-ee``

    Search for debug builds of Tarantool Enterprise SDK.

.. option:: --local-repo

    Search in the local repository, which is specified in the
    :ref:`repo section <tt-config_file_repo>` of the ``tt`` configuration file.

.. option:: --version VERSION

    **Applicable to:** ``taranttol-ee``

    Tarantool Enterprise version.

Example
--------

*   List available Tarantool versions:

    ..  code-block:: console

        $ tt search tarantool

*   List available ``tt`` versions from the local repository:

    ..  code-block:: console

        $ tt search --local-repo tt
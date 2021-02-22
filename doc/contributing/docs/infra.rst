
Documentation infrastructure
=============================

In this section of the :doc:`documentation guidelines </contributing/docs>`,
we deal with some support activities to ensure the correct building of
documentation.

.. _guidelines_doc_submodules:

Adding submodules
-----------------

The source files with the documentation content are mainly stored in the
`documentation repository <https://github.com/tarantool/doc>`_.
However, in some of the cases the content source files are stored in
repositories of other Tarantool-related products and modules, for example,
`Cartridge <https://github.com/tarantool/cartridge>`_,
`Monitoring <https://github.com/tarantool/metrics/tree/master/doc/monitoring>`_,
and some others.

In this case, we need to add such a repository containing the source files
as a submodule to the `documentation repository <https://github.com/tarantool/doc>`_
and set up other necessary settings to ensure the proper building of the entire
body of Tarantool documentation presented at the `official web-site <http://www.tarantool.io/en/doc>`_.

The steps to do that are the following:

.. contents::
   :local:
   :depth: 1

.. _guidelines_doc_submodules_add:

1. Add a submodule
~~~~~~~~~~~~~~~~~~

First, we need to add a repository containing the content source files as
a submodule.

#.  Make sure you are in the root directory of the documentation repository.

#.  In the ``./modules`` directory, add the new submodule:

    ..  code-block:: bash

        cd modules
        git submodule add https://<path_to_submodule_repository>
        cd ..


#.  Check that the new submodule appears in the ``.gitmodules`` file, for example:

   ..   code-block:: ini

        [submodule "modules/metrics"]
           path = modules/metrics
           url = https://github.com/tarantool/metrics.git

.. _guidelines_doc_submodules_update:

2. Update build_submodules.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Next, we should define what directories and files are to be copied from
the submodule repository into the documentation one before building
documentation. These settings are defined in the ``build_submodules.sh`` file
which is in the root directory of the documentation repository.

We can take examples of the already existing submodules to show the logic of
the settings.

metrics
^^^^^^^

In case of the ``metrics`` submodule, the content source files are in the
``./doc/monitoring`` directory of the submodule repository.
In the final documentation view, the content should appear in the
`Monitoring <https://www.tarantool.io/en/doc/latest/book/monitoring/>`_
chapter (``https://www.tarantool.io/en/doc/latest/book/monitoring/``).

So, we need to:

*   create a directory at ``./doc/book/monitoring/``.
*   copy the entire content of the  ``./modules/metrics/doc/monitoring/`` directory to
    ``./doc/book/monitoring/``.

The corresponding lines in the ``build_submodules.sh`` file are the following:

..  code-block:: bash

    monitoring_root="${project_root}/modules/metrics/doc/monitoring" #
    monitoring_dest="${project_root}/doc/book"

    mkdir -p "${monitoring_dest}"
    yes | cp -rf "${monitoring_root}" "${monitoring_dest}/"

The ``${project_root}`` variable is defined earlier as ``project_root=$(pwd)``.
We should start the documentation build from the documentation repository root
directory so that will be the value of the variable.

cartridge_cli
^^^^^^^^^^^^^

In case of the ``cartridge_cli`` submodule, the content source is in
the ``README.rst`` file located in the directory of the submodule repository.
In the final documentation view, the content should appear here:
``https://www.tarantool.io/en/doc/latest/book/cartridge/cartridge_cli/``.

So, we need to:

*   create a directory at ``./doc/book/cartridge/cartridge_cli``
*   copy ``./modules/cartridge_cli/README.rst`` to
    ``./doc/book/cartridge/cartridge_cli/index.rst``.

The corresponding settings in the ``build_submodules.st`` file are the following:

..  code-block:: bash

    rst_dest="${project_root}/doc/book/cartridge"
    cartridge_cli_root="${project_root}/modules/cartridge-cli"
    cartridge_cli_dest="${rst_dest}/cartridge_cli"
    cartridge_cli_index_dest="${cartridge_cli_dest}/index.rst"

    mkdir -p "${cartridge_cli_dest}"
    yes | cp -rf "${cartridge_cli_root}/README.rst" "${cartridge_cli_index_dest}"

.. _guidelines_doc_submodules_gitignore:

3. Update .gitignore
~~~~~~~~~~~~~~~~~~~~

Finaly, we should add paths to the copied directories and files to
the ``.gitignore`` file.

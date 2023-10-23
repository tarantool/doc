
Documentation infrastructure
=============================

This section of the :doc:`documentation guidelines </contributing/docs>`
discusses some of the support activities that ensure the correct building of
documentation.

.. _guidelines_doc_submodules:

Adding submodules
-----------------

The documentation source files are mainly stored in the
`documentation repository <https://github.com/tarantool/doc>`_.
However, in some cases, they are stored in the
repositories of other Tarantool-related products
or modules, such as
`Monitoring <https://github.com/tarantool/metrics/tree/master/doc/monitoring>`__.

If you are working with source files from a product or module repository,
add that repository as a submodule to the
`documentation repository <https://github.com/tarantool/doc>`_
and configure other necessary settings.
This will ensure that the entire
body of Tarantool documentation,
presented on the `official website <http://www.tarantool.io/en/doc>`_,
is built properly.

Here is how to do that:

.. contents::
   :local:
   :depth: 1

.. _guidelines_doc_submodules_add:

1. Add a submodule
~~~~~~~~~~~~~~~~~~

First, we need to add the repository with content source files as
a submodule.

#.  Make sure you are in the root directory of the documentation repository.

#.  In the ``./modules`` directory, add the new submodule:

    ..  code-block:: bash

        cd modules
        git submodule add https://<path_to_submodule_repository>
        cd ..


#.  Check that the new submodule is in the ``.gitmodules`` file, for example:

   ..   code-block:: ini

        [submodule "modules/metrics"]
           path = modules/metrics
           url = https://github.com/tarantool/metrics.git

.. _guidelines_doc_submodules_update:

2. Update build_submodules.sh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now define what directories and files are to be copied from
the submodule repository to the documentation repository before building
documentation. These settings are defined in the ``build_submodules.sh`` file
in the root directory of the documentation repository.

Here are some real submodule examples
that show the logic of the settings.

metrics
^^^^^^^

The content source files for the ``metrics`` submodule are in the
``./doc/monitoring`` directory of the submodule repository.
In the final documentation view, the content should appear in the
`Monitoring <https://www.tarantool.io/en/doc/latest/book/monitoring/>`__
chapter (``https://www.tarantool.io/en/doc/latest/book/monitoring/``).

To make this work:

*   Create a directory at ``./doc/book/monitoring/``.
*   Copy the entire content of the  ``./modules/metrics/doc/monitoring/`` directory to
    ``./doc/book/monitoring/``.

Here are the corresponding lines in ``build_submodules.sh``:

..  code-block:: bash

    monitoring_root="${project_root}/modules/metrics/doc/monitoring" #
    monitoring_dest="${project_root}/doc/book"

    mkdir -p "${monitoring_dest}"
    yes | cp -rf "${monitoring_root}" "${monitoring_dest}/"

The ``${project_root}`` variable is defined earlier in the file as ``project_root=$(pwd)``.
This is because the documentation build has to start from the documentation repository root
directory.

.. _guidelines_doc_submodules_gitignore:

3. Update .gitignore
~~~~~~~~~~~~~~~~~~~~

Finally, add paths to the copied directories and files to ``.gitignore``.

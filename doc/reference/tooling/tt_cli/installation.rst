Installation
============

To install the ``tt`` command-line utility, use a package manager -- ``yum``
or ``apt``. If you need a specific ``tt`` build or use MacOS, you can build
``tt`` from sources.

Using package managers
----------------------

On Linux systems, you can install with ``yum`` or ``apt`` package managers from
the ``tarantool/modules`` repository. Learn how to `add this repository
<https://www.tarantool.io/en/download/os-installation/>`_.

The installation command looks like this:

*   On Ubuntu:

    .. code-block:: console

      $ sudo apt-get install tt

*   On CentOS:

    .. code-block:: console

      $ sudo yum install tt

Building from sources
---------------------

.. note::

    As of ``tt`` 1.0.0, there is no pre-built version for MacOS, so building
    from sources is the only supported way to install ``tt`` on it.

1.  Install third-party software required for building ``tt``:

  * `git <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`__,
    the version control system.
  * `Go language <https://golang.org/doc/install>`__, version 1.18 or later.
  * `mage <https://magefile.org/>`__ build tool.

2.  Clone the `tarantool/tt <https://github.com/tarantool/tt>`_ repository:

    ..  code-block:: bash

      git clone https://github.com/tarantool/tt --recursive

3.  Go to the ``tt/`` directory:

    ..  code-block:: bash

      cd tt

4.  (Optional) Checkout a release tag to build a specific version:

    ..  code-block:: bash

      git checkout tags/v1.0.0

5.  Build ``tt`` using mage:

    ..  code-block:: bash

      mage build

``tt`` will appear in the current directory.

Enabling shell completion
-------------------------

To enable the completion for ``tt`` commands, run the following command specifying
the shell (``bash`` or ``zsh``):

..  code-block:: bash

      . <(tt completion bash)
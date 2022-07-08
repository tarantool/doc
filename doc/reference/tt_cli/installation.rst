Installation
===================

1.  Install third-party software required for building ``tt``:

  * `git <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`__,
    the version control system.
  * `Go language <https://golang.org/doc/install>`__, version 1.18 or later.
  * `mage <https://magefile.org/>`__ build tool.

2.  Clone the `tarantool/tt <https://github.com/tarantool/tt>`_ repository:

    ..  code-block:: bash

      git clone https://github.com/tarantool/tt --recursive

3.  Go to the ``tt/`` directory and build ``tt`` using mage:

    ..  code-block:: bash

      cd tt
      mage build

``tt`` will appear in the current directory.

Enabling shell completion
-------------------------

To enable the completion for ``tt`` commands, run the following command specifying
the shell (``bash`` or ``zsh``):

..  code-block:: bash

      . <(tt completion bash)
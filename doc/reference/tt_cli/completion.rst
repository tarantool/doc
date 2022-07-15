Generating completion for tt
============================

..  code-block:: bash

    tt completion SHELL

``tt completion`` generates tab-based completion for ``tt`` commands
in the specified shell.

Details
-------

``tt`` completion can be generated for two shells: ``bash`` and ``zsh``.

The generated completion includes both internal and external commands.

Examples
--------

Generate ``tt`` completion for ``bash``:

..  code-block:: bash

    . <(tt completion bash)
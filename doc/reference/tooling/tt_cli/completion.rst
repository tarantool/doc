.. _tt-completion:

Generating completion for tt
============================

..  code-block:: console

    $ tt completion SHELL

``tt completion`` generates tab-based completion for ``tt`` commands
in the specified shell: ``bash`` or ``zsh``.


Examples
--------

Generate ``tt`` completion for the current ``bash`` terminal:

..  code-block:: console

    $ . <(tt completion bash)

.. note::

    You can add an execution of the completion script to a user's ``.bashrc``
    file to make the completion work for this user in all their terminals.
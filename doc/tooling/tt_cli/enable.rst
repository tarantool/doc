.. _tt-enable:

Adding external applications to environments
============================================

..  code-block:: console

    $ tt enable {APPLICATION|SCRIPT}

``tt enable`` adds an external Tarantool application to the current environment
by creating a symlink to it in the ``instances.enabled`` directory.

To add the application located in ``/home/tt-user/external_app`` to the current
``tt`` environment:

..  code-block:: console

    $ tt enable /home/tt-user/external_app

Once the application is added, you can work with it the same way as with applications
created in this environment.
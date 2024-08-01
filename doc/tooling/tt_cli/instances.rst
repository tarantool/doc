.. _tt-instances:

Listing enabled applications
============================

..  code-block:: console

    $ tt instances

``tt instances`` shows the list of enabled applications and their instances
in the current environment.

.. note::

    *Enabled* applications are applications that are stored inside the ``instances_enabled``
    directory specified in the :ref:`tt configuration file <tt-config_file_app>`.
    They can be either running or not. To check if an application is running,
    use :doc:`tt status <status>`.

Example
--------

*   Show the list of enabled applications and their instances:

    ..  code-block:: console

        $ tt instances
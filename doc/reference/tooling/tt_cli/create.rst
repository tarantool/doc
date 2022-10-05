.. _tt-create:

Create an application from a template
=====================================

..  code-block:: bash

    tt create TEMPLATE_NAME [flags]


``tt create`` creates a new Tarantool application from a specified template.

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``-d``

                ``--dst``
            -   Path to the directory where the application will be created
        *   -   ``-f``

                ``--force``
            -   Force rewrite the application directory if it already exists
        *   -   ``-n``

                ``--name``
            -   Application name
        *   -   ``-s``

                ``--non-interactive``
            -   Non-interactive mode
        *   -   ``--var``
            -   Variable definition. Usage: ``--var var_name=value``
        *   -   ``--vars-file``
            -   Path to the file with variable definitions

Details
-------

Application templates define the

Template structure
~~~~~~~~~~~~~~~~~~

An application template must contain two

*   MANIFEST.yml
*   init.lua.tt.template

Optional:
pre-build
post-build
other files

Variables
~~~~~~~~~



Location
~~~~~~~~

By default, the application will appear in the directory named after the provided
application name (``--name`` value).

..  What is the parent directory: working or current?

To change the application location, use the ``-dst`` flag.



Examples
--------

*   Create the application ``app1`` from the ``simple_app`` template in the current directory:

    ..  code-block:: bash

        tt create simple_app --name app1


*   Create the ``cartridge_app`` application in ``/opt/tt/apps/``, set the ``user_name``
    variable to ``admin``, force rewrite the application directory if it already exists.
    User interaction is disabled.

    ..  code-block:: bash

        tt create cartridge --name cartridge_app --var user_name=admin -f --non-interactive -dst /opt/tt/apps/

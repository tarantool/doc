.. _tt-create:

Create an application from a template
=====================================

..  code-block:: bash

    tt create TEMPLATE_NAME [flags]


``tt create``

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``-d``

                ``--dst``
            -   Path to the directory where an application will be created
        *   -   ``-f``

                ``--force``
            -   Force rewrite application directory if already exists
        *   -   ``-n``

                ``--name``
            -   Application name
        *   -   ``-s``

                ``--non-interactive``
            -   Non-interactive mode
        *   -   ``--var``
            -   Variable definition. Usage: --var var_name=value
        *   -   ``--vars-file``
            -   Variables definition file path

Details
-------


Examples
--------

*   Create an application ``app1`` from a template:

    ..  code-block:: bash

        tt create <template name> --name app1


*   Create cartridge_app application in /opt/tt/apps/, set user_name value,
    force replacing of application directory (cartridge_app) if it exists.
    User interaction is disabled.

    ..  code-block:: bash

        tt create <template name> --name cartridge_app --var user_name=admin -f --non-interactive -dst /opt/tt/apps/

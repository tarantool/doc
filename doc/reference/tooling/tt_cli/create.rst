.. _tt-create:

Create an application from a template
=====================================

..  code-block:: bash

    tt create TEMPLATE_NAME [flags]


``tt create`` creates a new Tarantool application from a template.

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

*Application templates* streamline the development of Tarantool applications by
defining their initial structure and content. A template can include the application
code, configuration, build scripts, and other resources.

.. git commit? as in cartridge
.. don't include rocks?

Template structure
~~~~~~~~~~~~~~~~~~

A minimal application template is a directory with two files:

*   MANIFEST.yml
*   *.lua.tt.template  .. restrictions on .tt.template file name?



Optional:
pre-build
post-build
other files

.. Manifest structure: required and optional components?


Variables
~~~~~~~~~

Templates can use variables. These variables are replaced with their
provided values upon the template instantiation.

All templates have the ``name`` variable. Its value is taken from the `--name`` flag.
.. what are built-in variables? name, something else?

To add more variables, define them in the ``vars`` section of the template manifest.
A variable can have the following attributes:

*   ``prompt``: a line of text inviting to enter the variable value in the interactive mode
*   ``name``: the variable name
*   ``default``: the default value
*   ``re``: a regular expression that the value must match

.. what are optional and required var attributes?

Example:

..  code:: yaml

    vars:
      - prompt: Cluster cookie
        name: cluster_cookie
        default: cookie
        re: ^\w+$

Variables can be used in file names and their content. To use a variable, enclose its
name with a period in the beginning in double curly braces: ``{{.var_name}}`` (as in
the ``Golang text templates <https://golang.org/pkg/text/template/>`__ syntax).

For example, variables usage in the template code can look like this:

..  code:: lua

    local app_name = {{.name}}
    local login = {{.user_name}}

And a file name containing a variable may be ``{{.user_name}}.txt``.

Variables receive their values during the template instantiation. There are three
ways to pass the values:

*   Interactively: when you call ``tt create``, you will be asked to enter the values.
    You can use the ``-s`` (or ``--non-interactive``) flag to disable the interactive
    input.
.. what happens with non-provided values in non-interactive mode?

*   In ``--var`` flag. Pass a string of the ``var=value`` format after the ``--var``
    flag. You can pass multiple variables, each after a separate ``--var`` flag:

    ..  code-block:: bash

        tt create template app --var user_name=admin

*   In a file. Specify ``var=value`` pairs in a file (each on a new line) and
    pass it after the ``--vars-file`` flag:

    ..  code-block:: bash

        tt create template app --vars-file variables.txt

    ``variables.txt`` cal look like this:

    ..  code-block:: text

        user_name=admin
        password=p4$$w0rd
        version=2

You can combine all three ways of passing variables in a single call of ``tt create``.

.. what if a variable in assigned in more than one way?

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

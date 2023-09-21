.. _tt-create:

Creating an application from a template
=======================================

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

*Application templates* speed up the development of Tarantool applications by
defining their initial structure and content. A template can include application
code, configuration, build scripts, and other resources.

``tt`` searches templates in the directories specified in the ``templates`` section
of its :ref:`configuration file <tt-config_file>`.

Template structure
~~~~~~~~~~~~~~~~~~

Application templates are directories with files.

The main file of a template is its *manifest*. It defines how the applications
are instantiated from this template.

A template manifest is a YAML file named ``MANIFEST.yaml``. It can contain the following sections:

*   ``description`` -- the template description.
*   ``vars`` -- :ref:`template variables <template-variables>`.
*   ``pre-hook`` and ``post-hook`` -- paths to executables to run before and after the template
    instantiation.
*   ``include`` -- a list of files to keep in the application directory after
    instantiation. If this section is omitted, the application will contain all template files
    and directories.

All sections are optional.

Example:

..  code-block:: yaml

    description: Template description
    vars:
      - prompt: User name
        name: user_name
        default: admin
        re: ^\w+$

      - prompt: Retry count
        default: "3"
        name: retry_count
        re: ^\d+$
    pre-hook: ./hooks/pre-gen.sh
    post-hook: ./hooks/post-gen.sh
    include:
      - init.lua
      - instances.yml

Files and directories of a template are copied to the application directory
according to the ``include`` section of the manifest (or its absence).

.. note::

    Don't include the ``.rocks`` directory in application templates.
    To specify application dependencies, use the ``.rockspec`` files.

There is a special file type ``*.tt.template``. The content of such files is
adjusted for each application with the help of :ref:`template variables <template-variables>`.
During the instantiation, the variables in these files are replaced with provided
values and the ``*.tt.template`` extension is removed.

.. _template-variables:

Variables
~~~~~~~~~

Templates variables are replaced with their values provided upon the instantiation.

All templates have the ``name`` variable. Its value is taken from the ``--name`` flag.

To add other variables, define them in the ``vars`` section of the template manifest.
A variable can have the following attributes:

*   ``prompt``: a line of text inviting to enter the variable value in the interactive mode. Required.
*   ``name``: the variable name. Required.
*   ``default``: the default value. Optional.
*   ``re``: a regular expression that the value must match. Optional.

Example:

..  code-block:: yaml

    vars:
      - prompt: Cluster cookie
        name: cluster_cookie
        default: cookie
        re: ^\w+$

Variables can be used in all file names and the content of ``*.tt template`` files.

.. note::

    Variables don't work in directory names.

To use a variable, enclose its name with a period in the beginning in double curly braces:
``{{.var_name}}`` (as in the `Golang text templates <https://golang.org/pkg/text/template/>`__
syntax).

Examples:

*   ``init.lua.tt.template`` file:

    ..  code:: lua

        local app_name = {{.name}}
        local login = {{.user_name}}

*   A file name ``{{.user_name}}.txt``

Variables receive their values during the template instantiation. By default, ``tt create``
asks you to provide the values interactively. You can use the ``-s`` (or ``--non-interactive``)
flag to disable the interactive input. In this case, the values are searched in the following order:

*   In the ``--var`` flag. Pass a string of the ``var=value`` format after the ``--var``
    flag. You can pass multiple variables, each after a separate ``--var`` flag:

    ..  code-block:: bash

        tt create template app --var user_name=admin

*   In a file. Specify ``var=value`` pairs in a plain text file, each on a new line, and
    pass it as the value of the ``--vars-file`` flag:

    ..  code-block:: bash

        tt create template app --vars-file variables.txt

    ``variables.txt`` can look like this:

    ..  code-block:: text

        user_name=admin
        password=p4$$w0rd
        version=2

If a variable isn't initialized in any of these ways, the default value
from the manifest will be used.

You can combine different ways of passing variables in a single call of ``tt create``.

Application directory
~~~~~~~~~~~~~~~~~~~~~

By default, the application will appear in the directory named after the provided
application name (``--name`` value).

To change the application location, use the ``-dst`` flag.

Examples
--------

*   Create the application ``app1`` from the ``simple_app`` template in the current directory:

    ..  code-block:: bash

        tt create simple_app --name app1


*   Create the ``app1`` application in ``/opt/tt/apps/``, set the ``user_name``
    variable to ``admin``, force rewrite the application directory if it already exists.
    User interaction is disabled.

    ..  code-block:: bash

        tt create cartridge --name app1 --var user_name=admin -f --non-interactive -dst /opt/tt/apps/

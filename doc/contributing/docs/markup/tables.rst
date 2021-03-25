Tables
======

Tables are very useful and rST markup
`offers <https://docutils.sourceforge.io/docs/ref/rst/directives.html#tables>`_
different ways to create them.

We prefer list-tables to create table of contents:

..  code-block:: rst

    ..  container:: table

        ..  list-table::
            :widths: 25 75
            :header-rows: 1

            *   - Name
                - Use

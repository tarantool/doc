Tables
======

Tables are very useful and rST markup
`offers <https://docutils.sourceforge.io/docs/ref/rst/directives.html#tables>`_
different ways to create them.

We prefer list-tables because they allow you to put as much content as you need
without painting ASCII-style borders:

..  literalinclude:: _includes/table.rst
    :language: rst

This is how the table will look like:

..  include:: _includes/table.rst

Notice that we use ``*`` and then ``-`` in tables because it is more readable
when rows and columns marked differently.
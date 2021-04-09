Tables
======

Tables are very useful and rST markup
`offers <https://docutils.sourceforge.io/docs/ref/rst/directives.html#tables>`_
different ways to create them.

We prefer list-tables because they allow you to put as much content as you need
without painting ASCII-art borders:

..  literalinclude:: _includes/table.rst
    :language: rst

And this table will appear like this:

..  include:: _includes/table.rst

Notice that we use ``*``, then ``-`` in tables because it is more readable
when rows and columns marked differently.
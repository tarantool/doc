General syntax guidelines
=========================

Basic syntax
------------

Paragraphs contain text and may contain inline markup: *emphasis*,
**strong emphasis**, `interpreted text`, ``inline literals``.

Text can be organized in bullet-lists:

..  code-block:: rst

    *   This is a bullet list.

    *   Bullets can be "*", "+", or "-".

        -   Lists can be nested. And it is good to indent them with 4 spaces.

or in enumerated lists:

..  code-block:: rst

    1.  This is an enumerated list.

    2.  Tarantool build uses only arabic numbers as enumerators.

    #.  You can put #. instead of point numbers and Sphinx will
        recognize it as an enumerated list.

Wrapping text
-------------

It's good practice to wrap lines in documentation source text.
It makes source better readable and results in lesser ``git diff``'s.
The recommended limit is 80 characters per line for plain text.

In new documents, try to wrap lines by sentences,
or by parts of a complex sentence.
Don't wrap formatted text if it affects rST readability and/or HTML output.
However, wrapping with proper indentation shouldn't break things.

Indentation
-----------

In rST, indents play exactly the same role as in Python: they denote object
boundaries and nesting.

For example, a list starts with a marker, then come some spaces and text.
From there, all lines relating to that list item must be at the
same indentation level. We can continue the list item by creating a second
paragraph in it. To do that we have to leave it at the same level.

We can put a new object inside: another list, or a block of code. Then we have
to indent 4 more spaces.

It's best if all indents are multiples of 4 spaces, even in lists. Otherwise
the document is not consistent. Also, it is much easier to put indents
with tabs than manually.

Note that you have to use two or three spaces instead of one.
It is allowed in rST markup:

..  code-block:: rst

    |...|...|...|...
    *   unordered list
    #.  ordered list
    ..  directive::
    |...|...|...|...

Example:

..  literalinclude:: _includes/indentation.rst
    :language: rst

Resulting output:

    ..  include:: _includes/indentation.rst
        :start-line: 1
        :end-line: -1

Making comments
---------------

Sometimes we may need to leave comments in an rST file. To make Sphinx ignore
some text during processing, use the following per-line notation with ".. //" as
the comment marker:

..  code-block:: rst

    .. // your comment here

The starting characters ``.. //`` do not interfere with the other rST markup, and
they are easy to find both visually and using ``grep``. There are no characters
to escape in grep search, just go ahead with something like this:

..  code-block:: console

    $ grep ".. //" doc/sphinx/dev_guide/*.rst

These comments don't work properly in nested documentation, though.
For example, if you leave a comment in module -> object -> method,
Sphinx ignores the comment and all nested content that follows
in the method description.

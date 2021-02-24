================================================================================
reStructuredText markup
================================================================================

Tarantool documentation is built via
`Sphinx <https://www.sphinx-doc.org/en/master/index.html>`_ engine and is written in
`reStructuredText <https://docutils.sourceforge.io/docs/ref/rst/restructuredtext.html>`_
markup. This document will guide you through our typical cases while writing the docs.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
General syntax guidelines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Paragraphs contain text and may contain inline markup: *emphasis*,
**strong emphasis**, `interpreted text`, ``inline literals``.

Text can be organized in bullet-lists:

..  code-block:: rst

    - This is a bullet list.

    - Bullets can be "*", "+", or "-".

        * Lists can be nested. And it is good to indent them with 4 spaces.

or in enumerated lists:

..  code-block:: rst

    1.  This is an enumerated list.

    2.  Tarantool build uses only arabic numbers as enumerators.

    #.  You can put #. instead of point numbers and Sphinx will
        recognize it as an enumerated list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Wrapping text
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It's good practice to wrap lines in documentation source text.
It makes source better readable and results in lesser ``git diff``'s.
The recommended limit is 80 characters per line for plain text.

In new documents, try to wrap lines by sentences,
or by parts of a complex sentence.
Don't wrap formatted text if it affects rST readability and/or HTML output.
However, wrapping with proper indentation shouldn't break things.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Indentation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Code snippets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For code snippets, we use the ``code-block:: language``
`directive <https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html#directive-code-block>`_
with an appropriate highlighting language.
The most commonly used highlighting languages are:

*   ``tarantoolsession``—interactive Tarantool session,
    where command lines start with ``tarantlool>`` prompt.
*   ``console``—interactive console session, where command lines start with ``$`` or ``#``.
*   ``lua``, ``bash`` or ``c`` for programming languages.
*   ``text`` for cases when we want the code block to have no highlighting.

Sphinx uses the Pygments library for highlighing source code.
For a complete list of possible languages, see the
`list of Pygments lexers <https://pygments.org/docs/lexers/>`_.

For example, a code snippet in Lua:

..  literalinclude:: _includes/lua.rst
    :language: rst

Lua syntax is highlighted in the output:

..  include:: _includes/lua.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Inline code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To format some inline text as ``code``, enclose it with double ````` characters
or use the ``:code:`` role:

..  literalinclude:: _includes/inline-code.rst
    :language: rst

Both options produce the same output:

..  include:: _includes/inline-code.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Highlighting variables in code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you need to highlight variables in code inline, use the ``:samp:`` role,
like this:

..  literalinclude:: _includes/samp.rst
    :language: rst

And you will get this:

..  include:: _includes/samp.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Linking to other documentation pages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create a link to another document in our documentation, we use the ``:doc:`` role.
For example, this link points to the document ``/reference/reference_lua/box_error.rst``:

..  code-block:: rst

    :doc:`box.error reference </reference/reference_lua/box_error>`

Our convention is to put the full path to the referred document so that we can
easily replace the path if it changes.
Note that we can omit the ``.rst`` part of the filename.

You can use the target document's title as the link text.
To do so, omit the text in the link definition:

..  literalinclude:: _includes/doc-link.rst
    :language: rst

And you will get this:

..  include:: _includes/doc-link.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Linking to labels (anchors)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To generate a link to the certain place in the page, we use the ``:ref:`` role.
For this purpose, we add our own labels for linking to any place in this documentation.

Our naming convention is as follows:

* Character set: a through z, 0 through 9, dash, underscore.
* Format: ``path dash filename dash tag``

**Example:**

..  code-block:: rst

    ..  _c_api-box_index-iterator_type:

where:

*   ``c_api`` is the directory name,
*   ``box_index`` is the file name (without ".rst"), and
*   ``iterator_type`` is the tag.

Use a dash "-" to delimit the path and the file name. In the documentation
source, we use only underscores "_" in paths and file names, reserving dash "-"
as the delimiter for local links.

The tag can be anything meaningful. The only guideline is for Tarantool syntax
items (such as members), where the preferred tag syntax is
``module_or_object_name dash member_name``. For example, ``box_space-drop``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Linking to external resources
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To make an external link, use the following syntax:

..  code-block:: text

    This is a paragraph that contains `a link <http://example.com/>`_.

Avoid separating the link and the target definition, like this:

..  container:: dont

    ..  code-block:: rst

        This is wrong way to make `a link`_.

        ..  _a link: http://example.com/

**Warning:** Every separated link tends to cause troubles when this documentation
is translated to other languages. Please avoid using separated links.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Titles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Admonitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Making comments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

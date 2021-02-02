================================================================================
Markup issues
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
Wrapping text and indentation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The limit is 80 characters per line for plain text, and no limit for any other
constructions when wrapping affects rST readability and/or HTML output. Also,
it makes no sense to wrap text into lines shorter than 80 characters unless you
have a good reason to do so.

In rST, indents play exactly the same role as in Python: they denote object
boundaries and nesting.

For example, a list starts with a marker, then come some spaces and text.
From there, all lines relating to that list item must be at the
same indentation level. We can continue the list item by creating a second
paragraph in it. To do that we have to leave it at the same level.

We can put a new object inside: another list, or a block of code. Then we have
to indent 4 more spaces.

Ideally, when all indents are multiples of 4 spaces, even in lists. Otherwise
the document is not consistent. Also, it is much easier to put indents
with tabs than manually.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Formatting code snippets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For code snippets, we mainly use the ``code-block`` directive with an appropriate
highlighting language. The most commonly used highlighting languages are:

* ``.. code-block:: tarantoolsession``
* ``.. code-block:: console``
* ``.. code-block:: lua``
* ``.. code-block:: text``
* ``.. code-block:: с``

For example (a code snippet in Lua):

..  code-block:: lua

    for page in paged_iter("X", 10) do
      print("New Page. Number Of Tuples = " .. #page)
      for i=1,#page,1 do print(page[i]) end
    end

If you need to highlight some variables in code inline, use ``:samp:`` role,
like this:

..  code-block:: rst

    :samp:`{space_object}:insert`:code:`({ffi.cast('double',`:samp:`{value}`:code:`)})`

And you will get this: :samp:`{space_object}:insert`:code:`({ffi.cast('double',`:samp:`{value}`:code:`)})`

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Creating links
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Tarantool documentation we have these types of links:

* a link to a document
* a link to a label
* a link to an external source

------------------------------
Linking to document
------------------------------

We use ``:doc:`` role to create a link to another document in our documentation,
like this:

..  code-block:: rst

    :doc:`box.error reference </reference/reference_lua/box_error>`

Our convention is to put the full path to the referred document so that we can
easily replace the path if it changes.

------------------------------
Linking to label
------------------------------

We use ``:ref:`` role to generate link to the certain place in the page. For this
purpose, we add our own labels for linking to any place in this documentation.

Our naming convention is as follows:

* Character set: a through z, 0 through 9, dash, underscore.
* Format: ``path dash filename dash tag``

**Example:**

``_c_api-box_index-iterator_type`` |br|
where: |br|
``c_api`` is the directory name, |br|
``box_index`` is the file name (without ".rst"), and |br|
``iterator_type`` is the tag.

Use a dash "-" to delimit the path and the file name. In the documentation
source, we use only underscores "_" in paths and file names, reserving dash "-"
as the delimiter for local links.

The tag can be anything meaningful. The only guideline is for Tarantool syntax
items (such as members), where the preferred tag syntax is
``module_or_object_name dash member_name``. For example, ``box_space-drop``.

------------------------------
Linking to external resources
------------------------------

Avoid separating the link and the target definition, like this:

..  code-block:: rst

   This is a paragraph that contains `a link`_.

   ..  _a link: http://example.com/

Use non-separated links instead:

..  code-block:: rst

   This is a paragraph that contains `a link <http://example.com/>`_.

Warning: Every separated link tends to cause troubles when this documentation is
translated to other languages. Please avoid using separated links unless it is
REALLY needed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Tables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tables are very useful and rST markup
`offers <https://docutils.sourceforge.io/docs/ref/rst/directives.html#tables>`_
different ways to create them.

We prefer list-tables to create table of contents.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Titles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Admonitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              Making comments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes we may need to leave comments in a rST file. To make sphinx ignore
some text during processing, use the following per-line notation with ".. //" as
the comment marker:

..  code-block:: rst

    .. // your comment here

The starting symbols ".. //" do not interfere with the other rST markup, and
they are easy to find both visually and using grep. There are no symbols to
escape in grep search, just go ahead with something like this:

..  code-block:: console

    $ grep ".. //" doc/sphinx/dev_guide/*.rst

These comments don't work properly in nested documentation, though (e.g. if you
leave a comment in module -> object -> method, sphinx ignores the comment and
all nested content that follows in the method description).

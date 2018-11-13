.. _documentation_guidelines:

-------------------------------------------------------------------------------
                        Documentation guidelines
-------------------------------------------------------------------------------

These guidelines are updated on the on-demand basis, covering only those issues
that cause pains to the existing writers. At this point, we do not aim to come
up with an exhaustive Documentation Style Guide for the Tarantool project.

===========================================================
                        Markup issues
===========================================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                Wrapping text
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The limit is 80 characters per line for plain text, and no limit for any other
constructions when wrapping affects ReST readability and/or HTML output. Also,
it makes no sense to wrap text into lines shorter than 80 characters unless you
have a good reason to do so.

The 80-character limit comes from the ISO/ANSI 80x24 screen resolution, and it's
unlikely that readers/writers will use 80-character consoles. Yet it's still a
standard for many coding guidelines (including Tarantool). As for writers, the
benefit is that an 80-character page guide allows keeping the text window rather
narrow most of the time, leaving more space for other applications in a
wide-screen environment.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              Formatting code snippets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For code snippets, we mainly use the ``code-block`` directive with an
appropriate highlighting language. The most commonly used highlighting languages
are:

  * ``.. code-block:: tarantoolsession``
  * ``.. code-block:: console``
  * ``.. code-block:: lua``

For example (a code snippet in Lua):

.. code-block:: lua

    for page in paged_iter("X", 10) do
      print("New Page. Number Of Tuples = " .. #page)
      for i=1,#page,1 do print(page[i]) end
    end

In rare cases, when we need custom highlight for specific parts of a code
snippet and the ``code-block`` directive is not enough, we use the per-line
``codenormal`` directive together and explicit output formatting (defined in
:file:`doc/sphinx/_static/sphinx_design.css`).

Examples:

* Function syntax (the placeholder `space-name` is displayed in italics):

  :codenormal:`box.space.`:codeitalic:`space-name`:codenormal:`:create_index('index-name')`

* A tdb session (user input is in bold, command prompt is in blue, computer
  output is in green):

  .. cssclass:: highlight
  .. parsed-literal::

      $ :codebold:`tarantool example.lua`
      :codeblue:`(TDB)`  :codegreen:`Tarantool debugger v.0.0.3. Type h for help`
      example.lua
      :codeblue:`(TDB)`  :codegreen:`[example.lua]`
      :codeblue:`(TDB)`  :codenormal:`3: i = 1`

Warning: Every entry of explicit output formatting (``codenormal``, ``codebold``,
etc) tends to cause troubles when this documentation is translated to other
languages. Please avoid using explicit output formatting unless it is REALLY
needed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              Using separated links
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Avoid separating the link and the target definition (ref), like this:

.. code-block:: text

   This is a paragraph that contains `a link`_.

   .. _a link: http://example.com/

Use non-separated links instead:

.. code-block:: text

   This is a paragraph that contains `a link <http://example.com/>`_.

Warning: Every separated link tends to cause troubles when this documentation is
translated to other languages. Please avoid using separated links unless it is
REALLY needed (e.g. in tables).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Creating labels for local links
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We avoid using links that sphinx generates automatically for most objects.
Instead, we add our own labels for linking to any place in this documentation.

Our naming convention is as follows:

* Character set: a through z, 0 through 9, dash, underscore.

* Format: ``path dash filename dash tag``

  Example: ``_c_api-box_index-iterator_type`` |br|
  where: |br|
  ``c_api`` is the directory name, |br|
  ``box_index`` is the file name (without ".rst"), and |br|
  ``iterator_type`` is the tag.

The file name is useful for knowing, when you see "ref", where it is pointing
to. And if the file name is meaningful, you see that better.

The file name alone, without a path, is enough when the file name is unique
within ``doc/sphinx``.
So, for ``fiber.rst`` it should be just "fiber", not "reference-fiber".
While for "index.rst" (we have a handful of "index.rst" in different
directories) please specify the path before the file name, e.g.
"reference-index".

Use a dash "-" to delimit the path and the file name. In the documentation
source, we use only underscores "_" in paths and file names, reserving dash "-"
as the delimiter for local links.

The tag can be anything meaningful. The only guideline is for Tarantool syntax
items (such as members), where the preferred tag syntax is
``module_or_object_name dash member_name``. For example, ``box_space-drop``.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
              Making comments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sometimes we may need to leave comments in a ReST file. To make sphinx ignore
some text during processing, use the following per-line notation with ".. //" as
the comment marker:

.. code-block:: text

   .. // your comment here

The starting symbols ".. //" do not interfere with the other ReST markup, and
they are easy to find both visually and using grep. There are no symbols to
escape in grep search, just go ahead with something like this:

.. code-block:: console

    $ grep ".. //" doc/sphinx/dev_guide/*.rst

These comments don't work properly in nested documentation, though (e.g. if you
leave a comment in module -> object -> method, sphinx ignores the comment and
all nested content that follows in the method description).

===========================================================
                Language and style issues
===========================================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
               US vs British spelling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We use English US spelling.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
               Instance vs server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We say "instance" rather than "server" to refer to an instance of Tarantool
server. This keeps the manual terminology consistent with names like
``/etc/tarantool/instances.enabled`` in the Tarantool environment.

Wrong usage: "Replication allows multiple Tarantool *servers* to work on copies
of the same databases."

Correct usage: "Replication allows multiple Tarantool *instances* to work on
copies of the same databases."

===========================================================
               Examples and templates
===========================================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
               Module and function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of documenting a module (``my_fiber``) and a function
(``my_fiber.create``).

.. module:: my_fiber

.. function:: create(function [, function-arguments])

    Create and start a ``my_fiber`` object. The object is created and begins to
    run immediately.

    :param function: the function to be associated with the ``my_fiber`` object
    :param function-arguments: what will be passed to function

    :return: created ``my_fiber`` object
    :rtype: userdata

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> my_fiber = require('my_fiber')
        ---
        ...
        tarantool> function function_name()
                 >   my_fiber.sleep(1000)
                 > end
        ---
        ...
        tarantool> my_fiber_object = my_fiber.create(function_name)
        ---
        ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
               Module, class and method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of documenting a module (``my_box.index``), a class
(``my_index_object``) and a function (``my_index_object.rename``).

.. module:: my_box.index

.. class:: my_index_object

    .. method:: rename(index-name)

        Rename an index.

        :param index_object: an object reference
        :param index_name: a new name for the index (type = string)

        :return: nil

        Possible errors: index_object does not exist.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> box.space.space55.index.primary:rename('secondary')
            ---
            ...

        Complexity Factors: Index size, Index type, Number of tuples accessed.

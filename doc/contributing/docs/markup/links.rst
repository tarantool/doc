Links and references
====================

Linking to other documentation pages
------------------------------------

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

Linking to labels (anchors)
---------------------------

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

To add a link to an anchor, use the following syntax:

    ..  literalinclude:: _includes/ref-link.rst
        :language: rst

The result will be like this:

    ..  include:: _includes/ref-link.rst

Linking to external resources
-----------------------------

To make an external link, use the following syntax:

    ..  code-block:: text

        Feel free to report an issue at `Tarantool GitHub <https://github.com/tarantool/tarantool/issues>`_.

Avoid separating the link and the target definition, like this:

    ..  container:: dont

        ..  code-block:: rst

            Feel free to report an issue at `Tarantool GitHub`_.

            ..  _Tarantool GitHub: https://github.com/tarantool/tarantool/issues

because every separated link tends to cause troubles when this documentation
is translated to other languages.
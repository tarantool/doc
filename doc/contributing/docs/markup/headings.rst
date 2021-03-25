Headings
========

Heading markup
--------------

We use the following markup for headings:

..  code-block:: rst

    Level 1 heading
    ===============

    Level 2 heading
    ---------------

    Level 3 heading
    ~~~~~~~~~~~~~~~

    Level 4 heading
    ^^^^^^^^^^^^^^^

The underlining should be exactly the same length as the heading text above it.
Mismatching length will result in a build warning.

Sphinx allows using other characters and styles to format headings.
Indeed, using this markup consistently helps us better reuse and move content.
It also helps us recognize the heading level immediately without reading
the whole document and calculating levels.

If you're going to make a 4th or 5th level heading,
you probably need to split the document instead.


Title headings
--------------

The top-level heading of each document plays the important role of a document title.
Title's text is used in several places:

*   Literally as a ``<h1>`` tag in HTML or top-level heading in other formats.
*   Text in the breadcrumbs — the path to the document shown above the text.
*   The ``:doc:`` link's :doc:`default text <links>`.
*   Part of the page's ``title`` tag contents, used as the browser tab name.

    ..  code-block:: html

        <title>
            Documentation guidelines | Tarantool
        </title>

*   Potentially, the page's OpenGraph metadata which is used for building
    page preview cards on social networks and messengers.

    ..  code-block:: html

        <meta property="og:title" content="Documentation guidelines">


ard to navigate in a hierarchy of more than three heading levels.
Sphinx-build warnings reference
-------------------------------

This document will guide you through the possible warnings raised by Sphinx engine
while building the docs.

Warnings and solutions list
===========================

Below we cite a list with the most frequent warnings and the ways of solutions.

Bullet list ends without a blank line; unexpected unindent
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Similar warning:** Block quote ends without a blank line; unexpected unindent

**Example:**

..  code-block:: rst

    *   The last point of bullet list
    This text should start after a blank line

**Solution:**

..  code-block:: rst

    *   The last point of bullet list

    This text should start after a blank line

Could not lex literal_block as "...". Highlighting skipped
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example:**

**Solution:**

Duplicate explicit target name: "..."
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example:**

..  code-block:: rst

    * `Install <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_
      ``git``, a version control system.

    * `Install <https://linuxize.com/post/how-to-unzip-files-in-linux/>`_
      the ``unzip`` utility.

**Solution:**

Doc-builder doesn't like when we call different targets the same names.
Sphinx developers `recommend <https://github.com/sphinx-doc/sphinx/issues/3921>`_
using double underlines ``__`` in such cases to avoid this warning.

..  code-block:: rst

    * `Install <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`__
         ``git``, a version control system.

    * `Install <https://linuxize.com/post/how-to-unzip-files-in-linux/>`__
      the ``unzip`` utility.

Document isn't included in any toctree
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This warning means that you forgot to put the document name in the toctree.

**Solution:**

If you don't need it there, place ``:orphan:`` directive at the top of the file.
Or, if this file is included somewhere or reused, add it to the _includes directory.
These directories are ignored by Sphinx because we put them in ``exclude_patterns``
in ``conf.py`` file.

Duplicate label "...", other instance in ".../.../..."
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example:**

This happens if you include the contents of one file with tags in another.
Then Sphinx thinks the tags are repeated.

**Solution:**

The recommendation is the same as for previous warning.

Malformed hyperlink target
~~~~~~~~~~~~~~~~~~~~~~~~~~

**Similar warning:** Unknown target name: "..."

Check the spelling of the target or the accuracy of the tag.

**Example:**

..  code-block:: rst

    .. _box_space-index_func

..  code-block:: rst

     See the :ref:`Creating a functional index <box_space-index_func>` section.

**Solution:**

Semicolon is missing in tag definition:

..  code-block:: rst

    .. _box_space-index_func:

Toctree contains reference to nonexisting document '...'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example:**

This may happen when you, for example, refer to the wrong path to a document.

**Solution:**

Check the path.

**See also:**

*   :doc:`/contributing/docs/markup/links`

Undefined label: ... (if the link has no caption the label must precede a section header)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example:**

..  code-block:: rst

    Read more in :ref:`<sql_data_type_conversion>`.

**Solution:**

We recommend using custom captions with ``:ref:``:

..  code-block:: rst

    Read more in :ref:`Data Type Conversion <sql_data_type_conversion>`.

**See also:**

*   :doc:`/contributing/docs/markup/links`

Unexpected indentation
~~~~~~~~~~~~~~~~~~~~~~

**Example:**

Note: ``|..|`` is instead of backspaces.

..  code-block:: rst

    |..|* (Engines) Improve dump start/stop logging. When initiating memory dump, print
    how much memory is going to be dumped, expected dump rate, ETA, and the recent
    write rate.

**Solution:**

..  code-block:: rst

    *|...|(Engines) Improve dump start/stop logging. When initiating memory dump, print
    |....|how much memory is going to be dumped, expected dump rate, ETA, and the recent
    |....|write rate.

**See also:**

*   :doc:`/contributing/docs/markup/intro`

Unknown document
~~~~~~~~~~~~~~~~

**Example:**

..  code-block:: rst

    :doc:`reference/reference_lua/box_space/update`

**Solution:**

Sphinx did not recognise the file path correctly
due to a missing slash at the beginning, so let's just put it there:

..  code-block:: rst

    :doc:`/reference/reference_lua/box_space/update`



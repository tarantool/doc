Sphinx-build warnings reference
===============================

This document will guide you through the possible warnings raised by Sphinx engine
while building the docs.

Below we cite a list with the most frequent warnings and the ways of solutions.

Bullet list ends without a blank line; unexpected unindent
----------------------------------------------------------

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
----------------------------------------------------------

This warning means that there's a ``code-block`` with an unknown lexer.
Most probably, it's a typo.
Check out the `full list of Pygments lexers <https://pygments.org/docs/lexers/>`_
for the right spelling. 

**Example:**

..  code-block:: rst

    ..  code-block:: cxx
    
        // some code here

**Solution:**

..  code-block:: rst

    ..  code-block:: cpp
    
        // some code here
 
Sometimes, however, there's no appropriate lexer, or the code snippet can't be
lexed properly. In such case, use ``code-block:: text``.

Duplicate explicit target name: "..."
-------------------------------------

**Example:**

..  code-block:: rst

    *   `Install <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_
        ``git``, a version control system.

    *   `Install <https://linuxize.com/post/how-to-unzip-files-in-linux/>`_
        the ``unzip`` utility.

**Solution:**

Sphinx-builder raises warnings when we call different targets the same names.
Sphinx developers `recommend <https://github.com/sphinx-doc/sphinx/issues/3921>`_
using double underlines ``__`` in such cases to avoid this.

..  code-block:: rst

    *   `Install <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`__
        ``git``, a version control system.

    *   `Install <https://linuxize.com/post/how-to-unzip-files-in-linux/>`__
        the ``unzip`` utility.

Document isn't included in any toctree
--------------------------------------

This warning means that you forgot to put the document name in the toctree.

**Solution:**

If you don't need it there, place ``:orphan:`` directive at the top of the file.
Or, if this file is included somewhere or reused, add it to the _includes directory.
These directories are ignored by Sphinx because we put them in ``exclude_patterns``
in ``conf.py`` file.

Duplicate label "...", other instance in ".../.../..."
------------------------------------------------------

**Example:**

This happens if you include the contents of one file with tags in another.
Then Sphinx thinks the tags are repeated.

**Solution:**

As in previous case, don't forget to add such file in _includes or avoid using
tags within it.

Malformed hyperlink target
--------------------------

**Similar warning:** Unknown target name: "..."

Check the spelling of the target or the accuracy of the tag.

**Example:**

..  code-block:: rst

    ..  _box_space-index_func

..  code-block:: rst

     See the :ref:`Creating a functional index <box_space-index_func>` section.

**Solution:**

Semicolon is missing in tag definition:

..  code-block:: rst

    ..  _box_space-index_func:

Toctree contains reference to nonexisting document '...'
--------------------------------------------------------

**Example:**

This may happen when you, for example, refer to the wrong path to a document.

**Solution:**

Check the path.

If the path is in ``cartridge`` or another submodule, check that you've
:doc:`built the submodules content </contributing/docs/build>`
before building docs.

Undefined label: ... (if the link has no caption the label must precede a section header)
-----------------------------------------------------------------------------------------

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
----------------------

The reStructuredText syntax is based on indentation, much like in Python.
In a block of content, all lines should be equally indented.
An increase or decrease in indentation means the end of the current block and
the beginning of a new one.

**Example:**

Note: dots show indentation spaces in these examples.
For example, ``|..|`` means a two-space indentation.

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
----------------

**Example:**

..  code-block:: rst

    :doc:`reference/reference_lua/box_space/update`

**Solution:**

Sphinx did not recognise the file path correctly
due to a missing slash at the beginning, so let's just put it there:

..  code-block:: rst

    :doc:`/reference/reference_lua/box_space/update`


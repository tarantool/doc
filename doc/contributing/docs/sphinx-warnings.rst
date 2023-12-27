Sphinx-build warnings reference
===============================

This document will guide you through the warnings that can be raised by Sphinx
while building the docs.

Below are the most frequent warnings and the ways to solve them.

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
 
However, sometimes there's no appropriate lexer or the code snippet can't be
lexed properly. In that case, use ``code-block:: text``.

Duplicate explicit target name: "..."
-------------------------------------

**Example:**

..  code-block:: rst

    *   `Install <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`_
        ``git``, the version control system.

    *   `Install <https://linuxize.com/post/how-to-unzip-files-in-linux/>`_
        the ``unzip`` utility.

**Solution:**

Sphinx-builder raises warnings when we call different targets the same name.
Sphinx developers `recommend <https://github.com/sphinx-doc/sphinx/issues/3921>`_
using double underlines ``__`` in such cases to avoid this.

..  code-block:: rst

    *   `Install <https://git-scm.com/book/en/v2/Getting-Started-Installing-Git>`__
        ``git``, the version control system.

    *   `Install <https://linuxize.com/post/how-to-unzip-files-in-linux/>`__
        the ``unzip`` utility.

Document isn't included in any toctree
--------------------------------------

This warning means that you forgot to put the document name in the toctree.

**Solution:**

If you don't want to include the document in a toctree,
place the ``:orphan:`` directive at the top of the file.
If this file is already included somewhere or reused, add it to the _includes directory.
Sphinx ignores everything in this directory
because we list it among ``exclude_patterns`` in ``conf.py``.

Duplicate label "...", other instance in ".../.../..."
------------------------------------------------------

..  // **Example:**

This happens if you include the contents of a file into another file,
when the included file has tags in it.
In this, Sphinx thinks the tags are repeated.

**Solution:**

As in the previous case, add the file to _includes or avoid using tags in it.

Malformed hyperlink target
--------------------------

**Similar warning:** Unknown target name: "..."

Check the target spelling and the tag syntax.

**Example:**

..  code-block:: rst

    ..  _box_space-index_func

..  code-block:: rst

     See the :ref:`Creating a functional index <box_space-index_func>` section.

**Solution:**

A semicolon is missing in the tag definition:

..  code-block:: rst

    ..  _box_space-index_func:

Anonymous hyperlink mismatch
----------------------------

**Warning example:** Anonymous hyperlink mismatch: 1 references but 0 targets.

Check the hyperlink formatting.

**Example:**

..  code-block:: rst

     Read more in `Lua Manual <https://www.lua.org/manual/5.3`__.

**Solution:**

A closing greater-than sign is missing in the tag definition:

..  code-block:: rst

     Read more in `Lua Manual <https://www.lua.org/manual/5.3>`__.

Toctree contains reference to nonexisting document '...'
--------------------------------------------------------

**Example:**

This may happen when you refer to a wrong path to a document.

**Solution:**

Check the path.

If the path points to a submodule, check that you've
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

*   :doc:`Links and references </contributing/docs/markup/links>`

Unexpected indentation
----------------------

The reStructuredText syntax is based on indentation, much like in Python.
All lines in a block of content must be equally indented.
An increase or decrease in indentation denotes the end of the current block and
the beginning of a new one.

**Example:**

Note: In the following examples, dots stand for indentation spaces.
For example, ``|..|`` denotes a two-space indentation.

..  code-block:: rst

    |..|* (Engines) Improve dump start/stop logging. When initiating memory dump, print
    how much memory is going to be dumped, the expected dump rate, ETA, and the recent
    write rate.

**Solution:**

..  code-block:: rst

    *|...|(Engines) Improve dump start/stop logging. When initiating memory dump, print
    |....|how much memory is going to be dumped, the expected dump rate, ETA, and the recent
    |....|write rate.

**See also:**

*   :doc:`General syntax guidelines </contributing/docs/markup/intro>`

Unknown document
----------------

**Example:**

..  code-block:: rst

    :doc:`reference/reference_lua/box_space/update`

**Solution:**

Sphinx did not recognize the file path correctly
due to a missing slash at the beginning, so let's just put it there:

..  code-block:: rst

    :doc:`/reference/reference_lua/box_space/update`


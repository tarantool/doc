.. _lua_tips:

--------------------------------------------------------------------------------
Tips on Lua syntax
--------------------------------------------------------------------------------

The Lua syntax for :ref:`data-manipulation functions <index-box_data-operations>`
can vary. Here are examples of the variations with ``select()`` requests.
The same rules exist for the other data-manipulation functions.

Every one of the examples does the same thing:
select a tuple set from a space named 'tester' where the primary-key field value
equals 1. For these examples, we assume that the numeric id of 'tester'
is 512, which happens to be the case in our sandbox example only.

.. _app_server-object_reference:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Object reference variations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, there are three **object reference variations**:

.. code-block:: tarantoolsession

    -- #1 module . submodule . name
    tarantool> box.space.tester:select{1}
    -- #2 replace name with a literal in square brackets
    tarantool> box.space['tester']:select{1}
    -- #3 use a variable for the entire object reference
    tarantool> s = box.space.tester
    tarantool> s:select{1}

Examples in this manual usually have the ":samp:`box.space.{tester}:`"
form (#1). However, this is a matter of user preference and all the variations
exist in the wild.

Also, descriptions in this manual use the syntax "``space_object:``"
for references to objects which are spaces, and
"``index_object:``" for references to objects which are indexes (for example
:samp:`box.space.{tester}.index.{primary}:`).

.. _app_server-parameter_reference:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Parameter variations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Then, there are seven **parameter variations**:

.. code-block:: tarantoolsession

    -- #1
    tarantool> box.space.tester:select{1}
    -- #2
    tarantool> box.space.tester:select({1})
    -- #3
    tarantool> box.space.tester:select(1)
    -- #4
    tarantool> box.space.tester.select(box.space.tester,1)
    -- #5
    tarantool> box.space.tester:select({1},{iterator='EQ'})
    -- #6
    tarantool> variable = 1
    tarantool> box.space.tester:select{variable}
    -- #7
    tarantool> variable = {1}
    tarantool> box.space.tester:select(variable)

Lua allows to omit parentheses ``()`` when invoking a function if its only
argument is a Lua table, and we use it sometimes in our examples.
This is why ``select{1}`` is equivalent to ``select({1})``.
Literal values such as ``1`` (a scalar value) or ``{1}`` (a Lua table value)
may be replaced by variable names, as in examples #6 and #7.

Although there are special cases where braces can be omitted, they are
preferable because they signal "Lua table".
Examples and descriptions in this manual have the ``{1}`` form. However, this
too is a matter of user preference and all the variations exist in the wild.

.. _app_server-names:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Rules for object names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Database objects have loose **rules for names**:
the maximum length is 65000 bytes (not characters),
and almost any legal Unicode character is allowed,
including spaces, ideograms and punctuation.

In those cases, to prevent confusion with Lua operators and
separators, object references should have the literal-in-square-brackets
form (#2), or the variable form (#3). For example:

.. code-block:: tarantoolsession

    tarantool> box.space['1*A']:select{1}
    tarantool> s = box.space['1*A !@$%^&*()_+12345678901234567890']
    tarantool> s:select{1}

Disallowed:

* characters which are unassigned code points,
* line and paragraph separators,
* control characters,
* the replacement character (U+FFFD).

Not recommended: characters which cannot be displayed.

Names are "case sensitive", so 'A' and 'a' are not the same.


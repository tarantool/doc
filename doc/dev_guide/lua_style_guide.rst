.. _lua_style_guide:

-------------------------------------------------------------------------------
                                Lua Style Guide
-------------------------------------------------------------------------------

Inspiration:

* https://github.com/Olivine-Labs/lua-style-guide
* http://dev.minetest.net/Lua_code_style_guidelines
* http://sputnik.freewisdom.org/en/Coding_Standard

Programming style is an art. There is some arbitrariness to the rules, but there
are sound rationales for them. It is useful not only to provide sound advice on
style but to understand the underlying rationale and human aspect of why the
style recommendations are formed:

* http://mindprod.com/jgloss/unmain.html
* http://www.oreilly.com/catalog/perlbp/
* http://books.google.com/books?id=QnghAQAAIAAJ

Zen of Python is good; understand it and use wisely:

    | Beautiful is better than ugly.
    | Explicit is better than implicit.
    | Simple is better than complex.
    | Complex is better than complicated.
    | Flat is better than nested.
    | Sparse is better than dense.
    | Readability counts.
    | Special cases aren't special enough to break the rules.
    | Although practicality beats purity.
    | Errors should never pass silently.
    | Unless explicitly silenced.
    | In the face of ambiguity, refuse the temptation to guess.
    | There should be one -- and preferably only one -- obvious way to do it.
    | Although that way may not be obvious at first unless you're Dutch.
    | Now is better than never.
    | Although never is often better than *right* now.
    | If the implementation is hard to explain, it's a bad idea.
    | If the implementation is easy to explain, it may be a good idea.
    | Namespaces are one honking great idea -- let's do more of those!
    |
    | https://www.python.org/dev/peps/pep-0020/

===========================================================
                 Indentation and Formatting
===========================================================

* 4 spaces instead tabs. PIL suggests using of two spaces, but programmer looks
  at code 4 up to 8 hours a day, so it's simplier to distinguish indentation
  with 4 spaces. Why spaces? Similar representation everywhere.

  You can use vim modelines:

  .. code-block:: lua

      -- vim:ts=4 ss=4 sw=4 expandtab

* A file should ends w/ one newline symbol, but shouldn't ends w/ blank line
  (two newline symbols).

* Every do/while/for/if/function should indent 4 spaces.

* related ``or``/``and`` in ``if`` must be enclosed in the round brackets (). Example:

  .. code-block:: lua

      if (a == true and b == false) or (a == false and b == true) then
          <...>
      end -- good

      if a == true and b == false or a == false and b == true then
          <...>
      end -- bad

      if a ^ b == true then
      end -- good, but not explicit

* Type conversion

  Do not use concatenation to convert to string or addition to convert to number
  (use ``tostring``/``tonumber`` instead):

  .. code-block:: lua

      local a = 123
      a = a .. ''
      -- bad

      local a = 123
      a = tostring(a)
      -- good

      local a = '123'
      a = a + 5 -- 128
      -- bad

      local a = '123'
      a = tonumber(a) + 5 -- 128
      -- good

* Try to avoid multiple nested ``if``'s with common body:

  .. code-block:: lua

      if (a == true and b == false) or (a == false and b == true) then
          do_something()
      end
      -- good

      if a == true then
          if b == false then
              do_something()
          end
      if b == true then
          if a == false then
              do_something()
          end
      end
      -- bad

* Avoid multiple concatenations in one statement, use ``string.format`` instead:

  .. code-block:: lua

      function say_greeting(period, name)
          local a = "good  " .. period .. ", " .. name
      end
      -- bad

      function say_greeting(period, name)
          local a = string.format("good %s, %s", period, name)
      end
      -- good

      local say_greeting_fmt = "good %s, %s"
      function say_greeting(period, name)
          local a = say_greeting_fmt:format(period, name)
      end
      -- best

* Use ``and``/``or`` for default variable values

  .. code-block:: lua

    function(input)
        input = input or 'default_value'
    end -- good

    function(input)
        if input == nil then
            input = 'default_value'
        end
    end -- ok, but excessive

* ``if``'s and return statements:

  .. code-block:: lua

      if a == true then
          return do_something()
      end
      do_other_thing() -- good

      if a == true then
          return do_something()
      else
          do_other_thing()
      end -- bad

* Using spaces:

  - one shouldn't use spaces between function name and opening round bracket,
    but arguments must be splitted with one whitespace charachter

    .. code-block:: lua

        function name (arg1,arg2,...)
        end -- bad

        function name(arg1, arg2, ...)
        end -- good

  - use space after comment marker

    .. code-block:: lua

        while true do -- inline comment
        -- comment
        do_something()
        end
        --[[
          multiline
          comment
        ]]--

  - surrounding operators

    .. code-block:: lua

        local thing=1
        thing = thing-1
        thing = thing*1
        thing = 'string'..'s'
        -- bad

        local thing = 1
        thing = thing - 1
        thing = thing * 1
        thing = 'string' .. 's'
        -- good

  - use space after commas in tables

    .. code-block:: lua

        local thing = {1,2,3}
        thing = {1 , 2 , 3}
        thing = {1 ,2 ,3}
        -- bad

        local thing = {1, 2, 3}
        -- good

  - use space in map definitions around equality sign and commas

    .. code-block:: lua

        return {1,2,3,4} -- bad
        return {
            key1 = val1,key2=val2
        } -- bad

        return {
            1, 2, 3, 4
            key1 = val1, key2 = val2,
            key3 = vallll
        } -- good

    also, you may use alignment:

    .. code-block:: lua

        return {
            long_key  = 'vaaaaalue',
            key       = 'val',
            something = 'even better'
        }

  - extra blank lines may be used (sparingly) to separate groups of related
    functions. Blank lines may be omitted between a bunch of related one-liners
    (e.g. a set of dummy implementations)

    use blank lines in function, sparingly, to indicate logical sections

    .. code-block:: lua

        if thing then
            -- ...stuff...
        end
        function derp()
            -- ...stuff...
        end
        local wat = 7
        -- bad

        if thing then
            -- ...stuff...
        end

        function derp()
            -- ...stuff...
        end

        local wat = 7
        -- good

  - Delete whitespace at EOL (strongly forbidden. Use ``:s/\s\+$//gc`` in vim
    to delete them)

===========================================================
                   Avoid global variable
===========================================================

You must avoid global variables. If you have an exceptional case, use ``_G``
variable to set it, add prefix or add table instead of prefix:

.. code-block:: lua

    function bad_global_example()
    end -- very, very bad

    function good_local_example()
    end
    _G.modulename_good_local_example = good_local_example -- good
    _G.modulename = {}
    _G.modulename.good_local_example = good_local_example -- better

Always use prefix to avoid name clash

===========================================================
                           Naming
===========================================================

* names of variables/"objects" and "methods"/functions: snake_case
* names of "classes": CamelCase
* private variables/methods (properties in the future) of object starts with
  underscores ``<object>._<name>``. Avoid using of
  ``local function private_methods(self) end``
* boolean - naming ``is_<...>``, ``isnt_<...>``, ``has_``, ``hasnt_`` is a good style.
* for "very local" variables:
  - ``t`` is for tables
  - ``i``, ``j`` are for indexing
  - ``n`` is for counting
  - ``k``, ``v`` is what you get out of ``pairs()`` (are acceptable, ``_`` if unused)
  - ``i``, ``v`` is what you get out of ``ipairs()`` (are acceptable, ``_`` if unused)
  - ``k``/``key`` is for table keys
  - ``v``/``val``/``value`` is for values that are passed around
  - ``x``/``y``/``z`` is for generic math quantities
  - ``s``/``str``/``string`` is for strings
  - ``c`` is for 1-char strings
  - ``f``/``func``/``cb`` are for functions
  - ``status, <rv>..`` or ``ok, <rv>..`` is what you get out of pcall/xpcall
  - ``buf, sz`` is a (buffer, size) pair
  - ``<name>_p`` is for pointers
  - ``t0``.. is for timestamps
  - ``err`` is for errors
* abbrevations are acceptable if they're unambigous and if you'll document (or
  they're too common) them.
* global variables are written with ALL_CAPS. If it's some system variable, then
  they're using underscore to define it (``_G``/``_VERSION``/..)
* module naming snake_case (avoid underscores and dashes) - 'luasql', instead of
  'Lua-SQL'
* ``*_mt`` and ``*_methods`` defines metatable and methods table

===========================================================
                    Idioms and patterns
===========================================================

Always use round brackets in call of functions except multiple cases (common lua
style idioms):

* ``*.cfg{ }`` functions (``box.cfg``/``memcached.cfg``/..)
* ``ffi.cdef[[ ]]`` function

Avoid these kind of constructions:

* <func>'<name>' (strongly avoid require'..')
* ``function object:method() end`` (use ``functon object.method(self) end`` instead)
* do not use semicolon as table separator (only comma)
* semicolons at the end of line (only to split multiple statements on one line)
* try to avoid unnecessary function creation (closures/..)

===========================================================
                          Modules
===========================================================

Don't start modules with license/authors/descriptions, you can write it in
LICENSE/AUTHORS/README files.
For writing modules use one of the two patterns (dont use ``modules()``):

.. code-block:: lua

    local M = {}

    function M.foo()
    ...
    end

    function M.bar()
    ...
    end

    return M

or

.. code-block:: lua

    local function foo()
    ...
    end

    local function bar()
    ...
    end

    return {
    foo = foo,
    bar = bar,
    }

===========================================================
                         Commenting
===========================================================

You should write code the way it shouldn't be described, but don't forget about
commenting it. You shouldn't comment Lua syntax (assume that reader already
knows Lua language). Try to tell about functions/variable names/etc.

Multiline comments: use matching (``--[[ ]]--``) instead of simple
(``--[[ ]]``).

Public function comments (??):

.. code-block:: lua

    --- Copy any table (shallow and deep version)
    -- * deepcopy: copies all levels
    -- * shallowcopy: copies only first level
    -- Supports __copy metamethod for copying custom tables with metatables
    -- @function gsplit
    -- @table         inp  original table
    -- @shallow[opt]  sep  flag for shallow copy
    -- @returns            table (copy)

===========================================================
                          Testing
===========================================================

Use ``tap`` module for writing efficient tests. Example of test file:

.. code-block:: lua

    #!/usr/bin/env tarantool

    local test = require('tap').test('table')
    test:plan(31)

    do -- check basic table.copy (deepcopy)
        local example_table = {
            {1, 2, 3},
            {"help, I'm very nested", {{{ }}} }
        }

        local copy_table = table.copy(example_table)

        test:is_deeply(
            example_table,
            copy_table,
            "checking, that deepcopy behaves ok"
        )
        test:isnt(
            example_table,
            copy_table,
            "checking, that tables are different"
        )
        test:isnt(
            example_table[1],
            copy_table[1],
            "checking, that tables are different"
        )
        test:isnt(
            example_table[2],
            copy_table[2],
            "checking, that tables are different"
        )
        test:isnt(
            example_table[2][2],
            copy_table[2][2],
            "checking, that tables are different"
        )
        test:isnt(
            example_table[2][2][1],
            copy_table[2][2][1],
            "checking, that tables are different"
        )
    end

    <...>

    os.exit(test:check() and 0 or 1)

When you'll test your code output will be something like this:

.. code-block:: tap

    TAP version 13
    1..31
    ok - checking, that deepcopy behaves ok
    ok - checking, that tables are different
    ok - checking, that tables are different
    ok - checking, that tables are different
    ok - checking, that tables are different
    ok - checking, that tables are different
    ...

===========================================================
                       Error Handling
===========================================================

Be generous in what you accept and strict in what you return.

With error handling this means that you must provide an error object as second
multi-return value in case of error. The error object can be a string, a Lua
table or cdata, in the latter cases it must have ``__tostring`` metamethod
defined.

In case of error, use ``nil`` for the first return value. This makes the error
hard to ignore.

When checking function return values, check the first argument first. If it's
``nil``, look for error in the second argument:

.. code-block:: lua

    local data, err = foo()
    if not data then
        return nil, err
    end
    return bar(data)

Unless performance of your code is paramount, try to avoid using more than two
return values.

In rare cases you may want to return ``nil`` as a legal return value. In this
case it's OK to check for error first, and return second:

.. code-block:: lua

    local data, err = foo()
    if not err then
        return data
    end
    return nil, err


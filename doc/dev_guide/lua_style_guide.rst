..  _lua_style_guide:

Lua style guide
===============

Inspiration:

*   https://github.com/Olivine-Labs/lua-style-guide
*   http://dev.minetest.net/Lua_code_style_guidelines
*   http://sputnik.freewisdom.org/en/Coding_Standard

Programming style is art. There is some arbitrariness to the rules, but there
are sound rationales for them. It is useful not only to provide sound advice on
style but to understand the underlying rationale behind the
style recommendations:

*   http://mindprod.com/jgloss/unmain.html
*   http://www.oreilly.com/catalog/perlbp/
*   http://books.google.com/books?id=QnghAQAAIAAJ

The Zen of Python is good. Understand it and use wisely:

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


Indentation and formatting
--------------------------

*   4 spaces instead of tabs. PIL suggests using two spaces, but a programmer looks
    at code from 4 to 8 hours a day, so it's simpler to distinguish indentation
    with 4 spaces. Why spaces? Similar representation everywhere.

    You can use vim modelines:

    ..  code-block:: lua

        -- vim:ts=4 ss=4 sw=4 expandtab

*   A file should ends w/ one newline symbol, but shouldn't ends w/ blank line
    (two newline symbols).

*   Every do/while/for/if/function should indent 4 spaces.

*   Related ``or``/``and`` in ``if`` must be enclosed in the round brackets (). Example:

    ..  code-block:: lua

        -- Good
        if (a == true and b == false) or (a == false and b == true) then
            <...>
        end

        -- Bad
        if a == true and b == false or a == false and b == true then
            <...>
        end

        -- Good but not explicit
        if a ^ b == true then
        end

*   Type conversion

    Do not use concatenation to convert to string or addition to convert to number
    (use ``tostring``/``tonumber`` instead):

    ..  code-block:: lua

        -- Bad
        local a = 123
        a = a .. ''

        -- Good
        local a = 123
        a = tostring(a)

        -- Bad
        local a = '123'
        a = a + 5 -- 128

        -- Good
        local a = '123'
        a = tonumber(a) + 5 -- 128

*   Try to avoid multiple nested ``if``'s with common body:

    ..  code-block:: lua

        -- Good
        if (a == true and b == false) or (a == false and b == true) then
            do_something()
        end

        -- Bad
        if a == true then
            if b == false then
                do_something()
            end
        if b == true then
            if a == false then
                do_something()
            end
        end

*   Avoid multiple concatenations in one statement, use ``string.format`` instead:

    ..  code-block:: lua

        -- Bad
        function say_greeting(period, name)
            local a = "good  " .. period .. ", " .. name
        end

        -- Good
        function say_greeting(period, name)
            local a = string.format("good %s, %s", period, name)
        end

        -- Best
        local say_greeting_fmt = "good %s, %s"
        function say_greeting(period, name)
            local a = say_greeting_fmt:format(period, name)
        end

*   Use ``and``/``or`` for default variable values

    ..  code-block:: lua

        -- Good
        function(input)
            input = input or 'default_value'
        end

        -- Ok but excessive
        function(input)
            if input == nil then
                input = 'default_value'
            end
        end

*   ``if``'s and return statements:

    ..  code-block:: lua

        -- Good
        if a == true then
            return do_something()
        end
        do_other_thing()

        -- Bad
        if a == true then
            return do_something()
        else
            do_other_thing()
        end

*   Using spaces:

    -   Don't use spaces between function name and opening round bracket.
        Split arguments with one whitespace character:

        .. code-block:: lua

            -- Bad
            function name (arg1,arg2,...)
            end

            -- Good
            function name(arg1, arg2, ...)
            end

    -   Add a space after comment markers:

        ..  code-block:: lua

            while true do -- Inline comment
                -- Comment
                do_something()
            end
            --[[
            Multiline
            comment
            ]]--

    -   Surrounding operators:

        ..  code-block:: lua

            -- Bad
            local thing=1
            thing = thing-1
            thing = thing*1
            thing = 'string'..'s'

            -- Good
            local thing = 1
            thing = thing - 1
            thing = thing * 1
            thing = 'string' .. 's'

    -   Add a space after commas in tables:

        ..  code-block:: lua

            -- Bad
            local thing = {1,2,3}
            thing = {1 , 2 , 3}
            thing = {1 ,2 ,3}

            -- Good
            local thing = {1, 2, 3}

    -   Add a space in map definitions after equals signs and commas:

        ..  code-block:: lua

            -- Bad
            return {1,2,3,4}
            return {
                key1 = val1,key2=val2
            }

            -- Good
            return {1, 2, 3, 4}
            return {
                key1 = val1, key2 = val2,
                key3 = val3
            }

        You can also use alignment:

        ..  code-block:: lua

            return {
                long_key  = 'vaaaaalue',
                key       = 'val',
                something = 'even better'
            }


    -   Extra blank lines may be used (sparingly) to separate groups of related
        functions. Blank lines may be omitted between several related one-liners
        (for example, a set of dummy implementations).

        Use blank lines in functions (sparingly) to indicate logical sections:

        ..  code-block:: lua

            -- Bad
            if thing ~= nil then
                -- ... stuff ...
            end
            function derp()
                -- ... stuff ...
            end
            local wat = 7

            -- Good
            if thing ~= nil then
                -- ... stuff ...
            end

            function derp()
                -- ... stuff ...
            end

            local wat = 7

    -   Delete whitespace at EOL (strongly forbidden. Use ``:s/\s\+$//gc`` in vim
        to delete them).


Avoid global variables
----------------------

Avoid using global variables. In exceptional cases, start the name of such a variable with ``_G``,
add a prefix, or add a table instead of a prefix:

..  code-block:: lua

    -- Very bad
    function bad_global_example()
    end

    function good_local_example()
    end
    -- Good
    _G.modulename_good_local_example = good_local_example

    -- Better
    _G.modulename = {}
    _G.modulename.good_local_example = good_local_example

Always use a prefix to avoid name conflicts.

Naming
------

*   Names of variables/"objects" and "methods"/functions: snake_case.
*   Names of "classes": CamelCase.
*   Private variables/methods (future properties) of objects start with
    underscores ``<object>._<name>``. Avoid syntax like
    ``local function private_methods(self) end``.
*   Boolean: naming ``is_<...>``, ``isnt_<...>``, ``has_``, ``hasnt_`` is good style.
*   For "very local" variables:

    -   ``t`` is for tables
    -   ``i``, ``j`` are for indexing
    -   ``n`` is for counting
    -   ``k``, ``v`` is what you get out of ``pairs()`` (are acceptable, ``_`` if unused)
    -   ``i``, ``v`` is what you get out of ``ipairs()`` (are acceptable, ``_`` if unused)
    -   ``k``/``key`` is for table keys
    -   ``v``/``val``/``value`` is for values that are passed around
    -   ``x``/``y``/``z`` is for generic math quantities
    -   ``s``/``str``/``string`` is for strings
    -   ``c`` is for 1-char strings
    -   ``f``/``func``/``cb`` are for functions
    -   ``status, <rv>..`` or ``ok, <rv>..`` is what you get out of pcall/xpcall
    -   ``buf, sz`` is a (buffer, size) pair
    -   ``<name>_p`` is for pointers
    -   ``t0``.. is for timestamps
    -   ``err`` is for errors
    
*   Abbreviations are acceptable if they're very common or if they're unambiguous and you've documented them.
*   Global variables are spelled in ALL_CAPS. If it's a system variable, it starts with an underscore
    (``_G``/``_VERSION``/..).
*   Modules are named in snake_case (avoid underscores and dashes): for example, 'luasql', not
    'Lua-SQL'.
*   ``*_mt`` and ``*_methods`` defines metatable and methods table.

Idioms and patterns
-------------------

Always use round brackets in call of functions except multiple cases (common lua
style idioms):

*   ``*.cfg{ }`` functions (``box.cfg``/``memcached.cfg``/..)
*   ``ffi.cdef[[ ]]`` function

Avoid the following constructions:

*   <func>'<name>'. Strongly avoid require'..'.
*   ``function object:method() end``. Use ``function object.method(self) end`` instead.
*   Semicolons as table separators. Only use commas.
*   Semicolons at the end of line. Use semicolons only to split multiple statements on one line.
*   Unnecessary function creation (closures/..).

Avoid implicit casting to boolean in ``if`` conditions like ``if x then`` or ``if not x then``.
Such expressions will likely result in troubles with :doc:`box.NULL </reference/reference_lua/box_null/>`.
Instead of those conditions, use ``if x ~= nil then`` and ``if x == nil then``.

Modules
-------

Don't start modules with license/authors/descriptions, you can write it in
LICENSE/AUTHORS/README files.
To write modules, use one of the two patterns (don't use ``modules()``):

..  code-block:: lua

    local M = {}

    function M.foo()
        ...
    end

    function M.bar()
        ...
    end

    return M

or

..  code-block:: lua

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

Commenting
----------

Don't forget to comment your Lua code. You shouldn't comment Lua syntax (assume that the reader already
knows the Lua language). Instead, tell about functions/variable names/etc.

Start a sentence with a capital letter and end with a period.

Multiline comments: use matching (``--[[ ]]--``) instead of simple
(``--[[ ]]``).

Public function comments:

..  code-block:: lua

    --- Copy any table (shallow and deep version).
    -- * deepcopy: copies all levels
    -- * shallowcopy: copies only first level
    -- Supports __copy metamethod for copying custom tables with metatables.
    -- @function gsplit
    -- @table         inp  original table
    -- @shallow[opt]  sep  flag for shallow copy
    -- @returns            table (copy)

Testing
-------

Use the ``tap`` module for writing efficient tests. Example of a test file:

..  code-block:: lua

    #!/usr/bin/env tarantool

    local test = require('tap').test('table')
    test:plan(31)

    do
        -- Check basic table.copy (deepcopy).
        local example_table = {
            { 1, 2, 3 },
            { "help, I'm very nested", { { { } } } }
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

When you test your code, the output will be something like this:

..  code-block:: tap

    TAP version 13
    1..31
    ok - checking, that deepcopy behaves ok
    ok - checking, that tables are different
    ok - checking, that tables are different
    ok - checking, that tables are different
    ok - checking, that tables are different
    ok - checking, that tables are different
    ...


Error handling
--------------

Be generous in what you accept and strict in what you return.

With error handling, this means that you must provide an error object as the second
multi-return value in case of error. The error object can be a string, a Lua
table, cdata, or userdata. In the latter three cases, it must have a ``__tostring`` metamethod
defined.

In case of error, use ``nil`` for the first return value. This makes the error
hard to ignore.

When checking function return values, check the first argument first. If it's
``nil``, look for error in the second argument:

..  code-block:: lua

    local data, err = foo()
    if data == nil then
        return nil, err
    end
    return bar(data)

Unless the performance of your code is paramount, try to avoid using more than two
return values.

In rare cases, you may want to return ``nil`` as a legal return value. In this
case, it's OK to check for error first and then for return:

..  code-block:: lua

    local data, err = foo()
    if err == nil then
        return data
    end
    return nil, err

luacheck
--------

To check the code style, Tarantool uses ``luacheck``. It analyses different
aspects of code, such as unused variables, and sometimes it checks more aspects than needed.
So there is an agreement to ignore some warnings generated by ``luacheck``:

..  code-block:: lua

    "212/self",   -- Unused argument <self>.
    "411",        -- Redefining a local variable.
    "421",        -- Shadowing a local variable.
    "431",        -- Shadowing an upvalue.
    "432",        -- Shadowing an upvalue argument.

-------------------------------------------------------------------------------
                          Other package components
-------------------------------------------------------------------------------

All the Tarantool modules are, at some level, inside a package which,
appropriately, is named ``package``. There are also miscellaneous functions
and variables which are outside all modules.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`tonumber64()                   | Convert a string or a Lua       |
    | <other-tonumber64>`                  | number to a 64-bit integer      |
    +--------------------------------------+---------------------------------+
    | :ref:`dostring()                     | Parse and execute an arbitrary  |
    | <other-dostring>`                    | chunk of Lua code               |
    +--------------------------------------+---------------------------------+
    | :ref:`package.path                   | Where Tarantool looks for Lua   |
    | <other-package_path>`                | additions                       |
    +--------------------------------------+---------------------------------+
    | :ref:`package.cpath                  | Where Tarantool looks for C     |
    | <other-package_cpath>`               | additions                       |
    +--------------------------------------+---------------------------------+
    | :ref:`package.loaded                 | What Tarantool has already      |
    | <other-package_loaded>`              | looked for and found            |
    +--------------------------------------+---------------------------------+
    | :ref:`package.setsearchroot          | Set the root path for a         |
    | <other-package_setsearchroot>`       | directory search                |
    +--------------------------------------+---------------------------------+
    | :ref:`package.searchroot             | Get the root path for a         |
    | <other-package_searchroot>`          | directory search                |
    +--------------------------------------+---------------------------------+


.. _other-tonumber64:

.. function:: tonumber64(value)

    Convert a string or a Lua number to a 64-bit integer.
    The input value can be expressed in decimal, binary (for example 0b1010),
    or hexadecimal (for example -0xffff). The result can be
    used in arithmetic, and the arithmetic will be 64-bit integer arithmetic
    rather than floating-point arithmetic. (Operations on an unconverted Lua
    number use floating-point arithmetic.) The ``tonumber64()`` function is
    added by Tarantool; the name is global.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> type(123456789012345), type(tonumber64(123456789012345))
        ---
        - number
        - number
        ...
        tarantool> i = tonumber64('1000000000')
        ---
        ...
        tarantool> type(i), i / 2, i - 2, i * 2, i + 2, i % 2, i ^ 2
        ---
        - number
        - 500000000
        - 999999998
        - 2000000000
        - 1000000002
        - 0
        - 1000000000000000000
        ...

    **Warning:**
    There is an underlying LuaJIT
    library that operates with C rules.
    Therefore you should expect odd results
    if you compare unsigned and signed (for example 0ULL > -1LL is false),
    or if you use numbers outside the 64-bit integer range
    (for example 9223372036854775808LL is negative).
    Also you should be aware that :samp:`type({number-literal-ending-in-ULL})`
    is cdata, not a Lua arithmetic type, which prevents
    direct use with some functions in Lua libraries such as `math <https://www.lua.org/manual/5.1/manual.html#5.6>`_.
    See the `LuaJIT reference <http://luajit.org/ext_ffi_semantics.html>`_
    and look for the phrase "64 bit integer arithmetic".
    and the phrase "64 bit integer comparison".
    Or see the comments on
    `Issue#4089 <https://github.com/tarantool/tarantool/issues/4089>`_.

.. _other-dostring:

.. function:: dostring(lua-chunk-string [, lua-chunk-string-argument ...])

    Parse and execute an arbitrary chunk of Lua code. This function is mainly
    useful to define and run Lua code without having to introduce changes to
    the global Lua environment.

    :param string lua-chunk-string: Lua code
    :param lua-value lua-chunk-string-argument: zero or more scalar values
                            which will be appended to, or substitute for,
                            items in the Lua chunk.
    :return: whatever is returned by the Lua code chunk.

    Possible errors: If there is a compilation error, it is raised as a Lua
    error.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> dostring('abc')
        ---
        error: '[string "abc"]:1: ''='' expected near ''<eof>'''
        ...
        tarantool> dostring('return 1')
        ---
        - 1
        ...
        tarantool> dostring('return ...', 'hello', 'world')
        ---
        - hello
        - world
        ...
        tarantool> dostring([[
                 >   local f = function(key)
                 >     local t = box.space.tester:select{key}
                 >     if t ~= nil then
                 >       return t[1]
                 >     else
                 >       return nil
                 >     end
                 >   end
                 >   return f(...)]], 1)
        ---
        - null
        ...

.. _other-package_path:

.. data:: package.path

    This is a string that Tarantool uses to search for Lua modules,
    especially important for ``require()``.
    See :ref:`Modules, rocks and applications <app_server-modules>`.

.. _other-package_cpath:

.. data:: package.cpath

    This is a string that Tarantool uses to search for C modules,
    especially important for ``require()``.
    See :ref:`Modules, rocks and applications <app_server-modules>`.

.. _other-package_loaded:

.. data:: package.loaded

    This is a string that shows what Lua or C modules Tarantool
    has loaded, so that their functions and members are available.
    Initially it has all the pre-loaded modules, which don't need
    ``require()``.

.. _other-package_setsearchroot:

.. function:: package.setsearchroot([search-root])

    Set the search root. The search root is the root directory from
    which dependencies are loaded.

    :param string search-root: the path. Default = current directory.

    The search-root string must contain a relative or absolute path.
    If it is a relative path, then it will be expanded to an
    absolute path.
    If search-root is omitted, or is box.NULL, then the search root
    is reset to the current directory, which is found with debug.sourcedir().

    Example:

    Suppose that a Lua file ``myapp/init.lua`` is the project root. |br|
    Suppose the current path is ``/home/tara``. |br|
    Add this as the first line of ``myapp/init.lua``: |br|
    :code:`package.setsearchroot()` |br|
    Start the project with |br|
    :code:`$ tarantool myapp/init.lua` |br|
    The search root will be the default, made absolute: ``/home/tara/myapp``.
    Within the Lua application all dependencies will be searched relative
    to ``/home/tara/myapp``.

.. _other-package_searchroot:

.. function:: package.searchroot()

    Return a string with the current search root.
    After ``package.setsearchroot('/home')`` the returned
    string will be ``/home'``.


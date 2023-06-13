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
    | :ref:`package.path                   | Get file paths used to search   |
    | <other-package_path>`                | for Lua modules                 |
    +--------------------------------------+---------------------------------+
    | :ref:`package.cpath                  | Get file paths used to search   |
    | <other-package_cpath>`               | for C modules                   |
    +--------------------------------------+---------------------------------+
    | :ref:`package.loaded                 | Show Lua or C modules           |
    | <other-package_loaded>`              | loaded by Tarantool             |
    +--------------------------------------+---------------------------------+
    | :ref:`package.searchroot             | Get the root path for a         |
    | <other-package_searchroot>`          | directory search                |
    +--------------------------------------+---------------------------------+
    | :ref:`package.setsearchroot          | Set the root path for a         |
    | <other-package_setsearchroot>`       | directory search                |
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

    Get file paths used to search for Lua :ref:`modules <app_server-modules>`.
    For example, these paths are used to find modules loaded using the ``require()`` directive.

    See also: :ref:`package.searchroot() <other-package_searchroot>`

.. _other-package_cpath:

.. data:: package.cpath

    Get file paths used to search for C :ref:`modules <app_server-modules>`.
    For example, these paths are used to find modules loaded using the ``require()`` directive.

    See also: :ref:`package.searchroot() <other-package_searchroot>`

.. _other-package_loaded:

.. data:: package.loaded

    Show Lua or C modules loaded by Tarantool, so that their functions and members are available.
    ``loaded`` shows both pre-loaded modules and modules added using the ``require()`` directive.

    See also: :ref:`package.searchroot() <other-package_searchroot>`

.. _other-package_searchroot:

.. function:: package.searchroot()

    Return the current search root, which defines the path to the root directory from which dependencies are loaded.
    By default, the search root is the current directory.

    .. NOTE::

        The current directory is obtained using :ref:`debug.sourcedir() <debug-sourcedir>`.

    **Example**

    Suppose the application has the following structure:

    .. code-block:: none

        /home/testuser/myapp
        ├── .rocks/share/tarantool/
        │   └── foo.lua
        ├── init.lua
        └── modules
            └── bar.lua

    In this case, modules are placed in the same directory as the application initialization file.
    If you :ref:`run the application <app_server-launching_app_binary>` using the ``tarantool`` command from the ``myapp`` directory, ...

    .. code-block:: console

        /home/testuser/myapp$ tarantool init.lua

    ... the search root is ``/home/testuser/myapp`` and Tarantool finds all modules in this directory automatically.
    This means that to load the ``foo`` and ``modules.bar`` modules in ``init.lua``, you only need to add the corresponding ``require`` directives:

    .. code-block:: lua

        -- init.lua --
        require('foo')
        require('modules.bar')

    Starting with :doc:`2.11.0 </release/2.11.0>`, you can also run the application using the ``tarantool`` command from the directory other than ``myapp``:

    .. code-block:: console

        /home/testuser$ tarantool myapp/init.lua

    In this case, the path to the initialization file (``/home/testuser/myapp``) is added to search paths for modules.

    To load modules placed outside of the path to the application directory, use :ref:`package.setsearchroot() <other-package_setsearchroot>`.

.. _other-package_setsearchroot:

.. function:: package.setsearchroot([search-root])

    Set the search root, which defines the path to the root directory from which dependencies are loaded.
    By default, the search root is the current directory (see :ref:`package.searchroot() <other-package_searchroot>`).

    :param string search-root: a relative or absolute path to the search root. If ``search-root`` is a relative path, it is expanded to an absolute path. You can omit this argument or set it to :ref:`box.NULL <box-null>` to reset the search root to the current directory.

    **Example**

    Suppose external modules are stored outside the application directory, for example:

    .. code-block:: none

        /home/testuser/
        ├── myapp
        │   └── init.lua
        └── mymodules
            ├── .rocks/share/tarantool/
            │   └── foo.lua
            └── modules
                └── bar.lua

    In this case, you can specify the ``/home/testuser/mymodules`` path as the search root for modules in the following way:

    .. code-block:: lua

        -- init.lua --
        package.setsearchroot('/home/testuser/mymodules')

    Then, you can load the ``foo`` and ``bar`` modules using the ``require()`` directive:

    .. code-block:: lua

        -- init.lua --
        require('foo')
        require('modules.bar')

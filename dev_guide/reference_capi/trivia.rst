=================================================================
                         Module `trivia/config`
=================================================================

.. c:macro:: API_EXPORT

    Extern modifier for all public functions.

.. c:macro:: PACKAGE_VERSION_MAJOR

    Package major version - 1 for 1.9.2.

.. c:macro:: PACKAGE_VERSION_MINOR

    Package minor version - 9 for 1.9.2.

.. c:macro:: PACKAGE_VERSION_PATCH

    Package patch version - 2 for 1.9.2.

.. c:macro:: PACKAGE_VERSION

    A string with major-minor-patch-commit-id identifier of the release, e.g.
    1.9.2-0-g113ade24e.

.. c:macro:: SYSCONF_DIR

    System configuration dir (e.g ``/etc``)

.. c:macro:: INSTALL_PREFIX

    Install prefix (e.g. ``/usr``)

.. c:macro:: BUILD_TYPE

    Build type, e.g. Debug or Release

.. c:macro:: BUILD_INFO

    CMake build type signature, e.g. ``Linux-x86_64-Debug``

.. c:macro:: BUILD_OPTIONS

    Command line used to run CMake.

.. c:macro:: COMPILER_INFO

    Pathes to C and CXX compilers.

.. c:macro:: TARANTOOL_C_FLAGS

    C compile flags used to build Tarantool.

.. c:macro:: TARANTOOL_CXX_FLAGS

    CXX compile flags used to build Tarantool.

.. c:macro:: MODULE_LIBDIR

    A path to install ``*.lua`` module files.

.. c:macro:: MODULE_LUADIR

    A path to install ``*.so``/``*.dylib`` module files.

.. c:macro:: MODULE_INCLUDEDIR

  A path to Lua includes (the same directory where this file is contained)

.. c:macro:: MODULE_LUAPATH

  A constant added to ``package.path`` in Lua to find ``*.lua`` module files.

.. c:macro:: MODULE_LIBPATH

  A constant added to ``package.cpath`` in Lua to find ``*.so`` module files.

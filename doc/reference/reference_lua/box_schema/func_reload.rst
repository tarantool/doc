.. _box_schema-func_reload:

===============================================================================
box.schema.func.reload()
===============================================================================

.. module:: box.schema

.. function:: box.schema.func.reload([name])

    Reload a C module with all its functions without restarting the server.

    Under the hood, Tarantool loads a new copy of the module (``*.so`` shared
    library) and starts routing all new request to the new version.
    The previous version remains active until all started calls are finished.
    All shared libraries are loaded with ``RTLD_LOCAL`` (see "man 3 dlopen"),
    therefore multiple copies can co-exist without any problems.

    .. NOTE::

        Reload will fail if a module was loaded from Lua script with
        `ffi.load() <http://luajit.org/ext_ffi_api.html#ffi_load>`_.

    :param string name: the name of the module to reload

    **Example:**

    .. code-block:: lua

        -- reload the entire module contents
        box.schema.func.reload('module')

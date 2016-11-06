:orphan:

-----------------
Tarantool - Rocks
-----------------

.. wp_section::
    :class: b-block-lightgray b-rocks
    :title: Available rocks

    Add our LuaRocks repository with

    .. code-block:: bash

        mkdir ~/.luarocks
        echo "rocks_servers = { [[http://rocks.tarantool.org/]] }" >> ~/.luarocks/config.lua

    The following modules are available:

    .. wp_rocks::
        :path: rocks/


..  _compress-zstd-module:

Submodule compress.zstd
=======================

.. _overview-zstd-compress:

Overview
--------

The ``compress.zstd`` submodule provides the ability to compress and decompress data using the `zstd <https://en.wikipedia.org/wiki/Zstd>`_ algorithm.
You can use the ``zstd`` compressor as follows:

1.  Create a compressor instance using the :ref:`compress.zstd.new() <compress-zstd-new>` function:

    .. code-block:: lua

        local zstd_compressor = require('compress.zstd').new()
        -- or --
        local zstd_compressor = require('compress').zstd.new()

    Optionally, you can pass compression options (:ref:`zstd_opts <zstd_opts_class>`) specific for ``zstd``:

    ..  literalinclude:: code_snippets/compress_zstd.lua
        :language: lua
        :lines: 1-3

2.  To compress the specified data, use the :ref:`compress() <zstd_compressor-compress>` method:

    ..  literalinclude:: code_snippets/compress_zstd.lua
        :language: lua
        :lines: 5

3.  To decompress data, call :ref:`decompress() <zstd_compressor-decompress>`:

    ..  literalinclude:: code_snippets/compress_zstd.lua
        :language: lua
        :lines: 6



.. _api-reference-compress-zstd:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`compress.zstd.new() <compress-zstd-new>`
            -   Create a ``zstd`` compressor instance.

        *   -   **Objects**
            -

        *   -   :ref:`zstd_compressor <zstd_compressor_class>`
            -   A ``zstd`` compressor instance.

        *   -   :ref:`zstd_opts <zstd_opts_class>`
            -   Configuration options of the ``zstd`` compressor.



..  _compress-zstd-new:

compress.zstd.new()
~~~~~~~~~~~~~~~~~~~

..  module:: compress.zstd

..  function:: new([zstd_opts])

    Create a ``zstd`` compressor instance.

    :param table options: ``zstd`` compression options (see :ref:`zstd_opts <zstd_opts_class>`)

    :return: a new ``zstd`` compressor instance (see :ref:`zstd_compressor <zstd_compressor_class>`)
    :rtype:  userdata

    **Example**

    ..  literalinclude:: code_snippets/compress_zstd.lua
        :language: lua
        :lines: 1-3


..  _zstd_compressor_class:

zstd_compressor
~~~~~~~~~~~~~~~

..  class:: zstd_compressor

    A compressor instance that exposes the API for compressing and decompressing data using the ``zstd`` algorithm.
    To create the ``zstd`` compressor, call :ref:`compress.zstd.new() <compress-zstd-new>`.

    ..  _zstd_compressor-compress:

    .. method:: compress(data)

        Compress the specified data.

        :param string data: data to be compressed

        :return: compressed data
        :rtype:  string

        **Example**

        ..  literalinclude:: code_snippets/compress_zstd.lua
            :language: lua
            :lines: 5

    ..  _zstd_compressor-decompress:

    .. method:: decompress(data)

        Decompress the specified data.

        :param string data: data to be decompressed

        :return: decompressed data
        :rtype:  string

        **Example**

        ..  literalinclude:: code_snippets/compress_zstd.lua
            :language: lua
            :lines: 6


..  _zstd_opts_class:

zstd_opts
~~~~~~~~~

..  class:: zstd_opts

    Configuration options of the :ref:`zstd_compressor <zstd_compressor_class>`.
    These options can be passed to the :ref:`compress.zstd.new() <compress-zstd-new>` function.

    **Example**

    ..  literalinclude:: code_snippets/compress_zstd.lua
        :language: lua
        :lines: 1-3

    ..  _zstd_opts-level:

    .. data:: level

        Specifies the ``zstd`` compression level that enables you to adjust the compression ratio and speed.
        The lower level improves the compression speed at the cost of compression ratio.
        For example, you can use level 1 if speed is most important and level 22 if size is most important.

        | Default: 3
        | Minimum: -131072
        | Maximum: 22

        .. note::

            Assigning 0 to ``level`` resets its value to the default (3).

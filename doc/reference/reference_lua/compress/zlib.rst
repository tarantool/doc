..  _compress-zlib-module:

Submodule compress.zlib
=======================

..  admonition:: Enterprise Edition
    :class: fact

    This submodule is a part of the `Enterprise Edition <https://www.tarantool.io/compare/>`_.

.. _overview-zlib-compress:

Overview
--------

The ``compress.zlib`` submodule provides the ability to compress and decompress data using the `zlib <https://en.wikipedia.org/wiki/Zlib>`_ algorithm.
You can use the ``zlib`` compressor as follows:

1.  Create a compressor instance using the :ref:`compress.zlib.new() <compress-zlib-new>` function:

    .. code-block:: lua

        local zlib_compressor = require('compress.zlib').new()
        -- or --
        local zlib_compressor = require('compress').zlib.new()

    Optionally, you can pass compression options (:ref:`zlib_opts <zlib_opts_class>`) specific for ``zlib``:

    ..  literalinclude:: code_snippets/compress_zlib.lua
        :language: lua
        :lines: 1-5

2.  To compress the specified data, use the :ref:`compress() <zlib_compressor-compress>` method:

    ..  literalinclude:: code_snippets/compress_zlib.lua
        :language: lua
        :lines: 7

3.  To decompress data, call :ref:`decompress() <zlib_compressor-decompress>`:

    ..  literalinclude:: code_snippets/compress_zlib.lua
        :language: lua
        :lines: 8



.. _api-reference-compress-zlib:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`compress.zlib.new() <compress-zlib-new>`
            -   Create a ``zlib`` compressor instance.

        *   -   **Objects**
            -

        *   -   :ref:`zlib_compressor <zlib_compressor_class>`
            -   A ``zlib`` compressor instance.

        *   -   :ref:`zlib_opts <zlib_opts_class>`
            -   Configuration options of the ``zlib`` compressor.



..  _compress-zlib-new:

compress.zlib.new()
~~~~~~~~~~~~~~~~~~~

..  module:: compress.zlib

..  function:: new([zlib_opts])

    Create a ``zlib`` compressor instance.

    :param table options: ``zlib`` compression options (see :ref:`zlib_opts <zlib_opts_class>`)

    :return: a new ``zlib`` compressor instance (see :ref:`zlib_compressor <zlib_compressor_class>`)
    :rtype:  userdata

    **Example**

    ..  literalinclude:: code_snippets/compress_zlib.lua
        :language: lua
        :lines: 1-5


..  _zlib_compressor_class:

zlib_compressor
~~~~~~~~~~~~~~~

..  class:: zlib_compressor

    A compressor instance that exposes the API for compressing and decompressing data using the ``zlib`` algorithm.
    To create the ``zlib`` compressor, call :ref:`compress.zlib.new() <compress-zlib-new>`.

    ..  _zlib_compressor-compress:

    .. method:: compress(data)

        Compress the specified data.

        :param string data: data to be compressed

        :return: compressed data
        :rtype:  string

        **Example**

        ..  literalinclude:: code_snippets/compress_zlib.lua
            :language: lua
            :lines: 7

    ..  _zlib_compressor-decompress:

    .. method:: decompress(data)

        Decompress the specified data.

        :param string data: data to be decompressed

        :return: decompressed data
        :rtype:  string

        **Example**

        ..  literalinclude:: code_snippets/compress_zlib.lua
            :language: lua
            :lines: 8


..  _zlib_opts_class:

zlib_opts
~~~~~~~~~

..  class:: zlib_opts

    Configuration options of the :ref:`zlib_compressor <zlib_compressor_class>`.
    These options can be passed to the :ref:`compress.zlib.new() <compress-zlib-new>` function.

    **Example**

    ..  literalinclude:: code_snippets/compress_zlib.lua
        :language: lua
        :lines: 1-5

    ..  _zlib_opts-level:

    .. data:: level

        Specifies the ``zlib`` compression level that enables you to adjust the compression ratio and speed.
        The lower level improves the compression speed at the cost of compression ratio.

        | Default: 6
        | Minimum: 0 (no compression)
        | Maximum: 9


    ..  _zlib_opts-mem_level:

    .. data:: mem_level

        Specifies how much memory is allocated for the ``zlib`` compressor.
        The larger value improves the compression speed and ratio.

        | Default: 8
        | Minimum: 1
        | Maximum: 9


    ..  _zlib_opts-strategy:

    .. data:: strategy

        Specifies the compression strategy. The possible values:

        *   ``default`` - for normal data.
        *   ``huffman_only`` - forces Huffman encoding only (no string match). The fastest compression algorithm but not very effective in compression for most of the data.
        *   ``filtered`` - for data produced by a filter or predictor. Filtered data consists mostly of small values with a somewhat random distribution. This compression algorithm is tuned to compress them better.
        *   ``rle`` - limits match distances to one (run-length encoding). ``rle`` is designed to be almost as fast as ``huffman_only`` but gives better compression for PNG image data.
        *   ``fixed`` - prevents the use of dynamic Huffman codes and provides a simpler decoder for special applications.

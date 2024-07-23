..  _compress-lz4-module:

Submodule compress.lz4
=======================

..  admonition:: Enterprise Edition
    :class: fact

    This submodule is a part of the `Enterprise Edition <https://www.tarantool.io/compare/>`_.

.. _overview-lz4-compress:

Overview
--------

The ``compress.lz4`` submodule provides the ability to compress and decompress data using the `lz4 <https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)>`_ algorithm.
You can use the ``lz4`` compressor as follows:

1.  Create a compressor instance using the :ref:`compress.lz4.new() <compress-lz4-new>` function:

    .. code-block:: lua

        local lz4_compressor = require('compress.lz4').new()
        -- or --
        local lz4_compressor = require('compress').lz4.new()

    Optionally, you can pass compression options (:ref:`lz4_opts <lz4_opts_class>`) specific for ``lz4``:

    ..  literalinclude:: code_snippets/compress_lz4.lua
        :language: lua
        :lines: 1-4

2.  To compress the specified data, use the :ref:`compress() <lz4_compressor-compress>` method:

    ..  literalinclude:: code_snippets/compress_lz4.lua
        :language: lua
        :lines: 6

3.  To decompress data, call :ref:`decompress() <lz4_compressor-decompress>`:

    ..  literalinclude:: code_snippets/compress_lz4.lua
        :language: lua
        :lines: 7



.. _api-reference-compress-lz4:

API Reference
-------------

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`compress.lz4.new() <compress-lz4-new>`
            -   Create a ``lz4`` compressor instance.

        *   -   **Objects**
            -

        *   -   :ref:`lz4_compressor <lz4_compressor_class>`
            -   A ``lz4`` compressor instance.

        *   -   :ref:`lz4_opts <lz4_opts_class>`
            -   Configuration options of the ``lz4`` compressor.



..  _compress-lz4-new:

compress.lz4.new()
~~~~~~~~~~~~~~~~~~

..  module:: compress.lz4

..  function:: new([lz4_opts])

    Create a ``lz4`` compressor instance.

    :param table options: ``lz4`` compression options (see :ref:`lz4_opts <lz4_opts_class>`)

    :return: a new ``lz4`` compressor instance (see :ref:`lz4_compressor <lz4_compressor_class>`)
    :rtype:  userdata

    **Example**

    ..  literalinclude:: code_snippets/compress_lz4.lua
        :language: lua
        :lines: 1-4


..  _lz4_compressor_class:

lz4_compressor
~~~~~~~~~~~~~~

..  class:: lz4_compressor

    A compressor instance that exposes the API for compressing and decompressing data using the ``lz4`` algorithm.
    To create the ``lz4`` compressor, call :ref:`compress.lz4.new() <compress-lz4-new>`.

    ..  _lz4_compressor-compress:

    .. method:: compress(data)

        Compress the specified data.

        :param string data: data to be compressed

        :return: compressed data
        :rtype:  string

        **Example**

        ..  literalinclude:: code_snippets/compress_lz4.lua
            :language: lua
            :lines: 6

    ..  _lz4_compressor-decompress:

    .. method:: decompress(data)

        Decompress the specified data.

        :param string data: data to be decompressed

        :return: decompressed data
        :rtype:  string

        **Example**

        ..  literalinclude:: code_snippets/compress_lz4.lua
            :language: lua
            :lines: 7


..  _lz4_opts_class:

lz4_opts
~~~~~~~~

..  class:: lz4_opts

    Configuration options of the :ref:`lz4_compressor <lz4_compressor_class>`.
    These options can be passed to the :ref:`compress.lz4.new() <compress-lz4-new>` function.

    **Example**

    ..  literalinclude:: code_snippets/compress_lz4.lua
        :language: lua
        :lines: 1-5

    ..  _lz4_opts-acceleration:

    .. data:: acceleration

        Specifies the acceleration factor that enables you to adjust the compression ratio and speed.
        The higher acceleration factor increases the compression speed but decreases the compression ratio.

        | Default: 1
        | Maximum: 65537
        | Minimum: 1


    ..  _lz4_opts-decompress_buffer_size:

    .. data:: decompress_buffer_size

        Specifies the decompress buffer size (in bytes).
        If the size of decompressed data is larger than this value, the compressor returns an error on decompression.

        | Default: 1048576

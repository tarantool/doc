..  _internals-iproto-format:

Request and response format
===========================

*   The types referred to in this document are `MessagePack <http://MessagePack.org>`_ types.
*   Request size is passed before the request.
*   Request and response have the same sync number (IPROTO_SYNC).
*   It is legal to put more than one request in a packet.

All IPROTO constants are unsigned 8-bit integers. 

..  _internals-unified_packet_structure:


Requests and responses contain three sections: size, header, and body.

Size
----

The size is an MP_UINT -- unsigned integer, usually 32-bit.
The header and body are maps (MP_MAP).
Maximal iproto package body length is 2 GiB.

..  _box_protocol-header:

Header
------

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    :samp:`{{MP_UINT unsigned integer}}`
    # <header>
    :samp:`{{MP_MAP with <header> map-items}}`
    # <body>
    :samp:`{{MP_MAP with <body> map-items}}`

``<size>`` is the size of the header plus the size of the body.
It may be useful to compare it with the number of bytes remaining in the packet.

``<header>`` may contain, in any order:

..  cssclass:: highlight
..  parsed-literal::

    msgpack({
        <request type>: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
        IPROTO_STREAM_ID: :samp:`{{MP_UINT unsigned integer}}`
    })

..
    TODO: provide links to the constants above
    <internals-iproto-keys-sync>
    <internals-iproto-keys-schema_version>
    <box_protocol-iproto_stream_id>

For replication of :ref:`synchronous transactions <repl_sync>`
a header may contain a key = :ref:`IPROTO_FLAGS <box_protocol-flags>` and an MP_UINT value = one or more
bits: IPROTO_FLAG_COMMIT or IPROTO_FLAG_WAIT_SYNC or IPROTO_FLAG_WAIT_ACK.

Encoding and decoding
~~~~~~~~~~~~~~~~~~~~~

To see how Tarantool encodes the header, have a look at file
`xrow.c <https://github.com/tarantool/tarantool/blob/master/src/box/xrow.c>`_,
function ``xrow_header_encode``.

To see how Tarantool decodes the header, have a look at file ``net_box.c``,
function ``netbox_decode_data``.

For example, in a successful response to ``box.space:select()``,
the IPROTO_REQUEST_TYPE value will be 0 = ``IPROTO_OK`` and the
array will have all the tuples of the result.

Read the source code file `net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
where the function "decode_metadata_optional" is an example of how Tarantool
itself decodes extra items.

Body
----

The ``<body>`` has the details of the request or response. In a request, it can also
be absent or be an empty map. Both these states will be interpreted equally.
Responses will contain the ``<body>`` anyway even for an
:ref:`IPROTO_PING <box_protocol-ping>` request.


..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_OK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, may be 64-bit}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_DATA: :samp:`{{any type}}`
    })

- For :ref:`IPROTO_PING <box_protocol-ping>` the body will be an empty map.


IPROTO_DATA is what we get with net_box and :ref:`Module buffer <buffer-module>`
so if we were using net_box we could decode with
:ref:`msgpack.decode_unchecked() <msgpack-decode_unchecked_string>`,
or we could convert to a string with :samp:`ffi.string({pointer},{length})`.
The :ref:`pickle.unpack() <pickle-unpack>` function might also be helpful.

Response body
~~~~~~~~~~~~~

After the :ref:`header <box_protocol-header>`, for a response,
there will be a body.

Responses to SQL statements are slightly different and will be described
in the section :ref:`Responses for SQL <box_protocol-sql_protocol>`.

Here is a blueprint of a successful response:

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(:samp:`{{MP_UINT unsigned integer = size(<header>) + size(<body>)}}`)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: IPROTO_OK,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, may be 64-bit}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_DATA: :samp:`{{any type}}`
    })

..  note::

    When it comes to SQL-specific requests and responses, the body is a bit different.
    :ref:`Learn more <internals-iproto-sql>` about this type of packets.

..  _box_protocol-responses_error:

Responses for errors
--------------------

Instead of :ref:`IPROTO_OK <internals-iproto-keys-ok>`, an error response header
has IPROTO_REQUEST_TYPE = :ref:`IPROTO_TYPE_ERROR <internals-iproto-keys-type_error>`.
Its code is ``0x8XXX``, where ``XXX`` is the error code -- a value in
`src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_.
``src/box/errcode.h`` also has some convenience macros which define hexadecimal
constants for return codes.

The error response body is a map that contains two keys: :ref:`IPROTO_ERROR <internals-iproto-keys-error>`
and :ref:`IPROTO_ERROR_24 <internals-iproto-keys-error>`.
While IPROTO_ERROR contains an MP_EXT value, IPROTO_ERROR_24 contains a string.
The two keys are provided to accommodate clients with older and newer Tarantool versions.

..  cssclass:: highlight
..  parsed-literal::

    # <size>
    msgpack(32)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: :samp:`{{0x8XXX}}`,
        IPROTO_SYNC: :samp:`{{MP_UINT unsigned integer, may be 64-bit}}`,
        IPROTO_SCHEMA_VERSION: :samp:`{{MP_UINT unsigned integer}}`
    })
    # <body>
    msgpack({
        IPROTO_ERROR: :samp:`{{MP_ERROR error object}}`,
        IPROTO_ERROR_24: :samp:`{{MP_STR string}}`
    })


Before Tarantool v. :doc:`2.4.1 </release/2.4.1>`, the key IPROTO_ERROR contained a string
and was identical to the current IPROTO_ERROR_24 key.

In version 2.4.0 and earlier,
if this is the fifth message and the request is to create a duplicate
space with
``conn:eval([[box.schema.space.create('_space');]])``
the unsuccessful response will look like this:

..  code-block:: none

    # <size>
    msgpack(32)
    # <header>
    msgpack({
        IPROTO_REQUEST_TYPE: 0x800a,
        IPROTO_SYNC: 5,
        IPROTO_SCHEMA_VERSION: 0x78
    })
    # <body>
    msgpack({
        IPROTO_ERROR:  "Space '_space' already exists"
    })

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows actual byte codes of the response to the IPROTO_EVAL message.

Looking in errcode.h we find that error code 0x0a (decimal 10) is
ER_SPACE_EXISTS, and the string associated with ER_SPACE_EXISTS is
"Space '%s' already exists".

Since version :doc:`2.4.1 </release/2.4.1>`, responses for errors have extra information
following what was described above. This extra information is given via
MP_ERROR extension type. See details in :ref:`MessagePack extensions
<msgpack_ext-error>` section.

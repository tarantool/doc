..  _internals-iproto-format:

Request and response format
===========================

*   We use `MessagePack <http://MessagePack.org>`_ and refer to MessagePack types in this document.
*   Request size is passed before the request
*   Request and response have the same sync number (IPROTO_SYNC)
*   It is legal to put more than one request in a packet.

..  _internals-unified_packet_structure:

Requests and responses usually contain three sections: size, header, and body.

Size
~~~~

The size is an MP_UINT -- unsigned integer, usually 32-bit.
The header and body are maps (MP_MAP).

..  _box_protocol-header:

Header
~~~~~~

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

IPROTO_SYNC
^^^^^^^^^^^

Binary code: 0x01.

This is an unsigned integer that should be incremented so that it is unique in every
request. This integer is also returned from :doc:`community:reference/reference_lua/box_session/sync`.

The IPROTO_SYNC value of a response should be the same as
the IPROTO_SYNC value of a request.

IPROTO_SCHEMA_VERSION
^^^^^^^^^^^^^^^^^^^^^

Binary code: 0x05.

An unsigned number, sometimes called SCHEMA_ID, that goes up when there is a
major change.

In a request header, IPROTO_SCHEMA_VERSION is optional, so the version will not
be checked if it is absent.

In a response header, IPROTO_SCHEMA_VERSION is always present, and it is up to
the client to check if it has changed.

..  _box_protocol-iproto_stream_id:

IPROTO_STREAM_ID
^^^^^^^^^^^^^^^^

Binary code: 0x0a.

Only used in :ref:`streams <txn_mode_stream-interactive-transactions>`.
This is an unsigned number that should be unique in every stream.

In requests, IPROTO_STREAM_ID is useful for two things:
ensuring that requests within transactions are done in separate groups,
and ensuring strictly consistent execution of requests (whether or not they are within transactions).

In responses, IPROTO_STREAM_ID does not appear.

See :ref:`Binary protocol -- streams <box_protocol-streams>`.


Encoding and decoding
^^^^^^^^^^^^^^^^^^^^^

To see how Tarantool encodes the header, have a look at file
`xrow.c <https://github.com/tarantool/tarantool/blob/master/src/box/xrow.c>`_,
function ``xrow_header_encode``.

To see how Tarantool decodes the header, have a look at file ``net_box.c``,
function ``netbox_decode_data``.

For example, in a successful response to ``box.space:select()``,
the Response-Code-Indicator value will be 0 = ``IPROTO_OK`` and the
array will have all the tuples of the result.

Body
~~~~

The ``<body>`` has the details of the request or response. In a request, it can also
be absent or be an empty map. Both these states will be interpreted equally.
Responses will contain the ``<body>`` anyway even for an
:ref:`IPROTO_PING <box_protocol-ping>` request.


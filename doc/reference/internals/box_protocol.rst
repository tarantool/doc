..  _box_protocol-iproto_protocol:
..  _box_protocol:
..  _internals-box_protocol:

Binary protocol
===============

This section provides information on the Tarantool binary protocol, iproto.
The protocol is called "binary" because the database is most frequently accessed
via binary code instead of Lua request text. Tarantool experts use it:

*   to write their own connectors
*   to understand network messages
*   to support new features that their favorite connector doesn't support yet
*   to avoid repetitive parsing by the server

The binary protocol provides complete access to Tarantool functionality, including:

*   request multiplexing, for example ability to issue multiple requests
    asynchronously via the same connection
*   response format that supports zero-copy writes

..  note::

    Since version :doc:`2.11.0 </release/2.11.0>`, you can use the :ref:`box.iproto <box_iproto>` submodule to access
    IPROTO constants and features from Lua. The submodule enables to :ref:`send arbitrary IPROTO packets <reference_lua-box_iproto_send>`
    over the session's socket and :ref:`override the behavior <reference_lua-box_iproto_override>` for all IPROTO
    request types. Also, :ref:`IPROTO_UNKNOWN <box_iproto-unknown>` constant is introduced. The constant is used for the
    :ref:`box.iproto.override() <reference_lua-box_iproto_override>` API, which allows setting a handler for incoming requests with an unknown type.

..  toctree::
    :maxdepth: 1

    iproto/iproto
    iproto/mp_types
    iproto/format
    iproto/keys
    iproto/requests
    iproto/authentication
    iproto/streams
    iproto/events
    iproto/graceful_shutdown
    iproto/sql
    iproto/replication

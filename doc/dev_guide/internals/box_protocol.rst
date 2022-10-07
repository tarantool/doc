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

..  toctree::
    :maxdepth: 1

    iproto/mp_types
    iproto/format
    iproto/authentication
    iproto/keys
    iproto/requests
    iproto/streams
    iproto/events
    iproto/replication
    iproto/sql
    Examples <../../how-to/other/iproto>

.. _reference_lua-box_iproto_protocol-features:

box.iproto.protocol_version
===========================

..  module:: box.iproto

    ..  data:: protocol_version

        The set of IPROTO protocol features supported by the server.
        Learn more: `src/box/iproto_features.h <https://github.com/tarantool/tarantool/blob/master/src/box/iproto_features.h>`__
        and `iproto_features_resolve() <https://github.com/tarantool/tarantool/blob/dec0e0221e183fa972efa65bb0fb658112f2196f/src/box/lua/net_box.lua#L93-L105>`__).

**Example**

..  code-block:: lua

    box.iproto.protocol_features = {
    streams = true,
    transactions = true,
    error_extension = true,
    watchers = true,
    }


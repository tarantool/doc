..  _reference_lua-box_iproto_protocol-features:

box.iproto.protocol_features
============================

..  module:: box.iproto

..  data:: protocol_features

    The set of IPROTO protocol features supported by the server.
    Learn more: :ref:`net.box features <net_box-connect>`, `src/box/iproto_features.h <https://github.com/tarantool/tarantool/blob/master/src/box/iproto_features.h>`__,
    and `iproto_features_resolve() <https://github.com/tarantool/tarantool/blob/dec0e0221e183fa972efa65bb0fb658112f2196f/src/box/lua/net_box.lua#L93-L105>`__.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.protocol_features
        ---
        - transactions: true
          watchers: true
          error_extension: true
          streams: true
          pagination: true
        ...

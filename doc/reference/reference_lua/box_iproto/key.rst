..  _reference_lua-box_iproto_key:

box.iproto.key
==============

..  module:: box.iproto

..  data:: key

    Contains all available request keys, except :ref:`raft <reference_lua-box_iproto_raft>`,
    :ref:`metadata <reference_lua-box_iproto_metadata>`, and :ref:`ballot <reference_lua-box_iproto_ballot>` keys.
    Learn more: :ref:`Keys used in requests and responses <internals-iproto-keys>`.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.key.SYNC
        ---
        - 1
        ...
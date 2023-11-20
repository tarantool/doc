.. _reference_lua-box_iproto_raft:

box.iproto.raft
===============

..  module:: box.iproto

..  data:: raft_key

    Contains the keys from the ``IPROTO_RAFT_*`` requests.
    Learn more: :ref:`Synchronous replication keys <internals-iproto-keys-synchro-replication>`.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.raft_key.TERM
        ---
        - 0
        ...
        tarantool> box.iproto.raft_key.VOTE
        ---
        - 1
        ...

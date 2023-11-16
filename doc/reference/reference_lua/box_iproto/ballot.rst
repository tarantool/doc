..  _reference_lua-box_iproto_ballot:

box.iproto.ballot_key
=====================

..  module:: box.iproto

..  data:: ballot_key

    Contains the keys from the :ref:`IPROTO_BALLOT <box_protocol-ballots>` requests.
    Learn more: :ref:`IPROTO_BALLOT keys <internals-iproto-keys-ballot>`.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.ballot_key.IS_RO_CFG
        ---
        - 1
        ...
        tarantool> box.iproto.ballot_key.VCLOCK
        ---
        - 2
        ...


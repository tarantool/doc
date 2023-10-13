..  _reference_lua-box_iproto_ballot:

box.iproto.ballot_key
=====================

..  module:: box.iproto

    ..  data:: ballot_key

        The ``box.iproto.ballot_key`` namespace contains the keys from the :ref:`IPROTO_BALLOT <box_protocol-ballots>` requests.
        Learn more: :ref:`IPROTO_BALLOT keys <internals-iproto-keys-ballot>`.

    Available keys:

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Exported constant
            -   IPROTO constant name
            -   Code

        *   -   IS_RO_CFG
            -   :ref:`IPROTO_BALLOT_IS_RO_CFG <internals-iproto-keys-ballot>`
            -   0x01

        *   -   VCLOCK
            -   :ref:`IPROTO_BALLOT_VCLOCK <internals-iproto-keys-vclock>`
            -   0x02

        *   -   GC_VCLOCK
            -   :ref:`IPROTO_BALLOT_GC_VCLOCK <internals-iproto-keys-vclock>`
            -   0x03

        *   -   IS_RO
            -   :ref:`IPROTO_BALLOT_IS_RO <internals-iproto-keys-ballot>`
            -   0x04

        *   -   IS_ANON
            -   0x05
            -   :ref:`IPROTO_BALLOT_IS_ANON <internals-iproto-keys-ballot>`

        *   -   IS_BOOTED
            -   :ref:`IPROTO_BALLOT_IS_BOOTED <internals-iproto-keys-ballot>`
            -   0x06

        *   -   CAN_LEAD
            -   :ref:`IPROTO_BALLOT_CAN_LEAD <internals-iproto-keys-ballot>`
            -   0x07

        *   -   BOOTSTRAP_LEADER_UUID
            -   :ref:`IPROTO_BALLOT_BOOTSTRAP_LEADER_UUID <internals-iproto-keys-ballot>`
            -   0x08

        *   -   REGISTERED_REPLICA_UUIDS
            -   :ref:`IPROTO_BALLOT_REGISTERED_REPLICA_UUIDS <internals-iproto-keys-ballot>`
            -   0x09


**Example**

..  code-block:: lua

    box.iproto.ballot_key.IS_RO_CFG = 0x01
    -- ...
    box.iproto.ballot_key.VCLOCK = 0x02
    -- ...

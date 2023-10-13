.. _reference_lua-box_iproto_flag:

box.iproto.flag
===============

..  module:: box.iproto

    ..  data:: flag

        The ``box.iproto.flag`` namespace contains the flags from the ``IPROTO_FLAGS`` key.
        Learn more: :ref:`IPROTO_FLAGS key <box_protocol-flags>`.

    Available flags:

    ..  list-table::
        :header-rows: 1
        :widths: 40 20 40

        *   -   Exported flag
            -   IPROTO flag name
            -   Code

        *   -   COMMIT
            -   :ref:`IPROTO_FLAG_COMMIT <internals-iproto-keys-flags>`
            -   0x01

        *   -   WAIT_SYNC
            -   :ref:`IPROTO_FLAG_WAIT_SYNC <internals-iproto-keys-flags>`
            -   0x02

        *   -   WAIT_ACK
            -   :ref:`IPROTO_FLAG_WAIT_ACK <internals-iproto-keys-flags>`
            -   0x03


**Example**

..  code-block:: lua

    box.iproto.flag.COMMIT = 0x01
    -- ...
    box.iproto.flag.WAIT_SYNC = 0x02
    -- ...
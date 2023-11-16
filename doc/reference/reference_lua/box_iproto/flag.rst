.. _reference_lua-box_iproto_flag:

box.iproto.flag
===============

..  module:: box.iproto

..  data:: flag

    Contains the flags from the ``IPROTO_FLAGS`` key.
    Learn more: :ref:`IPROTO_FLAGS key <box_protocol-flags>`.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.flag.COMMIT
        ---
        - 1
        ...
        tarantool> box.iproto.flag.WAIT_SYNC
        ---
        - 2
        ...

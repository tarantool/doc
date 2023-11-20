.. _reference_lua-box_iproto_type:

box.iproto.type
===============

..  module:: box.iproto

..  data:: type

    Contains all available request types.
    Learn more about the requests: :ref:`Client-server requests and responses <internals-requests_responses>`.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.type.UNKNOWN
        ---
        - -1
        ...
        tarantool> box.iproto.type.CHUNK
        ---
        - 128
        ...

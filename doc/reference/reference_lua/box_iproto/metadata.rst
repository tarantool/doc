..  _reference_lua-box_iproto_metadata:

box.iproto.metadata_key
=======================

..  module:: box.iproto

..  data:: metadata_key

    The ``box.iproto.metadata_key`` namespace contains the ``IPROTO_FIELD_*`` keys, which are nested in the
    :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>` key.

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.metadata_key.NAME
        ---
        - 0
        ...
        tarantool> box.iproto.metadata_key.TYPE
        ---
        - 1
        ...

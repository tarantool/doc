..  _reference_lua-box_iproto_feature:

box.iproto.feature
==================

..  module:: box.iproto

..  data:: feature

    Contains the IPROTO protocol features that are supported by the server.
    Each feature is mapped to its corresponding code.
    Learn more: :ref:`IPROTO_FEATURES <internals-iproto-keys-features>`.

    The features in the namespace are written

    *   in lowercase letters
    *   without the ``IPROTO_FEATURE_`` prefix

    **Example**

    ..  code-block:: lua

        tarantool> box.iproto.feature.streams
        ---
        - 0
        ...
        tarantool> box.iproto.feature.transactions
        ---
        - 1
        ...

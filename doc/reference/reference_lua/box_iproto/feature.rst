..  _reference_lua-box_iproto_feature:

box.iproto.feature
==================

..  module:: box.iproto

    ..  data:: feature

        The ``box.iproto.feature`` namespace contains the IPROTO protocol features supported by the server.
        Each feature is mapped to its corresponding code.
        Learn more: :ref:`IPROTO_FEATURES <internals-iproto-keys-features>`.

        The features in the namespace are written

        *   in the lower case
        *   without the ``IPROTO_FEATURE_`` prefix

        Available features:

        ..  list-table::
            :header-rows: 1
            :widths: 40 20 40

            *   -   Exported feature
                -   IPROTO protocol feature
                -   Code
                -   Description

            *   -   streams
                -   :ref:`IPROTO_FEATURE_STREAMS <internals-iproto-keys-features>`
                -   0
                -   :ref:`Stream <box_protocol-iproto_stream_id>` support

            *   -   transactions
                -   :ref:`IPROTO_SYNC <internals-iproto-keys-sync>`
                -   1
                -   Transaction support

            *   -   error_extension
                -   :ref:`IPROTO_FEATURE_ERROR_EXTENSION <internals-iproto-keys-features>`
                -   2
                -   :ref:`MP_ERROR <msgpack_ext-error>` MsgPack extension support

            *   -   watchers
                -   :ref:`IPROTO_FEATURE_WATCHERS <internals-iproto-keys-features>`
                -   3
                -   Remote watchers support ( see :ref:`IPROTO_WATCH <box_protocol-watch>`,
                    :ref:`IPROTO_UNWATCH <box_protocol-unwatch>`, and :ref:`IPROTO_EVENT <box_protocol-event>`)

            *   -   pagination
                -   :ref:`IPROTO_FEATURE_PAGINATION <internals-iproto-keys-features>`
                -   4
                -   Pagination support


**Example**

..  code-block:: lua

    box.iproto.feature.streams = 0
    box.iproto.feature.transactions = 1
    box.iproto.feature.error_extension = 2
    box.iproto.feature.watchers = 3
    box.iproto.feature.pagination = 4

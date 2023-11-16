..  _box_iproto:

Submodule box.iproto
====================

Since :doc:`2.11.0 </release/2.11.0>`.

The ``box.iproto`` submodule provides the ability to work with the network subsystem of Tarantool.
It allows you to extend the :ref:`IPROTO <box_protocol>` functionality from Lua.
With this submodule, you can:

*   :ref:`parse unknown IPROTO request types <reference_lua-box_iproto_override>`
*   :ref:`send arbitrary IPROTO packets <reference_lua-box_iproto_send>`
*   :ref:`override the behavior <reference_lua-box_iproto_override>` of the existing and unknown request types in the binary protocol

The submodule exports all IPROTO :ref:`constants <internals-box_protocol>` and :ref:`features <internals-iproto-keys-features>` to Lua.

..  _box_iproto-constants:

IPROTO constants
----------------

IPROTO constants in the ``box.iproto`` namespace are written in uppercase letters without the ``IPROTO_`` prefix.
The constants are divided into several groups:

*   :ref:`key <reference_lua-box_iproto_key>`. Example: :ref:`IPROTO_SYNC <internals-iproto-keys-sync>`.
*   :ref:`request type <reference_lua-box_iproto_type>`. Example: :ref:`IPROTO_OK <internals-iproto-ok>`.
*   :ref:`flag <reference_lua-box_iproto_flag>`. Example: :ref:`IPROTO_COMMIT <box_protocol-commit>`.
*   :ref:`ballot key <reference_lua-box_iproto_ballot>`. Example: :ref:`IPROTO_FLAG_COMMIT <box_protocol-flags>`.
*   :ref:`metadata key <reference_lua-box_iproto_metadata>`. Example: :ref:`IPROTO_FIELD_IS_NULLABLE <internals-iproto-keys-sql-specific>`.
*   :ref:`RAFT key <reference_lua-box_iproto_raft>`. Example: :ref:`IPROTO_TERM <internals-iproto-keys-term>`.

Each group is located in the corresponding subnamespace without the prefix.
For example:

..  code-block:: lua

    box.iproto.key.SYNC = 0x01
    -- ...
    box.iproto.type.SELECT = 1
    -- ...
    box.iproto.flag.COMMIT = 1
    -- ...
    box.iproto.ballot_key.VCLOCK = 2
    -- ...
    box.iproto.metadata_key.IS_NULLABLE = 3
    -- ...
    box.iproto.raft_key.TERM = 0
    -- ...

..  _box_iproto-features:

IPROTO features
---------------

The submodule exports:

*   the current IPROTO protocol version (:ref:`box.iproto.protocol_version <reference_lua-box_iproto_version>`)
*   the set of IPROTO protocol features supported by the server (:ref:`box.iproto.protocol_features <reference_lua-box_iproto_protocol-features>`)
*   IPROTO protocol features with the corresponding code (:ref:`box.iproto.feature <reference_lua-box_iproto_feature>`)

**Example**

The example converts the feature names from ``box.iproto.protocol_features`` set into codes:

..  code-block:: lua

    -- Features supported by the server
    box.iproto.protocol_features = {
        streams = true,
        transactions = true,
        error_extension = true,
        watchers = true,
        pagination = true,
    }

    -- Convert the feature names into codes
    features = {}
    for name in pairs(box.iproto.protocol_features) do
        table.insert(features, box.iproto.feature[name])
    end
    return features -- [0, 1, 2, 3, 4]

..  _box_iproto-unknown:

Handling the unknown IPROTO request types
-----------------------------------------

Every IPROTO request has a static handler.
That is, before version :doc:`2.11.0 </release/2.11.0>`, any unknown request raised an error.
Since :doc:`2.11.0 </release/2.11.0>`, a new request type is introduced -- :ref:`IPROTO_UNKNOWN <internals-iproto-unknown>`.
This type is used to override the handlers of the unknown IPROTO request types. For details, see
:ref:`box.iproto.override() <reference_lua-box_iproto_override>` and :ref:`box_iproto_override <box_box_iproto_override>` functions.

..  _box_iproto-reference:

API reference
-------------

The table lists all available functions and data of the submodule:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 30 70
        :header-rows: 1

        *   - Name
            - Use

        *   - :doc:`./box_iproto/key`
            - Request keys

        *   - :doc:`./box_iproto/request_type`
            - Request types

        *   - :doc:`./box_iproto/flag`
            - Flags from the :ref:`IPROTO_FLAGS <box_protocol-flags>` key

        *   - :doc:`./box_iproto/ballot`
            - Keys from the :ref:`IPROTO_BALLOT <box_protocol-ballots>` requests

        *   - :doc:`./box_iproto/metadata`
            - Keys nested in the :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>` key

        *   - :doc:`./box_iproto/raft`
            - Keys from the ``IPROTO_RAFT_`` requests

        *   - :doc:`./box_iproto/protocol_version`
            - The current IPROTO protocol version

        *   - :doc:`./box_iproto/protocol_features`
            - The set of supported IPROTO protocol features

        *   - :doc:`./box_iproto/feature`
            - IPROTO protocol :ref:`features <internals-iproto-keys-features>`

        *   - :doc:`./box_iproto/override`
            - Set a new IPROTO request handler callback for the given request type

        *   - :doc:`./box_iproto/send`
            - Send an IPROTO packet over the session's socket


..  toctree::
    :hidden:

    box_iproto/key
    box_iproto/request_type
    box_iproto/flag
    box_iproto/ballot
    box_iproto/metadata
    box_iproto/raft
    box_iproto/protocol_version
    box_iproto/protocol_features
    box_iproto/feature
    box_iproto/override
    box_iproto/send

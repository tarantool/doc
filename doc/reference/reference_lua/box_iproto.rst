..  _box_iproto:

Submodule box.iproto
====================

Since :doc:`2.11.0 </release/2.11.0>`.

The ``box.iproto`` submodule provides the ability to work with the network subsystem of Tarantool.
It enables to extend the :ref:`binary protocol <box_protocol>` functionality from the Lua libraries.
With this submodule, you can:

*   parse the unknown IPROTO requests
*   send arbitrary IPROTO packets
*   override the behavior of the existing request types in binary protocol

To make this possible, the submodule exports all IPROTO :ref:`constants <box_iproto-constants>` and features to Lua.

..  _box_iproto-constants:

IPROTO constants
----------------

The IPROTO constants in the ``box.iproto`` namespace are written in the upper case without the ``IPROTO_`` prefix.
The constants are divided into several types:

*   :ref:`key <reference_lua-box_iproto_key>` (:ref:`IPROTO_SYNC <internals-iproto-keys-sync>`, :ref:`IPROTO_REQUEST_TYPE <internals-iproto-keys-request_type>`)
*   :ref:`request type <reference_lua-box_iproto_type>` (:ref:`IPROTO_OK <internals-iproto-ok>`)
*   :ref:`flag <reference_lua-box_iproto_flag>` (:ref:`IPROTO_COMMIT <box_protocol-commit>`)
*   :ref:`ballot key <reference_lua-box_iproto_ballot>` (:ref:`IPROTO_FLAG_COMMIT <box_protocol-flags>`)
*   :ref:`metadata key <reference_lua-box_iproto_metadata>` (:ref:`IPROTO_FIELD_IS_NULLABLE <internals-iproto-keys-sql-specific>`)
*   :ref:`RAFT key <reference_lua-box_iproto_raft>` (:ref:`IPROTO_TERM <internals-iproto-keys-term>`)

Each type is located in the corresponding subnamespace without prefix.
For example:

..  code-block:: lua

    box.iproto.key.SYNC = 0x01
    -- ...
    box.iproto.type.SELECT = 1
    -- ...
    box.iproto.flag.COMMIT = 0x01
    -- ...
    box.iproto.ballot_key.VCLOCK = 0x02
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

..  _box_iproto-reference:

API reference
-------------

The table lists all available functions and data of the submodule:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *   - :doc:`./box_iproto/keys`
            - Request keys

        *   - :doc:`./box_iproto/request_types`
            - Request types

        *   - :doc:`./box_iproto/flags`
            - Flags from the :ref:`IPROTO_FLAGS <box_protocol-flags>` key

        *   - :doc:`./box_iproto/ballot`
            - Keys from the :ref:`IPROTO_BALLOT <box_protocol-ballots>` requests

        *   - :doc:`./box_iproto/metadata`
            - Keys nested in the :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>` key

        *   - :doc:`./box_iproto/raft`
            - Keys from the ``IPROTO_RAFT*`` requests

        *   - :doc:`./box_iproto/protocol_version`
            - Current IPROTO protocol version

        *   - :doc:`./box_iproto/protocol_features`
            - The set of supported IPROTO protocol features

        *   - :doc:`./box_iproto/feature`
            - IPROTO protocol :ref:`features <internals-iproto-keys-features>`

         *  - :doc:`./box_iproto/override`
            - Set the IPROTO request handler callbacks

         *  - :doc:`./box_iproto/send`
            - Send an IPROTO packet over the session's socket


..  toctree::
    :hidden:

    box_iproto/key
    box_iproto/request_key
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

.. _reference_lua-box_iproto_metadata:

box.iproto.metadata_key
=======================

..  module:: box.iproto

..  data:: metadata_key

    The ``box.iproto.metadata_key`` namespace contains the ``IPROTO_FILED_*`` keys, which are nested in the
    :ref:`IPROTO_METADATA <internals-iproto-keys-metadata>` key.

    Available keys:

    ..  list-table::
        :header-rows: 1
        :widths: 40 40 20

        *   -   Exported constant
            -   IPROTO constant name
            -   Code

        *   -   NAME
            -   :ref:`IPROTO_FIELD_NAME <internals-iproto-keys-sql-specific>`
            -   0

        *   -   TYPE
            -   :ref:`IPROTO_FIELD_TYPE <internals-iproto-keys-sql-specific>`
            -   1

        *   -   COLL
            -   :ref:`IPROTO_FIELD_COLL <internals-iproto-keys-sql-specific>`
            -   2

        *   -   IS_NULLABLE
            -   :ref:`IPROTO_FIELD_IS_NULLABLE <internals-iproto-keys-sql-specific>`
            -   3

        *   -   IS_AUTOINCREMENT
            -   :ref:`IPROTO_FIELD_IS_AUTOINCREMENT <internals-iproto-keys-sql-specific>`
            -   4

        *   -   SPAN
            -   :ref:`IPROTO_FIELD_SPAN <internals-iproto-keys-sql-specific>`
            -   5


**Example**

..  code-block:: lua

    box.iproto.metadata_key.NAME = 1
    -- ...
    box.iproto.metadata_key.TYPE = 2
    -- ...

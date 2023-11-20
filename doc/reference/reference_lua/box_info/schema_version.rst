..  _box_info_schema_version:

box.info.schema_version
=======================

..  module:: box.info

..  data:: schema_version

    Since :doc:`2.11.0 </release/2.11.0>`.
    Show the database schema version.
    A schema version is a number that indicates whether the :ref:`database schema <index-box-data_schema_description>` is changed.
    For example, the ``schema_version`` value grows if a :ref:`space <index-box_space>` or :ref:`index <index-box_index>` is added or deleted, or a space, index, or field name is changed.

    :rtype: number

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> box.info.schema_version
        ---
        - 84
        ...

    See also: :ref:`IPROTO_SCHEMA_VERSION <internals-iproto-keys-schema_version>`

..  _box_data_model:

Defining and manipulating data
==============================

Tarantool stores data in :ref:`spaces <index-box_space>`, which can be thought of as tables in a relational database.
Every record or row in a space is called a :ref:`tuple <index-box_tuple>`.
A tuple may have any number of fields, and the fields may be of different :ref:`types <index-box_data-types>`.

String data in fields are compared based on the specified :ref:`collation <index-collation>` rules.
The user can provide hard limits for data values through :ref:`constraints <index-constraints>`
and link related spaces with :ref:`foreign keys <index-box_foreign_keys>`.

Tarantool supports highly customizable :ref:`indexes <index-box_index>` of various types.
In particular, indexes can be defined with generators like :ref:`sequences <index-box_sequence>`.

There are six basic :ref:`data operations <index-box_operations>` in Tarantool:
SELECT, INSERT, UPDATE, UPSERT, REPLACE, and DELETE. A number of :ref:`complexity factors <index-box_complexity-factors>`
affects the resource usage of each function.

Tarantool allows :ref:`describing the data schema <index-box-data_schema_description>` but does not require it.
The user can :ref:`migrate a schema <migrations>` without migrating the data.

To ensure :ref:`data persistence <index-box_persistence>` and recover quickly in case of failure,
Tarantool uses mechanisms like the write-ahead log (WAL) and snapshots.

This section contains guides on performing data operations in Tarantool.

..  toctree::
    :maxdepth: 1

    value_store
    schema_desc
    operations
    migrations
    read_views
    sql/index


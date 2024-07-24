.. _index-box_operations:

Operations
==========

.. _index-box_data-operations:

Data operations
---------------

The basic data operations supported in Tarantool are:

*   five data-manipulation operations (INSERT, UPDATE, UPSERT, DELETE, REPLACE), and
*   one data-retrieval operation (SELECT).

All of them are implemented as functions in :ref:`box.space <box_space>` submodule.

**Examples:**

*   :ref:`INSERT <box_space-insert>`: Add a new tuple to space 'tester'.

    The first field, field[1], will be 999 (MsgPack type is `integer`).

    The second field, field[2], will be 'Taranto' (MsgPack type is `string`).

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:insert{999, 'Taranto'}

*   :ref:`UPDATE <box_space-update>`: Update the tuple, changing field field[2].

    The clause "{999}", which has the value to look up in the index of the tuple's
    primary-key field, is mandatory, because ``update()`` requests must always have
    a clause that specifies a unique key, which in this case is field[1].

    The clause "{{'=', 2, 'Tarantino'}}" specifies that assignment will happen to
    field[2] with the new value.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:update({999}, {{'=', 2, 'Tarantino'}})

*   :ref:`UPSERT <box_space-upsert>`: Upsert the tuple, changing field field[2]
    again.

    The syntax of ``upsert()`` is similar to the syntax of ``update()``. However,
    the execution logic of these two requests is different.
    UPSERT is either UPDATE or INSERT, depending on the database's state.
    Also, UPSERT execution is postponed until after transaction commit, so, unlike
    ``update()``, ``upsert()`` doesn't return data back.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:upsert({999, 'Taranted'}, {{'=', 2, 'Tarantism'}})

*   :ref:`REPLACE <box_space-replace>`: Replace the tuple, adding a new field.

    This is also possible with the ``update()`` request, but the ``update()``
    request is usually more complicated.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:replace{999, 'Tarantella', 'Tarantula'}

*   :ref:`SELECT <box_space-select>`: Retrieve the tuple.

    The clause "{999}" is still mandatory, although it does not have to mention
    the primary key.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:select{999}

*   :ref:`DELETE <box_space-delete>`: Delete the tuple.

    In this example, we identify the primary-key field.

    ..  code-block:: tarantoolsession

        tarantool> box.space.tester:delete{999}

Summarizing the examples:

*   Functions ``insert`` and ``replace`` accept a tuple
    (where a primary key comes as part of the tuple).
*   Function ``upsert`` accepts a tuple
    (where a primary key comes as part of the tuple),
    and also the update operations to execute.
*   Function ``delete`` accepts a full key of any unique index
    (primary or secondary).
*   Function ``update`` accepts a full key of any unique index
    (primary or secondary),
    and also the operations to execute.
*   Function ``select`` accepts any key: primary/secondary, unique/non-unique,
    full/partial.

See reference on ``box.space`` for more
:ref:`details on using data operations <box_space-operations-detailed-examples>`.

..  NOTE::

    Besides Lua, you can use
    :ref:`Perl, PHP, Python or other programming language connectors <index-box_connectors>`.
    The client server protocol is open and documented.
    See this :ref:`annotated BNF <box_protocol-iproto_protocol>`.

..  _index-box_complexity-factors:

Complexity factors
------------------

In reference for :ref:`box.space <box_space>` and
:doc:`/reference/reference_lua/box_index`
submodules, there are notes about which complexity factors might affect the
resource usage of each function.

..  container:: table

    ..  list-table::
        :widths: 20 80
        :header-rows: 1

        *   -   Complexity factor
            -   Effect
        *   -   Index size
            -   The number of index keys is the same as the number
                of tuples in the data set. For a TREE index, if
                there are more keys, then the lookup time will be
                greater, although, of course, the effect is not
                linear. For a HASH index, if there are more keys,
                then there is more RAM used, but the number of
                low-level steps tends to remain constant.
        *   -   Index type
            -   Typically, a HASH index is faster than a TREE index
                if the number of tuples in the space is greater
                than one.
        *   -   Number of indexes accessed
            -   Ordinarily, only one index is accessed to retrieve
                one tuple. But to update the tuple, there must be N
                accesses if the space has N different indexes.
                |br|
                Note regarding storage engine: Vinyl optimizes away such
                accesses if secondary index fields are unchanged by
                the update. So, this complexity factor applies only to
                memtx, since it always makes a full-tuple copy on every
                update.
        *   -   Number of tuples accessed
            -   A few requests, for example, SELECT, can retrieve
                multiple tuples. This factor is usually less
                important than the others.
        *   -   WAL settings
            -   The important setting for the write-ahead log is
                :ref:`wal.mode <configuration_reference_wal_mode>`.
                If the setting causes no writing or
                delayed writing, this factor is unimportant. If the
                setting causes every data-change request to wait
                for writing to finish on a slow device, this factor
                is more important than all the others.

..  toctree::
    :hidden:

    crud
    sequences

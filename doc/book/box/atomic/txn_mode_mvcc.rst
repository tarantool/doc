..  _txn_mode_transaction-manager:

Transaction mode: MVCC
======================

Since version :doc:`2.6.1 </release/2.6.1>`,
Tarantool has another mode for transaction behavior that
allows yielding inside a memtx transaction. This is controlled by
the *transaction manager*.

..  _txn_mode_mvcc-tnx-manager:

Transaction manager
-------------------

The transaction manager is designed to isolate parallel transactions
and provides a *serializable* 
`transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_.
It consists of two parts:

*   *MVCC* -- multi version concurrency control engine, which stores all change actions of all 
    transactions. It also creates the transaction view of the database state and a read view 
    (a fixed state of the database that is never changed by other transactions) when necessary.
    

*   *Conflict manager* -- a manager that tracks changes to transactions and determines their correctness
    in the serialization order. The conflict manager declares transactions to be in conflict 
    or sends transactions to read views when necessary.

The transaction manager also provides: 

*   Non-classical snapshot isolation level -- this snapshot is not necessarily tied to the start 
    time of the transaction, like the classical snapshot where a transaction 
    can get a consistent snapshot of the database. The conflict manager decides if and when 
    each transaction gets which snapshot. This avoids some conflicts compared 
    to the classic snapshot isolation approach.

*   Special ``is_dirty`` flag -- a flag that helps to store and view the history of "dirty" 
    tuples separately.

..  _txn_mode_mvcc-enabling:

Enabling the transaction manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, the transaction manager is disabled. Use the :ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>` 
option to enable it via ``box.cfg``.

..  code-block:: enabling

    box.cfg{memtx_use_mvcc_engine = true}
 
..  _txn_mode_mvcc-examples:

Examples with MVCC enabled and disabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create ``init.lua``, containing the following:

..  code-block:: init.lua

    box.cfg{ listen = '127.0.0.1:3301', memtx_use_mvcc_engine = false }
    box.schema.user.grant('guest', 'super', nil, nil, {if_not_exists = true})

    tickets = box.schema.create_space('tickets', { if_not_exists = true })
    tickets:format({  { name = "id", type = "number" },  { name = "place", type = "number" }, })  
    tickets:create_index('primary', { parts = { 'id' } })
    tickets:insert({1, 428})
    
    box.begin()
    tickets:replace{1, 429}
    tickets:replace{2, 429}
    box.commit()

Run ``init.lua``:

..  code-block:: false
    
    Result: 
    tarantool> 2022-06-07 16:08:01.515[186747] main/103/run.lua txn.c:705 E> ER_TRANSACTION_YIELD: Transaction has been aborted by a fiber yield
    ---
    - error: Transaction has been aborted by a fiber yield
    …

Change ``memtx_use_mvcc_engine`` to ``true`` and run ``init.lua``:

..  code-block:: true
    
    Result:
    ---
    - - [1, 429]
      - [2, 429]
    ...
    tarantool> box.commit()
    ---
    …

..  _txn_mode_stream-interactive-transactions:

Streams and interactive transactions
------------------------------------

Since :tarantool-release:`2.10.0`, IPROTO implements streams and interactive 
transactions that can be used when :ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>`
is enabled on the server.

..  glossary::

    Stream
        A stream supports multiplexing several transactions over one connection. 
        Each stream has its own identifier, which is unique within the connection.
        All requests with the same non-zero stream ID belong to the same stream.
        All requests in a stream are executed strictly sequentially. 
        This allows the implementation of
        :term:`interactive transactions <interactive transaction>`.
        If the stream ID of a request is ``0``, it does not belong to any stream and is 
        processed in the old way.


In :doc:`net.box </reference/reference_lua/net_box>`, a stream is an object above 
the connection that has the same methods but allows sequential execution of requests.
The ID is automatically generated on the client side.
If a user writes their own connector and wants to use streams, 
they must transmit the ``stream_id`` over the :ref:`IPROTO protocol <box_protocol-id>`.

Unlike a thread, which involves multitasking and execution within a program,
a stream transfers data via the protocol between a client and a server.

..  glossary::

    Interactive transaction
        An interactive transaction is one that does not need to be sent in a single request.
        There are multiple ways to begin, commit, and roll back a transaction, and they can be mixed. 
        You can use :ref:`stream:begin() <net_box-stream_begin>`, :ref:`stream:commit() <net_box-stream_commit>`, 
        :ref:`stream:rollback() <net_box-stream_rollback>` or the appropriate stream methods 
        -- ``call``, ``eval``, or ``execute`` -- using the SQL transaction syntax. 

Example:

..  code-block:: lua

    local conn = net_box.connect(remote_server_addr)
    local conn_space = conn.space.test
    local stream = conn:new_stream()
    local stream_space = stream.space.test

    -- Begin transaction over an iproto stream:
    stream:begin()
    stream_space:replace({1})

    -- Empty select, the transaction was not committed.
    -- You can't see it from the requests that do not belong to the
    -- transaction.
    conn_space:select{}

    -- Select returns the previously inserted tuple,
    -- because this select belongs to the transaction:
    stream_space:select({})

    -- Commit transaction:
    stream:commit()

    -- Now this select also returns the tuple, because the transaction has been committed:
    conn_space:select{}




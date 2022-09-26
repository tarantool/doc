..  _txn_mode_transaction-manager:

Transaction mode: MVCC
======================

Since version :doc:`2.6.1 </release/2.6.1>`,
Tarantool has another transaction behavior mode that
allows :ref:`"yielding" <app-yields>` inside a :ref:`memtx <engines-chapter>` transaction. 
This is controlled by the *transaction manager*.


This mode allows concurrent transactions but may cause conflicts.
You can use this mode on the :ref:`memtx <engines-chapter>` storage engine. 
The :ref:`vinyl <engines-chapter>` storage engine also supports MVCC mode, 
but has a different implementation.

..  note::

    Currently, you cannot use several different storage engines within one transaction.

..  _txn_mode_mvcc-tnx-manager:

Transaction manager
-------------------

The transaction manager is designed to isolate concurrent transactions
and provides a *serializable* 
`transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_.
It consists of two parts:

*   *MVCC* -- multi version concurrency control engine, which stores all change actions of all 
    transactions. It also creates the transaction view of the database state and a read view 
    (a fixed state of the database that is never changed by other transactions) when necessary.
    

*   *Conflict manager* -- a manager that tracks changes to transactions and determines their correctness
    in the serialization order. The conflict manager declares transactions to be in conflict 
    or sends transactions to read views when necessary.

    Since version :doc:`2.10.1 </release/2.10.1>`, the conflict manager detects conflicts right after
    the first one of several conflicting transactions is committed. After this moment, any CRUD operations
```suggestion
    in the conflicted transaction will result in errors until the transaction is
    rolled back.

The transaction manager also provides a non-classical snapshot isolation level -- this snapshot is not 
necessarily tied to the start time of the transaction, like the classical snapshot where a transaction 
can get a consistent snapshot of the database. The conflict manager decides if and when each transaction 
gets which snapshot. This avoids some conflicts compared to the classic snapshot isolation approach.

..  _txn_mode_mvcc-enabling:

Enabling the transaction manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, the transaction manager is disabled. Use the :ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>` 
option to enable it via ``box.cfg``.

..  code-block:: 

    box.cfg{memtx_use_mvcc_engine = true}
 

..  _txn_mode_mvcc-options:

Setting the transaction isolation level
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The transaction manager has three options for the :ref:`transaction isolation level <transaction_model_levels>`:

*   ``best-effort`` (default)

*   ``read-committed``

*   ``read-confirmed``

Using ``best-effort`` as the default option allows MVCC to consider the actions of transactions
independently and determine the best :ref:`isolation level <transaction_model_levels>` for them.
It increases the probability of successful completion of the transaction and helps to avoid possible conflicts.

To set another default isolation level, for example, ``read-committed``, use the following command:

..  code-block:: lua

    box.cfg{txn_isolation = 'read-committed'}

You can also set an isolation level for a specific transaction in its ``box.begin()`` call:

..  code-block:: lua

    box.begin({tnx_isolation = 'best-effort'})

In this case, you can also use the ``default`` option. It sets the transaction's isolation level
to the one set in ``box.cfg``.

..  note::

    For autocommit transactions (actions with a statement without explicit ``box.begin/commit`` calls)
    there is an obvious rule: read-only transactions (for example, ``select``) are performed with ``read-confirmed``;
    all others (for example, ``replace``) -- with ``read-committed``.

You can also set the isolation level in the net.box :ref:`stream:begin() <net_box-stream_begin>` method
and :ref:`IPROTO_BEGIN <box_protocol-begin>` binary protocol request.


Choosing the better option depends on whether you have conflicts or not. 
If you have many conflicts, you should set a different option or use 
the :ref:`default transaction mode <txn_mode-default>`.


..  _txn_mode_mvcc-examples:

Examples with MVCC enabled and disabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a file ``init.lua``, containing the following:

..  code-block:: lua

    fiber = require 'fiber'
    
    box.cfg{ listen = '127.0.0.1:3301', memtx_use_mvcc_engine = false }
    box.schema.user.grant('guest', 'super', nil, nil, {if_not_exists = true})
    
    tickets = box.schema.create_space('tickets', { if_not_exists = true })
    tickets:format({
        { name = "id", type = "number" },
        { name = "place", type = "number" },
    })
    tickets:create_index('primary', {
        parts = { 'id' },
        if_not_exists = true
    })

Connect to the instance:

..  code-block:: bash

    tarantooctl connect 127.0.0.1:3301

Then try to execute the transaction with yield inside:

..  code-block:: lua

    box.atomic(function() tickets:replace{1, 429} fiber.yield() tickets:replace{2, 429} end)


You will receive an error message:

..  code-block:: tarantoolsession
    
    ---
    - error: Transaction has been aborted by a fiber yield
    ...

Also, if you leave a transaction open while returning from a request, you will get an error message:

..  code-block:: tarantoolsession
    
    127.0.0.1:3301> box.begin()
    ---
    - error: Transaction is active at return from function
    ...

Change ``memtx_use_mvcc_engine`` to ``true``, restart tarantool and try again:

..  code-block:: tarantoolsession
    
    127.0.0.1:3301> box.atomic(function() tickets:replace{1, 429} fiber.yield() tickets:replace{2, 429} end)
    ---
    ...

Now check if this transaction was successful:

..  code-block:: tarantoolsession
    
    127.0.0.1:3301> box.space.tickets:select({}, {limit = 10})
    ---
    - - [1, 429]
      - [2, 429]
    ...


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


Let’s create a Lua client (``client.lua``) and run it with tarantool:

..  code-block:: lua

    local net_box = require 'net.box'
    local conn = net_box.connect('127.0.0.1:3301')
    local conn_tickets = conn.space.tickets
    local yaml = require 'yaml'

    local stream = conn:new_stream()
    local stream_tickets = stream.space.tickets
    
    -- Begin transaction over an iproto stream:
    stream:begin()
    print("Replaced in a stream\n".. yaml.encode(  stream_tickets:replace({1, 768}) ))

    -- Empty select, the transaction was not committed.
    -- You can't see it from the requests that do not belong to the
    -- transaction.
    print("Selected from outside of transaction\n".. yaml.encode(conn_tickets:select({}, {limit = 10}) ))

    -- Select returns the previously inserted tuple
    -- because this select belongs to the transaction:
    print("Selected from within transaction\n".. yaml.encode(stream_tickets:select({}, {limit = 10}) ))

    -- Commit transaction:
    stream:commit()

    -- Now this select also returns the tuple because the transaction has been committed:
    print("Selected again from outside of transaction\n".. yaml.encode(conn_tickets:select({}, {limit = 10}) ))

    os.exit()

Then call it and see the following output:

..  code-block:: 

    Replaced in a stream
    --- [1, 768]
    ...

    Selected from outside of transaction
    ---
    - [1, 429]
    - [2, 429]
    ...

    Selected from within transaction
    ---
    - [1, 768]
    - [2, 429]
    ...

    Selected again from outside of transaction
    ---
    - [1, 768]
    - [2, 429]
    ...```




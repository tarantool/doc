..  _app-yields:

Yields
======

Tarantool has two types of yields:

*   Implicit.

*   Explicit.

..  _app-implicit-yields:

Implicit yields
---------------

**Implicit yields** are caused by many requests, because Tarantool is designed 
to avoid blocking. For example, it can be used with :ref:`box.begin() <box-begin>` 
when starting a transaction.


Database requests imply yields if and only if there is disk I/O.

For :ref:`memtx <engines-chapter>`, since all data is in memory, 
there is no disk I/O during a read request.

For :ref:`vinyl <engines-chapter>`, since some data may not be in memory, 
there may be disk I/O for a read (to fetch data from disk) or write 
(because a stall may occur while waiting for memory to be free).

For both :ref:`memtx <engines-chapter>` and :ref:`vinyl <engines-chapter>`, 
since data-change requests must be recorded in the WAL,
there is normally a commit. 
It happens automatically after each request in the default "autocommit" mode, 
or a commit happens at the end of a transaction in "transaction" mode, 
when a user intentionally commits by calling :doc:`/reference/reference_lua/box_txn_management/commit`.
Therefore, because there can be disk I/O, some database operations may imply yields for both storage engines.


Many functions in the modules :ref:`fio <fio-section>`, :ref:`net_box <net_box-module>`,
:ref:`console <console-module>` and :ref:`socket <socket-module>`
(the "os" and "network" requests) yield.

That is why executing separate commands like ``select()``, ``insert()``,
``update()`` in the console inside a transaction will cause an abort. This is
due to implicit yield happening after each chunk of code is executed in the console.

**Example #1**

*   *Engine = memtx* |br|
    The sequence ``select() insert()`` has one yield, at the end of the insert, caused 
    by implicit commit; ``select()`` has nothing to write to the WAL and so does not
    yield.

*   *Engine = vinyl* |br|
    The sequence ``select() insert()`` has one to three yields, since ``select()``
    may yield if the data is not in the cache, ``insert()`` may yield if it is waiting 
    for available memory, and there is an implicit yield at commit.

*   The sequence ``begin() insert() insert() commit()`` only yields on commit
    if the engine is memtx, and can yield up to 3 times if the engine is vinyl.

**Example #2**

Assume that there are tuples in the memtx space ‘tester’ where the third field
represents a positive dollar amount. Let's start a transaction, withdraw
from tuple#1, deposit in tuple#2, and end the transaction, making its
effects permanent.

..  code-block:: tarantoolsession

    tarantool> function txn_example(from, to, amount_of_money)
             >   box.begin()
             >   box.space.tester:update(from, {{'-', 3, amount_of_money}})
             >   box.space.tester:update(to,   {{'+', 3, amount_of_money}})
             >   box.commit()
             >   return "ok"
             > end
    
    Result:
    ---
    ...
    tarantool> txn_example({999}, {1000}, 1.00)
    ---
    - "ok"
    ...

If :ref:`wal_mode <cfg_binary_logging_snapshots-wal_mode>` = ‘none’, then
implicit yielding at the commit time does not take place, because there are
no writes to the WAL.

If a task is interactive -- sending requests to the server and receiving responses --
then it involves network I/O and thus an implicit yield, even if the
request that is sent to the server is not itself an implicit yield request.
Therefore, the following sequence causes yields three times sequentially 
when sending requests to the network and awaiting the results.

..  cssclass:: highlight
..  parsed-literal::

    conn.space.test:select{1}
    conn.space.test:select{2}
    conn.space.test:select{3}

On the server side, the same requests are executed
in a common order possibly mixing with other requests from the network and
local fibers. Something similar happens when using clients that operate
via telnet, via one of the connectors, or via the
:ref:`MySQL and PostgreSQL rocks <dbms_modules>`, or via the interactive mode when
:ref:`using Tarantool as a client <admin-using_tarantool_as_a_client>`.

After a fiber has yielded and regained control, it immediately issues
:ref:`testcancel <fiber-testcancel>`.

..  _app-explicit-yields:

Explicit yields
---------------

**Explicit yields** can (and should) normally be added as :ref:`"yield" <fiber-yield>` 
statements to prevent hogging in a Lua function. This allows for :ref:`cooperative multitasking <app-cooperative_multitasking>`.

:ref:`fiber.sleep() <fiber-sleep>` and :ref:`fiber.yield() <fiber-yield>` 
are the only explicit yield requests in Tarantool by default. 



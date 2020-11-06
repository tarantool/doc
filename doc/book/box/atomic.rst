.. _atomic-atomic_execution:

================================================================================
Transaction control
================================================================================

Transactions in Tarantool occur in **fibers** on a single **thread**.
That is why Tarantool has a guarantee of execution atomicity.
That requires emphasis.

.. _atomic-threads_fibers_yields:

--------------------------------------------------------------------------------
Threads, fibers and yields
--------------------------------------------------------------------------------

How does Tarantool process a basic operation? As an example, let's take this
query:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:update({3}, {{'=', 2, 'size'}, {'=', 3, 0}})

This is equivalent to the following SQL statement for a table that stores
primary keys in ``field[1]``:

.. code-block:: SQL

   UPDATE tester SET "field[2]" = 'size', "field[3]" = 0 WHERE "field[1]" = 3

Assuming this query is received by Tarantool via network,
it will be processed with three operating system **threads**:

1. The **network thread** on the server side receives the query, parses
   the statement, checks if it's correct, and then transforms it into a special
   structure--a message containing an executable statement and its options.

2. The network thread ships this message to the instance's
   **transaction processor thread** using a lock-free message bus.
   Lua programs execute directly in the transaction processor thread,
   and do not require parsing and preparation.

   The instance's transaction processor thread uses the primary-key index on
   field[1] to find the location of the tuple. It determines that the tuple
   can be updated (not much can go wrong when you're merely changing an
   unindexed field value).

3. The transaction processor thread sends a message to the
   :ref:`write-ahead logging (WAL) thread <internals-wal>` to commit the
   transaction. When done, the WAL thread replies with a COMMIT or ROLLBACK
   result to the transaction processor which gives it back to the network thread,
   and the network thread returns the result to the client.

Notice that there is only one transaction processor thread in Tarantool.
Some people are used to the idea that there can be multiple threads operating
on the database, with (say) thread #1 reading row #x, while thread #2 writes
row #y. With Tarantool, no such thing ever happens.
Only the transaction processor thread can access the database, and there is
only one transaction processor thread for each Tarantool instance.

Like any other Tarantool thread, the transaction processor thread can handle
many :ref:`fibers <fiber-fibers>`. A fiber is a set of computer instructions
that may contain "**yield**" signals. The transaction processor thread will
execute all computer instructions until a yield, then switch to execute the
instructions of a different fiber. Thus (say) the thread reads row #x for the
sake of fiber #1, then writes row #y for the sake of fiber #2.

Yields must happen, otherwise the transaction processor thread would stick
permanently on the same fiber. There are two types of yields:

* :ref:`implicit yields <atomic-implicit-yields>`: every data-change operation
  or network-access causes an implicit yield, and every statement that goes
  through the Tarantool client causes an implicit yield.

* explicit yields: in a Lua function, you can (and should) add
  :ref:`"yield" <fiber-yield>` statements to prevent hogging. This is called
  **cooperative multitasking**.

.. _atomic-cooperative_multitasking:

--------------------------------------------------------------------------------
Cooperative multitasking
--------------------------------------------------------------------------------

Cooperative multitasking means: unless a running fiber deliberately yields
control, it is not preempted by some other fiber. But a running fiber will
deliberately yield when it encounters a “yield point”: a transaction commit,
an operating system call, or an explicit :ref:`"yield" <fiber-yield>` request.
Any system call which can block will be performed asynchronously, and any running
fiber which must wait for a system call will be preempted, so that another
ready-to-run fiber takes its place and becomes the new running fiber.

This model makes all programmatic locks unnecessary: cooperative multitasking
ensures that there will be no concurrency around a resource, no race conditions,
and no memory consistency issues. The way to achieve this is quite simple:
in critical sections, don't use yields, explicit or implicit, and no one
can interfere into the code execution.

When requests are small, for example simple UPDATE or INSERT or DELETE or SELECT,
fiber scheduling is fair: it takes only a little time to process the request,
schedule a disk write, and yield to a fiber serving the next client.

However, a function might perform complex computations or might be written in
such a way that yields do not occur for a long time. This can lead to
unfair scheduling, when a single client throttles the rest of the system, or to
apparent stalls in request processing. Avoiding this situation is
the responsibility of the function’s author.

.. _atomic-transactions:

--------------------------------------------------------------------------------
Transactions
--------------------------------------------------------------------------------

In the absence of transactions, any function that contains yield points may see
changes in the database state caused by fibers that preempt.
Multi-statement transactions exist to provide **isolation**: each transaction
sees a consistent database state and commits all its changes atomically.
At :ref:`commit <box-commit>` time, a yield happens and all transaction changes
are written to the :ref:`write ahead log <internals-wal>` in a single batch.
Or, if needed, transaction changes can be rolled back --
:ref:`completely <box-rollback>` or to a specific
:ref:`savepoint <box-rollback_to_savepoint>`.

In Tarantool, `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_
is *serializable* with the clause "if no failure during writing to WAL". In
case of such a failure that can happen, for example, if the disk space
is over, the transaction isolation level becomes *read uncommitted*.

In :ref:`vynil <engines-chapter>`, to implement isolation Tarantool uses a simple optimistic scheduler:
the first transaction to commit wins. If a concurrent active transaction
has read a value modified by a committed transaction, it is aborted.

The cooperative scheduler ensures that, in absence of yields,
a multi-statement transaction is not preempted and hence is never aborted.
Therefore, understanding yields is essential to writing abort-free code.

Sometimes while testing the transaction mechanism in Tarantool you can notice
that yielding after ``box.begin()`` but before any read/write operation does not
cause an abort as it should according to the description. This happens because
actually ``box.begin()`` does not start a transaction. It is a mark telling
Tarantool to start a transaction after some database request that follows.

In memtx, if an instruction that implies yields, explicit or implicit, is
executed during a transaction, the transaction is fully rolled back. In vynil,
we use more complex transactional manager that allows yields.

.. note::

   You can’t mix storage engines in a transaction today.

.. _atomic-implicit-yields:

--------------------------------------------------------------------------------
Implicit yields
--------------------------------------------------------------------------------

The only explicit yield requests in Tarantool are :ref:`fiber.sleep() <fiber-sleep>`
and :ref:`fiber.yield() <fiber-yield>`, but many other requests "imply" yields
because Tarantool is designed to avoid blocking.

Database requests imply yields if and only if there is disk I/O.
For memtx, since all data is in memory, there is no disk I/O during a read request.
For vinyl, since some data may not be in memory, there may be disk I/O
for a read (to fetch data from disk) or for a write (because a stall
may occur while waiting for memory to be free).
For both memtx and vinyl, since data-change requests must be recorded in the WAL,
there is normally a commit.
A commit happens automatically after every request in default "autocommit" mode,
or a commit happens at the end of a transaction in "transaction" mode,
when a user deliberately commits by calling :ref:`box.commit() <box-commit>`.
Therefore for both memtx and vinyl, because there can be disk I/O,
some database operations may imply yields.

Many functions in modules :ref:`fio <fio-section>`, :ref:`net_box <net_box-module>`,
:ref:`console <console-module>` and :ref:`socket <socket-module>`
(the "os" and "network" requests) yield.

That is why executing separate commands such as ``select()``, ``insert()``,
``update()`` in the console inside a transaction will cause an abort. This is
due to implicit yield happening after each chunk of code is executed in the console.

**Example #1**

* *Engine = memtx* |br|
  The sequence ``select() insert()`` has one yield, at the end of insertion, caused by
  implicit commit; ``select()`` has nothing to write to the WAL and so does not
  yield.

* *Engine = vinyl* |br|
  The sequence ``select() insert()`` has one to three yields, since ``select()``
  may yield if the data is not in cache, ``insert()`` may yield waiting for
  available memory, and there is an implicit yield at commit.

* The sequence ``begin() insert() insert() commit()`` yields only at commit
  if the engine is memtx, and can yield up to 3 times if the engine is vinyl.

**Example #2**

Assume that in the memtx space ‘tester’ there are tuples in which the third field
represents a positive dollar amount. Let's start a transaction, withdraw
from tuple#1, deposit in tuple#2, and end the transaction, making its
effects permanent.

.. code-block:: tarantoolsession

    tarantool> function txn_example(from, to, amount_of_money)
             >   box.begin()
             >   box.space.tester:update(from, {{'-', 3, amount_of_money}})
             >   box.space.tester:update(to,   {{'+', 3, amount_of_money}})
             >   box.commit()
             >   return "ok"
             > end
    ---
    ...
    tarantool> txn_example({999}, {1000}, 1.00)
    ---
    - "ok"
    ...

If :ref:`wal_mode <cfg_binary_logging_snapshots-wal_mode>` = ‘none’, then
implicit yielding at commit time does not take place, because there are
no writes to the WAL.

If a task is interactive -- sending requests to the server and receiving responses --
then it involves network I/O, and therefore there is an implicit yield, even if the
request that is sent to the server is not itself an implicit yield request.
Therefore, the following sequence

.. cssclass:: highlight
.. parsed-literal::

   conn.space.test:select{1}
   conn.space.test:select{2}
   conn.space.test:select{3}

causes yields three times sequentially when sending requests to the network
and awaiting the results. On the server side, the same requests are executed
in common order possibly mixing with other requests from the network and
local fibers. Something similar happens when using clients that operate
via telnet, via one of the connectors, or via the
:ref:`MySQL and PostgreSQL rocks <dbms_modules>`, or via the interactive mode when
:ref:`using Tarantool as a client <admin-using_tarantool_as_a_client>`.

After a fiber has yielded and then has regained control, it immediately issues
:ref:`testcancel <fiber-testcancel>`.

.. atomic-transactional-manager

--------------------------------------------------------------------------------
Transactional manager
--------------------------------------------------------------------------------

Since version 2.6.1, Tarantool has another option for transaction behaviour that
allows yielding inside a memtx transaction. This is controled by
the *transactional manager*.

The transactional manager is designed for isolation of concurrent transactions.
It consists of two parts:

* *MVCC engine*
* *conflict manager*.

The MVCC engine provides personal read views for transactions if necessary.
The conflict manager tracks transactions' changes and determines their correctness
in serialization order. Of course, once yielded, a transaction could interfere
with other transactions and could be aborted due to conflict.

The transactional manager can be switched on and off by the ``box.cfg`` option
:ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>`.

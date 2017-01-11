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

How does Tarantool process a basic operation? As an example, let's take this query:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:update({3}, {{'=', 2, 'size'}, {'=', 3, 0}})

This is equivalent to an SQL statement like:

.. code-block:: SQL

   UPDATE tester SET "field[2]" = 'size', "field[3]" = 0 WHERE "field[[1]" = 3

This query will be processed with three operating system **threads**:

1. If we issue the query on a remote client, then the **network thread** on
   the server side receives the query, parses the statement and changes it
   to a server executable message which has already been checked, and which
   the server can understand without parsing everything again.

2. The network thread ships this message to the server's
   **"transaction processor" thread** using a lock-free message bus.
   Lua programs execute directly in the transaction processor thread,
   and do not require parsing and preparation.

   The server's transaction processor thread uses the primary-key index on
   field[1] to find the location of the tuple. It determines that the tuple
   can be updated (not much can go wrong when you're merely changing an
   unindexed field value to something shorter).

3. The transaction processor thread sends a message to the
   **write-ahead logging (WAL) thread** to commit the transaction.
   When done, the WAL thread replies with a COMMIT or ROLLBACK result,
   which is returned to the client.

Notice that there is only one transaction processor thread in Tarantool.
Some people are used to the idea that there can be multiple threads operating
on the database, with (say) thread #1 reading row #x, while thread #2 writes
row #y. With Tarantool, no such thing ever happens.
Only the transaction processor thread can access the database, and there is
only one transaction processor thread for each instance of the server.

Like any other Tarantool thread, the transaction processor thread can handle
many **fibers**. A fiber is a set of computer instructions that may contain
"**yield**" signals. The transaction processor thread will execute all computer
instructions until a yield, then switch to execute the instructions of a
different fiber. Thus (say) the thread reads row #x for the sake of fiber #1,
then writes row #y for the sake of fiber #2.

Yields must happen, otherwise the transaction processor thread would stick
permanently on the same fiber. There are two types of yields:

* :ref:`implicit yields <atomic-implicit-yields>`: every data-change operation
  or network-access causes an implicit yield, and every statement that goes
  through the Tarantool client causes an implicit yield.

* explicit yields: in a Lua function, you can (and should) add “yield”
  statements to prevent hogging. This is called **cooperative multitasking**.

.. _atomic-cooperative_multitasking:

--------------------------------------------------------------------------------
Cooperative multitasking
--------------------------------------------------------------------------------

Cooperative multitasking means: unless a running fiber deliberately yields
control, it is not preempted by some other fiber. But a running fiber will
deliberately yield when it encounters a “yield point”: a transaction commit,
an operating system call, or an explicit ``yield()`` request. Any system call
which can block will be performed asynchronously, and any running fiber
which must wait for a system call will be preempted, so that another
ready-to-run fiber takes its place and becomes the new running fiber.

This model makes all programmatic locks unnecessary: cooperative multitasking
ensures that there will be no concurrency around a resource, no race conditions,
and no memory consistency issues.

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
Multi-statement transactions exist to provide isolation: each transaction sees
a consistent database state and commits all its changes atomically.
At commit time, a yield happens and all transaction changes are written to the
write ahead log in a single batch.

To implement isolation, Tarantool uses a simple optimistic scheduler:
the first transaction to commit wins. If a concurrent active transaction
has read a value modified by a committed transaction, it is aborted.

The cooperative scheduler ensures that, in absence of yields,
a multi-statement transaction is not preempted and hence is never aborted.
Therefore, understanding yields is essential to writing abort-free code.

.. note::

   You can’t mix storage engines in a transaction today.

.. _atomic-implicit-yields:

--------------------------------------------------------------------------------
Implicit yields
--------------------------------------------------------------------------------

The only explicit yield requests in Tarantool are :ref:`fiber.sleep() <fiber-sleep>`
and :ref:`fiber.yield() <fiber-yield>`, but many other requests "imply" yields
because Tarantool is designed to avoid blocking.

Database operations usually do not yield, but it depends on the engine:

* In memtx, reads or writes do not require I/O and do not yield.

* In vinyl, not all data is in memory, and SELECT often incurs a disc I/O,
  and therefore yields, while a write may stall waiting for memory to free up,
  thus also causing a yield.

In the "autocommit" mode, all data change operations are followed by an automatic
commit, which yields. So does an explicit commit of a multi-statement transaction,
:ref:`box.commit() <box-commit>`.

Many functions in modules :ref:`fio <fio-section>`, :ref:`net_box <net_box-module>`,
:ref:`console <console-module>` and :ref:`socket <socket-module>`
(the "os" and "network" requests) yield.

**Example #1**

* *Engine = memtx* |br|
  ``select() insert()`` has one yield, at the end of insertion, caused by
  implicit commit; ``select()`` has nothing to write to WAL and so does not yield.

* *Engine = vinyl* |br|
  ``select() insert()`` has between one and three yields, since ``select()``
  may yield if the data is not in cache, ``insert()`` may yield waiting for
  available memory, and there is an implicit yield at commit.

* The sequence ``begin() insert() insert() commit()`` yields only at commit
  if the engine is memtx, and can yield up to 3 times if the engine is vinyl.

**Example #2**

Assume that in space ‘tester’ there are tuples in which the third field
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
then it involves network IO, and therefore there is an implicit yield, even if the
request that is sent to the server is not itself an implicit yield request.
Therefore, the sequence:

.. cssclass:: highlight
.. parsed-literal::

   select
   select
   select

causes blocking (in memtx), if it is inside a function or Lua program being
executed on the server, but causes yielding (in both memtx and vinyl) if it
is done as a series of transmissions from a client, including a client which
operates via telnet, via one of the connectors, or via the MySQL and PostgreSQL
rocks, or via the interactive mode when
:ref:`using Tarantool as a client <administration-using_tarantool_as_a_client>`.

After a fiber has yielded and then has regained control, it immediately issues
:ref:`testcancel <fiber-testcancel>`.

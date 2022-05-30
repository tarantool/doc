..  _atomic-transactional-manager:

Transactional manager
=====================

Since version :doc:`2.6.1 </release/2.6.1>`,
Tarantool has another option for transaction behavior that
allows yielding inside a memtx transaction. This is controlled by
the *transactional manager*.

The transactional manager is designed to isolate concurrent transactions
and provides a *serializable* `transaction isolation level <https://en.wikipedia.org/wiki/Isolation_(database_systems)#Isolation_levels>`_.
It consists of two parts:

*   *MVCC engine*
*   *conflict manager*

The MVCC engine provides personal read views for transactions if necessary.
The conflict manager tracks chaanges to transactions and determines their correctness
in serialization order. Of course, once yielded, a transaction could interfere
with other transactions and be aborted due to a conflict.

Another important point is that the transaction manager
provides a non-classical snapshot isolation level. This means that a transaction
can get a consistent snapshot of the database (that is common), but this snapshot
is not necessarily bound to the moment of the transaction started 
(that is not common).
The conflict manager decides if and when each transaction gets
which snapshot. That allows to avoid some conflicts compared to the classic 
snapshot isolation approach.

The transactional manager can be switched on and off by the ``box.cfg`` option
:ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>`.

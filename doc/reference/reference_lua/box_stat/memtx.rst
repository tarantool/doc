.. _box_introspection-box_stat_memtx:

box.stat.memtx()
================

.. module:: box.stat

.. function:: memtx()

    Shows ``memtx`` storage engine activity.

.. _box_introspection-box_stat_memtx_tx:

box.stat.memtx().tx
-------------------

``tx`` shows the statistics of the memtx transactional manager,
which is responsible for transactions (``box.stat.memtx().tx.txn``)
and multiversion concurrency control (``box.stat.memtx().tx.mvcc``).

* ``box.stat.memtx().tx.txn`` shows memory allocation related to transactions.

  It consists of the following sections:

  * ``statements`` are *transaction statements*.
    As an example, consider a user starting a transaction with
    ``space:replace{0, 1}`` within this transaction. Under the hood,
    this operation becomes a statement for this transaction.
  * ``user`` is the memory that a user allocated within
    the current transaction using the Tarantool C API function
    :ref:`box_txn_alloc() <txn-box_txn_alloc>`.
  * ``system`` is the memory allocated for internal needs
    (for example, logs) and savepoints.

    .. _box_introspection-box_stat_memtx_tx_total_avg_max:

    For each section, Tarantool reports the following statistics:

    * ``total`` is the number of bytes that are currently allocated in memtx
      for all transactions within the section scope.
    * ``avg`` is the average number of bytes that a single transaction uses
      (equals ``total`` / number of open transactions).
    * ``max`` is the maximal number of bytes that a single transaction uses.

* ``box.stat.memtx().tx.mvcc`` shows memory allocation related to
  :ref:`multiversion concurrency control (MVCC) <txn_mode_transaction-manager>`.
  MVCC is reponsible for isolating transactions.
  It reveals conflicts and makes sure that tuples that do not belong to a particular
  space but were (or could be) read by some transaction were not deleted.

  It consists of the following sections:

  * ``trackers`` is the memory allocated for *trackers* of transaction reads.
    Like in the :ref:`previous sections <box_introspection-box_stat_memtx_tx_total_avg_max>`,
    Tarantool reports the total, average, and maximal number of bytes allocated
    for trackers per a single transaction.
  * ``conflicts`` is the memory allocated for *conflicts*
    which are entities created when transactional conflicts occur.
    Like in the :ref:`previous sections <box_introspection-box_stat_memtx_tx_total_avg_max>`,
    Tarantool reports the total, average, and maximal number of allocated bytes.
  * ``tuples`` is the memory allocated for storing tuples.
    With MVCC, tuples are stored using the *stories* mechanism. Nearly every
    tuple has its story. Even tuples in an index may have their stories, so
    it may be useful to differentiate memory allocated for tuples and memory
    allocated for stories.

    All stored tuples fall into three categories, with memory statistics
    reported for each category:

    * ``tracking`` is for tuples that are not used by any transactions directly,
      but MVCC uses them for tracking transaction reads.
    * ``used`` is for tuples that are used by active read-write transactions.
      See a detailed :ref:`example <box_introspection-box_stat_memtx_tx_example>` below.
    * ``read_view`` is for tuples that are not used by active read-write transactions,
      but are used by read-only transactions.

      For each of the three categories, Tarantool reports two statistical blocks:

      * ``stories`` is for stories.
      * ``retained`` is for *retained* tuples which do not belong to any index,
        but MVCC doesn't allow to delete them yet.

      For each block, Tarantool reports the following statistics:

      * ``count`` is the number of stories or retained tuples.
      * ``total`` is the number of bytes allocated for stories or retained tuples.

.. _box_introspection-box_stat_memtx_tx_example:

**Example**

Let's get memory statistics for ``used`` tuples in a transaction.

First, we :ref:`enable MVCC <txn_mode_mvcc-enabling>` so that
``box.stat.memtx.tx().mvcc`` contained non-zero values.

.. code-block:: lua

   box.cfg{memtx_use_mvcc_engine = true}

We did it within the first ``box.cfg{}`` call to a new Tarantool instance,
because the parameter ``memtx_use_mvcc_engine`` is non-dynamic.

Next, we create a space with a primary index, and begin a transaction:

.. code-block:: lua

   box.schema.space.create('test')
   box.space.test:create_index('pk')

   box.begin()
   box.space.test:replace{0, 0}
   box.space.test:replace{0, string.rep('a', 100)}
   box.space.test:replace{0, 1}
   box.space.test:replace{1, 1}
   box.space.test:replace{2, 1}

In the transaction above, we replaced three tuples by the `0` key:

* ``{0, 0}``
* ``{0, 'aa...aa'}``
* ``{0, 1}``

MVCC considers all these tuples as ``used`` since they belong to the current transaction.
Also, MVCC considers tuples ``{0, 0}`` and ``{0, 'aa..aa'}`` as ``retained`` because
they don't belong to any index (unlike ``{0, 1}``), but they cannot be deleted yet.

If we call ``box.stat.memtx.tx()`` now, we'll see something like this:

.. code-block:: tarantoolsession
   :emphasize-lines: 33-39

	tarantool> box.stat.memtx.tx()
	---
	- txn:
	    statements:
	      max: 720
	      avg: 720
	      total: 720
	    user:
	      max: 0
	      avg: 0
	      total: 0
	    system:
	      max: 916
	      avg: 916
	      total: 916
	  mvcc:
	    trackers:
	      max: 0
	      avg: 0
	      total: 0
	    conflicts:
	      max: 0
	      avg: 0
	      total: 0
	    tuples:
	      tracking:
	        stories:
	          count: 0
	          total: 0
	        retained:
	          count: 0
	          total: 0
	      used:
	        stories:
	          count: 6
	          total: 944
	        retained:
	          count: 2
	          total: 119
	      read_view:
	        stories:
	          count: 0
	          total: 0
	        retained:
	          count: 0
	          total: 0
	...

Pay attention to highlighted lines -- it's the memory allocated for `used` tuples.

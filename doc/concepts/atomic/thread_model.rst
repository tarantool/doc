..  _thread_model:

Thread model
============

..  _main_threads:

Main threads
------------

The thread model assumes that a :ref:`query <index-box_operations>` received by Tarantool via network
is processed with three operating system **threads**:

1.  The **network thread** (or :ref:`threads <cfg_networking-iproto_threads>`)
    on the server side receives the query, parses
    the statement, checks if it is correct, and then transforms it into a special
    structure -- a message containing an executable statement and its options.

2.  The network thread sends this message to the instance's
    **transaction processor thread** (*TX thread*) via a lock-free message bus.
    Lua programs are executed directly in the transaction processor thread,
    and do not need to be parsed and prepared.

    The TX thread either uses a space index to find and update the tuple,
    or executes a stored function that performs a data operation.

3.  The execution of the operation results in a message to the
    :ref:`write-ahead logging (WAL) <internals-wal>` thread used to commit
    the transaction and the fiber executing the transaction is suspended.
    When the transaction results in a COMMIT or ROLLBACK, the following actions are taken:

    * The WAL thread responds with a message to the TX thread.

    * The fiber executing the transaction is resumed to process the result of the transaction.

    * The result of the fiber execution is passed to the network thread,
      and the network thread returns the result to the client.


..  note::

    There is only one TX thread in Tarantool.
    Some users are used to the idea that there can be multiple threads 
    working on the database. For example, thread #1 reads a row #x while
    thread #2 writes a row #y. With Tarantool this does not happen.
    Only the TX thread can access the database,
    and there is only one TX thread for each Tarantool instance.


The TX thread can handle many :ref:`fibers <fiber-fibers>` --
a set of computer instructions that can contain "**yield**" signals.
The TX thread executes all computer instructions up to a
yield signal, and then switches to execute the instructions of another fiber.


:ref:`Yields <app-yields>` must happen, otherwise the TX thread would
be permanently stuck on the same fiber.


..  _supplementary_threads:

Supplementary threads
---------------------

There are also several supplementary threads that serve additional capabilities:

*   For :ref:`replication <replication-architecture>`, Tarantool creates a separate thread for each connected replica.
    This thread reads a write-ahead log and sends it to the replica, following its position in the log.
    Separate threads are required because each replica can point to a different position in the log and can run at different speeds.

*   There is a thread pool for ad hoc asynchronous tasks, such as a DNS resolver or :ref:`fsync <configuration_reference_wal_mode>`.

*   There is a thread pool that can be used for parallel sorting (hence, to parallelize building :ref:`indexes <concepts-data_model_indexes>`).
    To configure it, use the :ref:`memtx.sort_threads <configuration_reference_memtx_sort_threads>` configuration option.
    The option sets the number of threads used to sort keys of secondary indexes on loading a ``memtx`` database.

.. note_drop_openmp_start

    ..  NOTE::

        Since :doc:`3.0.0 </release/3.0.0>`, this option replaces the approach when OpenMP threads are used to parallelize sorting.
        For backward compatibility, the ``OMP_NUM_THREADS`` environment variable is taken into account to
        set the number of sorting threads.

.. note_drop_openmp_end
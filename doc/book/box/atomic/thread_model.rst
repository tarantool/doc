..  _thread_model:

Thread model
============

The thread model assumes that a query received by Tarantool via network 
is processed with three operating system **threads**:

1.  The **network thread** on the server side receives the query, parses
    the statement, checks if it is correct, and then transforms it into a special
    structure -- a message containing an executable statement and its options.

2.  The network thread ships this message to the instance's
    **transaction processor thread** using a lock-free message bus.
    Lua programs are executed directly in the transaction processor thread,
    and do not need to be parsed and prepared.

    The transaction processor thread of the instance uses the primary key index on
    field[1] to find the location of the tuple. It determines that the tuple
    can be updated (not much can go wrong when you're merely changing an
    unindexed field value).

3.  The **transaction processor thread** sends a message to the
    :ref:`write-ahead logging (WAL) thread <internals-wal>` to commit the
    transaction. When this is done, the WAL thread replies with a COMMIT or ROLLBACK
    result to the transaction processor, which returns it to the network thread,
    and the network thread returns the result to the client.

..  note::

    There is only one transaction processor thread in Tarantool. 
    Some users are used to the idea that there can be multiple threads 
    working on the database. For example, thread #1 reads row #x while 
    thread #2 writes row #y. With Tarantool, this never happens. 
    Only the transaction processor thread can access the database, 
    and there is only one transaction processor thread for each Tarantool instance.

Like any other Tarantool thread, the transaction processor thread can handle
many :ref:`fibers <fiber-fibers>` -- a set of computer instructions
that may contain "**yield**" signals. 
The transaction processor thread executes all computer instructions up to 
a yield signal, and then switches to execute the instructions of another fiber. 

Yields must happen, otherwise the transaction processor thread would 
be permanently stuck on the same fiber. There are two types of these yields:

*   **implicit yields**: caused by any data change operation
    or network access and any statement passing
    through the Tarantool client.

*   **explicit yields**: can (and should) be added as 
    :ref:`"yield" <fiber-yield>` statements to prevent hogging in 
    a Lua function. This is called **cooperative multitasking**.
    
..  _thread_model-example:

Example
-------

Let's see how Tarantool process a basic operation using this query: 

..  code-block:: tarantoolsession

    tarantool> box.space.tester:update({3}, {{'=', 2, 'size'}, {'=', 3, 0}})

This is equivalent to the following SQL statement for a table that stores
primary keys in ``field[1]``:

..  code-block:: SQL

    UPDATE tester SET "field[2]" = 'size', "field[3]" = 0 WHERE "field[1]" = 3
    
..  note::

    It is better to follow best practice and use SQL with placeholders:
    ``box.execute([[ UPDATE tester SET "name" = 'size', "data" = 0 WHERE "id" = 3 ]], 123``
    

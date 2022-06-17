..  _thread_model:

Thread model
============

The thread model assumes that a query received by Tarantool via network 
is processed with three operating system **threads**:

1.  The **network thread** on the server side receives the query, parses
    the statement, checks if it is correct, and then transforms it into a special
    structure -- a message containing an executable statement and its options.

2.  The network thread ships this message to the instance's
    **transaction processor thread** (*tx thread*) using a lock-free message bus.
    Lua programs are executed directly in the transaction processor thread,
    and do not need to be parsed and prepared.

    The tx thread either use space index to find and update the tuple, 
    or executes stored function, that will perform some data operations.

3.  The execution of operation will result in a message to the 
    :ref:`write-ahead logging (WAL) thread <internals-wal>` thread to commit 
    the transaction and the fiber executing the transaction will be suspended. 
    When the transaction will result in a COMMIT or ROLLBACK, WAL thread will 
    reply with a message to the TX, fiber will be resumed to have an ability 
    to process the result of transaction and the result of fiber execution 
    will be passed to the network thread, and the network thread returns 
    the result to the client.


..  note::

    There is only one tx thread in Tarantool. 
    Some users are used to the idea that there can be multiple threads 
    working on the database. For example, thread #1 reads row #x while 
    thread #2 writes row #y. With Tarantool, this never happens. 
    Only the tx thread can access the database, 
    and there is only one tx thread for each Tarantool instance.


The tx thread can handle many :ref:`fibers <fiber-fibers>` -- 
a set of computer instructions that may contain "**yield**" signals. 
The tx thread executes all computer instructions up to a 
yield signal, and then switches to execute the instructions of another fiber.


:ref:`Yields <app-yields>` must happen, otherwise the tx thread would 
be permanently stuck on the same fiber.

..  _thread_model-example:

Example
-------

Create space "tester": 

..  code-block:: tarantoolsession

    box.schema.create_space('tester',{ if_not_exists = true; })
    
    box.space.tester:format( {
        { name = 'id';     type = 'number' },
        { name = 'name';   type = 'string' },
        { name = 'data';   type = '*'      },
    } );

    box.space.tester:create_index('primary', {
       parts = {{ 'id','number' }};
       if_not_exists = true;
    })

    box.space.tester:update({3}, {{'=', 'name, 'size'}, {'=', 'data', 0}})


Perform a basic operation with this query: 

..  code-block:: tarantoolsession

    box.space.tester:update({3}, {{'=', 'name, 'size'}, {'=', 'data', 0}})   


This is equivalent to the following SQL statement:

..  code-block:: SQL

    UPDATE tester SET "name" = 'size', "data" = 0 WHERE "id" = 3
    
..  note::

    It is better to follow best practice and use SQL with placeholders:
    
    ``box.execute([[ UPDATE tester SET "name" = ?, "data" = ? WHERE "id" = ? ]], 'size', 0, 123)``
    






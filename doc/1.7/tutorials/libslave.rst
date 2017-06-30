.. _libslave:

================================================================================
libslave
================================================================================

libslave is a C++ library for reading data changes done by MysQL and,
optionally, writing them to a Tarantool database.
It works by acting as a replication slave.
The MySQL server writes data-change information to
a "binary log", and transfers the information to
any client that says "I want to see the information
starting with this file and this record, continuously".
Primarily it is good for making a Tarantool database replica
(much faster than using a conventional MySQL slave server),
and for keeping track of data changes so they can be searched.

We will not go into the many details here -- the
API documentation has them. We will only show as
an exercise: a minimal program that uses the library.

Use a test machine. Do not use a production machine.

STEP 1: Make sure you have: a recently made Linux
(versions such as Ubuntu 14.04 will not do), a
recently made MySQL 5.6 or MySQL 5.7 server
(MariaDB will not do), and MySQL client development
package -- for example on Ubuntu you can download with |br|
``sudo apt-get install mysql-client-core-5.7``

STEP 2: Download libslave. The recommended source is |br|
``https://github.com/tarantool/libslave/``. |br|
Downloads are source code only. Say:

.. code-block:: none

    sudo apt-get install libboost-all-dev
    cd ~
    git clone https://github.com/tarantool/libslave.git tarantool-libslave
    cd tarantool-libslave
    git submodule init
    git submodule update
    cmake .
    make

If you see an error message mentioning the word "vector",
edit field.h and add this line: |br|
``#include <vector>``

STEP 3: Start the MySQL server. On the command line, add
appropriate switches for doing replication. For example: |br|
``mysqld --log-bin=mysql-bin --server-id=1``

STEP 4: For purposes of this exercise, we are assuming: |br|
There is a 'root' user with password 'root' with privileges. |br|
There is a 'test' database with a table named 'test'. |br|
There is a binary log named 'mysql-bin'. |br|
There is a server with server-id = 1. |br|
The values are hard coded in the program, though of course
you can change the program -- it's easy to see their settings.

STEP 5: Look at the program:

.. code-block:: none

    #include <unistd.h>
    #include <iostream>
    #include <sstream>
    #include "Slave.h"
    #include "DefaultExtState.h"

    slave::Slave* sl = NULL;

    void callback(const slave::RecordSet& event) {
        slave::Slave::binlog_pos_t sBinlogPos = sl->getLastBinlog();
        switch (event.type_event) {
        case slave::RecordSet::Update: std::cout << "UPDATE" << "\n"; break;
        case slave::RecordSet::Delete: std::cout << "DELETE" << "\n"; break;
        case slave::RecordSet::Write:  std::cout << "INSERT" << "\n"; break;
        default: break;
        }
    }

    bool isStopping()
    {
        return 0;
    }

    int main(int argc, char** argv)
    {
        slave::MasterInfo masterinfo;
        masterinfo.conn_options.mysql_host = "127.0.0.1";
        masterinfo.conn_options.mysql_port = 3306;
        masterinfo.conn_options.mysql_user = "root";
        masterinfo.conn_options.mysql_pass = "root";
        bool error = false;
        try {
            slave::DefaultExtState sDefExtState;
            slave::Slave slave(masterinfo, sDefExtState);
            sl = &slave;
            sDefExtState.setMasterLogNamePos("mysql-bin", 0);
            slave.setCallback("test", "test", callback);
            slave.init();
            slave.createDatabaseStructure();
            try {
                slave.get_remote_binlog(isStopping);
            } catch (std::exception& ex) {
                std::cout << "Error reading: " << ex.what() << std::endl;
                error = true;
            }
        } catch (std::exception& ex) {
            std::cout << "Error initializing: " << ex.what() << std::endl;
            error = true;
        }
        return 0;
    }

Everything unnecessary has been stripped so that you can
see quickly how it works. At the start of main() there are
some settings used for connecting -- host, port, user, password.
Then there is an initialization call with the binary log file
name = "mysql-bin". Pay particular attention to the setCallback
statement, which passes database name = "test", table name = "test",
and callback function address = callback. The program will be
looping and invoking this callback function. See how, earlier
in the program, the callback function prints "UPDATE" or "DELETE"
or "INSERT" depending on what is passed to it.

STEP 5: Put the program in the tarantool-libslave directory,
naming it example.cpp.

Step 6: Compile and build: |br|
``g++ -I/tarantool-libslave/include example.cpp -o example libslave_a.a -ldl -lpthread`` |br|
(Replace tarantool-libslave/include with the full directory name.)
(Beware. The name of the static library is libslave_a.a not libslave.a.)

Step 7: Run: |br|
``./example``


The result will be nothing -- the program is looping waiting for
the MySQL server to write to the replication binary log.

Step 8: Start a MySQL client program -- any client program will do.
Enter these statements:

.. code-block:: none

    USE test
    INSERT INTO test VALUES ('A');
    INSERT INTO test VALUES ('B');
    DELETE FROM test;

Watch what happens with example.cpp -- it displays:
  INSERT |br|
  INSERT |br|
  DELETE |br|
  DELETE |br|

(It's row-based replication, so you see two DELETEs,
because there are two rows.)

What the exercise has shown is: the library can be built,
programs that use the library can access everything that
the MySQL server dumps. That's all that we'll show here.
For the many details, and examples of usage in the field,
see:

`Our downloadable libslave version`_ |br|
`The version it was forked from`_ (with a different README) |br|
`How to speed up your MySQL with replication to in-memory database`_ |br|
`Replicatsiya iz MySQL v Tarantool`_ (in Russian) |br|
`Asynchronnaya Replicatsiya bez tsentsuri`_ (in Russian) |br|

.. _Our downloadable libslave version: https://github.com/tarantool/libslave
.. _The version it was forked from: https://github.com/vozbu/libslave/wiki/API
.. _How to speed up your MySQL with replication to in-memory database: http://highscalability.com/blog/2017/3/29/how-to-speed-up-your-mysql-with-replication-to-in-memory-dat.html
.. _Replicatsiya iz MySQL v Tarantool: https://habrahabr.ru/company/mailru/blog/323870/
.. _Asynchronnaya Replicatsiya bez tsentsuri: https://habrahabr.ru/company/oleg-bunin/blog/313594/

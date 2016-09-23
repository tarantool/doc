=====================================================================
                            PHP
=====================================================================

The most commonly used PHP driver is
`tarantool-php <https://github.com/tarantool/tarantool-php>`_.
It is not supplied as part of the Tarantool repository; it must be installed
separately. It can be installed with :program:`git`. It requires other modules
which should be installed first. For example, on Ubuntu, the installation could
look like this:

.. code-block:: console

    $ sudo apt-get install php5-cli
    $ sudo apt-get install php5-dev
    $ sudo apt-get install php-pear
    $ cd ~
    $ git clone https://github.com/tarantool/tarantool-php.git
    $ cd tarantool-php
    $ phpize
    $ ./configure
    $ make
    $ # make install is optional


At this point there is a file named :file:`~/tarantool-php/modules/tarantool.so`.
PHP will only find it if the PHP initialization file :file:`php.ini` contains a
line like :samp:`extension=./tarantool.so`, or if PHP is started with the option
:samp:`-d extension=~/tarantool-php/modules/tarantool.so`.

Here is a complete PHP program that inserts ``[99999,'BB']`` into a space named
``examples`` via the PHP API. Before trying to run, check that the server is
listening at ``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`. To run, paste the code into
a file named :file:`example.php` and say
:samp:`php -d extension=~/tarantool-php/modules/tarantool.so example.php`.
The program will open a socket connection with the Tarantool server at
``localhost:3301``, then send an INSERT request, then — if all is well — print
"Insert succeeded". If the tuple already exists, the program will print
“Duplicate key exists in unique index 'primary' in space 'examples'”.

.. code-block:: php

    <?php
    $tarantool = new Tarantool('localhost', 3301);

    try {
        $tarantool->insert('examples', array(99999, 'BB'));
        echo "Insert succeeded\n";
    } catch (Exception $e) {
        echo "Exception: ", $e->getMessage(), "\n";
    }

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see
`tarantool/tarantool-php <https://github.com/tarantool/tarantool-php>`_
project at GitHub.

Besides, you can use an alternative PHP driver from
another GitHub project: it includes a *client*
(see `tarantool-php/client <https://github.com/tarantool-php/client>`_)
and a *wrapper* for that client
(see `tarantool-php/mapper <https://github.com/tarantool-php/mapper>`_).

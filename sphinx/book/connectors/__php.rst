=====================================================================
                            PHP
=====================================================================

The most commonly used PHP driver is
`tarantool-php <https://github.com/tarantool/tarantool-php>`_.
It is not supplied as part of the Tarantool repository; it must be installed
separately, for example with :program:`git`. See
:ref:`installation instructions <https://github.com/tarantool/tarantool-php/blob/master/#installing-and-building>`_.
in the driver's :file:`README` file.

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
and a *mapper* for that client
(see `tarantool-php/mapper <https://github.com/tarantool-php/mapper>`_).

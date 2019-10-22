=====================================================================
                            PHP
=====================================================================

`tarantool-php <https://github.com/tarantool/tarantool-php>`_ is the official
PHP connector for Tarantool.
It is not supplied as part of the Tarantool repository and must be installed
separately (see `installation instructions
<https://github.com/tarantool/tarantool-php/#installing-and-building>`_
in the connector's ``README`` file).

Here is a complete PHP program that inserts ``[99999,'BB']`` into a space named
``examples`` via the PHP API.

Before trying to run, check that the server instance is
:ref:`listening <cfg_basic-listen>` at ``localhost:3301`` and that the space
``examples`` exists, as :ref:`described earlier <index-connector_setting>`.

To run, paste the code into a file named :file:`example.php` and say:

.. code-block:: console

    $ php -d extension=~/tarantool-php/modules/tarantool.so example.php

The program will open a socket connection with the Tarantool instance at
``localhost:3301``, then send an :ref:`INSERT <box_space-insert>` request,
then -- if all is well -- print "Insert succeeded".

If the tuple already exists, the program will print
"Duplicate key exists in unique index 'primary' in space 'examples'".

.. code-block:: php

    <?php
    $tarantool = new Tarantool('localhost', 3301);

    try {
        $tarantool->insert('examples', [99999, 'BB']);
        echo "Insert succeeded\n";
    } catch (Exception $e) {
        echo $e->getMessage(), "\n";
    }

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see
`tarantool/tarantool-php <https://github.com/tarantool/tarantool-php>`_
project at GitHub.

Besides, there is another community-driven
`GitHub project <https://github.com/tarantool-php>`_ which includes an
`alternative connector <https://github.com/tarantool-php/client>`_ written in
pure PHP, an `object mapper <https://github.com/tarantool-php/mapper>`_,
a `queue <https://github.com/tarantool-php/queue>`_ and other packages.

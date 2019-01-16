=====================================================================
                            Node.js
=====================================================================

The most commonly used node.js driver is the `Node Tarantool driver
<https://github.com/KlonD90/node-tarantool-driver>`_. It is not supplied as part
of the Tarantool repository; it must be installed separately. The most common
way to install it is with `npm
<https://www.sitepoint.com/beginners-guide-node-package-manager/>`_. For
example, on Ubuntu, the installation could look like this after npm has been
installed:

.. code-block:: console

    $ npm install tarantool-driver --global

Here is a complete node.js program that inserts ``[99999,'BB']`` into
``space[999]`` via the node.js API. Before trying to run, check that the server instance
is :ref:`listening <cfg_basic-listen>` at ``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`. To run, paste the code into
a file named :file:`example.rs` and say ``node example.rs``. The program will
connect using an application-specific definition of the space. The program will
open a socket connection with the Tarantool instance at ``localhost:3301``, then
send an :ref:`INSERT <box_space-insert>` request, then — if all is well — end after saying "Insert
succeeded". If Tarantool is not running on ``localhost`` with listen port =
3301, the program will print “Connect failed”. If :ref:`the 'guest' user <box_space-user>` does not have
authorization to connect, the program will print "Auth failed". If the insert
request fails for any reason, for example because the tuple already exists,
the program will print "Insert failed".

.. code-block:: javascript

    var TarantoolConnection = require('tarantool-driver');
    var conn = new TarantoolConnection({port: 3301});
    var insertTuple = [99999, "BB"];
    conn.connect().then(function() {
        conn.auth("guest", "").then(function() {
            conn.insert(999, insertTuple).then(function() {
                console.log("Insert succeeded");
                process.exit(0);
        }, function(e) { console.log("Insert failed");  process.exit(1); });
        }, function(e) { console.log("Auth failed");    process.exit(1); });
        }, function(e) { console.log("Connect failed"); process.exit(1); });

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see  `The node.js driver
repository <https://github.com/KlonD90/node-tarantool-driver>`_.

.. _index-box_connectors:

-------------------------------------------------------------------------------
                            Connectors
-------------------------------------------------------------------------------

This chapter documents APIs for various programming languages.

=====================================================================
                            Protocol
=====================================================================

Tarantool's binary protocol was designed with a focus on asynchronous I/O and
easy integration with proxies. Each client request starts with a variable-length
binary header, containing request id, request type, server id, log sequence
number, and so on.

The mandatory length, present in request header simplifies client or proxy I/O.
A response to a request is sent to the client as soon as it is ready. It always
carries in its header the same type and id as in the request. The id makes it
possible to match a request to a response, even if the latter arrived out of
order.

Unless implementing a client driver, you needn't concern yourself with the
complications of the binary protocol. Language-specific drivers provide a
friendly way to store domain language data structures in Tarantool. A complete
description of the binary protocol is maintained in annotated Backus-Naur form
in the source tree: please see the page about
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>`.

====================================================================
                          Packet example
====================================================================

The Tarantool API exists so that a client program can send a request packet to
the server, and receive a response. Here is an example of a what the client
would send for :samp:`box.space[513]:insert{'A', 'BB'}`. The BNF description of
the components is on the page about
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>`.

.. _Language-specific drivers: `Connectors`_

    .. container:: table

        .. rst-class:: left-align-column-1
        .. rst-class:: right-align-column-2
        .. rst-class:: right-align-column-3
        .. rst-class:: right-align-column-4

        +---------------------------------+---------+---------+---------+---------+
        | Component                       | Byte #0 | Byte #1 | Byte #2 | Byte #3 |
        +=================================+=========+=========+=========+=========+
        | code for insert                 |   02    |         |         |         |
        +---------------------------------+---------+---------+---------+---------+
        | rest of header                  |   ...   |   ...   |   ...   |   ...   |
        +---------------------------------+---------+---------+---------+---------+
        | 2-digit number: space id        |   cd    |   02    |   01    |         |
        +---------------------------------+---------+---------+---------+---------+
        | code for tuple                  |   21    |         |         |         |
        +---------------------------------+---------+---------+---------+---------+
        | 1-digit number: field count = 2 |   92    |         |         |         |
        +---------------------------------+---------+---------+---------+---------+
        | 1-character string: field[1]    |   a1    |   41    |         |         |
        +---------------------------------+---------+---------+---------+---------+
        | 2-character string: field[2]    |   a2    |   42    |   42    |         |
        +---------------------------------+---------+---------+---------+---------+

Now, you could send that packet to the Tarantool server, and interpret the
response (the page about
:ref:`Tarantool's binary protocol <box_protocol-iproto_protocol>` has a
description of the packet format for responses as well as requests). But it
would be easier, and less error-prone, if you could invoke a routine that
formats the packet according to typed parameters. Something like
:samp:`response=tarantool_routine("insert",513,"A","B");`. And that is why APIs
exist for drivers for Perl, Python, PHP, and so on.

.. _index-connector_setting:

====================================================================
          Setting up the server for connector examples
====================================================================

This chapter has examples that show how to connect to the Tarantool server via
the Perl, PHP, Python, node.js, and C connectors. The examples contain hard code that
will work if and only if the following conditions are met:

* the server (tarantool) is running on localhost (127.0.0.1) and is listening on
  port 3301 (:samp:`box.cfg.listen = '3301'`),
  
* space ``examples`` has id = 999 (:samp:`box.space.examples.id = 999`) and has
  a primary-key index for a numeric field
  (:samp:`box.space[999].index[0].parts[1].type = "unsigned"`),

* user 'guest' has privileges for reading and writing.

It is easy to meet all the conditions by starting the server and executing this
script:

.. code-block:: lua

    box.cfg{listen=3301}
    box.schema.space.create('examples',{id=999})
    box.space.examples:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}})
    box.schema.user.grant('guest','read,write','space','examples')
    box.schema.user.grant('guest','read','space','_space')

.. include:: __java.rst

.. include:: __go.rst

.. include:: __r.rst

=====================================================================
                            Erlang
=====================================================================

See `Erlang tarantool driver <https://github.com/stofel/taran>`_.

.. include:: __perl.rst

.. include:: __php.rst

.. include:: __python.rst

=====================================================================
                            node.js
=====================================================================

The most commonly used node.js driver is the
`Node Tarantool driver <https://github.com/KlonD90/node-tarantool-driver>`_.
It is not
supplied as part of the Tarantool repository; it must be installed separately.
The most common way to install it is with
`npm <https://www.sitepoint.com/beginners-guide-node-package-manager/>`_.
For example, on Ubuntu, the installation could look like this
after npm has been installed:

.. code-block:: none

    $ npm install tarantool-driver --global

Here is a complete node.js program that inserts ``[99999,'BB']`` into ``space[999]``
via the node.js API. Before trying to run, check that the server is listening at 
``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`.
To run, paste the code into a file named :file:`example.rs` and say
:samp:`node example.rs`. The program will connect using an application-specific
definition of the space. The program will open a socket connection with the
Tarantool server at ``localhost:3301``, then send an INSERT request, then — if
all is well — end after saying "Insert succeeded". If Tarantool is not running
on ``localhost`` with listen port = 3301, the program will print “Connect
failed”. If user ``guest`` does not have authorization to connect, the program
will print "Auth failed". If the insert request fails for any reason, for example
because the tuple already exists, the program will print "Insert failed".

.. code-block:: none

    var TarantoolConnection = require('tarantool-driver');
    var conn = new TarantoolConnection({port: 3301});
    var insertTuple = [99999, "BB"];
    conn.connect().then(function(){    
        conn.auth("guest", "").then(function(){
            conn.insert(999, insertTuple).then(function(){
                console.log("Insert succeeded");
                process.exit(0);
        }, function(e){ console.log("Insert failed"); process.exit(1); });
        }, function(e){ console.log("Auth failed"); process.exit(1); });
        }, function(e){ console.log("Connect failed"); process.exit(1); });

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see 
`The node.js driver repository <https://github.com/KlonD90/node-tarantool-driver>`_.

=====================================================================
                            C#
=====================================================================

The most commonly used csharp driver is the
`ProGaudi tarantool-csharp driver <https://github.com/progaudi/tarantool-csharp>`_.
It is not
supplied as part of the Tarantool repository; it must be installed separately.
The makers recommend installation on Windows and not on other platforms.
However, to be consistent with the other instructions in this chapter,
here is an unofficial way to install the driver on Ubuntu 16.04.

Install dotnet preview from Microsoft -- mono will not work, and
dotnet from xbuild will not work. Read the
`Microsoft End User License Agreement <http://aka.ms/dotnet-cli-eula>`_
first, because it is not an ordinary open-source agreement and there
will be a message during installation saying "This software may collect
information about you and your use of the software, and send that to
Microsoft." The dotnet instructions are at
`https://www.microsoft.com/net/core#ubuntu <https://www.microsoft.com/net/core#linuxubuntu>`_.

.. code-block:: none

    # Install tarantool-csharp from the github repository source
    # -- nuget will not work, so building from source is necessary,
    # thus:
    cd ~
    mkdir dotnet
    cd dotnet
    git clone https://github.com/progaudi/tarantool-csharp tarantool-csharp
    cd tarantool-csharp
    dotnet restore
    cd src/tarantool.client
    dotnet build
    # Find the .dll file that was produced by the "dotnet build"
    # step. The next instruction assumes it was produced in
    # bin/Debug/netcoreapp1.0.
    cd bin/Debug/netcoreapp1.0
    # Find the project.json file used for samples. The next
    # instruction assumes the docker-compose/dotnet directory
    # has a suitable one, which is true at time of writing.
    cp ~/dotnet/tarantool-csharp/samples/docker-compose/dotnet/project.json project.json
    dotnet restore

Do not change directories now, the example program should be
in the same directory as the .dll file.

Here is a complete C# program that inserts ``[99999,'BB']`` into space ``examples``
via the tarantool-csharp API. Before trying to run, check that the server is listening at 
``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`.
To run, paste the code into a file named :file:`example.cs` and say
:samp:`dotnet run example.cs`. The program will connect using an application-specific
definition of the space. The program will open a socket connection with the
Tarantool server at ``localhost:3301``, then send an INSERT request, then — if
all is well — end without saying anything. If Tarantool is not running
on ``localhost`` with listen port = 3301, or
if user ``guest`` does not have authorization to connect,
or if the insert request fails for any reason,
the program will print an error message, among other things.

.. code-block:: none

    using System;
    using System.Linq;
    using System.Threading.Tasks;
    using ProGaudi.Tarantool.Client;
    using ProGaudi.Tarantool.Client.Model;
    public class HelloWorld
    {
      static public void Main ()
      {
        Test().Wait();
      }
      static async Task Test()
      {
        var tarantoolClient = await Box.Connect("127.0.0.1:3301");
        var schema = tarantoolClient.getSchema();
        var space = await schema.getSpace("examples");
        await space.Insert(TarantoolTuple.Create(99999, "BB"));
      }
    }

The same program should work on Windows with
far less difficulty -- just install with nuget and run.

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see 
`The tarantool-csharp driver repository <https://github.com/progaudi/tarantool-csharp>`_.

.. include:: __c.rst

.. include:: __results.rst


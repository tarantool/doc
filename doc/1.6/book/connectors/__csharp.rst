=====================================================================
                            C#
=====================================================================

The most commonly used csharp driver is the `ProGaudi tarantool-csharp driver
<https://github.com/progaudi/tarantool-csharp>`_. It is not supplied as part of
the Tarantool repository; it must be installed separately. The makers recommend
installation on Windows and not on other platforms. However, to be consistent
with the other instructions in this chapter, here is an unofficial way to
install the driver on Ubuntu 16.04.

Install dotnet preview from Microsoft -- mono will not work, and dotnet from
xbuild will not work. Read the `Microsoft End User License Agreement
<http://aka.ms/dotnet-cli-eula>`_ first, because it is not an ordinary
open-source agreement and there will be a message during installation saying
"This software may collect information about you and your use of the software,
and send that to Microsoft." The dotnet instructions are at
`https://www.microsoft.com/net/core#ubuntu
<https://www.microsoft.com/net/core#linuxubuntu>`_.

.. code-block:: bash

    # Install tarantool-csharp from the github repository source -- nuget will
    # not work, so building from source is necessary, thus:
    cd ~
    mkdir dotnet
    cd dotnet
    git clone https://github.com/progaudi/tarantool-csharp tarantool-csharp
    cd tarantool-csharp
    dotnet restore
    cd src/tarantool.client
    dotnet build
    # Find the .dll file that was produced by the "dotnet build" step. The next
    instruction assumes it was produced in 'bin/Debug/netcoreapp1.0'.
    cd bin/Debug/netcoreapp1.0
    # Find the project.json file used for samples. The next instruction assumes
    # the docker-compose/dotnet directory has a suitable one, which is true at
    # time of writing.
    cp ~/dotnet/tarantool-csharp/samples/docker-compose/dotnet/project.json project.json
    dotnet restore

Do not change directories now, the example program should be in the same
directory as the .dll file.

Here is a complete C# program that inserts ``[99999,'BB']`` into space
``examples`` via the tarantool-csharp API. Before trying to run, check that the
server is listening at  ``localhost:3301`` and that the space ``examples``
exists, as :ref:`described earlier <index-connector_setting>`. To run, paste the
code into a file named :file:`example.cs` and say ``dotnet run example.cs``.
The program will connect using an application-specific definition of the space.
The program will open a socket connection with the Tarantool server at
``localhost:3301``, then send an INSERT request, then — if all is well — end
without saying anything. If Tarantool is not running on ``localhost`` with
listen port = 3301, or if user ``guest`` does not have authorization to connect,
or if the insert request fails for any reason, the program will print an error
message, among other things.

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

The same program should work on Windows with far less difficulty -- just install
with nuget and run.

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see `The tarantool-csharp driver
repository <https://github.com/progaudi/tarantool-csharp>`_.

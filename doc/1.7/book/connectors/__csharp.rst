=====================================================================
                            C#
=====================================================================

The most commonly used C# driver is
`progaudi.tarantool <https://github.com/progaudi/progaudi.tarantool>`_,
previously named ``tarantool-csharp``. It is not supplied as part of the
Tarantool repository; it must be installed separately. The makers recommend
`cross-platform installation using Nuget <https://www.nuget.org/packages/progaudi.tarantool>`_.

To be consistent with the other instructions in this chapter, here is a way to
install the driver directly on Ubuntu 16.04.

1. Install .net core from Microsoft. Follow
   `.net core installation instructions <https://www.microsoft.com/net/core#ubuntu>`_.

.. NOTE::

    * Mono will not work, nor will .Net from xbuild. Only .net core supported on
      Linux and Mac.
    * Read the Microsoft End User License Agreement first, because it is not an
      ordinary open-source agreement and there will be a message during
      installation saying "This software may collect information about you and
      your use of the software, and send that to Microsoft."
      Still you can
      `set environment variables <https://docs.microsoft.com/en-us/dotnet/core/tools/telemetry#behavior>`_
      to opt out from telemetry.

2. Create a new console project.

   .. code-block:: console

       $ cd ~
       $ mkdir progaudi.tarantool.test
       $ cd progaudi.tarantool.test
       $ dotnet new console

3. Add ``progaudi.tarantool`` reference.

   .. code-block:: console

       $ dotnet add package progaudi.tarantool

4. Change code in ``Program.cs``.

   .. code-block:: console

       $ cat <<EOT > Program.cs
       using System;
       using System.Threading.Tasks;
       using ProGaudi.Tarantool.Client;

       public class HelloWorld
       {
         static public void Main ()
         {
           Test().GetAwaiter().GetResult();
         }
         static async Task Test()
         {
           var box = await Box.Connect("127.0.0.1:3301");
           var schema = box.GetSchema();
           var space = await schema.GetSpace("examples");
           await space.Insert((99999, "BB"));
         }
       }
       EOT

5. Build and run your application.

   Before trying to run, check that the server is listening at ``localhost:3301``
   and that the space ``examples`` exists, as
   :ref:`described earlier <index-connector_setting>`.

   .. code-block:: console

       $ dotnet restore
       $ dotnet run

   The program will:

   * connect using an application-specific definition of the space,
   * open a socket connection with the Tarantool server at `localhost:3301`,
   * send an INSERT request, and — if all is well — end without saying anything.

   If Tarantool is not running on localhost with listen port = 3301, or if user
   'guest' does not have authorization to connect, or if the INSERT request
   fails for any reason, the program will print an error message, among other
   things (stacktrace, etc).

The example program only shows one request and does not show all that’s
necessary for good practice. For that, please see the
`progaudi.tarantool driver repository <https://github.com/progaudi/progaudi.tarantool>`_.

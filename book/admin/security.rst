.. _admin-security:

================================================================================
Security
================================================================================

Tarantool allows for two types of connections:

* With :ref:`console.listen() <console-listen>` function from ``console`` module,
  you can set up a port which can be used to open an administrative console to
  the server. This is for administrators to connect to a running instance and
  make requests. ``tarantoolctl`` invokes ``console.listen()`` to create a
  control socket for each started instance.

* With :ref:`box.cfg{listen=...} <cfg_basic-listen>` parameter from ``box``
  module, you can set up a binary port for connections which read and write to
  the database or invoke stored procedures.

When you connect to an admin console:

* The client-server protocol is plain text.
* No password is necessary.
* The user is automatically 'admin'.
* Each command is fed directly to the built-in Lua interpreter.

Therefore you must set up ports for the admin console very cautiously. If it is
a TCP port, it should only be opened for a specific IP. Ideally, it should not
be a TCP port at all, it should be a Unix domain socket, so that access to the
server machine is required. Thus a typical port setup for admin console is:

.. code-block:: lua

    console.listen('/var/lib/tarantool/socket_name.sock')

and a typical connection :ref:`URI <index-uri>` is:

.. code-block:: none

    /var/lib/tarantool/socket_name.sock

if the listener has the privilege to write on ``/var/lib/tarantool`` and the
connector has the privilege to read on ``/var/lib/tarantool``. Alternatively,
to connect to an admin console of an instance started with ``tarantoolctl``, use
:ref:`tarantoolctl enter <admin-executing_code_on_an_instance>`.

To find out whether a TCP port is a port for admin console, use ``telnet``.
For example:

.. code-block:: console

    $ telnet 0 3303
    Trying 0.0.0.0...
    Connected to 0.
    Escape character is '^]'.
    Tarantool 1.10.0 (Lua console)
    type 'help' for interactive help

In this example, the response does not include the word "binary" and does
include the words "Lua console". Therefore it is clear that this is a successful
connection to a port for admin console, and you can now enter admin requests on
this terminal.

When you connect to a binary port:

* The client-server protocol is :ref:`binary <box_protocol-iproto_protocol>`.
* The user is automatically ':ref:`guest <authentication-users>`'.
* To change the user, it’s necessary to authenticate.

For ease of use, ``tarantoolctl connect`` command automatically detects the type
of connection during handshake and uses :ref:`EVAL <box_protocol-eval>`
binary protocol command when it’s necessary to execute Lua commands over a binary
connection. To execute EVAL, the authenticated user must have global "EXECUTE"
privilege.

Therefore, when ``ssh`` access to the machine is not available, creating a
Tarantool user with global "EXECUTE" privilege and non-empty password can be
used to provide a system administrator **remote** access to an instance.


.. _tt-connect:

Connecting to a Tarantool instance
==================================

..  code-block:: console

    $ tt connect {URI|INSTANCE_NAME} [OPTION ...]


``tt connect`` connects to a Tarantool instance by its URI or instance name specified
in the current environment.

Options
-------

..  option:: -u USERNAME, --username USERNAME

    A Tarantool user for connecting to the instance.

..  option:: -p PASSWORD, --password PASSWORD

    The user's password.

..  option:: -f FILEPATH, --file FILEPATH

    Connect and evaluate the script from a file.

    ``-`` – read the script from stdin.

.. option:: -i, --interactive

    Enter the interactive mode after evaluating the script passed in ``-f``/``--file``.

..  option:: -l LANGUAGE, --language LANGUAGE

    The input language of the :ref:`tt interactive console <tt-interactive-console>`:
    ``lua`` (default) or ``sql``.

..  option:: -x FORMAT, --outputformat FORMAT

    The output format of the :ref:`tt interactive console <tt-interactive-console>`:
    ``yaml`` (default), ``lua``, ``table``, ``ttable``.

..  option:: --sslcertfile FILEPATH

    The path to an SSL certificate file for encrypted connections.

..  option:: --sslkeyfile FILEPATH

    The path to a private SSL key file for encrypted connections.

..  option:: --sslcafile FILEPATH

    The path to a trusted certificate authorities (CA) file for encrypted connections.

..  option:: --sslciphers STRING

    The list of SSL cipher suites used for encrypted connections, separated by colons (``:``).

Details
-------

To connect to an instance, ``tt`` typically needs its URI -- the host name or IP address
and the port.

You can also connect to instances in the same ``tt`` environment
(that is, those that use the same :ref:`configuration file <tt-config_file>` and Tarantool installation)
by their instance names.

Authentication
~~~~~~~~~~~~~~

When connecting to an instance by its URI, ``tt connect`` establishes a remote connection
for which authentication is required. Use one of the following ways to pass the
username and the password:

*   The ``-u`` (``--username``) and ``-p`` (``--password``) options:

    ..  code-block:: console

        $ tt connect 192.168.10.10:3301 -u myuser -p p4$$w0rD

*   The connection string:

    ..  code-block:: console

        $ tt connect myuser:p4$$w0rD@192.168.10.10:3301

*   Environment variables ``TT_CLI_USERNAME`` and ``TT_CLI_PASSWORD``:

    ..  code-block:: console

        $ export TT_CLI_USERNAME=myuser
        $ export TT_CLI_PASSWORD=p4$$w0rD
        $ tt connect 192.168.10.10:3301

If no credentials are provided for a remote connection, the user is automatically ``guest``.

.. note::

    Local connections (by instance name instead of the URI) don't require authentication.

Encrypted connection
~~~~~~~~~~~~~~~~~~~~

To connect to instances that use :ref:`SSL encryption <configuration_connections_ssl>`,
provide the SSL certificate and SSL key files in the ``--sslcertfile`` and ``--sslkeyfile`` options.
If necessary, add other SSL parameters -- ``--sslcafile`` and ``--sslciphers``.

Script evaluation
~~~~~~~~~~~~~~~~~

By default, ``tt connect`` opens an :ref:`interactive tt console <tt-interactive-console>`.
Alternatively, you can open a connection to evaluate a Lua script from a file or stdin.
To do this, pass the file path in the ``-f`` (``--file``) option or use ``-f -``
to take the script from stdin.

..  code-block:: console

    $ tt connect app -f test.lua

Examples
--------

*   Connect to the ``app`` instance in the same environment:

    ..  code-block:: console

        $ tt connect app

*   Connect to the ``master`` instance of the ``app`` application in the same environment:

    ..  code-block:: console

        $ tt connect app:master

*   Connect to the ``192.168.10.10`` host on port ``3301`` with authentication:

    ..  code-block:: console

        $ tt connect 192.168.10.10:3301 -u myuser -p p4$$w0rD

*   Connect to the ``app`` instance and evaluate the code from the ``test.lua`` file:

    ..  code-block:: console

        $ tt connect app -f test.lua

*   Connect to the ``app`` instance and evaluate the code from stdin:

    ..  code-block:: console

        $ echo "function test() return 1 end" | tt connect app -f - # Create the test() function
        $ echo "test()" | tt connect app -f -                       # Call this function
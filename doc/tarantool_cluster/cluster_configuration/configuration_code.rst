..  _configuration_code:

Configuration in code
=====================

.. box_cfg_legacy_note_start

.. NOTE::

    Starting with the 3.0 version, the recommended way of configuring Tarantool is using a :ref:`configuration file <configuration_file>`.
    Configuring Tarantool in code is considered a legacy approach.

.. box_cfg_legacy_note_end

This topic covers the specifics of configuring Tarantool in code using the ``box.cfg`` API.
In this case, a configuration is stored in an :ref:`initialization file <index-init_label>` - a Lua script with the specified configuration options.
You can find all the available options in the :ref:`Configuration reference <box-cfg-params-ref>`.


..  _index-init_label:

Initialization file
-------------------

If the command to :ref:`start Tarantool <configuration_code_run_instance_tarantool>` includes an instance file, then
Tarantool begins by invoking the Lua program in the file, which may have the name ``init.lua``.
The Lua program may get further arguments
from the command line or may use operating-system functions, such as ``getenv()``.
The Lua program almost always begins by invoking ``box.cfg()``, if the database
server will be used or if ports need to be opened. For example, suppose
``init.lua`` contains the lines

..  _index-init-example:

..  code-block:: lua

    #!/usr/bin/env tarantool
    box.cfg{
        listen              = os.getenv("LISTEN_URI"),
        memtx_memory        = 33554432,
        pid_file            = "tarantool.pid",
        wal_max_size        = 2500
    }
    print('Starting ', arg[1])

and suppose the environment variable ``LISTEN_URI`` contains 3301,
and suppose the command line is ``tarantool init.lua ARG``.
Then the screen might look like this:

..  code-block:: console

    $ export LISTEN_URI=3301
    $ tarantool init.lua ARG
    ... main/101/init.lua C> Tarantool 2.8.3-0-g01023dbc2
    ... main/101/init.lua C> log level 5
    ... main/101/init.lua I> mapping 33554432 bytes for memtx tuple arena...
    ... main/101/init.lua I> recovery start
    ... main/101/init.lua I> recovering from './00000000000000000000.snap'
    ... main/101/init.lua I> set 'listen' configuration option to "3301"
    ... main/102/leave_local_hot_standby I> ready to accept requests
    Starting  ARG
    ... main C> entering the event loop

If you wish to start an interactive session on the same terminal after
initialization is complete, you can pass the ``-i`` :ref:`command-line option <configuration_command_options>`.


..  _box-cfg-params-env:

Environment variables
---------------------

Starting from version :doc:`2.8.1 </release/2.8.1>`, you can specify configuration parameters via special environment variables.
The name of a variable should have the following pattern: ``TT_<NAME>``,
where ``<NAME>`` is the uppercase name of the corresponding :ref:`box.cfg parameter <box-cfg-params-ref>`.

For example:

* ``TT_LISTEN`` -- corresponds to the :ref:`box.cfg.listen <cfg_basic-listen>` option.
* ``TT_MEMTX_DIR`` -- corresponds to the :ref:`box.cfg.memtx_dir <cfg_basic-memtx_dir>` option.

In case of an array value, separate the array elements by a comma without space:

..  code-block:: console

    export TT_REPLICATION="localhost:3301,localhost:3302"

If you need to pass :ref:`additional parameters for URI <index-uri-several-params>`, use the ``?`` and ``&`` delimiters:

..  code-block:: console

    export TT_LISTEN="localhost:3301?param1=value1&param2=value2"

An empty variable (``TT_LISTEN=``) has the same effect as an unset one, meaning that the corresponding configuration parameter won't be set when calling ``box.cfg{}``.



..  _index-local_hot_standby:
..  _index-replication_port:
..  _index-slab_alloc_arena:
..  _index-replication_source:
..  _index-snap_dir:
..  _index-wal_dir:
..  _index-wal_mode:
..  _index-checkpoint daemon:

..  _box_cfg_params:


Configuration parameters
------------------------

Configuration parameters have the form:

:extsamp:`{**{box.cfg}**}{[{*{key = value}*} [, {*{key = value ...}*}]]}`

Configuration parameters can be set in a Lua :ref:`initialization file <index-init_label>`,
which is specified on the Tarantool command line.

Most configuration parameters are for allocating resources, opening ports, and
specifying database behavior. All parameters are optional.
Most of the parameters are dynamic, that is, they can be changed at runtime by calling ``box.cfg{}`` a second time.
For example, the command below sets the :ref:`listen port <cfg_basic-listen>` to ``3301``.

..  code-block:: tarantoolsession

    tarantool> box.cfg{ listen = 3301 }
    2023-05-10 13:28:54.667 [31326] main/103/interactive I> tx_binary: stopped
    2023-05-10 13:28:54.667 [31326] main/103/interactive I> tx_binary: bound to [::]:3301
    2023-05-10 13:28:54.667 [31326] main/103/interactive/box.load_cfg I> set 'listen' configuration option to 3301
    ---
    ...


To see all the non-null parameters, execute ``box.cfg`` (no parentheses).

..  code-block:: tarantoolsession

    tarantool> box.cfg
    ---
    - replication_skip_conflict: false
      wal_queue_max_size: 16777216
      feedback_host: https://feedback.tarantool.io
      memtx_dir: .
      memtx_min_tuple_size: 16
      -- other parameters --
    ...

To see a particular parameter value, call a corresponding ``box.cfg`` option.
For example, ``box.cfg.listen`` shows the specified :ref:`listen address <cfg_basic-listen>`.

..  code-block:: tarantoolsession

    tarantool> box.cfg.listen
    ---
    - 3301
    ...



.. _index-uri:

Listen URI
----------

Some configuration parameters and some functions depend on a URI (Universal Resource Identifier).
The URI string format is similar to the
`generic syntax for a URI schema <https://en.wikipedia.org/wiki/List_of_URI_schemes>`_.
It may contain (in order):

* user name for login
* password
* host name or host IP address
* port number
* query parameters

Only a port number is always mandatory. A password is mandatory if a user
name is specified unless the user name is 'guest'.

Formally, the URI
syntax is ``[host:]port`` or ``[username:password@]host:port``.
If a host is omitted, then "0.0.0.0" or "[::]" is assumed,
meaning respectively any IPv4 address or any IPv6 address
on the local machine.
If ``username:password`` is omitted, then the "guest" user is assumed. Some examples:

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    +-----------------------------+------------------------------+
    | URI fragment                | Example                      |
    +=============================+==============================+
    | port                        | 3301                         |
    +-----------------------------+------------------------------+
    | host:port                   | 127.0.0.1:3301               |
    +-----------------------------+------------------------------+
    | username:password@host:port | notguest:sesame@mail.ru:3301 |
    +-----------------------------+------------------------------+

In code, the URI value can be passed as a number (if only a port is specified) or a string:

..  code-block:: lua

    box.cfg { listen = 3301 }

    box.cfg { listen = "127.0.0.1:3301" }

In certain circumstances, a Unix domain socket may be used
where a URI is expected, for example, ``unix/:/tmp/unix_domain_socket.sock`` or
simply ``/tmp/unix_domain_socket.sock``.

The :ref:`uri <uri-module>` module provides functions that convert URI strings into their
components or turn components into URI strings.

.. _index-uri-several:

Specifying several URIs
~~~~~~~~~~~~~~~~~~~~~~~

Starting from version 2.10.0, a user can open several listening iproto sockets on a Tarantool instance
and, consequently, can specify several URIs in the configuration parameters
such as :ref:`box.cfg.listen <cfg_basic-listen>` and :ref:`box.cfg.replication <cfg_replication-replication>`.

URI values can be set in a number of ways:

*   As a string with URI values separated by commas.

    ..  code-block:: lua

        box.cfg { listen = "127.0.0.1:3301, /unix.sock, 3302" }

*   As a table that contains URIs in the string format.

    ..  code-block:: lua

        box.cfg { listen = {"127.0.0.1:3301", "/unix.sock", "3302"} }

*   As an array of tables with the ``uri`` field.

    ..  code-block:: lua

        box.cfg { listen = {
                {uri = "127.0.0.1:3301"},
                {uri = "/unix.sock"},
                {uri = 3302}
            }
        }

*   In a combined way -- an array that contains URIs in both the string and the table formats.

    ..  code-block:: lua

        box.cfg { listen = {
                "127.0.0.1:3301",
                { uri = "/unix.sock" },
                { uri = 3302 }
            }
        }

.. _index-uri-several-params:

Also, starting from version 2.10.0, it is possible to specify additional parameters for URIs.
You can do this in different ways:

*   Using the ``?`` delimiter when URIs are specified in a string format.

    ..  code-block:: lua

        box.cfg { listen = "127.0.0.1:3301?p1=value1&p2=value2, /unix.sock?p3=value3" }

*   Using the ``params`` table: a URI is passed in a table with additional parameters in the "params" table.
    Parameters in the "params" table overwrite the ones from a URI string ("value2" overwrites "value1" for ``p1`` in the example below).

    ..  code-block:: lua

        box.cfg { listen = {
                "127.0.0.1:3301?p1=value1",
                params = {p1 = "value2", p2 = "value3"}
            }
        }

*   Using the ``default_params`` table for specifying default parameter values.

    In the example below, two URIs are passed in a table.
    The default value for the ``p3`` parameter is defined in the ``default_params`` table
    and used if this parameter is not specified in URIs.
    Parameters in the ``default_params`` table are applicable to all the URIs passed in a table.

    ..  code-block:: lua

        box.cfg { listen = {
                "127.0.0.1:3301?p1=value1",
                { uri = "/unix.sock", params = { p2 = "value2" } },
                default_params = { p3 = "value3" }
            }
        }

The recommended way for specifying URI with additional parameters is the following:

..  code-block:: lua

    box.cfg { listen = {
            {uri = "127.0.0.1:3301", params = {p1 = "value1"}},
            {uri = "/unix.sock", params = {p2 = "value2"}},
            {uri = 3302, params = {p3 = "value3"}}
        }
    }

In case of a single URI, the following syntax also works:

..  code-block:: lua

    box.cfg { listen = {
            uri = "127.0.0.1:3301",
            params = { p1 = "value1", p2 = "value2" }
        }
    }


..  _configuration_code_iproto-encryption:

Traffic encryption
------------------

..  admonition:: Enterprise Edition
    :class: fact

    Traffic encryption is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.

Since version 2.10.0, Tarantool Enterprise Edition has the built-in support for using SSL to encrypt the client-server communications over :ref:`binary connections <box_protocol-iproto_protocol>`,
that is, between Tarantool instances in a cluster or connecting to an instance via connectors using :doc:`net.box </reference/reference_lua/net_box>`.

Tarantool uses the OpenSSL library that is included in the delivery package.
Note that SSL connections use only TLSv1.2.

..  _configuration_code_iproto-encryption-config:

Configuration
~~~~~~~~~~~~~

To configure traffic encryption, you need to set the special :ref:`URI parameters <index-uri-several-params>` for a particular connection.
The parameters can be set for the following ``box.cfg`` options and ``net.box`` method:

*   :ref:`box.cfg.listen <cfg_basic-listen>` -- on the server side.
*   :ref:`box.cfg.replication <cfg_replication-replication>` -- on the client side.
*   :ref:`net_box_object.connect() <net_box-connect>` -- on the client side.

Below is the list of the parameters.
In the :ref:`next section <configuration_code_iproto-encryption-config-sc>`, you can find details and examples on what should be configured on both the server side and the client side.

*   ``transport`` -- enables SSL encryption for a connection if set to ``ssl``.
    The default value is ``plain``, which means the encryption is off. If the parameter is not set, the encryption is off too.
    Other encryption-related parameters can be used only if the ``transport = 'ssl'`` is set.

    Example:

    ..  literalinclude:: /code_snippets/snippets/replication/instances.enabled/ssl_with_ca/myapp.lua
        :language: lua
        :start-at: net.box
        :end-before: return connection
        :dedent:

*   ``ssl_key_file`` -- a path to a private SSL key file.
    Mandatory for a server.
    For a client, it's mandatory if the ``ssl_ca_file`` parameter is set for a server; otherwise, optional.
    If the private key is encrypted, provide a password for it in the ``ssl_password`` or ``ssl_password_file`` parameter.

*   ``ssl_cert_file`` -- a path to an SSL certificate file.
    Mandatory for a server.
    For a client, it's mandatory if the ``ssl_ca_file`` parameter is set for a server; otherwise, optional.

*   ``ssl_ca_file`` -- a path to a trusted certificate authorities (CA) file. Optional. If not set, the peer won't be checked for authenticity.

    Both a server and a client can use the ``ssl_ca_file`` parameter:

    *   If it's on the server side, the server verifies the client.
    *   If it's on the client side, the client verifies the server.
    *   If both sides have the CA files, the server and the client verify each other.

*   ``ssl_ciphers`` -- a colon-separated (``:``) list of SSL cipher suites the connection can use. See the :ref:`configuration_code_iproto-encryption-ciphers` section for details. Optional.
    Note that the list is not validated: if a cipher suite is unknown, Tarantool just ignores it, doesn't establish the connection and writes to the log that no shared cipher found.

*   ``ssl_password`` -- a password for an encrypted private SSL key. Optional. Alternatively, the password
    can be provided in ``ssl_password_file``.

*   ``ssl_password_file`` -- a text file with one or more passwords for encrypted private SSL keys
    (each on a separate line). Optional. Alternatively, the password can be provided in ``ssl_password``.

    Tarantool applies the ``ssl_password`` and ``ssl_password_file`` parameters in the following order:

    1.  If ``ssl_password`` is provided, Tarantool tries to decrypt the private key with it.
    2.  If ``ssl_password`` is incorrect or isn't provided, Tarantool tries all passwords from ``ssl_password_file``
        one by one in the order they are written.
    3.  If ``ssl_password`` and all passwords from ``ssl_password_file`` are incorrect,
        or none of them is provided, Tarantool treats the private key as unencrypted.

Configuration example:

..  code-block:: lua

    box.cfg{ listen = {
        uri = 'localhost:3301',
        params = {
            transport = 'ssl',
            ssl_key_file = '/path_to_key_file',
            ssl_cert_file = '/path_to_cert_file',
            ssl_ciphers = 'HIGH:!aNULL',
            ssl_password = 'topsecret'
        }
    }}

..  _configuration_code_iproto-encryption-ciphers:

Supported ciphers
*****************

Tarantool Enterprise supports the following cipher suites:

*   ECDHE-ECDSA-AES256-GCM-SHA384
*   ECDHE-RSA-AES256-GCM-SHA384
*   DHE-RSA-AES256-GCM-SHA384
*   ECDHE-ECDSA-CHACHA20-POLY1305
*   ECDHE-RSA-CHACHA20-POLY1305
*   DHE-RSA-CHACHA20-POLY1305
*   ECDHE-ECDSA-AES128-GCM-SHA256
*   ECDHE-RSA-AES128-GCM-SHA256
*   DHE-RSA-AES128-GCM-SHA256
*   ECDHE-ECDSA-AES256-SHA384
*   ECDHE-RSA-AES256-SHA384
*   DHE-RSA-AES256-SHA256
*   ECDHE-ECDSA-AES128-SHA256
*   ECDHE-RSA-AES128-SHA256
*   DHE-RSA-AES128-SHA256
*   ECDHE-ECDSA-AES256-SHA
*   ECDHE-RSA-AES256-SHA
*   DHE-RSA-AES256-SHA
*   ECDHE-ECDSA-AES128-SHA
*   ECDHE-RSA-AES128-SHA
*   DHE-RSA-AES128-SHA
*   AES256-GCM-SHA384
*   AES128-GCM-SHA256
*   AES256-SHA256
*   AES128-SHA256
*   AES256-SHA
*   AES128-SHA
*   GOST2012-GOST8912-GOST8912
*   GOST2001-GOST89-GOST89

Tarantool Enterprise static build has the embedded engine to support the GOST cryptographic algorithms.
If you use these algorithms for traffic encryption, specify the corresponding cipher suite in the ``ssl_ciphers`` parameter, for example:

..  code-block:: lua

    box.cfg{ listen = {
        uri = 'localhost:3301',
        params = {
            transport = 'ssl',
            ssl_key_file = '/path_to_key_file',
            ssl_cert_file = '/path_to_cert_file',
            ssl_ciphers = 'GOST2012-GOST8912-GOST8912'
        }
    }}

For detailed information on SSL ciphers and their syntax, refer to `OpenSSL documentation <https://www.openssl.org/docs/man1.1.1/man1/ciphers.html>`__.

Using environment variables
***************************

The URI parameters for traffic encryption can also be set via :ref:`environment variables <box-cfg-params-env>`, for example:

..  code-block:: bash

    export TT_LISTEN="localhost:3301?transport=ssl&ssl_cert_file=/path_to_cert_file&ssl_key_file=/path_to_key_file"


..  _configuration_code_iproto-encryption-config-sc:

Server-client configuration details
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When configuring the traffic encryption, you need to specify the necessary parameters on both the server side and the client side.
Below you can find the summary on the options and parameters to be used and :ref:`examples of configuration <configuration_code_iproto-encryption-config-example>`.

**Server side**

*   Is configured via the ``box.cfg.listen`` option.
*   Mandatory URI parameters: ``transport``, ``ssl_key_file`` and ``ssl_cert_file``.
*   Optional URI parameters: ``ssl_ca_file``, ``ssl_ciphers``, ``ssl_password``, and ``ssl_password_file``.


**Client side**

*   Is configured via the ``box.cfg.replication`` option (see :ref:`details <configuration_code_iproto-encryption-config-example>`) or ``net_box_object.connect()``.

Parameters:

*   If the server side has only the ``transport``, ``ssl_key_file`` and ``ssl_cert_file`` parameters set,
    on the client side, you need to specify only ``transport = ssl`` as the mandatory parameter.
    All other URI parameters are optional.

*   If the server side also has the ``ssl_ca_file`` parameter set,
    on the client side, you need to specify ``transport``, ``ssl_key_file`` and ``ssl_cert_file`` as the mandatory parameters.
    Other parameters -- ``ssl_ca_file``, ``ssl_ciphers``, ``ssl_password``, and ``ssl_password_file`` -- are optional.


..  _configuration_code_iproto-encryption-config-example:

Configuration examples
**********************

Suppose, there is a :ref:`master-replica <replication-master_replica_bootstrap>` set with two Tarantool instances:

*   127.0.0.1:3301 -- master (server)
*   127.0.0.1:3302 -- replica (client).

Examples below show the configuration related to connection encryption for two cases:
when the trusted certificate authorities (CA) file is not set on the server side and when it does.
Only mandatory URI parameters are mentioned in these examples.

1. **Without CA**

*   127.0.0.1:3301 -- master (server)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3301',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file'
                }
            }
        }

*   127.0.0.1:3302 -- replica (client)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3302',
                params = {transport = 'ssl'}
            },
            replication = {
                uri = 'username:password@127.0.0.1:3301',
                params = {transport = 'ssl'}
            },
            read_only = true
        }

2. **With CA**

*   127.0.0.1:3301 -- master (server)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3301',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file',
                    ssl_ca_file = '/path_to_ca_file'
                }
            }
        }

*   127.0.0.1:3302 -- replica (client)

    ..  code-block:: lua

        box.cfg{
            listen = {
                uri = '127.0.0.1:3302',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file'
                }
            },
            replication = {
                uri = 'username:password@127.0.0.1:3301',
                params = {
                    transport = 'ssl',
                    ssl_key_file = '/path_to_key_file',
                    ssl_cert_file = '/path_to_cert_file'
                }
            },
            read_only = true
        }



.. _configuration_code_run_instance_tarantool:

Starting a Tarantool instance
-----------------------------

Below is the syntax for starting a Tarantool instance configured in a Lua initialization script:

..  code-block:: console

    $ tarantool LUA_INITIALIZATION_FILE [OPTION ...]

The ``tarantool`` command also provides a set of :ref:`options <configuration_command_options>` that might be helpful for development purposes.

The command below starts a Tarantool instance configured in the ``init.lua`` file:

.. code-block:: console

    $ tarantool init.lua

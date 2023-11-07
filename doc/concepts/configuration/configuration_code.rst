..  _configuration_code:

Configuration in code
=====================

.. box_cfg_legacy_note_start

.. NOTE::

    Starting with the 3.0 version, the recommended way of configuring Tarantool is using a :ref:`configuration file <configuration_file>`.
    Configuring Tarantool in code is considered a legacy approach.

.. box_cfg_legacy_note_end

This topic covers specifics of configuring Tarantool in code using the ``box.cfg`` API.
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

and suppose the environment variable LISTEN_URI contains 3301,
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

* ``TT_LISTEN`` -- corresponds to the ``box.cfg.listen`` option.
* ``TT_MEMTX_DIR`` -- corresponds to the ``box.cfg.memtx_dir`` option.

In case of an array value, separate the array elements by a comma without space:

..  code-block:: console

    export TT_REPLICATION="localhost:3301,localhost:3302"

If you need to pass :ref:`additional parameters for URI <index-uri-several-params>`, use the ``?`` and ``&`` delimiters:

..  code-block:: console

    export TT_LISTEN="localhost:3301?param1=value1&param2=value2"

An empty variable (``TT_LISTEN=``) has the same effect as an unset one meaning that the corresponding configuration parameter won't be set when calling ``box.cfg{}``.



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
If a host is omitted, then "0.0.0.0" or "[::]" is assumed
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
where a URI is expected, for example, "unix/:/tmp/unix_domain_socket.sock" or
simply "/tmp/unix_domain_socket.sock".

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

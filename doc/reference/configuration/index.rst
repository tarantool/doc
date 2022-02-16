.. _index-book_cfg:

================================================================================
Configuration reference
================================================================================

This reference covers all options and parameters which can be set for Tarantool
on the command line or in an :ref:`initialization file <index-init_label>`.

Tarantool is started by entering either of the following command:

..  cssclass:: highlight
..  parsed-literal::

    $ **tarantool**

    $ **tarantool** *options*

    $ **tarantool** *lua-initialization-file* **[** *arguments* **]**

--------------------------------------------------------------------------------
Command options
--------------------------------------------------------------------------------

..  option:: -h, --help

    Print an annotated list of all available options and exit.

.. _index-tarantool_version:

..  option:: -V, --version

    Print product name and version, for example:

    ..  code-block:: console

        $ ./tarantool --version
        Tarantool 2.6.2-0-g34d504d
        Target: Darwin-x86_64-Release
        ...

    In this example:

    “Tarantool” is the name of the reusable asynchronous networking
    programming framework.

    The 3-number version follows the standard ``<major>-<minor>-<patch>``
    scheme, in which ``<major>`` number is changed only rarely, ``<minor>`` is
    incremented for each new milestone and indicates possible incompatible
    changes, and ``<patch>`` stands for the number of bug fix releases made after
    the start of the milestone. For non-released versions only, there may be a
    commit number and commit SHA1 to indicate how much this particular build has
    diverged from the last release.

    “Target” is the platform tarantool was built on. Some platform-specific details
    may follow this line.

    ..  NOTE::

        Tarantool uses
        `git describe <http://www.kernel.org/pub/software/scm/git/docs/git-describe.html>`_
        to produce its version id, and this id can be used at any time to check
        out the corresponding source from our
        `git repository <http://github.com/tarantool/tarantool.git>`_.

.. _index-uri:

--------------------------------------------------------------------------------
URI
--------------------------------------------------------------------------------

Some configuration parameters and some functions depend on a URI, or
"Universal Resource Identifier". The URI string format is similar to the
`generic syntax for a URI schema <https://en.wikipedia.org/wiki/List_of_URI_schemes>`_.
So it may contain (in order) a user name
for login, a password, a host name or host IP address, and a port number. Only
the port number is always mandatory. The password is mandatory if the user
name is specified, unless the user name is 'guest'.

Formally, the URI
syntax is ``[host:]port`` or ``[username:password@]host:port``.
If host is omitted, then '0.0.0.0' or '[::]' is assumed,
meaning respectively any IPv4 address or any IPv6 address,
on the local machine.
If ``username:password`` is omitted, then 'guest' is assumed. Some examples:

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

In certain circumstances, a Unix domain socket may be used
where a URI is expected, for example, "unix/:/tmp/unix_domain_socket.sock" or
simply "/tmp/unix_domain_socket.sock".

Starting from version 2.10.0, a user can open several listening iproto sockets on a Tarantool instance
and, consequently, can specify several URIs in the configuration parameters such as :ref:`box.cfg.listen <cfg_basic-listen>` and :ref:`box.cfg.replication <cfg_replication-replication>`.

In addition to specifying URI as a number or a string, a number of other ways to pass URI values is available starting from Tarantool 2.10.0:

*   As a string with one or several URIs separated by commas (provides backward compatibility)

    code-block:: lua

    box.cfg { listen = "127.0.0.1:3301, /unix.sock, 3302" }

*   As an array that contains URIs in a string format

    code-block:: lua

    box.cfg { listen = {"127.0.0.1:3301", "/unix.sock", "3302"} }

*   As an array of tables with the ``uri`` field

    code-block:: lua

    box.cfg { listen = {
            {uri = "127.0.0.1:3301"},
            {uri = "/unix.sock"},
            {uri = 3302}
        }
    }


A method for parsing URIs is illustrated in :ref:`Module uri <uri-parse>`.

..  _index-init_label:

--------------------------------------------------------------------------------
Initialization file
--------------------------------------------------------------------------------

If the command to start Tarantool includes :codeitalic:`lua-initialization-file`, then
Tarantool begins by invoking the Lua program in the file, which by convention
may have the name "``script.lua``". The Lua program may get further arguments
from the command line or may use operating-system functions, such as ``getenv()``.
The Lua program almost always begins by invoking ``box.cfg()``, if the database
server will be used or if ports need to be opened. For example, suppose
``script.lua`` contains the lines

..  code-block:: lua

    #!/usr/bin/env tarantool
    box.cfg{
        listen              = os.getenv("LISTEN_URI"),
        memtx_memory        = 100000,
        pid_file            = "tarantool.pid",
        wal_max_size        = 2500
    }
    print('Starting ', arg[1])

and suppose the environment variable LISTEN_URI contains 3301,
and suppose the command line is ``~/tarantool/src/tarantool script.lua ARG``.
Then the screen might look like this:

..  code-block:: console

    $ export LISTEN_URI=3301
    $ ~/tarantool/src/tarantool script.lua ARG
    ... main/101/script.lua C> version 1.7.0-1216-g73f7154
    ... main/101/script.lua C> log level 5
    ... main/101/script.lua I> mapping 107374184 bytes for a shared arena...
    ... main/101/script.lua I> recovery start
    ... main/101/script.lua I> recovering from './00000000000000000000.snap'
    ... main/101/script.lua I> primary: bound to 0.0.0.0:3301
    ... main/102/leave_local_hot_standby I> ready to accept requests
    Starting  ARG
    ... main C> entering the event loop

If you wish to start an interactive session on the same terminal after
initialization is complete, you can use :ref:`console.start() <console-start>`.

..  _index-local_hot_standby:
..  _index-replication_port:
..  _index-slab_alloc_arena:
..  _index-replication_source:
..  _index-snap_dir:
..  _index-wal_dir:
..  _index-wal_mode:
..  _index-checkpoint daemon:

..  _box_cfg_params:

--------------------------------------------------------------------------------
Configuration parameters
--------------------------------------------------------------------------------

Configuration parameters have the form:

:extsamp:`{**{box.cfg}**}{[{*{key = value}*} [, {*{key = value ...}*}]]}`

Since ``box.cfg`` may contain many configuration parameters and since some of the
parameters (such as directory addresses) are semi-permanent, it's best to keep
``box.cfg`` in a Lua file. Typically this Lua file is the initialization file
which is specified on the tarantool command line.

Most configuration parameters are for allocating resources, opening ports, and
specifying database behavior. All parameters are optional. A few parameters are
dynamic, that is, they can be changed at runtime by calling ``box.cfg{}``
a second time.

To see all the non-null parameters, say ``box.cfg`` (no parentheses). To see a
particular parameter, for example the listen address, say ``box.cfg.listen``.

The following sections describe all parameters for basic operation, for storage,
for binary logging and snapshots, for replication, for networking,
for logging, and for feedback.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Basic parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_basic.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Configuring the storage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_storage.rst

..  _book_cfg_checkpoint_daemon:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Checkpoint daemon
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_snapshot_daemon.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Binary logging and snapshots
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_binary_logging_snapshots.rst

..  _index-hot_standby:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hot standby
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_hot_standby.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Replication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_replication.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Networking
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_networking.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Logging
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_logging.rst

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Deprecated parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

..  include:: cfg_deprecated.rst

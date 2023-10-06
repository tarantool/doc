Security audit
==============

This document will help you audit the security of a Tarantool Enterprise cluster.
It explains certain security aspects, their rationale, and the ways to check them.
For details on how to configure Tarantool Enterprise and its infrastructure for each aspect,
refer to the :doc:`security hardening guide <security>`.

Encryption of external iproto traffic
-------------------------------------

Tarantool Enterprise uses the
:doc:`iproto binary protocol </dev_guide/internals/box_protocol>`
for replicating data between instances and also in the connector libraries.

Since version 2.10.0, Tarantool Enterprise has the built-in support for using SSL to encrypt the client-server communications over binary connections.
For details on enabling SSL encryption, see the :ref:`enterprise-iproto-encryption` section of this document.

In case the built-in encryption is not enabled, we recommend using VPN to secure data exchange between data centers.

Closed iproto ports
-------------------

When a Tarantool Enterprise cluster does not use iproto for external requests,
connections to the iproto ports should be allowed only between Tarantool instances.

For more details on configuring ports for iproto,
see the ``advertise_uri`` section in the Cartridge documentation.


HTTPS connection termination
----------------------------

A Tarantool Enterprise instance can accept HTTP connections from external services
or access the administrative web UI.
All such connections must go through an HTTPS-providing web server,
running on the same host, such as nginx.
This requirement is for both virtual and physical hosts.
Running HTTP traffic through a few separate hosts with HTTPS termination
is not sufficiently secure.


Closed HTTP ports
-----------------

Tarantool Enterprise accepts HTTP connections on a specific port, configured with
``http_port: <number>`` value
(see :ref:`configuring Cartridge instances <cartridge-config>`).
It must be only available on the same host for nginx to connect to it.

Check that the configured HTTP port is closed
and that the HTTPS port (``443`` by default) is open.

Restricted access to the administrative console
-----------------------------------------------

The :doc:`console </reference/reference_lua/console>` module provides
a way to connect to a running instance and run custom Lua code.
This can be useful for development and administration.
The following code examples open connections on a TCP port and on a UNIX socket.

..  code-block:: lua

    console.listen(<port number>)
    console.listen('/var/lib/tarantool/socket_name.sock')

Opening an administrative console through a TCP port is always unsafe.
Check that there are no calls like ``console.listen(<port_number>)``
in the code.

Connecting through a socket requires having the write permission on the
``/var/lib/tarantool`` directory.
Check that write permission to this directory is limited to the ``tarantool`` user.

Limiting the guest user
-----------------------

Connecting to the instance with ``tt connect`` or ``tarantoolctl connect`` without
user credentials (under the ``guest`` user) must be disabled.

There are two ways to check this vulnerability:

*   Check that the source code doesn't grant access to the ``guest`` user.
    The corresponding code can look like this:

    ..  code-block:: lua

        box.schema.user.grant('guest',
            'read,write',
            'universe',
            nil, { if_not_exists = true }
        )

    Besides searching for the whole code pattern,
    search for any entries of ``'universe'``.

*   Try connecting with ``tt connect`` to each Tarantool Enterprise node.

For more details, refer to the documentation on
:ref:`access control <authentication>`.

Authorization in the web UI
---------------------------

Using the web interface must require logging in with a username and password.
See more details in the documentation on
:ref:`configuring web interface authorization <cartridge-auth-enable>`.

Running under the tarantool user
--------------------------------

All Tarantool Enterprise instances should be running under the ``tarantool`` user.

Limiting access to the tarantool user
-------------------------------------

The ``tarantool`` user must be a non-privileged user without the ``sudo`` permission.
Also, it must not have a password set to prevent logging in via SSH or ``su``.


Keeping two or more snapshots
-----------------------------

In order to have a reliable backup, a Tarantool Enterprise instance must keep
two or more latest snapshots.
This should be checked on each Tarantool Enterprise instance.

The :ref:`snapshot_count <cfg_checkpoint_daemon-checkpoint_count>` value
determines the number of kept snapshots.
Configuration values are primarily set in the configuration files
but :doc:`can be overridden </book/cartridge/cartridge_api/modules/cartridge.argparse>`
with environment variables and command-line arguments.
So, it's best to check both the values in the configuration files and the actual values
using the console:

..  code-block:: tarantoolsession

    tarantool> box.cfg.checkpoint_count
    ---
    - 2


Enabled write-ahead logging (WAL)
---------------------------------

Tarantool Enterprise records all incoming data in the write-ahead log (WAL).
The WAL must be enabled to ensure that data will be recovered in case of
a possible instance restart.

Secure values of ``wal_mode`` are ``write`` and ``fsync``:

..  code-block:: tarantoolsession

    tarantool> box.cfg.wal_mode
    ---
    - write

An exclusion from this requirement is when the instance is processing data,
which can be freely rejected.
For example, when Tarantool Enterprise is used for caching.
Then WAL can be disabled to reduce i/o load.

For more details, see the
:ref:`wal_mode reference <cfg_binary_logging_snapshots-wal_mode>`.

The logging level is INFO or higher
-----------------------------------

The logging level should be set to 5 (``INFO``), 6 (``VERBOSE``), or 7 (``DEBUG``).
Application logs will then have enough information to research a possible security breach.

..  code-block:: tarantoolsession

    tarantool> box.cfg.log_level
    ---
    - 5

For a full list of logging levels, see the
:ref:`log_level reference <cfg_logging-log_level>`.


Logging with journald
---------------------

Tarantool Enterprise should use ``journald`` for logging.

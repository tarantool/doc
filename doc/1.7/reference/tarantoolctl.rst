.. _tarantoolctl:

--------------------------------------------------------------------------------
tarantoolctl
--------------------------------------------------------------------------------

``tarantoolctl`` is a utility for administering Tarantool instances. It is
shipped and installed as part of Tarantool distribution.

The command format is:

``tarantoolctl COMMAND NAME [URI] [FILE] [OPTIONS..]``

where:

* COMMAND is one of the following: start, stop, logrotate, status, enter,
  restart, eval, check, connect, cat, play.
  
* NAME is the name of an :ref:`instance file <admin-instance_file>`.

* FILE is the path to some file (.lua, .xlog or .snap).

* URI is the URI of some Tarantool instance.

* OPTIONS are options taken by some ``tarantoolctl`` commands.

See also:

* Detailed reference upon ``man tarantoolctl`` or ``tarantoolctl --help``. 
* Usage examples in `Server administration <admin>` section.
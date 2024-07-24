.. _enterprise-rocks:

===============================================================================
Modules
===============================================================================

This section covers open and closed source Lua modules for Tarantool Enterprise Edition
included in the distribution as an offline rocks repository.

-------------------------------------------------------------------------------
Open source modules
-------------------------------------------------------------------------------

* `avro-schema <https://github.com/tarantool/avro-schema/blob/master/README.md>`_
  is an assembly of `Apache Avro <http://avro.apache.org/docs/current/>`_
  schema tools;

* :ref:`checks <checks-module>`
  is a type checker of functional arguments. This library that declares
  a ``checks()`` function and ``checkers`` table that allow to check the
  parameters passed to a Lua function in a fast and unobtrusive way.
* `http <https://github.com/tarantool/http/blob/master/README.md>`_ is an
  on-board HTTP-server, which comes in addition to Tarantool's out-of-the-box
  HTTP client, and must be installed as described in the
  :ref:`installation section <enterprise-rocks-install>`.
* `icu-date <https://github.com/tarantool/icu-date/blob/master/README.md>`_
  is a date-and-time formatting library for Tarantool
  based on International Components for Unicode;
* `kafka <https://github.com/tarantool/kafka/blob/master/README.md>`_
  is a full-featured high-performance ``kafka`` library for Tarantool
  based on ``librdkafka``;
* `luacheck <https://github.com/tarantool/luacheck>`_ is a static analyzer and
  linter for Lua, preconfigured for Tarantool.
* `luarapidxml <https://github.com/tarantool/luarapidxml/blob/master/README.md>`_
  is a fast XML parser.
* `luatest <https://github.com/tarantool/luatest/blob/master/README.rst>`_ is
  a Tarantool test framework written in Lua.
* :ref:`membership <membership>`
  builds a mesh from multiple Tarantool instances based on gossip protocol.
  The mesh monitors itself, helps members discover everyone else in the group
  and get notified about their status changes with low latency. It is built
  upon the ideas from Consul or, more precisely, the SWIM algorithm.
* :ref:`metrics <monitoring>` is a collection
  of useful monitoring metrics.
* `tracing <https://github.com/tarantool/tracing/>`_
  is a module for debugging performance issues.
* :ref:`vshard <vshard>`
  is an automatic sharding system that enables horizontal scaling for Tarantool
  DBMS instances.

-------------------------------------------------------------------------------
Closed source modules
-------------------------------------------------------------------------------

* :doc:`ldap <modules/ldap/rst/index>`
  allows you to authenticate in a LDAP server and perform searches.
* :doc:`odbc <modules/odbc/rst/index>`
  is an ODBC connector for Tarantool based on unixODBC.
* :doc:`oracle <modules/oracle/rst/index>`
  is an Oracle connector for Lua applications through which they can send and
  receive data to and from Oracle databases.
  The advantage of the Tarantool-Oracle integration is that anyone can handle all
  the tasks with Oracle DBMSs (control, manipulation, storage, access) with the
  same high-level language (Lua) and with minimal delay.
* :doc:`task <modules/task/rst/index>`
  is a module for managing background tasks in a Tarantool cluster.

.. _enterprise-rocks-install:

-------------------------------------------------------------------------------
Installing and using modules
-------------------------------------------------------------------------------

To use a module, install the following:

#.  All the necessary third-party software packages (if any). See the
    module's prerequisites for the list.

#.  The module itself on every Tarantool instance:

    .. code-block:: console

        $ tt rocks install MODULE_NAME [MODULE_VERSION]

See the :ref:`tt rocks reference <tt-rocks>` to learn more about
managing Lua modules.

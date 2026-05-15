..  _tcm_terminals:

Terminals
=========

|tcm_full_name| (TCM) provides two ways to interact with Tarantool instances:

-  ``direct`` — a terminal that connects directly to a Tarantool instance using the `go-tarantool <https://github.com/tarantool/go-tarantool/>`__ library, bypassing the `tt connect` utility
-  ``tt-connect`` — a terminal that uses the :ref:`tt-cli` utility to connect to a Tarantool instance

Both terminals allow executing SQL queries, managing cluster state, viewing metrics, and more.

..  _tcm_terminals_direct:

Terminal direct
---------------

Authentication credentials are taken from the cluster configuration:

..  code-block:: yaml

    credentials:
      users:
        tcm_tarantool:
          password: tcm_tarantool_password
          roles: [super]


..  _tcm_terminals_tt-connect:

Terminal tt-connect
-------------------

Specify the path to the tt connect utility in the tcm.yaml configuration file:

..  code-block:: yaml

    mode: production
    cluster:
      tt-command: .tarantool/tt

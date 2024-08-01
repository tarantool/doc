.. _tarantoolctl-migration-to-tt:

Migration from tarantoolctl to tt
=================================

:ref:`tt <tt-cli>` is a command-line utility for managing Tarantool applications
that comes to replace ``tarantoolctl``. Starting from version 3.0, ``tarantoolctl``
is no longer shipped as a part of Tarantool distribution; ``tt`` is the only
recommended tool for managing Tarantool applications from the command line.

``tarantoolctl`` remains fully compatible with Tarantool 2.* versions. However,
it doesn't receive major updates anymore.

We recommend that you migrate from ``tarantoolctl`` to ``tt`` to ensure the full
support and timely updates and fixes.

System-wide configuration
-------------------------

``tt`` supports system-wide environment configuration by default. If you have
Tarantool instances managed by ``tarantoolctl`` in such an environment, you can
switch to ``tt`` without additional migration steps or use ``tt`` along with ``tarantoolctl``.

Example:

..  code-block:: bash

    $ sudo tt instances
    List of enabled applications:
    • example

    $ tarantoolctl start example
    Starting instance example...
    Forwarding to 'systemctl start tarantool@example'

    $ tarantoolctl status example
    Forwarding to 'systemctl status tarantool@example'
    ● tarantool@example.service - Tarantool Database Server
        Loaded: loaded (/lib/systemd/system/tarantool@.service; enabled; vendor preset: enabled)
        Active: active (running)
        Docs: man:tarantool(1)
        Main PID: 6698 (tarantool)
    . . .

    $ sudo tt status
    • example: RUNNING. PID: 6698.

    $ sudo tt connect example
    • Connecting to the instance...
    • Connected to /var/run/tarantool/example.control

    /var/run/tarantool/example.control>

    $ sudo tt stop example
    • The Instance example (PID = 6698) has been terminated.

    $ tarantoolctl status example
    Forwarding to 'systemctl status tarantool@example'
    ○ tarantool@example.service - Tarantool Database Server
        Loaded: loaded (/lib/systemd/system/tarantool@.service; enabled; vendor preset: enabled)
        Active: inactive (dead)

Local configuration
-------------------

If you have a local ``tarantoolctl`` configuration, create a ``tt`` environment
based on the existing ``.tarantoolctl`` configuration file. To do this, run
``tt init`` in the directory where the file is located.

Example:

..  code-block:: bash

    $ cat .tarantoolctl
    default_cfg = {
        pid_file  = "./run/tarantool",
        wal_dir   = "./lib/tarantool",
        memtx_dir = "./lib/tarantool",
        vinyl_dir = "./lib/tarantool",
        log       = "./log/tarantool",
        language  = "Lua",
    }
    instance_dir = "./instances.enabled"

    $ tt init
    • Found existing config '.tarantoolctl'
    • Environment config is written to 'tt.yaml'

After that, you can start managing Tarantool instances in this environment with ``tt``:

..  code-block:: bash

    $ tt start app1
    • Starting an instance [app1]...

    $ tt status app1
    • app1: RUNNING. PID: 33837.

    $ tt stop app1
    • The Instance app1 (PID = 33837) has been terminated.

    $ tt check app1
    • Result of check: syntax of file '/home/user/instances.enabled/app1.lua' is OK

Commands difference
-------------------

Most ``tarantoolctl`` commands look the same in ``tt``: ``tarantoolctl start`` and
``tt start``, ``tarantoolctl play`` and ``tt play``, and so on. To migrate such
calls, it is usually enough to replace the utility name. There can be slight differences
in command flags and format. For details on ``tt`` commands, see the
:ref:`tt commands reference <tt-commands>`.

The following commands are different in ``tt``:

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 1

        *   -   ``tarantoolctl`` command
            -   ``tt`` command
        *   -   ``tarantoolctl enter``
            -   ``tt connect``
        *   -   ``tarantoolctl eval``
            -   ``tt connect`` with ``-f`` flag

..  note::

    ``tt connect`` also covers ``tarantoolctl connect`` with the same syntax.

Example:

..  code-block:: bash

    # tarantoolctl enter > tt connect
    $ tarantoolctl enter app1
    connected to unix/:./run/tarantool/app1.control
    unix/:./run/tarantool/app1.control>

    $ tt connect app1
    • Connecting to the instance...
    • Connected to /home/user/run/tarantool/app1/app1.control

    # tarantoolctl eval > tt connect -f
    $ tarantoolctl eval app1 eval.lua
    connected to unix/:./run/tarantool/app1.control
    ---
    - 42
    ...

   $ tt connect app1 -f eval.lua
    ---
    - 42
    ...

    # tarantoolctl connect > tt connect
    $ tarantoolctl connect localhost:3301
    connected to localhost:3301
    localhost:3301>

    $ tt connect localhost:3301
    • Connecting to the instance...
    • Connected to localhost:3301
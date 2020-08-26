* :ref:`background <cfg_basic-background>`
* :ref:`custom_proc_title <cfg_basic-custom_proc_title>`
* :ref:`listen <cfg_basic-listen>`
* :ref:`memtx_dir <cfg_basic-memtx_dir>`
* :ref:`pid_file <cfg_basic-pid_file>`
* :ref:`read_only <cfg_basic-read_only>`
* :ref:`vinyl_dir <cfg_basic-vinyl_dir>`
* :ref:`vinyl_timeout <cfg_basic-vinyl_timeout>`
* :ref:`username <cfg_basic-username>`
* :ref:`wal_dir <cfg_basic-wal_dir>`
* :ref:`work_dir <cfg_basic-work_dir>`
* :ref:`worker_pool_threads <cfg_basic-worker_pool_threads>`

.. _cfg_basic-background:

.. confval:: background

    Since version 1.6.2.
    Run the server as a background task. The :ref:`log <cfg_logging-log>`
    and :ref:`pid_file <cfg_basic-pid_file>` parameters must be non-null for
    this to work.

    | Type: boolean
    | Default: false
    | Dynamic: no

.. _cfg_basic-custom_proc_title:

.. confval:: custom_proc_title

    Since version 1.6.7.
    Add the given string to the server's process title
    (what’s shown in the COMMAND column for
    ``ps -ef`` and ``top -c`` commands).

    For example, ordinarily :samp:`ps -ef` shows the Tarantool server process
    thus:

    .. code-block:: console

        $ ps -ef | grep tarantool
        1000     14939 14188  1 10:53 pts/2    00:00:13 tarantool <running>

    But if the configuration parameters include ``custom_proc_title='sessions'``
    then the output looks like:

    .. code-block:: console

        $ ps -ef | grep tarantool
        1000     14939 14188  1 10:53 pts/2    00:00:16 tarantool <running>: sessions

    | Type: string
    | Default: null
    | Dynamic: yes

.. _cfg_basic-listen:

.. confval:: listen

    Since version 1.6.4.
    The read/write data port number or :ref:`URI <index-uri>` (Universal
    Resource Identifier) string. Has no default value, so **must be specified**
    if connections will occur from remote clients that do not use the
    :ref:`“admin port” <admin-security>`. Connections made with
    :samp:`listen = {URI}` are called "binary port" or "binary protocol"
    connections.

    A typical value is 3301.

    .. NOTE::

        A replica also binds to this port, and accepts connections, but these
        connections can only serve reads until the replica becomes a master.

    | Type: integer or string
    | Default: null
    | Dynamic: yes

.. _cfg_basic-memtx_dir:

.. confval:: memtx_dir

    Since version 1.7.4.
    A directory where memtx stores snapshot (.snap) files. Can be relative to
    :ref:`work_dir <cfg_basic-work_dir>`. If not specified, defaults to
    ``work_dir``. See also :ref:`wal_dir <cfg_basic-wal_dir>`.

    | Type: string
    | Default: "."
    | Dynamic: no

.. _cfg_basic-pid_file:

.. confval:: pid_file

    Since version 1.4.9.
    Store the process id in this file. Can be relative to :ref:`work_dir
    <cfg_basic-work_dir>`. A typical value is “:file:`tarantool.pid`”.

    | Type: string
    | Default: null
    | Dynamic: no

.. _cfg_basic-read_only:

.. confval:: read_only

    Since version 1.7.1.
    Say ``box.cfg{read_only=true...}`` to put the server instance in read-only
    mode. After this, any requests that try to change persistent data will fail with error
    :errcode:`ER_READONLY`. Read-only mode should be used for master-replica
    :ref:`replication <replication>`. Read-only mode does not affect data-change
    requests for spaces defined as :ref:`temporary <box_schema-space_create>`.
    Although read-only mode prevents the server from writing to the :ref:`WAL <internals-wal>`,
    it does not prevent writing diagnostics with the :ref:`log module <log-module>`.

    | Type: boolean
    | Default: false
    | Dynamic: yes

    Setting ``read_only == true`` affects spaces differently depending on the
    :ref:`options <box_schema-space_create-options>` that were used during
    :ref:`box.schema.space.create <box_schema-space_create>`.

.. _cfg_basic-vinyl_dir:

.. confval:: vinyl_dir

    Since version 1.7.1.
    A directory where vinyl files or subdirectories will be stored. Can be
    relative to :ref:`work_dir <cfg_basic-work_dir>`. If not specified, defaults
    to ``work_dir``.

    | Type: string
    | Default: "."
    | Dynamic: no

.. _cfg_basic-vinyl_timeout:

.. confval:: vinyl_timeout

    Since version 1.7.5.
    The vinyl storage engine has a scheduler which does compaction.
    When vinyl is low on available memory, the compaction scheduler
    may be unable to keep up with incoming update requests.
    In that situation, queries may time out after ``vinyl_timeout`` seconds.
    This should rarely occur, since normally vinyl
    would throttle inserts when it is running low on compaction bandwidth.
    Compaction can also be ordered manually with
    :ref:`index_object:compact() <box_index-compact>`.

    | Type: float
    | Default: 60
    | Dynamic: yes

.. _cfg_basic-username:

.. confval:: username

    Since version 1.4.9. UNIX user name to switch to after start.

    | Type: string
    | Default: null
    | Dynamic: no

.. _cfg_basic-wal_dir:

.. confval:: wal_dir

    Since version 1.6.2.
    A directory where write-ahead log (.xlog) files are stored. Can be relative
    to :ref:`work_dir <cfg_basic-work_dir>`. Sometimes ``wal_dir`` and
    :ref:`memtx_dir <cfg_basic-memtx_dir>` are specified with different values, so
    that write-ahead log files and snapshot files can be stored on different
    disks. If not specified, defaults to ``work_dir``.

    | Type: string
    | Default: "."
    | Dynamic: no

.. _cfg_basic-work_dir:

.. confval:: work_dir

    Since version 1.4.9.
    A directory where database working files will be stored. The server instance
    switches to ``work_dir`` with :manpage:`chdir(2)` after start. Can be
    relative to the current directory. If not specified, defaults to
    the current directory. Other directory parameters may be relative to
    ``work_dir``, for example:

    .. code-block:: lua

        box.cfg{
            work_dir = '/home/user/A',
            wal_dir = 'B',
            memtx_dir = 'C'
        }

    will put xlog files in ``/home/user/A/B``, snapshot files in ``/home/user/A/C``,
    and all other files or subdirectories in ``/home/user/A``.

    | Type: string
    | Default: null
    | Dynamic: no


.. _cfg_basic-worker_pool_threads:

.. confval:: worker_pool_threads

    Since version 1.7.5.
    The maximum number of threads to use during execution
    of certain internal processes (currently
    :ref:`socket.getaddrinfo() <socket-getaddrinfo>` and
    :ref:`coio_call() <c_api-coio-coio_call>`).

    | Type: integer
    | Default: 4
    | Dynamic: yes

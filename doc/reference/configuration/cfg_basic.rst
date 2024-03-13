* :ref:`background <cfg_basic-background>`
* :ref:`custom_proc_title <cfg_basic-custom_proc_title>`
* :ref:`listen <cfg_basic-listen>`
* :ref:`memtx_dir <cfg_basic-memtx_dir>`
* :ref:`pid_file <cfg_basic-pid_file>`
* :ref:`read_only <cfg_basic-read_only>`
* :ref:`sql_cache_size <cfg_basic-sql_cache_size>`
* :ref:`vinyl_dir <cfg_basic-vinyl_dir>`
* :ref:`vinyl_timeout <cfg_basic-vinyl_timeout>`
* :ref:`username <cfg_basic-username>`
* :ref:`wal_dir <cfg_basic-wal_dir>`
* :ref:`work_dir <cfg_basic-work_dir>`
* :ref:`worker_pool_threads <cfg_basic-worker_pool_threads>`
* :ref:`strip_core <cfg_basic-strip_core>`
* :ref:`memtx_use_mvcc_engine <cfg_basic-memtx_use_mvcc_engine>`

.. _cfg_basic-background:

.. confval:: background

    Since version 1.6.2.

    Run the server as a background task. The :ref:`log <cfg_logging-log>`
    and :ref:`pid_file <cfg_basic-pid_file>` parameters must be non-null for
    this to work.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_BACKGROUND
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

    |
    | Type: string
    | Default: null
    | Environment variable: TT_CUSTOM_PROC_TITLE
    | Dynamic: yes

.. _cfg_basic-listen:

.. confval:: listen

    Since version 1.6.4.

    The read/write data port number or :ref:`URI <index-uri>` (Universal
    Resource Identifier) string. Has no default value, so **must be specified**
    if connections occur from the remote clients that don't use the
    :ref:`"admin port" <admin-security>`. Connections made with
    :samp:`listen = {URI}` are called "binary port" or "binary protocol"
    connections.

    A typical value is 3301.

    ..  code-block:: lua

        box.cfg { listen = 3301 }

        box.cfg { listen = "127.0.0.1:3301" }

    ..  NOTE::

        A replica also binds to this port, and accepts connections, but these
        connections can only serve reads until the replica becomes a master.

    Starting from version 2.10.0, you can specify :ref:`several URIs <index-uri-several>`,
    and the port number is always stored as an integer value.

    |
    | Type: integer or string
    | Default: null
    | Environment variable: TT_LISTEN
    | Dynamic: yes

.. _cfg_basic-memtx_dir:

.. confval:: memtx_dir

    Since version 1.7.4.

    A directory where memtx stores snapshot (``.snap``) files.
    A relative path in this option is interpreted as relative to :ref:`work_dir <cfg_basic-work_dir>`.

    By default, snapshots and WAL files are stored in the same directory.
    However, you can set different values for the ``memtx_dir`` and :ref:`wal_dir <cfg_basic-wal_dir>` options
    to store them on different physical disks for performance matters.

    |
    | Type: string
    | Default: "."
    | Environment variable: TT_MEMTX_DIR
    | Dynamic: no

.. _cfg_basic-pid_file:

.. confval:: pid_file

    Since version 1.4.9.

    Store the process id in this file. Can be relative to :ref:`work_dir
    <cfg_basic-work_dir>`. A typical value is “:file:`tarantool.pid`”.

    |
    | Type: string
    | Default: null
    | Environment variable: TT_PID_FILE
    | Dynamic: no

.. _cfg_basic-read_only:

.. confval:: read_only

    Since version 1.7.1.

    Say ``box.cfg{read_only=true...}`` to put the server instance in read-only
    mode. After this, any requests that try to change persistent data will fail with error
    :errcode:`ER_READONLY`. Read-only mode should be used for master-replica
    :ref:`replication <replication>`. Read-only mode does not affect data-change
    requests for spaces defined as
    :doc:`temporary </reference/reference_lua/box_schema/space_create>`.
    Although read-only mode prevents the server from writing to the :ref:`WAL <internals-wal>`,
    it does not prevent writing diagnostics with the :ref:`log module <log-module>`.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_READ_ONLY
    | Dynamic: yes

    Setting ``read_only == true`` affects spaces differently depending on the
    :ref:`options <space_opts_object>` that were used during
    :doc:`box.schema.space.create </reference/reference_lua/box_schema/space_create>`,
    as summarized by this chart:

    .. container:: table

        +------------+-----------------+--------------------+----------------+----------------+
        | Option     | Can be created? | Can be written to? | Is replicated? | Is persistent? |
        +============+=================+====================+================+================+
        | (default)  | no              | no                 | yes            | yes            |
        +------------+-----------------+--------------------+----------------+----------------+
        | temporary  | no              | yes                | no             | no             |
        +------------+-----------------+--------------------+----------------+----------------+
        | is_local   | no              | yes                | no             | yes            |
        +------------+-----------------+--------------------+----------------+----------------+

.. _cfg_basic-sql_cache_size:

.. confval:: sql_cache_size

    Since version 2.3.1.

    The maximum number of bytes in the cache for
    :ref:`SQL prepared statements <box-sql_box_prepare>`.
    (The number of bytes that are actually used can be seen with
    :ref:`box.info.sql().cache.size <box_introspection-box_info>`.)

    |
    | Type: number
    | Default: 5242880
    | Environment variable: TT_SQL_CACHE_SIZE
    | Dynamic: yes

.. _cfg_basic-vinyl_dir:

.. confval:: vinyl_dir

    Since version 1.7.1.

    A directory where vinyl files or subdirectories will be stored. Can be
    relative to :ref:`work_dir <cfg_basic-work_dir>`. If not specified, defaults
    to ``work_dir``.

    |
    | Type: string
    | Default: "."
    | Environment variable: TT_VINYL_DIR
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
    :doc:`/reference/reference_lua/box_index/compact`.

    |
    | Type: float
    | Default: 60
    | Environment variable: TT_VINYL_TIMEOUT
    | Dynamic: yes

.. _cfg_basic-username:

.. confval:: username

    Since version 1.4.9.

    UNIX user name to switch to after start.

    |
    | Type: string
    | Default: null
    | Environment variable: TT_USERNAME
    | Dynamic: no

.. _cfg_basic-wal_dir:

.. confval:: wal_dir

    Since version 1.6.2.

    A directory where write-ahead log (``.xlog``) files are stored.
    A relative path in this option is interpreted as relative to :ref:`work_dir <cfg_basic-work_dir>`.

    By default, WAL files and snapshots are stored in the same directory.
    However, you can set different values for the ``wal_dir`` and :ref:`memtx_dir <cfg_basic-memtx_dir>` options
    to store them on different physical disks for performance matters.

    |
    | Type: string
    | Default: "."
    | Environment variable: TT_WAL_DIR
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

    |
    | Type: string
    | Default: null
    | Environment variable: TT_WORK_DIR
    | Dynamic: no


.. _cfg_basic-worker_pool_threads:

.. confval:: worker_pool_threads

    Since version 1.7.5.

    The maximum number of threads to use during execution
    of certain internal processes (currently
    :ref:`socket.getaddrinfo() <socket-getaddrinfo>` and
    :ref:`coio_call() <c_api-coio-coio_call>`).

    |
    | Type: integer
    | Default: 4
    | Environment variable: TT_WORKER_POOL_THREADS
    | Dynamic: yes

.. _cfg_basic-strip_core:

.. confval:: strip_core

    Since version 2.2.2.

    Whether coredump files should include memory allocated for tuples.
    (This can be large if Tarantool runs under heavy load.)
    Setting to ``true`` means "do not include".
    In an older version of Tarantool the default value of this parameter was ``false``.

    |
    | Type: boolean
    | Default: true
    | Environment variable: TT_STRIP_CORE
    | Dynamic: no

.. _cfg_basic-memtx_use_mvcc_engine:

.. confval:: memtx_use_mvcc_engine

    Since version :doc:`2.6.1 </release/2.6.1>`.

    Enable :ref:`transactional manager <txn_mode_transaction-manager>` if set to ``true``.

    |
    | Type: boolean
    | Default: false
    | Environment variable: TT_MEMTX_USE_MVCC_ENGINE
    | Dynamic: no

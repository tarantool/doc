.. _xlog:

-------------------------------------------------------------------------------
                            Module `xlog`
-------------------------------------------------------------------------------

The xlog module contains one function: ``pairs()``. It can be used to read
Tarantool's :ref:`snapshot files<index-box_persistence>` or
:ref:`write-ahead-log (WAL) <internals-wal>` files. A description of the
file format is in section :ref:`Data persistence and the WAL file format
<internals-data_persistence>`.

.. module:: xlog

.. _xlog-pairs:

.. method:: pairs([file-name])

    Open a file, and allow iterating over one file entry at a time.

    :returns: iterator  which can be used in a for/end loop.
    :rtype: `iterator <https://www.lua.org/pil/7.1.html>`_

    Possible errors: File does not contain properly formatted snapshot or
    write-ahead-log information.

    **Example:**

    This will read the first write-ahead-log (WAL) file that was created in the
    :ref:`wal_dir <cfg_basic-wal_dir>` directory 
    in our :ref:`"Getting started" exercises <getting_started>`.

    Each result from ``pairs()`` is formatted with MsgPack so its structure can
    be specified with :ref:`__serialize <msgpack-serialize>`.

    .. code-block:: lua

        xlog = require('xlog')
        t = {}
        for k, v in xlog.pairs('00000000000000000000.xlog') do
          table.insert(t, setmetatable(v, { __serialize = "map"}))
        end
        return t

    The first lines of the result will look like:

    .. code-block:: tarantoolsession

        (...)
        ---
        - - {'BODY':   {'space_id': 272, 'index_base': 1, 'key': ['max_id'],
                        'tuple': [['+', 2, 1]]},
             'HEADER': {'type': 'UPDATE', 'timestamp': 1477846870.8541,
                        'lsn': 1, 'server_id': 1}}
          - {'BODY':   {'space_id': 280,
                         'tuple': [512, 1, 'tester', 'memtx', 0, {}, []]},
             'HEADER': {'type': 'INSERT', 'timestamp': 1477846870.8597,
                        'lsn': 2, 'server_id': 1}}

..  _index_connector_py:

Python
======

`tarantool-python <http://github.com/tarantool/tarantool-python>`__
is the official Python connector for Tarantool. It is not supplied as part
of the Tarantool repository and must be installed separately (see below for details).

Here is a complete Python program that inserts ``[99999,'Value','Value']`` into
space ``examples`` via the high-level Python API.

..  code-block:: python

    #!/usr/bin/python
    from tarantool import Connection

    c = Connection("127.0.0.1", 3301)
    result = c.insert("examples",(99999,'Value', 'Value'))
    print result

To prepare, paste the code into a file named :file:`example.py` and install
the ``tarantool-python`` connector with either :samp:`pip install tarantool\>0.4`
to install in :file:`/usr` (requires **root** privilege) or
:samp:`pip install tarantool\>0.4 --user` to install in :file:`~` i.e. user's
default directory.

Before trying to run, check that the server instance is :ref:`listening <cfg_basic-listen>` at
``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`.
To run the program, say :samp:`python example.py`. The program will connect
to the Tarantool server, will send the :ref:`INSERT <box_space-insert>` request, and will not throw any exception if
all went well. If the tuple already exists, the program will throw
``tarantool.error.DatabaseError: (3, "Duplicate key exists in unique index 'primary' in space 'examples'")``.

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see
`tarantool-python <http://github.com/tarantool/tarantool-python>`__ project at GitHub.

Also there are several community-driven Python connectors:

* `asynctnt <https://github.com/igorcoding/asynctnt>`__ with asyncio support
* `aiotarantool <https://github.com/shveenkov/aiotarantool>`__ also with asyncio support, **no active maintenance**
* `gtarantool <https://github.com/shveenkov/gtarantool>`__ with gevent support, **no active maintenance**

The table below contains a feature comparison for asynctnt and
tarantool-python. aiotarantool and gtarantool are absent there because they are quite outdated and
unmaintained.

..  _python-feature-comparison:

Feature comparison
------------------

Last update: September 2023

..  list-table::
    :header-rows: 1
    :stub-columns: 1

    *   -   Parameter
        -   `igorcoding/asynctnt <https://github.com/igorcoding/asynctnt>`__
        -   `tarantool/tarantool-python <https://github.com/tarantool/tarantool-python>`__

    *   -   License
        -   Apache License 2.0
        -   BSD-2

    *   -   Is maintained
        -   Yes
        -   Yes

    *   -   Known Issues
        -   None
        -   None

    *   -   Documentation
        -   Yes (`github.io <https://igorcoding.github.io/asynctnt/>`__)
        -   Yes (`readthedocs
            <https://tarantool-python.readthedocs.io/en/latest/quick-start.en.html>`__
            and :ref:`tarantool.io <getting_started-python>`)

    *   -   Testing / CI / CD
        -   GitHub Actions
        -   GitHub Actions

    *   -   GitHub Stars
        -   73
        -   92

    *   -   Static Analysis
        -   Yes (Flake8)
        -   Yes (Flake8, Pylint)

    *   -   Packaging
        -   `pip <https://pypi.org/project/asynctnt/>`__
        -   `pip, deb, rpm <https://github.com/tarantool/tarantool-python#download-and-install>`__

    *   -   Code coverage
        -   Yes
        -   Yes

    *   -   Support asynchronous mode
        -   Yes, `asyncio <https://docs.python.org/3/library/asyncio.html>`__
        -   No

    *   -   Batching support
        -   No
        -   Yes (with CRUD API)

    *   -   Schema reload
        -   Yes (automatically, see `auto_refetch_schema <https://igorcoding.github.io/asynctnt/api.html>`__)
        -   Yes (automatically)

    *   -   Space / index names
        -   Yes
        -   Yes

    *   -   Access tuple fields by names
        -   Yes
        -   No

    *   -   :ref:`SQL support <reference_sql>`
        -   Yes
        -   Yes

    *   -   :ref:`Interactive transactions <txn_mode_stream-interactive-transactions>`
        -   Yes
        -   No (`issue #163 <https://github.com/tarantool/tarantool-python/issues/163>`__)

    *   -   :ref:`Varbinary support <index-box_data-types>`
        -   Yes (in ``MP_BIN`` fields)
        -   Yes

    *   -   :ref:`Decimal support <msgpack_ext-decimal>`
        -   Yes
        -   Yes

    *   -   :ref:`UUID support <msgpack_ext-uuid>`
        -   Yes
        -   Yes

    *   -   :ref:`EXT_ERROR support <msgpack_ext-error>`
        -   Yes
        -   Yes

    *   -   :ref:`Datetime support <msgpack_ext-datetime>`
        -   Yes
        -   Yes

    *   -   :ref:`Interval support <msgpack_ext-interval>`
        -   No (`issue #30 <https://github.com/igorcoding/asynctnt/issues/30>`__)
        -   Yes

    *   -   :ref:`box.session.push() responses <box_session-push>`
        -   Yes
        -   Yes

    *   -   :ref:`Session settings <box_space-session_settings>`
        -   No
        -   No

    *   -   `Graceful shutdown <https://github.com/tarantool/tarantool/issues/5924>`__
        -   No
        -   No

    *   -   `IPROTO_ID (feature discovery) <https://github.com/tarantool/doc/issues/2419>`__
        -   Yes
        -   Yes

    *   -   `CRUD support <https://github.com/tarantool/crud>`__
        -   No
        -   Yes

    *   -   Transparent request retrying
        -   No
        -   No

    *   -   Transparent reconnecting
        -   Autoreconnect
        -   Yes (reconnect_max_attempts, reconnect_delay), checking of connection liveness

    *   -   Connection pool
        -   No
        -   Yes (with master discovery)

    *   -   Support of `PEP 249 -- Python Database API Specification v2.0 <https://www.python.org/dev/peps/pep-0249/>`__
        -   No
        -   `Yes <https://github.com/tarantool/tarantool-python/wiki/PEP-249-Database-API>`__

    *   -   :ref:`Encrypted connection (Tarantool Enterprise) <enterprise-iproto-encryption>`
        -   No (`issue #22 <https://github.com/igorcoding/asynctnt/issues/22>`__)
        -   Yes

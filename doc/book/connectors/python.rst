Python
======

`tarantool-python <http://github.com/tarantool/tarantool-python>`__
is the official Python connector for Tarantool. It is not supplied as part
of the Tarantool repository and must be installed separately (see below for details).

Here is a complete Python program that inserts ``[99999,'Value','Value']`` into
space ``examples`` via the high-level Python API.

.. code-block:: python

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
For an example of using Python API with
`queue managers for Tarantool <https://github.com/tarantool/queue>`__, see
`queue-python <https://github.com/tarantool/queue-python>`__ project at GitHub.

Also there are several community-driven Python connectors:

* `asynctnt <https://github.com/igorcoding/asynctnt>`__ with asyncio support
* `aiotarantool <https://github.com/shveenkov/aiotarantool>`__ also with asyncio support
* `gtarantool <https://github.com/shveenkov/gtarantool>`__ with gevent support, **no active maintenance**

The table below contains a feature comparison for asynctnt, gtarantool and
tarantool-python. aiotarantool is absent there because it is quite outdated and
unmaintained.

..  _python-feature-comparison:

Feature comparison
------------------

Last update: July 2022

..  list-table::
    :header-rows: 1
    :stub-columns: 1

    *   -   Parameter
        -   `igorcoding/asynctnt <https://github.com/igorcoding/asynctnt>`__
        -   `shveenkov/gtarantool <https://github.com/shveenkov/gtarantool>`__
        -   `tarantool/tarantool-python <https://github.com/tarantool/tarantool-python>`__

    *   -   License
        -   Apache License 2.0
        -   LGPL
        -   BSD-2

    *   -   Is maintained
        -   Yes
        -   No (last updated in 2016)
        -   Yes

    *   -   Known Issues
        -   None
        -   None
        -   None

    *   -   Documentation
        -   Yes (`github.io <https://igorcoding.github.io/asynctnt/>`__)
        -   No
        -   Yes (`tarantool.io
            <https://www.tarantool.io/en/doc/latest/getting_started/getting_started_python/>`__
            and `readthedocs
            <https://tarantool-python.readthedocs.io/en/latest/quick-start.en.html>`__
            (`obsolete
            <https://github.com/tarantool/tarantool-python/issues/67>`__))

    *   -   Testing / CI / CD
        -   GitHub Actions
        -   No (tests exist)
        -   GitHub Actions

    *   -   GitHub Stars
        -   65
        -   17
        -   84

    *   -   Static Analysis
        -   Yes (Flake8)
        -   No
        -   No

    *   -   Packaging
        -   `pip <https://pypi.org/project/asynctnt/>`__
        -   `pip <https://pypi.org/project/gtarantool/>`__
        -   `deb, rpm, pip <https://github.com/tarantool/tarantool-python#download-and-install>`__

    *   -   Code coverage
        -   Yes
        -   No
        -   Yes

    *   -   Support asynchronous mode
        -   Yes, `asyncio <https://docs.python.org/3/library/asyncio.html>`__
        -   Yes (`gevent
            <https://www.gevent.org/api/gevent.event.html#gevent.event.AsyncResult>`__,
            example: `test_gevent.py
            <https://github.com/shveenkov/gtarantool/blob/master/tests/test_gevent.py>`__)
        -   No

    *   -   Batching support
        -   No
        -   No
        -   No (`issue #55 <https://github.com/tarantool/tarantool-python/issues/55>`__)

    *   -   Schema reload
        -   Yes (automatically, see `auto_refetch_schema <https://igorcoding.github.io/asynctnt/api.html>`__)
        -   Yes (automatically)
        -   Yes (automatically)

    *   -   Space / index names
        -   Yes
        -   Yes
        -   Yes

    *   -   Access tuple fields by names
        -   Yes
        -   No
        -   No

    *   -   `SQL support <https://www.tarantool.io/en/doc/latest/reference/reference_sql/>`__
        -   Yes (tests/test_op_sql.py)
        -   No
        -   Yes (tarantool/connection.py)

    *   -   `Interactive transactions <https://www.tarantool.io/en/doc/latest/book/box/stream/>`__
        -   Yes
        -   No
        -   No (`issue #163 <https://github.com/tarantool/tarantool-python/issues/163>`__)

    *   -   `Varbinary support <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`__
        -   Yes (in ``MP_BIN`` fields)
        -   No
        -   Yes

    *   -   `UUID support <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`__
        -   Yes
        -   No
        -   No

    *   -   `Decimal support <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`__
        -   Yes
        -   No
        -   No

    *   -   `EXT_ERROR support <https://www.tarantool.io/ru/doc/latest/dev_guide/internals/msgpack_extensions/#the-error-type>`__
        -   Yes
        -   No
        -   No

    *   -   `Datetime support <https://github.com/tarantool/tarantool/discussions/6244>`__
        -   Yes
        -   No
        -   No

    *   -   `box.session.push() responses <https://www.tarantool.io/ru/doc/latest/reference/reference_lua/box_session/push/>`__
        -   Yes (see push_subscribe option and docs/pushes.rst)
        -   No
        -   No

    *   -   `Session settings <https://www.tarantool.io/en/doc/latest/reference/reference_lua/box_space/_session_settings/>`__
        -   No
        -   No
        -   No

    *   -   `Graceful shutdown <https://github.com/tarantool/tarantool/issues/5924>`__
        -   No
        -   No
        -   No

    *   -   `IPROTO_ID (feature discovering) <https://github.com/tarantool/doc/issues/2419>`__
        -   Yes
        -   No
        -   No

    *   -   Support `CRUD <https://github.com/tarantool/crud>`__
        -   No
        -   No
        -   No

    *   -   Transparent request retrying
        -   No
        -   No
        -   No

    *   -   Transparent reconnecting
        -   Autoreconnect
        -   Yes (reconnect_max_attempts, reconnect_delay)
        -   Yes (reconnect_max_attempts, reconnect_delay), checking of connection liveness

    *   -   Connection pool
        -   No
        -   No
        -   Yes (with master discovery)

    *   -   Support of `PEP 249 -- Python Database API Specification v2.0 <https://www.python.org/dev/peps/pep-0249/>`__
        -   No
        -   No
        -   `Yes <https://github.com/tarantool/tarantool-python/wiki/PEP-249-Database-API>`__

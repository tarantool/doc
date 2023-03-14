.. _index_connector_go:

Go
==

The following connectors are available:

*   Tarantool-supported `go-tarantool <https://github.com/tarantool/go-tarantool>`__

*   Community-supported `viciious/go-tarantool <https://github.com/viciious/go-tarantool>`_

*   Community-supported `FZambia/tarantool <https://github.com/FZambia/tarantool>`_.

..  _go-feature-comparison:

Feature comparison
------------------

Last update: January 2023

..  list-table::
    :header-rows: 1
    :stub-columns: 1

    *   -
        -   `tarantool/go-tarantool <https://github.com/tarantool/go-tarantool>`_
        -   `viciious/go-tarantool <https://github.com/viciious/go-tarantool>`_
        -   `FZambia/tarantool <https://github.com/FZambia/tarantool>`_

    *   -   License
        -   BSD 2-Clause
        -   MIT
        -   BSD 2-Clause

    *   -   Last update
        -   2023
        -   2022
        -   2022

    *   -   Documentation
        -   README with examples and up-to-date GoDoc
        -   README with examples, code comments
        -   README with examples

    *   -   Testing / CI / CD
        -   GitHub Actions
        -   Travis CI
        -   GitHub Actions

    *   -   GitHub Stars
        -   147
        -   45
        -   14

    *   -   Static analysis
        -   golangci-lint, luacheck
        -   golint
        -   golangci-lint

    *   -   Packaging
        -   go get
        -   go get
        -   go get

    *   -   Code coverage
        -   Yes
        -   No
        -   No

    *   -   msgpack driver
        -   `vmihailenco/msgpack/v2 <https://github.com/vmihailenco/msgpack/tree/v2>`_ or `vmihailenco/msgpack/v5 <https://github.com/vmihailenco/msgpack/tree/v5>`_
        -   `tinylib/msgp <https://github.com/tinylib/msgp>`_
        -   `vmihailenco/msgpack/v5 <https://github.com/vmihailenco/msgpack/tree/v5>`_

    *   -   Async work
        -   Yes
        -   Yes
        -   Yes

    *   -   Schema reload
        -   Yes (manual pull)
        -   Yes (manual pull)
        -   Yes (manual pull)

    *   -   Space / index names
        -   Yes
        -   Yes
        -   Yes

    *   -   Tuples as structures
        -   Yes (structure and marshall functions must be predefined in Go code)
        -   No
        -   Yes (structure and marshall functions must be predefined in Go code)

    *   -   Access tuple fields by names
        -   Only if marshalled to structure
        -   No
        -   Only if marshalled to structure

    *   -   `SQL <https://www.tarantool.io/en/doc/latest/reference/reference_sql/>`_ support
        -   Yes
        -   No (`#18 <https://github.com/viciious/go-tarantool/issues/18>`_, closed)
        -   No

    *   -   `Interactive transactions <https://www.tarantool.io/en/doc/latest/book/box/stream/>`_
        -   Yes
        -   No
        -   No

    *   -   `Varbinary <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`_ support
        -   Yes (with in-built language tools)
        -   Yes (with in-built language tools)
        -   Yes (decodes to string by default, see `#6 <https://github.com/FZambia/tarantool/issues/6>`_)

    *   -   `UUID <https://www.tarantool.io/en/doc/latest/book/box/data_model/>`_ support
        -   Yes
        -   No
        -   No

    *   -   Decimal support
        -   Yes
        -   No
        -   No

    *   -   `EXT_ERROR <https://www.tarantool.io/ru/doc/latest/dev_guide/internals/msgpack_extensions/#the-error-type>`_
            support
        -   Yes
        -   No
        -   No

    *   -   `Datetime <https://github.com/tarantool/tarantool/discussions/6244>`_ support
        -   Yes
        -   No
        -   No

    *   -   `box.session.push() responses <https://www.tarantool.io/ru/doc/latest/reference/reference_lua/box_session/push/>`_
        -   Yes
        -   No (`#21 <https://github.com/viciious/go-tarantool/issues/21>`_)
        -   Yes

    *   -   `Session settings <https://www.tarantool.io/en/doc/latest/reference/reference_lua/box_space/_session_settings/>`_
        -   Yes
        -   No
        -   No

    *   -   `Graceful shutdown <https://github.com/tarantool/tarantool/issues/5924>`_
        -   Yes
        -   No
        -   No

    *   -   `IPROTO_ID (feature discovering) <https://github.com/tarantool/tarantool/issues/6253>`_
        -   Yes
        -   No
        -   No

    *   -   `tarantool/crud <https://github.com/tarantool/crud>`_ support
        -   No
        -   No
        -   No

    *   -   Connection pool
        -   Yes (round-robin failover, no balancing)
        -   No
        -   No

    *   -   Transparent reconnecting
        -   Yes (see comments in `#129 <https://github.com/tarantool/go-tarantool/issues/129>`_)
        -   No (handle reconnects explicitly, refer to `#11 <https://github.com/viciious/go-tarantool/issues/11>`_)
        -   Yes (see comments in `#7 <https://github.com/FZambia/tarantool/issues/7>`_)

    *   -   Transparent request retrying
        -   No
        -   No
        -   No

    *   -   `Watchers <https://github.com/tarantool/tarantool/pull/6510>`_
        -   Yes
        -   No
        -   No

    *   -   `Pagination <https://github.com/tarantool/tarantool/issues/7639>`_
        -   Yes
        -   No
        -   No

    *   -   Language features
        -   context
        -   context
        -   context

    *   -   Miscellaneous
        -   Supports `tarantool/queue <https://github.com/tarantool/queue>`_ API
        -   Can mimic a Tarantool instance (also as replica). Provides instrumentation for reading snapshot and xlog files
            via `snapio module <https://github.com/viciious/go-tarantool/tree/master/snapio>`_.
            Implements unpacking of query structs if you want to implement your own iproto proxy
        -   API is experimental and breaking changes may happen

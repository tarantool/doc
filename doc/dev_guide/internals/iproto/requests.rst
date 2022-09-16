..  _internals-requests_responses:

Client requests and responses
=============================

Секцию со всеми возможными пользовательскими запросами с описанием, что делает,
какие аргументы принимает, что возвращает.


..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 17 16 17 50

        *   -   Name
            -   Binary code
            -   Type
            -   Description
        *   -   :ref:`IPROTO_SELECT <box_protocol-select>`
            -   0x01
            -   Map
            -   :ref:`Select <box_space-select>` request
        *   -   :ref:`IPROTO_INSERT <box_protocol-insert>`
            -   0x02
            -   Map
            -   :ref:`Insert <box_space-insert>` request
        *   -   :ref:`IPROTO_REPLACE <box_protocol-replace>`
            -   0x03
            -   Map
            -   :ref:`Replace <box_space-insert>` request
        *   -   :ref:`IPROTO_UPDATE <box_protocol-update>`
            -   0x04
            -   Map
            -   :ref:`Update <box_space-update>` request
        *   -   :ref:`IPROTO_UPSERT <box_protocol-upsert>`
            -   0x09
            -   Map
            -   :ref:`Upsert <box_space-upsert>` request
        *   -   :ref:`IPROTO_DELETE <box_protocol-delete>`
            -   0x05
            -   Map
            -   :ref:`Delete <box_space-delete>` request
    
    Function remote call (conn:call())
    IPROTO_CALL=0x0a
    IPROTO_CALL_16=0x06

    Authentification
    IPROTO_AUTH=0x07

    Evaluates a Lua expresstion (conn:eval())
    IPROTO_EVAL=0x08
    
    Execute an SQL statement (box.execute())
    IPROTO_EXECUTE=0x0b
    Prepare an SQL statement (box.prepare())
    IPROTO_PREPARE=0x0d

    Increment the LSN and do nothing else
    IPROTO_NOP=0x0c

    Transactions over streams
    IPROTO_BEGIN=0x0e
    IPROTO_COMMIT=0x0f
    IPROTO_ROLLBACK=0x10

    Replication
    IPROTO_JOIN=0x41    
    IPROTO_RAFT=0x1e
    box.ctl.promote()
    IPROTO_RAFT_PROMOTE=0x1f
    box.ctl.demote()
    IPROTO_RAFT_DEMOTE=0x20
    IPROTO_RAFT_CONFIRM=0x28
    IPROTO_RAFT_ROLLBACK=0x29
    IPROTO_SUBSCRIBE=0x42
    IPROTO_VOTE_DEPRECATED=0x43
    IPROTO_VOTE=0x44

    Ping (conn:ping())
    IPROTO_PING=0x40

    Fetch snapshot
    IPROTO_FETCH_SNAPSHOT=0x45
    
    Register an anonymous replica so it is not anonymous anymore
    IPROTO_REGISTER=0x46

    Share iproto version and supported features
    IPROTO_ID=0x49

    Event subscription system
    IPROTO_WATCH=0x4a
    IPROTO_UNWATCH=0x4b
    IPROTO_EVENT=0x4c
    
    
Everything OK? -> IPROTO_OK
Out-of-band? -> IPROTO_CHUNK
Error? -> 0x8xxx where xxx is a value from errcode.h

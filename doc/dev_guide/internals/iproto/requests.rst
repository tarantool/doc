..  _internals-requests_responses:

Client-server requests and responses
====================================

This section describes client requests, their arguments, and the values returned by the server.

Some requests are described on separate pages. Those are the requests related to:

*   :ref:`stream transactions <internals-iproto-streams>`
*   :ref:`asynchronous server-client notifications <internals-events>`
*   :ref:`replication <internals-iproto-replication>`
*   :ref:`SQL <internals-iproto-sql>` --
    :ref:`IPROTO_EXECUTE <box_protocol-execute>` and :ref:`IPROTO_PREPARE <box_protocol-prepare>`.

Overview
--------

..  container:: table

    ..  list-table::
        :header-rows: 1
        :widths: 35 20 45

        *   -   Name
            -   Code
            -   Description

        *   -   :ref:`IPROTO_OK <internals-iproto-ok>`
            -   0x00 |br| MP_UINT
            -   Successful response
        
        *   -   :ref:`IPROTO_CHUNK <internals-iproto-chunk>`
            -   0x80 |br| MP_UINT
            -   Out-of-band response
        
        *   -   :ref:`IPROTO_TYPE_ERROR <internals-iproto-type_error>`
            -   0x8XXX |br| MP_INT
            -   Error response

        *   -   :ref:`IPROTO_SELECT <box_protocol-select>`
            -   0x01
            -   :ref:`Select <box_space-select>` request

        *   -   :ref:`IPROTO_INSERT <box_protocol-insert>`
            -   0x02
            -   :ref:`Insert <box_space-insert>` request

        *   -   :ref:`IPROTO_REPLACE <box_protocol-replace>`
            -   0x03
            -   :ref:`Replace <box_space-insert>` request

        *   -   :ref:`IPROTO_UPDATE <box_protocol-update>`
            -   0x04
            -   :ref:`Update <box_space-update>` request

        *   -   :ref:`IPROTO_UPSERT <box_protocol-upsert>`
            -   0x09
            -   :ref:`Upsert <box_space-upsert>` request

        *   -   :ref:`IPROTO_DELETE <box_protocol-delete>`
            -   0x05
            -   :ref:`Delete <box_space-delete>` request

        *   -   :ref:`IPROTO_CALL <box_protocol-call>`
            -   0x0a 
            -   Function remote call (:ref:`conn:call() <net_box-call>`)
        
        *   -   :ref:`IPROTO_AUTH <box_protocol-auth>`
            -   0x07
            -   Authentication request

        *   -   :ref:`IPROTO_EVAL <box_protocol-eval>`
            -   0x08
            -   Evaluate a Lua expression (:ref:`conn:eval() <net_box-eval>`)

        *   -   :ref:`IPROTO_NOP <box_protocol-nop>`
            -   0x0c
            -   Increment the LSN and do nothing else

        *   -   :ref:`IPROTO_PING <box_protocol-ping>`
            -   0x40
            -   Ping (:ref:`conn:ping() <conn-ping>`)

        *   -   :ref:`IPROTO_ID <box_protocol-id>`
            -   0x49
            -   Share iproto version and supported features



..  _internals-iproto-ok:

IPROTO_OK
---------

Code: 0x00.

This request/response type is contained in the header and signifies success. Here is an example:

..  raw:: html
    :file: images/ok_example.svg

..  _internals-iproto-chunk:

IPROTO_CHUNK
------------

Code: 0x80.

If the response is out-of-band, due to use of :ref:`box.session.push() <box_session-push>`,
then IPROTO_REQUEST_TYPE is IPROTO_CHUNK instead of IPROTO_OK.

..  _internals-iproto-type_error:

IPROTO_TYPE_ERROR
-----------------

Code: 0x8XXX (see below).

Instead of :ref:`IPROTO_OK <internals-iproto-keys-ok>`, an error response header
has ``0x8XXX`` for IPROTO_REQUEST_TYPE. ``XXX`` is the error code -- a value in
`src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`_.
``src/box/errcode.h`` also has some convenience macros which define hexadecimal
constants for return codes.

To learn more about error responses,
check the section :ref:`Request and response format <box_protocol-responses_error>`.

..  _box_protocol-select:

IPROTO_SELECT
-------------

Code: 0x01.

See :ref:`space_object:select() <box_space-select>`.
The body is a 6-item map.

..  raw:: html
    :file: images/select.svg

Example
~~~~~~~

If the id of 'tspace' is 512 and this is the fifth message, |br|
:samp:`{conn}.`:code:`space.tspace:select({0},{iterator='GT',offset=1,limit=2})` will cause:

..  raw:: html
    :file: images/select_example.svg

In the :ref:`examples <box_protocol-illustration>`,
you can find actual byte codes of an IPROTO_SELECT message.

..  _box_protocol-insert:

IPROTO_INSERT
-------------

Code: 0x02.

See :ref:`space_object:insert()  <box_space-insert>`.
The body is a 2-item map:

..  raw:: html
    :file: images/insert.svg

For example, if the request is
:samp:`INSERT INTO {table-name} VALUES (1), (2), (3)`, then the response body
contains an :samp:`IPROTO_SQL_INFO` map with :samp:`SQL_INFO_ROW_COUNT = 3`.
:samp:`SQL_INFO_ROW_COUNT` can be 0 for statements that do not change rows,
but can be 1 for statements that create new objects.

Example
~~~~~~~

If the id of 'tspace' is 512 and this is the fifth message, |br|
:samp:`{conn}.`:code:`space.tspace:insert{1, 'AAA'}` will produce the following request and response packets:

..  raw:: html
    :file: images/insert_example.svg

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows actual byte codes of the response to the IPROTO_INSERT message.

..  _box_protocol-replace:

IPROTO_REPLACE
--------------

Code: 0x03.

See :ref:`space_object:replace()  <box_space-replace>`.
The body is a 2-item map, the same as for IPROTO_INSERT:

..  raw:: html
    :file: images/replace.svg

..  _box_protocol-update:

IPROTO_UPDATE
-------------

Code: 0x04.

See :ref:`space_object:update()  <box_space-update>`.

The body is usually a 4-item map:

..  raw:: html
    :file: images/update.svg

Examples
~~~~~~~~

If the operation specifies no values, then IPROTO_TUPLE is a 2-item array: 

..  raw:: html
    :file: images/update_example_0.svg

Normally field numbers start with 1.

If the operation specifies one value, then IPROTO_TUPLE is a 3-item array:

..  raw:: html
    :file: images/update_example_1.svg

Otherwise IPROTO_TUPLE is a 5-item array:

..  raw:: html
    :file: images/update_example_regular.svg

If the id of 'tspace' is 512 and this is the fifth message, |br|
:samp:`{conn}.`:code:`space.tspace:update(999, {{'=', 2, 'B'}})` will cause:

..  raw:: html
    :file: images/update_example.svg

The map item IPROTO_INDEX_BASE is optional.

The tutorial :ref:`Understanding the binary protocol <box_protocol-illustration>`
shows the actual byte codes of an IPROTO_UPDATE message.


..  _box_protocol-upsert:

IPROTO_UPSERT
-------------

Code: 0x09.

See :ref:`space_object:upsert()  <box_space-upsert>`.

The body is usually a 4-item map:

..  raw:: html
    :file: images/upsert.svg

IPROTO_OPS is the array of operations. It is the same as the IPROTO_TUPLE of :ref:`IPROTO_UPDATE <box_protocol-update>`.

IPROTO_TUPLE is an array of primary-key field values.

..  _box_protocol-delete:

IPROTO_DELETE
-------------

Code: 0x05.

See :ref:`space_object:delete()  <box_space-delete>`.
The body is a 3-item map:

..  raw:: html
    :file: images/delete.svg

..  _box_protocol-eval:

IPROTO_EVAL
-----------

Code: 0x08.

See :ref:`conn:eval() <net_box-eval>`.
Since the argument is a Lua expression, this is
Tarantool's way to handle non-binary with the
binary protocol. Any request that does not have
its own code, for example :samp:`box.space.{space-name}:drop()`,
will be handled either with :ref:`IPROTO_CALL <box_protocol-call>`
or IPROTO_EVAL.

The :ref:`tarantoolctl <tarantoolctl>` administrative utility
makes extensive use of ``eval``.

The body is a 2-item map:

..  raw:: html
    :file: images/eval.svg

*   For :ref:`IPROTO_EVAL <box_protocol-eval>` and :ref:`IPROTO_CALL <box_protocol-call>`
    the response body will usually be an array but, since Lua requests can result in a wide variety
    of structures, bodies can have a wide variety of structures.

..  note::

    For SQL-specific responses, the body is a bit different.
    :ref:`Learn more <internals-iproto-sql>` about this type of packets.

Example
~~~~~~~

If this is the fifth message, :samp:`conn:eval('return 5;')` will cause:

..  raw:: html
    :file: images/eval_example.svg

..  _box_protocol-call:

IPROTO_CALL
-----------

Code: 0x0a.

See :ref:`conn:call() <net_box-call>`.
This is a remote stored-procedure call.
:doc:`/release/1.6` and earlier made use of the IPROTO_CALL_16 request (code: 0x06). It is now deprecated
and superseded by IPROTO_CALL.

The body is a 2-item map. The response will be a list of values, similar to the
:ref:`IPROTO_EVAL <box_protocol-eval>` response. The return from conn:call is whatever the function returns.

..  raw:: html
    :file: images/call.svg

..  note::

    For SQL-specific responses, the body is a bit different.
    :ref:`Learn more <internals-iproto-sql>` about this type of packets.

..  _box_protocol-auth:

IPROTO_AUTH
-----------

Code: 0x07.

For general information, see the :ref:`Access control <authentication-users>` section in the administrator's guide.

For more on how authentication is handled in the binary protocol,
see the :ref:`Authentication <box_protocol-authentication>` section of this document.

The client sends an authentication packet as an IPROTO_AUTH message:

..  raw:: html
    :file: images/auth.svg

IPROTO_USERNAME holds the user name. IPROTO_TUPLE must be an array of 2 fields:
authentication mechanism ("chap-sha1" is the only supported mechanism right now)
and scramble, encrypted according to the specified mechanism.

The server instance responds to an authentication packet with a standard response with 0 tuples.

To see how Tarantool handles this, look at
`net_box.c <https://github.com/tarantool/tarantool/blob/master/src/box/lua/net_box.c>`_
function ``netbox_encode_auth``.

..  _box_protocol-nop:

IPROTO_NOP
----------

Code: 0x0c.

There is no Lua request exactly equivalent to IPROTO_NOP.
It causes the LSN to be incremented.
It could be sometimes used for updates where the old and new values
are the same, but the LSN must be increased because a data-change
must be recorded.
The body is: nothing.


..  _box_protocol-ping:

IPROTO_PING
-----------

Code: 0x40.

See :ref:`conn:ping() <conn-ping>`. The body will be an empty map because IPROTO_PING
in the header contains all the information that the server instance needs.

..  raw:: html
    :file: images/ping.svg

..  _box_protocol-id:

IPROTO_ID
---------

Code: 0x49.

Clients send this message to inform the server about the protocol version and
features they support. Based on this information, the server can enable or
disable certain features in interacting with these clients.

The body is a 2-item map:

..  raw:: html
    :file: images/id.svg

The response body has the same structure as
the request body. It informs the client about the protocol version and features
that the server supports.

IPROTO_ID requests can be processed without authentication.
